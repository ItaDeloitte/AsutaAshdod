// Test: AccountServicesTest
public class AccountServices {

    public static void checkIdNumberUniqueness(Map<String, Account> idNumbersToAccountMap, Set<String> idNumbersSet) {
        System.debug('AccountServices.checkIdNumberUniqueness...');

        List<Account> accounts = [SELECT Id, ID_Number__c, ID_Type__c FROM Account
                                  WHERE ID_Number__c IN :idNumbersSet];

        if (!accounts.isEmpty()) {
            System.debug('accounts ' + accounts);
            for (Account account_i : accounts) {
                if (idNumbersToAccountMap.containsKey(account_i.ID_Number__c + account_i.ID_Type__c)) {
                    idNumbersToAccountMap.get(account_i.ID_Number__c + account_i.ID_Type__c).addError(System.Label.Id_number_should_be_unique);
                }
            }
        }
    }

    public static void validateIdNumber(Map<String, Account> idNumbersToAccountMap) {
        System.debug('AccountServices.validateIdNumber...');

        for (String idNumber_i : idNumbersToAccountMap.keySet()) {
            if (!idNumber_i.isNumeric()){
                idNumbersToAccountMap.get(idNumber_i).addError(System.Label.Person_Id_should_be_Numeric);
            }
            else if (!ValidateUtil.isValidIdNumber(idNumber_i)) {
                idNumbersToAccountMap.get(idNumber_i).addError(System.Label.Person_Id_is_incorrect);
            }
        }
    }

    public static void handleCreatePatient(Set<Id> accountIds, String recordType) {
        System.debug('AccountServices.handleCreatePatient...');
        Set<Id> accountIdsToTafnit = new Set<Id>();

        for (Account account_i : [SELECT ID_Type__c, ID_Number__c, FirstName, LastName, PersonBirthdate, Gender__c, PersonMailingCity, PersonMailingCountry FROM Account WHERE Id IN :accountIds]) {
            if (validateRequiredFields(new List<String>{account_i.ID_Type__c, account_i.ID_Number__c, account_i.FirstName, account_i.LastName, String.valueof(account_i.PersonBirthdate), account_i.Gender__c})) {
                accountIdsToTafnit.add(account_i.Id);
            }
        }

        if (!accountIdsToTafnit.isEmpty()) {
            System.debug('accountIdsToTafnit ' + accountIdsToTafnit);
            CreatePatientTafnitIntegration.createPatientInTafnit(accountIdsToTafnit, recordType, 'Account');
        }
    }

    private static Boolean validateRequiredFields(List<String> requiredFields) {
        System.debug('AccountServices.validateRequiredFields...');

        for (String field_i : requiredFields) {
            if (String.isBlank(field_i)) {
                return false;
            }
        }
        return true;
    }

    public static void CheckDemography(List<Account> AccLst) {
        /*List<Account> acclist = new List<Account>();
        List<Disabilities__c> dislist = new List<Disabilities__c>();
        for(Account account_i :AccLst){
            Account updateAcc = new Account(ID = account_i.ID);
            DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(updateAcc, account_i.ID_Number__c, account_i.ID_Type__c);
            if (accountWithDemography.IsDemographyExist) {
                acclist.add(accountWithDemography.acct);
                for (Disabilities__c disability_i : accountWithDemography.disabilities) {
                    System.debug('Disability '+disability_i);
                    disability_i.Patient_Account__c = accountWithDemography.acct.ID;
                    dislist.add(disability_i);
                }   
            } 
            else{
                updateAcc.Create_Tafnit_AC__c = true;
                updateAcc.DisableValidation__c =!account_i.DisableValidation__c;
                acclist.add(updateAcc);  
            }
        }
        update acclist;
        insert dislist;*/
    }

    public static void updateCasebyAccountFields(Set<Id> accountIdSet, Map<Id, Account> accountOldMap) {
        System.debug('AccountServices.updateCasebyAccountFields...');
        List<Account> accounts = [SELECT Id, Phone, payer_factor_ID__c, Preferred_Channel__c, SMS_Phone_Number__c, PersonEmail FROM Account WHERE Id IN: accountIdSet];
        Map<Id, List<Case>> casesMap = new Map<Id, List<Case>>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case case_i : [SELECT Id, AccountId, PayerFactor__c, phone__c, preferd_chanal_case__c, SMS_Phone_Number__c, email_from_patient__c, Contact.AccountId FROM Case
                            WHERE Status != 'סגירת אירוע אוטומטית' AND Status != 'Closed' AND Status != 'Caneclled' AND Contact.AccountId IN: accountIdSet]) {
            if (!casesMap.containsKey(case_i.Contact.AccountId)) {
                casesMap.put(case_i.Contact.AccountId, new List<Case>());
            }
            casesMap.get(case_i.Contact.AccountId).add(case_i);
        }

        System.debug('casesMap: size: ' + casesMap.size() + ' values: ' + casesMap);

        for (Account account_i : accounts) {
            if (casesMap.containsKey(account_i.Id) && accountOldMap.containsKey(account_i.Id)) {
                for (Case case_i : casesMap.get(account_i.Id)) {
                    Boolean updated = false;
                    if (case_i.phone__c == accountOldMap.get(account_i.Id).Phone 
                        && case_i.phone__c != account_i.Phone) {
                        case_i.phone__c = account_i.Phone;
                        updated = true;
                    }
                    if (case_i.PayerFactor__c == accountOldMap.get(account_i.Id).payer_factor_ID__c 
                        && case_i.PayerFactor__c != account_i.payer_factor_ID__c) {
                        case_i.PayerFactor__c = account_i.payer_factor_ID__c;
                        updated = true;
                    }
                    if (case_i.preferd_chanal_case__c == accountOldMap.get(account_i.Id).Preferred_Channel__c 
                        && case_i.preferd_chanal_case__c != account_i.Preferred_Channel__c) {
                        case_i.preferd_chanal_case__c = account_i.Preferred_Channel__c;
                        updated = true;
                    }
                    if (case_i.SMS_Phone_Number__c == accountOldMap.get(account_i.Id).SMS_Phone_Number__c 
                        && case_i.SMS_Phone_Number__c != account_i.SMS_Phone_Number__c) {
                        case_i.SMS_Phone_Number__c = account_i.SMS_Phone_Number__c;
                        updated = true;
                    }
                    if (case_i.email_from_patient__c == accountOldMap.get(account_i.Id).PersonEmail 
                        && case_i.email_from_patient__c != account_i.PersonEmail) {
                        case_i.email_from_patient__c = account_i.PersonEmail;
                        updated = true;
                    }
                    // add into the update list only if a field was updated
                    System.debug('updated ' + updated);
                    if (updated) {
                        casesToUpdate.add(case_i);
                    }
                }
            }
        }

        // update only if there are changed records
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    public static void checkPromotedDocAdvisorDocAmount(List<Account> accounts) {
        DocAdvisorSetting__c docAdvSetting = DocAdvisorSetting__c.getOrgDefaults(); 
        Integer promotedDoctorsAmount = Integer.valueOf(docAdvSetting.Promoted_Doctors_Amount__c);
        List<Account> accList = [SELECT Id,Promoted_doctor_DA__c FROM Account WHERE RecordType.DeveloperName = 'Doctor_Account' AND Promoted_doctor_DA__c=true LIMIT : promotedDoctorsAmount+1];
        Integer currentPromotedDoctorsAmount = accList.size();
        
        for(Account acc : accounts){
            if(currentPromotedDoctorsAmount < promotedDoctorsAmount){
                acc.Promoted_doctor_DA__c=true;
                currentPromotedDoctorsAmount++;
            }else{
                acc.addError('Reached maximum amount of promoted DocAdvisor Doctors ('+promotedDoctorsAmount+')');
            }
        }
        
    }

    public static void postalCodeFields(List<Account> accounts){
        System.debug('AccountServices.postalCodeFields...');
        for(Account acc : accounts){
            //check postalCode and ShippingPostalCode
            if((acc.PersonMailingPostalCode != null && !acc.PersonMailingPostalCode.isNumeric()) ||
               (acc.ShippingPostalCode != null && !acc.ShippingPostalCode.isNumeric())){
                if(UserInfo.getProfileId() == System.Label.Integration_ProfileId){
                    acc.PersonMailingPostalCode = '';
                }else{
                    acc.addError(System.Label.postal_code_not_numbers);
                }
            }
        }
    }

    public static void fill360Coordinator(Map<Id, Account> caseToAccountMap) {
        for (Case case_i : [SELECT Id, First_user_to_own_the_case__c FROM Case WHERE Id IN :caseToAccountMap.keySet()]) {
            Account acc = caseToAccountMap.get(case_i.Id);

            acc.X360_Coordinator__c = case_i.First_user_to_own_the_case__c;
        }
        System.debug('AccountServices.fill360Coordinator ... logic has been executed');
    }

    public static void handleMailingApproval(Set<String> pCommChannelSet, Map<String, Account> pExactMatchAccountMap, Map<String, Account> pPartialMatchAccountMap) {
        Map<String, List<Account>> commChannelToAccountsMap = new Map<String, List<Account>>();
        Map<String, List<Lead>> commChannelToLeadsMap = new Map<String, List<Lead>>();
        List<SObject> recordToUpdateList = new List<SObject>();

        List<Lead> dbLeadList = [
            SELECT SyncToMC__c
                 , ApprovesMailing__c
                 , Email
                 , Phone
              FROM Lead
             WHERE IsConverted = false
               AND Campaign__r.Status != 'Inactive'
               AND Status NOT IN ('lost', 'false', 'win')
               AND (Email IN :pCommChannelSet OR Phone IN :pCommChannelSet)
          ORDER BY CreatedDate DESC];
        System.debug('TR Account dbLeadList [' + dbLeadList.size() + ']: ' + dbLeadList);

        List<Account> dbAccountList = [
            SELECT SyncToMC__pc
                 , Mailing_approval__c
                 , OTP_EMAIL_HIDDEN__c
                 , SMS_Phone_Number__c
              FROM Account
             WHERE (Status__c = null OR Status__c = 'פ')
               AND RecordType.DeveloperName = 'PersonAccount'
               AND (OTP_EMAIL_HIDDEN__c IN :pCommChannelSet OR SMS_Phone_Number__c IN :pCommChannelSet)
          ORDER BY CreatedDate DESC];
        System.debug('TR Account dbAccountList [' + dbAccountList.size() + ']: ' + dbAccountList);

        for (Account account_i : dbAccountList) {
            Boolean isUpdated_i = false;
            String exactKey_i = account_i.OTP_EMAIL_HIDDEN__c + account_i.SMS_Phone_Number__c;

            if (pExactMatchAccountMap.containsKey(exactKey_i)) {
                if (!commChannelToAccountsMap.containsKey(exactKey_i)) {
                    commChannelToAccountsMap.put(exactKey_i, new List<Account>());
                }

                if (account_i.SyncToMC__pc != commChannelToAccountsMap.get(exactKey_i).isEmpty()) {
                    account_i.SyncToMC__pc = commChannelToAccountsMap.get(exactKey_i).isEmpty();
                    isUpdated_i = true;
                }

                commChannelToAccountsMap.get(exactKey_i).add(account_i);
            }

            if (pPartialMatchAccountMap.containsKey(account_i.OTP_EMAIL_HIDDEN__c) || pPartialMatchAccountMap.containsKey(account_i.SMS_Phone_Number__c)) {
                String partialKey_i = pPartialMatchAccountMap.containsKey(account_i.OTP_EMAIL_HIDDEN__c)
                    ? account_i.OTP_EMAIL_HIDDEN__c
                    : account_i.SMS_Phone_Number__c;

                if (account_i.Mailing_approval__c != pPartialMatchAccountMap.get(partialKey_i).Mailing_approval__c) {
                    account_i.Mailing_approval__c = pPartialMatchAccountMap.get(partialKey_i).Mailing_approval__c;
                    isUpdated_i = true;
                }
            }

            if (isUpdated_i) {
                recordToUpdateList.add(account_i);
            }
        }
        System.debug('TR Account recordToUpdateList [' + recordToUpdateList.size() + ']: ' + recordToUpdateList);

        for (Lead lead_i : dbLeadList) {
            Boolean isUpdated_i = false;
            String exactKey_i = lead_i.Email + lead_i.Phone;

            if (pExactMatchAccountMap.containsKey(exactKey_i)) {
                if (!commChannelToLeadsMap.containsKey(exactKey_i)) {
                    commChannelToLeadsMap.put(exactKey_i, new List<Lead>());
                }

                if (lead_i.SyncToMC__c != commChannelToLeadsMap.get(exactKey_i).isEmpty()) {
                    lead_i.SyncToMC__c = commChannelToLeadsMap.get(exactKey_i).isEmpty();
                    isUpdated_i = true;
                }

                commChannelToLeadsMap.get(exactKey_i).add(lead_i);
            }

            if (pPartialMatchAccountMap.containsKey(lead_i.Email) || pPartialMatchAccountMap.containsKey(lead_i.Phone)) {
                String partialKey_i = pPartialMatchAccountMap.containsKey(lead_i.Email)
                    ? lead_i.Email
                    : lead_i.Phone;

                if (lead_i.ApprovesMailing__c != pPartialMatchAccountMap.get(partialKey_i).Mailing_approval__c) {
                    lead_i.ApprovesMailing__c = pPartialMatchAccountMap.get(partialKey_i).Mailing_approval__c;
                    isUpdated_i = true;
                }
            }

            if (isUpdated_i) {
                recordToUpdateList.add(lead_i);
            }
        }
        System.debug('TR Account recordToUpdateList [' + recordToUpdateList.size() + ']: ' + recordToUpdateList);

        if (!recordToUpdateList.isEmpty()) {
            recordToUpdateList.sort();
            update recordToUpdateList;
            System.debug('TR Account handleMailingApproval ... executed');
        }
    }

    public static void checkEndUser(List<Account> accounts, Map<Id, String> accountMap) {
        System.debug('AccountServices.checkEndUser...');        
        Id channelId = null;        
        Map<Id, String> accIdToPhoneNumber =  new Map<Id, String>();
        Map<String, MessagingEndUser> phoneNumberToEndUser =  new Map<String, MessagingEndUser>();
        List<MessagingEndUser> messEndUserToInsert = new List<MessagingEndUser>();
        List<MessagingEndUser> messEndUserToUpdate = new List<MessagingEndUser>();
        
        List<MessagingChannel> mesChannels = MessagingEndUserUtil.getMessagingChannel();
        if (!mesChannels.isEmpty()) {
            channelId = mesChannels.get(0).Id;
        }
                    
        for (Account account_i : accounts) {
            accIdToPhoneNumber.put(account_i.Id, MessagingEndUserUtil.validPhoneNumber(account_i.SMS_Phone_Number__c));
        }
        System.debug('TR Account accIdToPhoneNumber [' + accIdToPhoneNumber.size() + ']: ' + accIdToPhoneNumber);
                
        for (MessagingEndUser endUser_i : MessagingEndUserUtil.getMessagingEndUser(channelId, accIdToPhoneNumber.values())) {
            phoneNumberToEndUser.put(endUser_i.MessagingPlatformKey , endUser_i);
        }
        System.debug('TR Account phoneNumberToEndUser [' + phoneNumberToEndUser.size() + ']: ' + phoneNumberToEndUser);

        for (Account account_i : accounts) {
            if (!phoneNumberToEndUser.containskey(accIdToPhoneNumber.get(account_i.Id)))  {
                messEndUserToInsert.add(MessagingEndUserUtil.createMessagingEndUser(channelId
                                                                                    , account_i.Id                                                                                     
                                                                                    , accIdToPhoneNumber.get(account_i.Id)                                                                                    
                                                                                   )
                                       );
            } else if (phoneNumberToEndUser.get(accIdToPhoneNumber.get(account_i.Id)).AccountId == null) {
                messEndUserToUpdate.add(new MessagingEndUser (Id = phoneNumberToEndUser.get(accIdToPhoneNumber.get(account_i.Id)).Id
                                                                 , AccountId = account_i.Id
                                                             )
                                       );
            }        
        }        
          
        if (!accountMap.isEmpty()) {
            Map<String, Id> phoneToAccountId = new Map<String, Id>();
            Map<String, String> phoneToValidPhone = new Map<String, String>();
            Map<String, Id> phoneNumberToEndUserId =  new Map<String, Id>();
            
            for (Account account_i : [SELECT Id,
                                            SMS_Phone_Number__c
                                      FROM Account 
                                     WHERE Id NOT IN : accountMap.keySet()
                                     AND SMS_Phone_Number__c IN :accountMap.values()]) {
                phoneToAccountId.put(account_i.SMS_Phone_Number__c, account_i.Id);                    
            }
            System.debug('TR Account phoneToAccountId [' + phoneToAccountId.size() + ']: ' + phoneToAccountId);
            
            for (String phone_i : accountMap.values()) {
                phoneToValidPhone.put(phone_i, MessagingEndUserUtil.validPhoneNumber(phone_i));
            }

            for (MessagingEndUser endUser_i : MessagingEndUserUtil.getMessagingEndUser(channelId, phoneToValidPhone.values())) {
                phoneNumberToEndUserId.put(endUser_i.MessagingPlatformKey , endUser_i.Id);
            }
            System.debug('TR Account phoneNumberToEndUserId [' + phoneNumberToEndUserId.size() + ']: ' + phoneNumberToEndUserId);

            for (String phone_i : accountMap.values()) {
                if (phoneToAccountId.containsKey(phone_i)) {
                    if (phoneNumberToEndUserId.containsKey(phoneToValidPhone.get(phone_i))) {
                        messEndUserToUpdate.add(new MessagingEndUser (Id = phoneNumberToEndUserId.get(phoneToValidPhone.get(phone_i))
                                                                        , AccountId = phoneToAccountId.get(phone_i)));
                    }
                } else if (phoneNumberToEndUserId.containsKey(phoneToValidPhone.get(phone_i))) {
                        messEndUserToUpdate.add(new MessagingEndUser (Id = phoneNumberToEndUserId.get(phoneToValidPhone.get(phone_i))
                                                                        , AccountId = null));
                }                               
            }           
        }
        
        System.debug('TR Account messEndUserToInsert [' + messEndUserToInsert.size() + ']: ' + messEndUserToInsert);
        if (!messEndUserToInsert.isEmpty()) { 
            insert messEndUserToInsert; 
            System.debug('TR Account checkEndUser ... executed');
        } 
        
        System.debug('TR Account messEndUserToUpdate [' + messEndUserToUpdate.size() + ']: ' + messEndUserToUpdate);
        if (!messEndUserToUpdate.isEmpty()) { 
            update messEndUserToUpdate; 
            System.debug('TR Account checkEndUser ... executed');
        } 
    } 

    public static void createSurveyForDoctors(Set<Id> doctorIds) {
        System.debug('TR Account createSurveyForDoctors '); 
        List<SurveyTaker__c> takersToInsert = new List<SurveyTaker__c>();
        List<SurveyQuestionResponse__c> qResponses = new List<SurveyQuestionResponse__c>();
        
        List<Account> doctors = [
            SELECT Id,
                RecordType.DeveloperName,
                Expertise_1__c,
                Expertise_1__r.SendDoctorStatisfactionSurvey__c
            FROM Account
            WHERE Id IN :doctorIds
            AND Expertise_1__r.SendDoctorStatisfactionSurvey__c = true
        ];

        if (doctors.isEmpty()) {           
            System.debug('No doctors eligible for survey creation');
            return;
        }

        List<Survey__c> surveys = [SELECT Id, SurveyCode__c, Survey_Version__c, Maximum_submission__c
                                   FROM Survey__c
                                   WHERE SurveyCode__c = 'DocSatisfaction'];
        if (surveys.isEmpty()) {           
            System.debug('No Survey found with code DocSatisfaction');
            return;
        }
        Survey__c survey = surveys.get(0);
    
        for (Id doctorId_i :doctorIds) {
            takersToInsert.add(new SurveyTaker__c(
                                RecordTypeId = AppointmentTriggerUtil.S_TAKER_RT_MAP.get('Digital_Forms').getRecordTypeId(),                
                                Doctor__c = doctorId_i,
                                Survey__c = survey.Id,
                                Survey_Version__c = survey.Survey_Version__c,
                                Taker_Maximum_submission__c = survey.Maximum_submission__c));
        }

        System.debug('TR Account takersToInsert [' + takersToInsert.size() + ']: ' + takersToInsert);
        if (!takersToInsert.isEmpty()) {
            insert takersToInsert;
        }

        List<Survey_Question__c> questions = [SELECT Id, Name, IsForAvg__c, UnShow__c
                                              FROM Survey_Question__c
                                              WHERE Survey__c = :survey.Id AND status_question__c = true];        
       
        for (SurveyTaker__c taker_i : takersToInsert) {
            for (Survey_Question__c question_k : questions) {
                qResponses.add(new SurveyQuestionResponse__c(
                    Survey_Question__c = question_k.Id,
                    SurveyTaker__c = taker_i.Id,
                    IsForAvg__c = question_k.IsForAvg__c,
                    UnShow__c = question_k.UnShow__c
                ));
            }
        }

        System.debug('TR Account qResponses [' + qResponses.size() + ']: ' + qResponses);
        if (!qResponses.isEmpty()) {
            insert qResponses;
        }
    }    
}