// Test: LC_Case360ControllerTest
public class LC_Case360Controller implements ILCController {

    public static Map<String, Schema.RecordTypeInfo> caseRTMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    public class LC_Case360ControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            // CONVERT
            when 'convert' {
                return this.convert((String) params.get('recordId'));
            }
            // LINK
            when 'getCases' {
                return this.getCases((String) params.get('recordId'));
            }
            when 'linkRecommendation' {
                return this.linkRecommendation((String) params.get('recordId'),
                                               (String) params.get('caseId'));
            }
            // CLOSE
            when 'getCloseData' {
                return this.getCloseData();
            }
            when 'closeRecommendation' {
                return this.closeRecommendation((String) params.get('recordId'),
                                                (String) params.get('closeReason'));
            }
            // CALL SMS EMAIL
            when 'getContactDoctorData' {
                return this.getContactDoctorData((String) params.get('recordId'));
            }
            when 'doctorSearch' {
                return LC_SearchUtils.doctorSearch((String) params.get('keyWord'));
            }
            when 'getDoctorInfo' {
                return this.getDoctorInfo((String) params.get('doctorId'));
            }
            when 'contactDoctor' {
                return this.contactDoctor((String) params.get('recordId'),
                                          (String) params.get('doctorId'),
                                          (String) params.get('text'),
                                          (String) params.get('phone'),
                                          (String) params.get('email'),
                                          Boolean.valueOf(params.get('saveInfo')));
            }
            // ELSE
            when else {
                throw new LC_Case360ControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    // CONVERT
    private Response convert(String recordId) {
        System.debug('LC_Case360Controller.convert...\nrecordId: ' + recordId);
        if (Id.valueOf(recordId).getSobjectType() == Recommendations_after_exam__c.getSobjectType()) {
            return this.convertRecommendation(recordId);
        } else if (Id.valueOf(recordId).getSobjectType() == Case.getSobjectType()) {
            return this.convertCase(recordId);
        } else {
            return new Response('Something went wrong. Please, check button condition.');
        }
    }

    private Response convertCase(String recordId) {
        System.debug('LC_Case360Controller.convertCase...\nrecordId: ' + recordId);
        Case currentCase = [SELECT Id, OwnerId, ParentId, AccountId FROM Case WHERE Id =: recordId];

        Case cloneCase = new Case(
            AccountId = currentCase.AccountId,
            OwnerId = currentCase.OwnerId,
            RecordTypeId = caseRTMap.get('Assuta_360').getRecordTypeId()
        );
        insert cloneCase;

        currentCase.ParentId = cloneCase.Id;
        update currentCase;

        System.debug('Case converted: ' + cloneCase.Id);
        return new Response('Case converted');
    }

    private Response convertRecommendation(String recordId) {
        System.debug('LC_Case360Controller.convertRecommendation...\nrecordId: ' + recordId);
        this.convertRecommendation([SELECT Id,
                                           Status_recommendation__c,
                                           Case360__c,
                                           Patient__c,
                                           Site_Appointment__c,
                                           Type_of_recommendation__c,
                                           Related_Appointment__c,
                                           Related_Appointment__r.Patient_Account__c,
                                           Related_Appointment__r.after_appointment__c,
                                           Related_Appointment__r.Medical_Procedure__r.Procedure_Code__c,
                                           Referral_Doctor__c,
                                           Referral_Doctor__r.Expertise_1__c,
                                           Referral_Doctor__r.Expertise_2__c,
                                           Referral_Doctor__r.Expertise_1__r.Expertise_Code__c,
                                           Referral_Doctor__r.Expertise_2__r.Expertise_Code__c,
                                           RecordType.Name,
                                           Agamon_Record__c
                                    FROM Recommendations_after_exam__c
                                    WHERE Id =: recordId],
                                    false);

        System.debug('Recommendation converted');
        return new Response('Recommendation converted');
    }

    public void convertRecommendation(List<Recommendations_after_exam__c> convertedRecommendations, Boolean isTrigger) {
        System.debug('LC_Case360Controller.convertRecommendation...\nconvertedRecommendations: ' + convertedRecommendations);
        Id queueId = isTrigger ? [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Assuta_360'].Id : null;
        List<String> expertiseCodes = Label.Convert_Expertise_Ids.split(',');
        System.debug('expertiseCodes: size: ' + expertiseCodes.size() + ' values: ' + expertiseCodes);
        Map<Id, Case> recommendToCase = new Map<Id, Case>();
        Map<Id, Case> appToCase = new Map<Id, Case>();
        Set<String> mProcedureCodes = new Set<String>();
        List<String> recommendRelatedApp = new List<String>();

        for (Medical_Procedure_Plan__mdt procedure_i : [SELECT MedicalProcedureCode1__c FROM Medical_Procedure_Plan__mdt]) {
            mProcedureCodes.add(procedure_i.MedicalProcedureCode1__c);
        }

        for (Recommendations_after_exam__c recommendation_i : convertedRecommendations) {
            if(recommendation_i.Related_Appointment__c != null && recommendation_i.Related_Appointment__r.after_appointment__c == null){
                Case case_i = new Case(
                    RecordTypeId = caseRTMap.get('Assuta_360').getRecordTypeId(),
                    Memo_refferal_doctor__c = recommendation_i.Referral_Doctor__c,
                    Case_subject__c = recommendation_i.Agamon_Record__c ? 'אגמון דימות' : recommendation_i.RecordType.Name,
                    sub_case_subject__c = recommendation_i.Agamon_Record__c ? 'חדש': recommendation_i.RecordType.Name,
                    Apex_Assigned__c = true
                );
                if (recommendation_i.Related_Appointment__c != null && recommendation_i.Related_Appointment__r.Patient_Account__c != null) {
                    case_i.AccountId = recommendation_i.Related_Appointment__r.Patient_Account__c;
                }
                if (recommendation_i.Referral_Doctor__c != null && (
                (recommendation_i.Referral_Doctor__r.Expertise_1__c != null && expertiseCodes.contains(recommendation_i.Referral_Doctor__r.Expertise_1__r.Expertise_Code__c)) ||
                (recommendation_i.Referral_Doctor__r.Expertise_2__c != null && expertiseCodes.contains(recommendation_i.Referral_Doctor__r.Expertise_2__r.Expertise_Code__c)))) {
                        case_i.surgeon_doctor__c = recommendation_i.Referral_Doctor__c;
                }
                if (isTrigger) {
                    case_i.OwnerId = queueId;
                    case_i.Status = 'Third Party';
                }
                if(recommendation_i.Related_Appointment__r.Medical_Procedure__c != null
                && recommendation_i.Related_Appointment__r.Medical_Procedure__r.Procedure_Code__c != null
                && mProcedureCodes.contains(recommendation_i.Related_Appointment__r.Medical_Procedure__r.Procedure_Code__c)){
                    appToCase.put(recommendation_i.Related_Appointment__c, case_i);
                }
                if(recommendation_i.Type_of_recommendation__c != null){
                    if(recommendation_i.Site_Appointment__c != null){
                        case_i.RecommendationSite360__c = recommendation_i.Site_Appointment__c;
                    }
                    switch on recommendation_i.Type_of_recommendation__c{
                        when 'Breast'{
                            case_i.Case_subject__c = 'ממוגרפיה'; 
                            case_i.sub_case_subject__c = 'ממוגרפיה';
                            case_i.Status = 'נדרשת המלצה/קביעת תור לכירורג שד';
                        }
                        when 'Consultations'{
                            case_i.Case_subject__c = 'אגמון דימות'; 
                            case_i.sub_case_subject__c = 'חדש';
                            case_i.Status = 'המלצה למומחה';
                        }
                        when 'Gastro'{
                            case_i.Case_subject__c = 'Gastro'; 
                            case_i.sub_case_subject__c = 'חדש';
                            case_i.Status = 'המלצה למומחה';
                        }
                        when 'Cardiology'{
                            case_i.Case_subject__c = 'Cardiology'; 
                            case_i.sub_case_subject__c = 'Recommendation_to_cardiologist';
                            case_i.Status = 'recomendation for expert check or catherization';
                        }
                        when 'Cardiac_ct'{
                            case_i.Case_subject__c = 'Cardiology'; 
                            case_i.sub_case_subject__c = 'Recommendation_to_cardiologist';
                            case_i.Status = 'recomendation for expert check or catherization';
                        }
                        when 'Lungs'{
                            case_i.Case_subject__c = 'Lungs'; 
                            case_i.sub_case_subject__c = 'חדש';
                            case_i.Status = 'המלצה למומחה';
                        }
                        when 'prostate'{
                            case_i.Case_subject__c = 'prostate'; 
                            case_i.sub_case_subject__c = 'חדש';
                            case_i.Status = 'המלצה למומחה';
                        }
                    }
                }
                recommendToCase.put(recommendation_i.Id, case_i);
            }else{
                System.debug('else:  ' + recommendation_i.Related_Appointment__r.after_appointment__c);
                recommendRelatedApp.add(recommendation_i.Related_Appointment__r.after_appointment__c);
            }
        }

        System.debug('recommendToCase: size: ' + recommendToCase.size() + ' value: ' + recommendToCase);
        System.debug('appToCase: size: ' + appToCase.size() + ' value: ' + appToCase);
        System.debug('recommendRelatedApp: size: ' + recommendRelatedApp.size() + ' value: ' + recommendRelatedApp);

        if(!recommendRelatedApp.isEmpty()){
            Map<Id, Id> case360toRecommend = new Map<Id, Id>();
            for(Recommendations_after_exam__c recommendRelApp_i:[SELECT Id, Related_Appointment__c, Related_Appointment__r.after_appointment__c, Case360__c FROM Recommendations_after_exam__c WHERE Related_Appointment__c IN :recommendRelatedApp]){
                case360toRecommend.put(recommendRelApp_i.Related_Appointment__c, recommendRelApp_i.Case360__c);
            }
            System.debug('case360toRecommend: size: ' + case360toRecommend.size() + ' value: ' + case360toRecommend);
            if(!case360toRecommend.isEmpty()){
                System.debug('convertedRecommendations: ' + convertedRecommendations);
                for (Recommendations_after_exam__c recommendation_i : convertedRecommendations) {
                    recommendation_i.Status_recommendation__c = 'הומר לאירוע קיים';
                    recommendation_i.Case360__c = case360toRecommend.get(recommendation_i.Related_Appointment__r.after_appointment__c);   
                }
                System.debug('case360toRecommend: size: ' + case360toRecommend.size() + ' value: ' + case360toRecommend);
                update convertedRecommendations;
            }
        }
        
        if (!recommendToCase.isEmpty()) {
            insert recommendToCase.values();

            for (Recommendations_after_exam__c recommendation_i : convertedRecommendations) {
                recommendation_i.Status_recommendation__c = 'הומר לאירוע חדש';
                recommendation_i.Case360__c = recommendToCase.get(recommendation_i.Id).Id;
            }

            if(!appToCase.isEmpty()){
                for(Recommendations_after_exam__c recommendApp_i:[SELECT Id, Related_Appointment__r.after_appointment__c FROM Recommendations_after_exam__c WHERE Related_Appointment__r.after_appointment__c IN :appToCase.keySet()]){
                    recommendApp_i.Status_recommendation__c = 'הומר לאירוע קיים';
                    recommendApp_i.Case360__c = appToCase.get(recommendApp_i.Related_Appointment__r.after_appointment__c).Id;
                    convertedRecommendations.add(recommendApp_i);
                }
            }

            System.debug('convertedRecommendations: size: ' + convertedRecommendations.size() + ' value: ' + convertedRecommendations);
            if (!convertedRecommendations.isEmpty()) {
                update convertedRecommendations;
            }
        }
    }

    // LINK
    private Response getCases(String recordId) {
        System.debug('LC_Case360Controller.getCases...\nrecordId: ' + recordId);

        Recommendations_after_exam__c recommendation = [SELECT Id, Patient__c FROM Recommendations_after_exam__c WHERE Id =: recordId];
        List<Case> cases = [SELECT Id, CaseNumber, Account.Name, Owner.Name, memograph_exam__r.Name FROM Case WHERE RecordType.DeveloperName = 'Assuta_360' AND AccountId =: recommendation.Patient__c ORDER BY CreatedDate DESC];
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        return new Response(cases);
    }

    private Response linkRecommendation(String recordId, String caseId) {
        System.debug('LC_Case360Controller.linkRecommendation...\nrecordId: ' + recordId + '\ncaseId: ' + caseId);

        Recommendations_after_exam__c recommendation = [SELECT Id, Status_recommendation__c, Case360__c, Related_Appointment__c FROM Recommendations_after_exam__c WHERE Id =: recordId];
        recommendation.Status_recommendation__c = 'הומר לאירוע קיים';
        recommendation.Case360__c = caseId;
        update recommendation;

        return new Response('Recommendation linked');
    }

    // CLOSE
    private Response getCloseData() {
        System.debug('LC_Case360Controller.getCloseData...');

        CloseDataWrapper wrapper = new CloseDataWrapper();
        wrapper.closeReasons = new List<PicklistUtil.PicklistValue>();
        for (PicklistUtil.PicklistValue value_i : PicklistUtil.buildPickListOptionsBySchema('Recommendations_after_exam__c', 'Close_Reason_Memo__c', false)) {
            if (value_i.value != 'הושלם') {
                wrapper.closeReasons.add(value_i);
            }
        }
        System.debug('closeReasons: size: ' + wrapper.closeReasons.size() + ' value: ' + wrapper.closeReasons);

        return new Response(wrapper);
    }

    private Response closeRecommendation(String recordId, String closeReason) {
        System.debug('LC_Case360Controller.closeRecommendation...\nrecordId: ' + recordId + '\ncloseReason: ' + closeReason);

        Recommendations_after_exam__c recommendation = [SELECT Id, Status_recommendation__c, Close_Reason_Memo__c FROM Recommendations_after_exam__c WHERE Id =: recordId];
        recommendation.Status_recommendation__c = 'נסגר ללא טיפול המשך';
        recommendation.Close_Reason_Memo__c = closeReason;
        update recommendation;

        return new Response('Recommendation closed');
    }

    // CALL SMS EMAIL
    private Response getContactDoctorData(String recordId) {
        System.debug('LC_Case360Controller.chooseDoctor...\nrecordId: ' + recordId);

        ContactDoctorWrapper wrapper = new ContactDoctorWrapper();
        Map<String, String> placeholderToValue = new Map<string, String>();
        wrapper.quickTexts = [SELECT Id, Name, Message FROM QuickText];
        String queryStr = 'SELECT Id, Contact_doctor__c, Contact_doctor__r.Name, Contact_doctor__r.Doctor_personal_phone__c, Contact_doctor__r.Email__c';
        for (QuickText quickTest_i : wrapper.quickTexts) {
            List<Integer> placeholderChars = new List<Integer>();
            Boolean isPlaceholder = false;
            for (Integer character_i : quickTest_i.Message.getChars()) {
                if (character_i == 123) {
                    isPlaceholder = true;
                }
                if (isPlaceholder) {
                    placeholderChars.add(character_i);
                }
                if (character_i == 125) {
                    isPlaceholder = false;
                    String singlePlaceholder = String.fromCharArray(placeholderChars);
                    placeholderChars.clear();
                    if (singlePlaceholder.contains('Case') && !queryStr.contains(singlePlaceholder.substringBetween('{!Case.', '}'))) {
                        queryStr += ', ' + singlePlaceholder.substringBetween('{!Case.', '}');
                    } else if (!singlePlaceholder.contains('Case') && !queryStr.contains(singlePlaceholder.substringBetween('{!', '}'))) {
                        queryStr += ', ' + singlePlaceholder.substringBetween('{!', '}');
                    }
                    placeholderToValue.put(singlePlaceholder, '');
                }
            }
        }
        queryStr += ' FROM Case WHERE Id =: recordId';
        System.debug('queryStr: ' + queryStr);
        Case cas = Database.query(queryStr);

        for (String key_i : placeholderToValue.keySet()) {
            if (key_i.contains('Case') && cas.get(key_i.substringBetween('{!Case.', '}')) != null) {
                placeholderToValue.put(key_i, String.valueOf(cas.get(key_i.substringBetween('{!Case.', '}'))));
            } else if (!key_i.contains('Case') && cas.getSObject(key_i.substringBetween('{!', '.')) != null && cas.getSObject(key_i.substringBetween('{!', '.')).get(key_i.substringBetween('.', '}')) != null) {
                placeholderToValue.put(key_i, String.valueOf(cas.getSObject(key_i.substringBetween('{!', '.')).get(key_i.substringBetween('.', '}'))));
            }
        }

        for (QuickText quickTest_i : wrapper.quickTexts) {
            for (String key_i : placeholderToValue.keySet()) {
                if (quickTest_i.Message.contains(key_i) && placeholderToValue.containsKey(key_i)) {
                    quickTest_i.Message = quickTest_i.Message.replace(key_i, placeholderToValue.get(key_i));
                }
            }
        }
        wrapper.defaultDoctor = new Account(Id = cas.Contact_doctor__c,
                                            Name = cas.Contact_doctor__r.Name,
                                            Doctor_personal_phone__c = cas.Contact_doctor__r.Doctor_personal_phone__c,
                                            Email__c = cas.Contact_doctor__r.Email__c);
        System.debug('defaultDoctor: ' + wrapper.defaultDoctor);
        System.debug('quickTexts: size: ' + wrapper.quickTexts.size() + ' value: ' + wrapper.quickTexts);

        return new Response(wrapper);
    }

    private Response getDoctorInfo(String doctorId) {
        System.debug('LC_Case360Controller.getDoctorInfo...\ndoctorId: ' + doctorId);

        List<Doctor_in_Clinic__c> clinics = [SELECT Doctors__c, Clinic__c, Clinic__r.Name, Clinic__r.Area__c, Clinic__r.street_address__c, Clinic__r.Address__c
                                             FROM Doctor_in_Clinic__c WHERE Doctors__c =: doctorId AND Clinic__r.Site__c != null AND Clinic__r.Site__r.US_Calendar__c != null];
        List<Contact> contacts = [SELECT Id, Name, Email, HomePhone, MobilePhone FROM Contact WHERE AccountId =: doctorId];
        Account doctor = [SELECT Id, Name, Doctor_personal_phone__c, Email__c, Doctors_Phones_Hidden__c, Doctors_Emails_Hidden__c FROM Account WHERE Id =: doctorId];
        DoctorInfoWrapper wrapper = new DoctorInfoWrapper(doctor, clinics, contacts);
        System.debug('clinics: size: ' + clinics.size() + ' value: ' + clinics);
        System.debug('contacts: size: ' + contacts.size() + ' value: ' + contacts);
        System.debug('doctor: ' + doctor);

        return new Response(wrapper);
    }

    private Response contactDoctor(String recordId, String doctorId, String text, String phone, String email, Boolean saveInfo) {
        System.debug('LC_Case360Controller.contactDoctor...\nrecordId: ' + recordId + '\ndoctorId: ' + doctorId + '\ntext: ' + text + '\nphone: ' + phone + '\nemail: ' + email);

        Account doctor = [SELECT Id, Doctor_personal_phone__c, Email__c, Doctors_Phones_Hidden__c, Doctors_Emails_Hidden__c FROM Account WHERE Id =: doctorId];
        if (String.isNotBlank(phone) && saveInfo) {
            if (String.isNotBlank(doctor.Doctors_Phones_Hidden__c) && !doctor.Doctors_Phones_Hidden__c.contains(phone) && doctor.Doctor_personal_phone__c != phone) {
                doctor.Doctors_Phones_Hidden__c += ',' + phone;
            } else if (String.isBlank(doctor.Doctors_Phones_Hidden__c)) {
                doctor.Doctors_Phones_Hidden__c = phone;
            }
        }
        if (String.isNotBlank(email) && saveInfo) {
            if (String.isNotBlank(doctor.Doctors_Emails_Hidden__c) && !doctor.Doctors_Emails_Hidden__c.contains(email) && doctor.Email__c != email) {
                doctor.Doctors_Emails_Hidden__c += ',' + email;
            } else if (String.isBlank(doctor.Doctors_Emails_Hidden__c)) {
                doctor.Doctors_Emails_Hidden__c = email;
            }
        }
        update doctor;

        if (String.isNotBlank(phone)/* && !Test.isRunningTest()*/) {
            SMS__c smsMessage = new SMS__c(Content__c = text, Type__c = 'Outgoing', Phone_Number__c = phone, status__c = '1', Case__c = recordId);
            insert smsMessage;
        }

        if (String.isNotBlank(email)) {
            Email__c emailMessage = new Email__c(Content__c = text, Email__c = email, Case__c = recordId);
            insert emailMessage;
        }

        return new Response('success');
    }

    // WRAPPER
    public class CloseDataWrapper {
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> closeReasons {get;set;}
    }

    public class ContactDoctorWrapper {
        @AuraEnabled
        public Account defaultDoctor {get;set;}
        @AuraEnabled
        public List<QuickText> quickTexts {get;set;}
    }

    public class DoctorInfoWrapper {
        @AuraEnabled
        public List<Doctor_in_Clinic__c> clinics {get;set;}
        @AuraEnabled
        public List<Contact> contacts {get;set;}
        @AuraEnabled
        public List<String> phoneNumbers {get;set;}
        @AuraEnabled
        public List<String> emails {get;set;}
        @AuraEnabled
        public String defaultPhoneNumber {get;set;}
        @AuraEnabled
        public String defaultEmail {get;set;}
        @AuraEnabled
        public Account doctor {get;set;}

        public DoctorInfoWrapper(Account doctor, List<Doctor_in_Clinic__c> clinics, List<Contact> contacts) {
            this.doctor = doctor;
            this.clinics = clinics;
            this.contacts = contacts;
            this.defaultPhoneNumber = String.isNotBlank(doctor.Doctor_personal_phone__c) ? doctor.Doctor_personal_phone__c : '';
            this.defaultEmail = String.isNotBlank(doctor.Email__c) ? doctor.Email__c : '';

            this.phoneNumbers = new List<String>();
            this.emails = new List<String>();
            if (String.isNotBlank(doctor.Doctor_personal_phone__c)) {
                this.phoneNumbers.add(doctor.Doctor_personal_phone__c);
            }
            if (String.isNotBlank(doctor.Doctors_Phones_Hidden__c)) {
                this.phoneNumbers.addAll(doctor.Doctors_Phones_Hidden__c.split(','));
            }
            if (String.isNotBlank(doctor.Email__c)) {
                this.emails.add(doctor.Email__c);
            }
            if (String.isNotBlank(doctor.Doctors_Emails_Hidden__c)) {
                this.emails.addAll(doctor.Doctors_Emails_Hidden__c.split(','));
            }
        }
    }
}