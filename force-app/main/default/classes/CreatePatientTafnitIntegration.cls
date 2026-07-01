// Test: DisabilityServicesTest, AccountContactRelationTest, AccountServicesTest, CreatePatientMock

public  class CreatePatientTafnitIntegration {

    public CreatePatientTafnitIntegration() {}
    
    private static String formatDate(Date d) {
        if (d!= null) {return  d.day() + '/' + d.month() + '/' + d.year();}
        return null;
    }

    private static Map<Id, ws_CreatePatient.Connections> selectContact(Set<Id> recordIds) {
        System.debug('CreatePatientTafnitIntegration.selectContact...'); 
        Map<Id, ws_CreatePatient.Connections> recordIdToConnectionssMap = new Map<Id, ws_CreatePatient.Connections>();
        Map<Id,List<AccountContactRelation>> recordIdToConSFMap = new Map<Id,List<AccountContactRelation>>();
        Set<Id> contactIds = new Set<Id>(); 

        ws_CreatePatient.Connections Connections = new ws_CreatePatient.Connections();
        Connections.IsContactExists = 'FALSE'; 
        try {
            List<AccountContactRelation> ConRelationList = [SELECT Id, AccountId, ContactId, Roles, Contact_Not_Active__c FROM AccountContactRelation 
                                                            WHERE AccountId IN :recordIds AND Contact_Not_Active__c = False] ;
            if (ConRelationList.size() > 0) {
                for (AccountContactRelation acc_i : ConRelationList) {
                    contactIds.add(acc_i.ContactId);

                    if (!recordIdToConSFMap.containsKey(acc_i.AccountId)) {
                        recordIdToConSFMap.put(acc_i.AccountId, new List<AccountContactRelation>());
                    }
                recordIdToConSFMap.get(acc_i.AccountId).add(acc_i);
                }
            }
            Id escortRecordId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Escort' AND SobjectType = 'Contact' LIMIT 1].Id;
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, LastName, FirstName, Phone, Main_Escort__c, Relationship__c, RecordTypeId FROM Contact WHERE Id IN :contactIds
                                                                AND RecordTypeId = :escortRecordId AND Status__c != '1']);
            
            System.debug('Connections.IsContactExists' + Connections.IsContactExists);    

            for (Id recordId_i : recordIds) {
                if (recordIdToConSFMap.containsKey(recordId_i)) {
                    ws_CreatePatient.ArrayOfPatientConnectPatientConnect ArrayOfPatientConnect = new ws_CreatePatient.ArrayOfPatientConnectPatientConnect();
                    ws_CreatePatient.PatientConnect[] PatientConnect = new ws_CreatePatient.PatientConnect[]{};
                    for (AccountContactRelation AccCon_i :recordIdToConSFMap.get(recordId_i)){
                        if(contactMap != null && !contactMap.isEmpty() && contactMap.containsKey(AccCon_i.ContactId)){
                            ws_CreatePatient.PatientConnect con = new ws_CreatePatient.PatientConnect();
                            con.ConnMainFlag = contactMap.get(AccCon_i.ContactId).Main_Escort__c ? 'Y': 'N';
                            con.ConnFirstName = contactMap.get(AccCon_i.ContactId).FirstName;
                            con.ConnLastName = contactMap.get(AccCon_i.ContactId).LastName;
                            con.ConnPhone = contactMap.get(AccCon_i.ContactId).Phone;
                            con.ConnRelation = contactMap.get(AccCon_i.ContactId).Relationship__c;
                            PatientConnect.add(con);
                        }
                    }
                    System.debug('PatientConnect' + PatientConnect);
                    if(PatientConnect!= null){
                        Connections.IsContactExists = 'TRUE';
                        System.debug('Connections.IsContactExists' + Connections.IsContactExists);
                        ArrayOfPatientConnect.PatientConnect = PatientConnect;
                        Connections.PatientConnect = ArrayOfPatientConnect;
                    }
                }
                recordIdToConnectionssMap.put(recordId_i, Connections);
            } 
        } catch (Exception ex) {
            System.debug('Create Patient In Tafnit fail in selectContact func: '+ ex);   
        }
        return recordIdToConnectionssMap;
    }
                 
     private static Map<Id, ws_CreatePatient.Disabilities> selectDisability(Set<Id> recordIds) {
        System.debug('CreatePatientTafnitIntegration.selectDisability...'); 
        Map<Id, List<Disabilities__c>> recordIdToDisSFMap = new Map<Id, List<Disabilities__c>>();
        Map<Id, ws_CreatePatient.Disabilities> recordIdToDisabilitiesMap = new Map<Id, ws_CreatePatient.Disabilities>();
        try {
            List<Disabilities__c> disAssList = [SELECT Id, Type_of_disability__c, Type_of_Assist__c, Side__c, Permanency__c, Notes__c,
                                                Date_of_request__c, Assistance_notes__c, Assistance_des__c, Patient_Account__c, Date_of_start__c, Patient_Account__r.Id
                                                FROM Disabilities__c WHERE Patient_Account__c IN :recordIds];

            if (disAssList.size() > 0) {
                for (Disabilities__c dis_i : disAssList) {
                    if (!recordIdToDisSFMap.containsKey(dis_i.Patient_Account__r.Id)) {
                        recordIdToDisSFMap.put(dis_i.Patient_Account__r.Id, new List<Disabilities__c>());
                    }
                    recordIdToDisSFMap.get(dis_i.Patient_Account__r.Id).add(dis_i);
                }
            }
            
            System.debug('recordIdToDisSFMap   ' + recordIdToDisSFMap); 
            for (Id recordId_i : recordIds) {
                ws_CreatePatient.Disabilities Disabilities = new ws_CreatePatient.Disabilities();
                if (recordIdToDisSFMap.containsKey(recordId_i)) {
                    ws_CreatePatient.PatientDisabilities PatientDisabilities = new ws_CreatePatient.PatientDisabilities ();
                    ws_CreatePatient.ArrayOfPatientDisabilityPatientDisability ArrayOfPatientDisability = new  ws_CreatePatient.ArrayOfPatientDisabilityPatientDisability();
                    ws_CreatePatient.PatientDisability[] PatientDisability = new ws_CreatePatient.PatientDisability[]{};
                    
                    ws_CreatePatient.PatientAssistance PatientAssistance = new ws_CreatePatient.PatientAssistance();
                    ws_CreatePatient.ArrayOfPatientAssistPatientAssist ArrayOfPatientAssistPatientAssist = new ws_CreatePatient.ArrayOfPatientAssistPatientAssist();
                    ws_CreatePatient.PatientAssist[] PatientAssist = new ws_CreatePatient.PatientAssist[]{};
                    
                    Disabilities.PatientApprove = true;
                    for (Disabilities__c dis_i : recordIdToDisSFMap.get(recordId_i)) {
                        if(dis_i.Type_of_disability__c != null){
                            ws_CreatePatient.PatientDisability dis = new ws_CreatePatient.PatientDisability();
                            dis.DisCode = dis_i.Type_of_disability__c;
                            dis.SideCode = dis_i.Side__c;
                            dis.Permanence = dis_i.Permanency__c;
                            dis.DisabilityRemark = dis_i.Notes__c;
                            dis.DateOfDisability = formatDate(dis_i.Date_of_start__c);
                            PatientDisability.add(dis);
                        }
                        if(dis_i.Type_of_Assist__c != null){
                            if(dis_i.Type_of_Assist__c.contains(';')){// אם קימיים כמה עזרים 
                                List<String> typeOfAssistSet = dis_i.Type_of_Assist__c.split(';'); 
                                for (String assist :typeOfAssistSet){
                                    ws_CreatePatient.PatientAssist ass = new ws_CreatePatient.PatientAssist();
                                    ass.AssistCode = assist;
                                    ass.DateOfAssist = formatDate(dis_i.Date_of_request__c);
                                    ass.AssistRemark = dis_i.Assistance_notes__c;
                                    PatientAssist.add(ass);
                                }
                            }
                            else{//אם קיים עזר בודד
                                ws_CreatePatient.PatientAssist ass = new ws_CreatePatient.PatientAssist();
                                ass.AssistCode = dis_i.Type_of_Assist__c;
                                ass.DateOfAssist = formatDate(dis_i.Date_of_request__c);
                                ass.AssistRemark = dis_i.Assistance_notes__c;
                                PatientAssist.add(ass);
                            }
                        }
                    }
                    ArrayOfPatientDisability.PatientDisability = PatientDisability;
                    PatientDisabilities.PatientDisability = ArrayOfPatientDisability;

                    ArrayOfPatientAssistPatientAssist.PatientAssist = PatientAssist;
                    PatientAssistance.PatientAssist = ArrayOfPatientAssistPatientAssist;  

                    Disabilities.PatientDisabilities = PatientDisabilities;
                    Disabilities.PatientAssistance = PatientAssistance;
                }
                else{
                    Disabilities.PatientApprove = false; 
                }
                recordIdToDisabilitiesMap.put(recordId_i, Disabilities);   
            }
        } catch (Exception ex) {
            System.debug('Create Patient In Tafnit fail in selectDisability func: '+ ex);   
        }
        return recordIdToDisabilitiesMap;
    }

    private static Map<Id, ws_CreatePatient.Patient> selectPatient(Set<Id> recordIds, String recordType) {
        System.debug('CreatePatientTafnitIntegration.selectPatient...');
        Map<Id, Account> recordIdToAccountSFMap = new Map<Id, Account>();
        Map<Id, ws_CreatePatient.Patient> recordIdToPatientMap = new Map<Id, ws_CreatePatient.Patient>();
        Set<String> cityName = new Set<String>();
        Map<String, String> cityCodes = new Map<String, String>();
        try {
            List<Account> accList = [SELECT Id, LastName, FirstName, Gender__c, ID_Type__c, ID_Number__c, PersonBirthdate,Status__c, PersonMailingCity, PersonMailingCountry, PersonMailingStreet,
                                            PersonMailingPostalCode, PersonOtherPhone, Phone, Fax, PersonEmail, Insurer_factor__c, Preferred_Language_Service__c, Other_Health_Services__c
                                    FROM Account WHERE Id IN :recordIds];
            if (!accList.isEmpty()) {
                for (Account acc_i : accList) {
                    if (!recordIdToAccountSFMap.containsKey(acc_i.Id)) {
                        recordIdToAccountSFMap.put(acc_i.Id, acc_i);
                    }
                    if(String.isNotBlank(acc_i.PersonMailingCity) && !cityName.contains(acc_i.PersonMailingCity)){
                        cityName.add(acc_i.PersonMailingCity);
                    }
                }

                for(City__c city_i :[SELECT Name, City_Code__c FROM City__c WHERE Name IN :cityName]){
                    cityCodes.put(city_i.Name, String.valueOf(city_i.City_Code__c));
                }
                
                for (Id recordId_i : recordIds) {
                    if (recordIdToAccountSFMap.containsKey(recordId_i)) {
                        ws_CreatePatient.Patient patient = new ws_CreatePatient.Patient();
                        Account acc_i = recordIdToAccountSFMap.get(recordId_i);
                        patient.DemographicDataSource = '1';
                        patient.System_x = '16';
                        if (String.isNotBlank(recordType)) {patient.RecordType = recordType;}
                        if (String.isNotBlank(acc_i.ID_Type__c)) {patient.IdType = acc_i.ID_Type__c;}
                        if (String.isNotBlank(acc_i.ID_Number__c)) {patient.Id = acc_i.ID_Number__c;}
                        if (String.isNotBlank(acc_i.FirstName)) {
                            Integer maxSize = 20;
                            patient.FirstName = acc_i.FirstName.length() > maxSize ? acc_i.FirstName.substring(0, maxSize) : acc_i.FirstName;
                        }  
                        if (String.isNotBlank(acc_i.LastName)) {
                            Integer maxSize = 30;
                            patient.LastName = acc_i.LastName.length() > maxSize ? acc_i.LastName.substring(0, maxSize) : acc_i.LastName;
                        }
                        if (acc_i.PersonBirthdate != null) {patient.BirthDate = formatDate(acc_i.PersonBirthdate);}
                        if (String.isNotBlank(acc_i.Gender__c)) {patient.Gender = acc_i.Gender__c;}
                        if (String.isNotBlank(acc_i.Status__c)) {patient.Status = acc_i.Status__c;}
                        if (String.isNotBlank(acc_i.PersonMailingCountry ) && acc_i.PersonMailingCountry.contains('ישראל')){patient.State = '01';} else{patient.State = '9999';}
                        if (String.isNotBlank(cityCodes.get(acc_i.PersonMailingCity))) {
                            patient.CityCode = cityCodes.get(acc_i.PersonMailingCity);
                            patient.State = '01';
                        }else{
                            patient.CityCode = '9999';
                        }
                        if (String.isNotBlank(acc_i.PersonMailingCity)) {patient.CityDesc = acc_i.PersonMailingCity;}
                        if (String.isNotBlank(acc_i.PersonMailingStreet)) {
                            String street = '';
                            String houseNum1 = '';
                            Integer i = 0;
                            Integer j = 0;
                            List<String> streetlst = acc_i.PersonMailingStreet.split(' ',0);
                            for (string str : streetlst){
                                if(str.isNumeric()){
                                    if(i == 0){
                                        houseNum1 = str; 
                                    }else{
                                        houseNum1 += ' ' + str;
                                    }
                                    i++;
                                }
                                else if(str.isAlpha()){
                                    if(j == 0){
                                        street = str; 
                                    }else{
                                        street += ' ' + str;
                                    }
                                    j++;
                                }
                            }
                            if (houseNum1!= null && String.isNotBlank(houseNum1)) {
                                patient.StreetNo = houseNum1;
                            } 
                            if(street != null) {
                                patient.Street = street;
                            } 
                        }
                        if (String.isNotBlank(acc_i.PersonMailingPostalCode)) {patient.ZipCode = acc_i.PersonMailingPostalCode;}
                        if (String.isNotBlank(acc_i.PersonOtherPhone)) {patient.HomePhone = acc_i.PersonOtherPhone;}
                        if (String.isNotBlank(acc_i.Phone)) {patient.MobilePhone = acc_i.Phone;}
                        if (String.isNotBlank(acc_i.Fax)) {patient.Fax = acc_i.Fax;}
                        if (String.isNotBlank(acc_i.PersonEmail)) {patient.Email = acc_i.PersonEmail;}
                        if (String.isNotBlank(acc_i.Insurer_factor__c)) {patient.SickFundCode = acc_i.Insurer_factor__c;}
                        if (String.isNotBlank(acc_i.Other_Health_Services__c)){
                            if (acc_i.Other_Health_Services__c == 'ללא'){
                                switch on acc_i.Insurer_factor__c {
                                    when '1'{ //Clalit
                                        patient.InsuranceFlagCode = '57';
                                    }
                                    when '2'{ //Maccabi
                                        patient.InsuranceFlagCode = '17';
                                    }
                                    when '3'{ //Meuhedet
                                        patient.InsuranceFlagCode = '27';
                                    }
                                    when '4'{ //Leumit
                                        patient.InsuranceFlagCode = '67';
                                    }
                                }
                            }
                            else{
                                patient.InsuranceFlagCode = acc_i.Other_Health_Services__c;
                            }
                        }
                        if (String.isNotBlank(acc_i.Preferred_Language_Service__c)) {
                            //שפות אלו לא קיימות בתפנית ולכן נשלח קוד שפה עברית 
                            patient.Language = (acc_i.Preferred_Language_Service__c == 'צרפתית' || acc_i.Preferred_Language_Service__c == 'אמהרית') ? '1' : acc_i.Preferred_Language_Service__c; 
                        }
                        /*patient.Userzonetype = 'PUBLIC';
                        patient.ResetPassword = False;
                        patient.SendSMS = False;
                        patient.IsOTP = False;*/
                        recordIdToPatientMap.put(recordId_i, patient);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Create Patient In Tafnit fail in selectPatient func: '+ ex);   
        }
        return recordIdToPatientMap;
    }

    @future(callout=true)
    public static void createPatientInTafnit(Set<Id> recordIds, String recordType, String obj) {
        System.debug('CreatePatientTafnitIntegration.createPatientInTafnit...'); 
        System.debug('recordType...' + recordType); 
        ws_CreatePatient.CreatePatientWSSoap CreatePatientWSSoap = new  ws_CreatePatient.CreatePatientWSSoap();
        ws_CreatePatient.CreatePatientRequest  CreatePatientRequest = new ws_CreatePatient.CreatePatientRequest();
        Map<Id, ws_CreatePatient.CreatePatientResponse> CreatePatientResponseLst = new Map<Id, ws_CreatePatient.CreatePatientResponse>();
        Map<Id, ws_CreatePatient.Patient> patientsMap = selectPatient(recordIds, recordType);
        System.debug('Patient ...' + patientsMap.values());
        if (recordType == 'U') {
            Map<Id, ws_CreatePatient.Disabilities> disabilitiesMap = selectDisability(recordIds);
            System.debug('Disabilities ...' + disabilitiesMap.values());
            for (Id recordId_i : disabilitiesMap.keySet()) {
                if (patientsMap.containsKey(recordId_i)) {
                    patientsMap.get(recordId_i).Disabilities = disabilitiesMap.get(recordId_i);
                }
            }
            
            if(obj == 'Contact'){
                Map<Id, ws_CreatePatient.Connections> contactsMap = selectContact(recordIds);
                System.debug('Contacts ...' + contactsMap.values());
                for (Id recordId_i : contactsMap.keySet()) {
                    if (patientsMap.containsKey(recordId_i)) {
                        patientsMap.get(recordId_i).Connections = contactsMap.get(recordId_i);
                    }
                }
            }  
        }
        try {/*Callout CreatePatient*/
         //if(!Test.isRunningTest()){
            for (Id recordId_i : patientsMap.keySet()) {
                CreatePatientRequest.Patient = patientsMap.get(recordId_i);
                CreatePatientResponseLst.put(recordId_i, CreatePatientWSSoap.CreateAssutaPatient(CreatePatientRequest));
            }
         //}
        } catch (Exception ex) {
           System.debug('Create Patient In Tafnit fail: '+ ex);   
        }
        updateAccount(CreatePatientResponseLst);
    }

    private static void updateAccount(Map<Id, ws_CreatePatient.CreatePatientResponse> recordIdToResultMap) {
        System.debug('CreatePatientTafnitIntegration.UpdateAccount...');
        Set<Id> accountIdsToUpdate = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        try {
            for (Id recordId_i : recordIdToResultMap.keySet()) {
                system.debug('RESPONSE recordId_i ' + recordId_i);
                if (recordIdToResultMap.get(recordId_i) != null) {
                    accountIdsToUpdate.add(recordId_i);
                }
            }
            
            for (Account account_i : [SELECT Id, Create_Tafnit_AC__c, Update_Tafnit_AC__c, DisableValidation__c FROM Account WHERE Id IN :accountIdsToUpdate]) {                 
                String success = ''; 
                String errorMessage = '';     
                
                for(ws_CreatePatient.InfoSorceSystem info_i :recordIdToResultMap.get(account_i.Id).InfoSorceSystems.InfoSorceSystem){
                    success += ';'+ info_i.success;
                    errorMessage += ';'+ info_i.errorMessage;  
                }

                System.debug('success' + success);
                if(Success.contains('true') && account_i.update_Tafnit_AC__c == False){                
                    accountsToUpdate.add(new Account(ID = account_i.ID, Update_Tafnit_AC__c = true, DisableValidation__c = !account_i.DisableValidation__c));                
                }  
            }
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        } catch (Exception ex) {
            System.debug('Create Patient In Tafnit fail in updateAccount func: '+ ex);   
        }
    }
}