// Test: LC_CaseAppointmentButtonsTest
public class LC_CaseAppointmentButtons implements ILCController {

    public class LC_CaseAppointmentButtonsException extends Exception {}

    private static final List<String> OPPT_SKIP_STATUSES = new List<String>{'Closed Lost','Closed Won'};
    private static final List<String> CASE_SKIP_STATUSES = new List<String>{'Closed','Caneclled','סגירת אירוע אוטומטית'};
    private static final List<String> MACABI_PF_CODES = new List<String>{'3','43','44','89','35','31'};

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'checkObject' {
                return this.checkObject((String) params.get('recordId'));
            }
            when else {
                throw new LC_CaseAppointmentButtonsException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    public class ButtonsVisibility {
        @AuraEnabled
        public Map<String, Boolean> additionalButtons {get;set;}
        @AuraEnabled
        public String sobjectType {get;set;}
        @AuraEnabled
        public String recordType {get;set;}
        @AuraEnabled
        public String screenMode {get;set;}
        @AuraEnabled
        public Boolean isCreate {get;set;}
        @AuraEnabled
        public Boolean isUpdate {get;set;}
        @AuraEnabled
        public Boolean isCancel {get;set;}

        public ButtonsVisibility(String sobjectType) {
            this.additionalButtons = new Map<String, Boolean>();
            this.sobjectType = sobjectType;
            this.screenMode = 'full';
            this.isCreate = false;
            this.isUpdate = false;
            this.isCancel = false;
        }
    }

    public Response checkObject(String recordId) {
        System.debug('LC_CaseAppointmentButtons.checkObject...');
        String sobjectName = String.valueOf(Id.valueOf(recordId).getSobjectType());
        SObject record = this.obtainRecord(recordId, sobjectName);
        ButtonsVisibility wrapper = new ButtonsVisibility(sobjectName.substringBefore('__'));

        switch on wrapper.sobjectType {
            when 'Account' {
                Account acct = (Account) record;
                wrapper.recordType = acct.RecordType.DeveloperName;

                switch on wrapper.recordType {
                    when 'PersonAccount' {
                        wrapper.isCreate = true;
                        if (Label.Portal_Maccabi_Btn_Available_ProfileId.contains(UserInfo.getProfileId()) && acct.Insurer_factor__c == '2' && acct.ID_Number__c != null) {
                            wrapper.additionalButtons.put('portalMaccabi', true);
                        }
                    }
                }
            }
            when 'Appointment' {
                Appointment__c appt = (Appointment__c) record;
                wrapper.recordType = appt.RecordType.DeveloperName;

                switch on wrapper.recordType {
                    when 'Institutes' {
                        if (appt.Accession_Number__c != null && appt.after_appointment__c == null && appt.Appointment_Date_Time__c > System.now() && (appt.Appointment_Status__c == 'WaitingForAppointment' || appt.Appointment_Status__c == 'וידוא הגעה לפגישה')) {
                            if ((appt.Medical_procedure__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Profile_upd_cncl__c.contains(UserInfo.getProfileId())) &&
                                    (appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c.contains(UserInfo.getProfileId()))) {
                                if (!appt.Patient_Account__r.Not_active__c) {
                                    wrapper.isUpdate = true;
                                }
                                wrapper.isCancel = true;
                            }
                            if (appt.IsUrgent__c && this.isUrgentCalMedp(appt) &&
                                    (Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(UserInfo.getUserId()) ||
                                    Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(UserInfo.getProfileId()) ||
                                    (UserInfo.getUserRoleId() != null && Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(UserInfo.getUserRoleId())))) {
                                System.debug('UpdateUrgentApp is true');
                                wrapper.additionalButtons.put('UpdateUrgentApp', true);
                            }
                        }
                        if (this.isValidForPayment(appt)) {
                            wrapper.additionalButtons.put('Payment', true);
                        }
                        if (appt.Site__r.Site_Code__c == '48') {
                            wrapper.additionalButtons.put('SendQuestionnaireLink', true);
                        }
                    }
                    when 'Experts' {
                        if (appt.Appointment_Date_Time__c > System.now() &&
                                (appt.Appointment_Status__c == 'WaitingForAppointment' || appt.Appointment_Status__c == 'וידוא הגעה לפגישה') &&
                                (appt.Medical_procedure__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Profile_upd_cncl__c.contains(UserInfo.getProfileId())) &&
                                (appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c.contains(UserInfo.getProfileId()))) {
                            if (!appt.Patient_Account__r.Not_active__c) {
                                wrapper.isUpdate = true;
                            }
                            wrapper.isCancel = true;
                        }

                        if (this.isValidForPayment(appt)) {
                            wrapper.additionalButtons.put('Payment', true);
                        }
                    }
                    when 'Surgeries' {
                        wrapper.screenMode = 'limitedProcedures';
                        if (appt.Presurgery_needed1__c && !appt.Patient_Account__r.Not_active__c) {
                            wrapper.isCreate = true;
                        }
                        if (appt.Case__r.Case_subject__c == 'טיפול אדמיניסטרטיבי טרום הניתוח' && appt.Case__r.sub_case_subject__c == 'ביטול ניתוח' && appt.Appointment_Status__c != 'Canceled' && appt.Accession_Number__c != null) {
                            wrapper.isCancel = true;
                        }

                        if (MACABI_PF_CODES.contains(appt.PayerFactor__r.InsuranceCode__c)) {
                            wrapper.additionalButtons.put('MacabiNeeded', true);
                        }
                    }
                }
            }
            when 'Case' {
                Case cas = (Case) record;
                wrapper.recordType = cas.RecordType.DeveloperName;

                if (CASE_SKIP_STATUSES.contains(cas.Status)) {
                    return new Response(wrapper);
                }

                switch on wrapper.recordType {
                    when 'General_Info' {
                        if (cas.ParentId == null && cas.Case_subject__c == 'מועמד ל-360') {
                            wrapper.additionalButtons.put('Convert', true);
                        }
                    }
                    when 'Assuta_360' {
                        if (this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        }
                        if (this.isAppointmentsExist(cas)) {
                            if (this.isAccountActive(cas)) {
                                wrapper.isUpdate = true;
                            }
                            wrapper.isCancel = true;
                        }

                        if (cas.Case_subject__c == 'עדכון תור קיים' || cas.Case_subject__c == 'עדכון תור לרופא') {
                            wrapper.additionalButtons.put('UpdateMedicalAids', true);
                        }
                        if (!cas.send_OTP__c) {
                            wrapper.additionalButtons.put('SendOTP', true);
                        }
                        wrapper.additionalButtons.put('TransferToManager', true);
                        wrapper.additionalButtons.put('ContactDoctor', false);
                    }
                    when 'DOC_expert' {
                        if (cas.Case_subject__c == 'זימון רופא מומחה' && (cas.sub_case_subject__c == 'המלצה על רופא מומחה' || cas.sub_case_subject__c == 'זימון תור לאחר המלצה' || (cas.sub_case_subject__c == 'זימון תור לרופא מומחה' && cas.Recommended_doc__c != null)) && this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        } else if (cas.Case_subject__c == 'עדכון תור לרופא' && cas.sub_case_subject__c == 'שינוי מועד התור' && this.isAppointmentsExist(cas) && this.isAccountActive(cas)) {
                            wrapper.isUpdate = true;
                        } else if (cas.Case_subject__c == 'עדכון תור לרופא' && cas.sub_case_subject__c == 'ביטול תור קיים' && this.isAppointmentsExist(cas)) {
                            wrapper.isCancel = true;
                        }

                        if (cas.Clinic_Email__c != null && cas.Recommended_doc__c != null && cas.Recommended_doc__r.Experts_center__c) {
                            wrapper.additionalButtons.put('UploadFilesToClinic', true);
                        }
                        if (cas.Case_subject__c == 'עדכון תור קיים' || cas.Case_subject__c == 'עדכון תור לרופא') {
                            wrapper.additionalButtons.put('UpdateMedicalAids', true);
                        }
                        if (!cas.send_OTP__c) {
                            wrapper.additionalButtons.put('SendOTP', true);
                        }
                        wrapper.additionalButtons.put('TransferToManager', true);
                    }
                    when 'Appointments' {
                        if (cas.Case_subject__c !=null && (cas.Case_subject__c == 'זימון תור חדש' || cas.Case_subject__c == 'זימון תור חדש - קורונה' || cas.Case_subject__c.contains('קמפיין')) && cas.sub_case_subject__c == 'זימון תור חדש' && this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        } else if (cas.Case_subject__c == 'עדכון תור קיים' && cas.sub_case_subject__c == 'שינוי תור קיים' && this.isAppointmentsExist(cas) && this.isAccountActive(cas)) {
                            wrapper.isUpdate = true;
                        } else if (cas.Case_subject__c == 'עדכון תור קיים' && cas.sub_case_subject__c == 'ביטול תור קיים' && this.isAppointmentsExist(cas)) {
                            wrapper.isCancel = true;
                        }

                        if (cas.Case_subject__c == 'עדכון תור קיים' || cas.Case_subject__c == 'עדכון תור לרופא') {
                            wrapper.additionalButtons.put('UpdateMedicalAids', true);
                        }
                        if (!cas.send_OTP__c) {
                            wrapper.additionalButtons.put('SendOTP', true);
                        }
                        wrapper.additionalButtons.put('TransferToManager', true);
                    }
                    when 'Surgery' {
                        if (this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        }
                        if (cas.Case_subject__c == 'טיפול אדמיניסטרטיבי טרום הניתוח' && cas.sub_case_subject__c == 'ביטול ניתוח' && this.isAppointmentsExist(cas)) {
                            wrapper.isCancel = true;
                        }

                        if (cas.Case_subject__c == 'עדכון תור קיים' || cas.Case_subject__c == 'עדכון תור לרופא') {
                            wrapper.additionalButtons.put('UpdateMedicalAids', true);
                        }
                        if (!cas.send_OTP__c) {
                            wrapper.additionalButtons.put('SendOTP', true);
                        }
                        wrapper.additionalButtons.put('TransferToManager', true);
                    }
                    when 'transfer_to_secretaries' {
                        if ((cas.Status == 'In_Progress' || cas.Status == 'New') && this.isAccountActive(cas) && this.isAshdodEmployee()) {
                            wrapper.isCreate = true;
                        }
                    }
                    when 'CaseAfterSale' {
                        if (this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        }
                        if (this.isAppointmentsExist(cas)) {
                            if (this.isAccountActive(cas)) {
                                wrapper.isUpdate = true;
                            }
                            wrapper.isCancel = true;
                        }
                    }
                    when 'Home_Hospitalization' {
                        wrapper.isCreate = true;
                    }
                    when 'Home_diagnosis' {
                        if (this.isAccountActive(cas)) {
                            wrapper.isCreate = true;
                        }
                    }
                    when 'PublicInquiries' {
                        if (!cas.send_OTP__c) {
                            wrapper.additionalButtons.put('SendOTP', true);
                        }
                        wrapper.additionalButtons.put('LinkToCase', true);
                    }
                    when 'Shikum_Bait' {
                        wrapper.isCreate = true;
                    }
                }
            }
            when 'Opportunity' {
                Opportunity oppt = (Opportunity) record;

                if (!OPPT_SKIP_STATUSES.contains(oppt.StageName) && !oppt.Medical_Tourism__c) {
                    wrapper.isCreate = true;
                }

                if (!oppt.SendOTP__c) {
                    wrapper.additionalButtons.put('SendOTP', true);
                }
            }
            when 'Recommendations_after_exam' {
                Recommendations_after_exam__c recs = (Recommendations_after_exam__c) record;
                wrapper.recordType = recs.RecordType.DeveloperName;

                switch on wrapper.recordType {
                    when 'Memo' {
                        if (recs.Status_recommendation__c == null || recs.Status_recommendation__c == 'חדש') {
                            wrapper.additionalButtons.putAll(new Map<String, Boolean>{'Convert' => true, 'Link' => false, 'Close' => false});
                        }
                    }
                    when 'Shikum_Bait'{
                        wrapper.isCreate = true;
                    }
                }
            }
        }

        System.debug('success\nwrapper: ' + JSON.serialize(wrapper));
        return new Response(wrapper);
    }

    private SObject obtainRecord(String recordId, String sobjectName) {
        Set<String> fields = new Set<String>{'Id'};

        switch on sobjectName {
            when 'Account' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'ID_Type__c',
                    'ID_Number__c',
                    'Insurer_factor__c'});
            }
            when 'Appointment__c' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'IsUrgent__c',
                    'Calendar__c',
                    'BIRAD_apt__c',
                    'Accession_Number__c',
                    'after_appointment__c',
                    'Presurgery_needed1__c',
                    'Appointment_Status__c',
                    'Appointment_Date_Time__c',
                    'Is_Hidden_Appointment__c',
                    'Site__r.Site_Code__c',
                    'Case__r.Case_subject__c',
                    'Case__r.sub_case_subject__c',
                    'PayerFactor__r.InsuranceCode__c',
                    'Patient_Account__r.Not_active__c',
                    'Patient_Account__r.PersonBirthdate',
                    'Medical_Procedure__r.Profile_upd_cncl__c',
                    'Medical_Procedure__r.Domain__r.Profile_upd_cncl__c'});
            }
            when 'Case' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'Status',
                    'ParentId',
                    'send_OTP__c',
                    'Clinic_Email__c',
                    'Case_subject__c',
                    'sub_case_subject__c',
                    'Account.Not_active__c',
                    'Recommended_doc__r.Experts_center__c'});
            }
            when 'Opportunity' {
                fields.addAll(new Set<String>{
                    'StageName',
                    'SendOTP__c',
                    'Medical_Tourism__c'});
            }
            when 'Recommendations_after_exam__c' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'Status_recommendation__c'});
            }
        }

        SObject record = Database.query(
            'SELECT ' + String.join(new List<String>(fields), ',')
           + ' FROM ' + sobjectName
          + ' WHERE Id = :recordId');
        System.debug('record: ' + record);

        return record;
    }

    private Boolean isAppointmentsExist(Case cas) {
        return !LC_SearchUtils.getConnectedAppointmentsToCase(cas, '', true, true).isEmpty();
    }

    private Boolean isAshdodEmployee() {
        return [SELECT Ashdod_employee__c FROM User WHERE Id = :UserInfo.getUserId()].Ashdod_employee__c;
    }

    private Boolean isAccountActive(Case cas) {
        return cas.AccountId != null && !cas.Account.Not_active__c;
    }

    private boolean isValidForPayment(Appointment__c appt) {
        return appt.Appointment_Date_Time__c == null || (Math.abs(Date.valueOf(appt.Appointment_Date_Time__c).daysBetween(appt.Patient_Account__r.PersonBirthdate)) >= 5 && appt.Appointment_Date_Time__c >= System.now());
    }

    private Boolean isUrgentCalMedp(Appointment__c app) {
        System.debug('LC_CaseAppointmentButtons.isUrgentCalMedp...');
        List<calendar_medp__c> calendarProcedure = [SELECT Medical_Procedure__c, Calendar__c, save_slot__c
                                                    FROM calendar_medp__c
                                                    WHERE Calendar__c =: app.Calendar__c 
                                                    AND Medical_Procedure__c = :app.Medical_Procedure__c];
        System.debug('isUrgentCalMedp value...' + (!calendarProcedure.isEmpty() && calendarProcedure.get(0).save_slot__c));
        if (!calendarProcedure.isEmpty() && calendarProcedure.get(0).save_slot__c) {
            return true;
        }
        return false;
    }

    /** IVF LINK */
    @AuraEnabled
    public static void sendIVFLink(String recipient,String caseId,String sendOption){
        System.debug('LC_CaseAppointmentButtons.sendIVFLink...');
        try {
             Case currCase = [SELECT Id,
                                AccountId,
                                ivf_upload_files_sent__c,
                                ParentId,
                                Partner_Name__c,
                                Case_site__c,
                                formtitan_ivf_upload_files_female__c,
                                formtitan_ivf_upload_files_male__c,
                                email_from_patient__c,
                                Partner_Email__c,
                                Partner_Name__r.PersonEmail,
                                SMS_Phone_Number__c,
                                Phone__c,
                                Primary_Phone_Partner__c,
                                Fax_Number_IVF__c,
                                Site_Email__c FROM Case WHERE Id =:caseId LIMIT 1];
        switch on sendOption {
            when 'both' {
                System.debug('option both');
                sendIVFLinkbySMS(recipient,currCase);
                sendIVFLinkByEmail(recipient, currCase);
            }
            when 'sms' {
                System.debug('option sms');
                sendIVFLinkbySMS(recipient,currCase);
            }
            when 'email'{
                System.debug('email');
                sendIVFLinkByEmail(recipient, currCase);
            }
        }
        updateIVFsendStatus(recipient, currCase, sendOption);
        } catch (Exception e) {
            System.debug(e);
        }
    }

    private static void sendIVFLinkbySMS(String recipient,Case caseObj){
        String phoneNum = caseObj.SMS_Phone_Number__c != null ? caseObj.SMS_Phone_Number__c : caseObj.Phone__c; 
        try {
            insert new SMS__c(
                status__c = '1',
                Type__c = 'Outgoing',
                Template_Text__c = getTemplate(caseObj,'IVF_Upload_Link',recipient),
                Phone_Number__c = recipient=='female' ? phoneNum:caseObj.Primary_Phone_Partner__c,
                Account__c = recipient=='female'? caseObj.AccountId : caseObj.Partner_Name__c,
                Case__c = caseObj.Id
        );
            
        } catch (Exception e) {
            System.debug(e);
        }     
    }

    private static void sendIVFLinkByEmail(String recipient,Case caseObj){
        System.debug('LC_CaseAppointmentButtons.sendIVFLinkByEmail...');
        try {
            insert new EmailMessage(
                AccountId__c= recipient == 'female' ? caseObj.AccountId : caseObj.Partner_Name__c,
                ParentId=caseObj.Id,
                ToAddress=recipient == 'female' ? caseObj.email_from_patient__c : caseObj.Partner_Email__c,
                FromAddress = caseObj.Case_site__c == 'Rishon_Letzion' ? 'rishon.info@assuta.co.il' : 'ramat.info@assuta.co.il', // will be changed to dynamic in the future
                FromName= caseObj.Case_Site__c == 'Rishon_Letzion' ? 'אסותא ראשון לציון' : 'אסותא רמת החייל',
                ExpectedSendingDateTime__c = Datetime.now(),
                TemplateMergeField__c = caseObj.ParentId,
                EmailTemplateDeveloperName__c = recipient == 'female' 
                    ? 'Uploading_Documents_Female'
                    : 'Uploading_Documents_Partner'
            );
            
        } catch (Exception e) {
            System.debug(e);
        }

    }

    private static String getTemplate(Case caseObj,String smsName,String recipient){
        String link = recipient=='female'? caseObj.formtitan_ivf_upload_files_female__c:caseObj.formtitan_ivf_upload_files_male__c;
        String template = smsName + ',' + link+ ',' + caseObj.Fax_Number_IVF__c+ ',' + caseObj.Site_Email__c ;
        System.debug('getTemplate: '+template);
        return template;
    }

    private static void updateIVFsendStatus(String recipient,Case currCase,String sendOption){
        try {
            currCase.ivf_upload_files_sent__c =currCase.ivf_upload_files_sent__c!= null ? +currCase.ivf_upload_files_sent__c+';'+recipient+';'+sendOption :recipient+';'+sendOption;
            update currCase;
        } catch (Exception e) {
            System.debug(e.getMessage());
        } 
    }
}