// Test: AccountServicesTest
public class AccountTriggerDispatcher {

    public static Map<String, Schema.RecordTypeInfo> acctRTMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    public static Boolean isFirstTime = true;

    public static void checkIdNumberUniqueness(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.checkIdNumberUniqueness...');
        Map<String, Account> idNumbersToAccountMap = new Map<String, Account>();
        Set<String> idNumbersSet = new Set<String>();
        Set<Id> recordTypeIdsSet = new Set<Id>();
        
        recordTypeIdsSet.add(acctRTMap.get('PersonAccount').getRecordTypeId());
        recordTypeIdsSet.add(acctRTMap.get('Doctor_Account').getRecordTypeId());

        for (Account account_i : newList) {        
            if (recordTypeIdsSet.contains(account_i.RecordTypeId) 
                && account_i.ID_Number__c != null 
                && (oldMap == null 
                    || account_i.ID_Type__c != oldMap.get(account_i.Id).ID_Type__c
                    || account_i.ID_Number__c != oldMap.get(account_i.Id).ID_Number__c)) {
                        account_i.ID_Number__c = account_i.ID_Type__c == '1' && account_i.ID_Number__c.length() < 9 ? '000000000'.substring(account_i.ID_Number__c.length()) + account_i.ID_Number__c : account_i.ID_Number__c;
                        if (!idNumbersToAccountMap.containsKey(account_i.ID_Number__c + account_i.ID_Type__c)) {
                            idNumbersToAccountMap.put(account_i.ID_Number__c + account_i.ID_Type__c, account_i);
                            idNumbersSet.add(account_i.ID_Number__c);
                        } else {
                            account_i.addError(System.Label.Id_number_should_be_unique);
                        }
            }
        }

        if (!idNumbersToAccountMap.isEmpty()) {
            System.debug('idNumbersToAccountMap ' + idNumbersToAccountMap);
            System.debug('idNumbersSet ' + idNumbersSet);
            AccountServices.checkIdNumberUniqueness(idNumbersToAccountMap, idNumbersSet);                                         
        }
    }

    public static void validateIdNumber(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.validateIdNumber...');
        Map<String, Account> idNumbersToAccountMap = new Map<String, Account>();

        for (Account account_i : newList) {
            if (account_i.ID_Type__c == '1' && String.isNotBlank(account_i.ID_Number__c) && (oldMap == null || account_i.ID_Number__c != oldMap.get(account_i.Id).ID_Number__c || 
                 account_i.ID_Type__c != oldMap.get(account_i.Id).ID_Type__c)) {
                String personIdTmp = account_i.ID_Number__c.length() < 9 ? '000000000'.substring(account_i.ID_Number__c.length()) + account_i.ID_Number__c : account_i.ID_Number__c;
                idNumbersToAccountMap.put(personIdTmp, account_i);
            }
        }

        if (!idNumbersToAccountMap.isEmpty()) {
            System.debug('idNumbersToAccountMap ' + idNumbersToAccountMap);
            AccountServices.validateIdNumber(idNumbersToAccountMap);
        }
    }

    public static void fillFormtitanId(List<Account> newList, Map<Id, Account> oldMap){
        System.debug('AccountTriggerDispatcher.fillFormtitanId...');
        for (Account account_i : newList) {
            if((account_i.RecordTypeId == acctRTMap.get('Doctor_Account').getRecordTypeId() && (oldMap == null ||
                (oldMap.get(account_i.Id).Approval_request_number__c == null &&
                account_i.Approval_request_number__c != oldMap.get(account_i.Id).Approval_request_number__c))) || (oldMap == null ||
                (oldMap.get(account_i.Id).Approval_request_number_Medical__c == null &&
                account_i.Approval_request_number_Medical__c != oldMap.get(account_i.Id).Approval_request_number_Medical__c))|| 
                (account_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId() && oldMap == null)) {
                String randomStr = CommonService.generateRandomKey(15);
                account_i.formtitan_id_2__c = randomStr;
                System.debug('account_i.formtitan_id_2__c' + account_i.formtitan_id_2__c);
            }
        }
    }

    public static void handleCreatePatient(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.handleCreatePatient...');
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountlst = new List<Account>();
        String recordType = oldMap == null ? 'I' : 'U';

        for (Account account_i : newList) {
            if (account_i.Create_Source_System__c && recordType == 'I') {
                accountIds.add(account_i.Id);// was accountlst.add();
            } else if(account_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId()) {
                if (recordType == 'I' ) {
                    System.debug('Insert person Account');
                    if (account_i.Create_Tafnit_AC__c) {
                        System.debug('Demography no exists');
                        accountIds.add(account_i.Id);
                    } else {
                        System.debug('Demography exists');
                        Account updateAcc = new Account(ID = account_i.ID);
                        updateAcc.Create_Tafnit_AC__c = true;
                        updateAcc.Update_Tafnit_AC__c = true;
                        updateAcc.DisableValidation__c = !account_i.DisableValidation__c;
                        update updateAcc;
                    }
                }

                if (recordType == 'U') {
                    System.debug('Update person Account');
                    System.debug('isFirstTime ' + isFirstTime);
                    if(isFirstTime){
                        isFirstTime = false;
                        for(Create_Tafnit_AC__mdt metadata_i :[SELECT Field__c FROM Create_Tafnit_AC__mdt]){
                            System.debug('Field name: '+ metadata_i.Field__c +'. New value: ' + account_i.get(metadata_i.Field__c) +'. Old value: '+oldMap.get(account_i.Id).get(metadata_i.Field__c));
                            if(account_i.get(metadata_i.Field__c) != oldMap.get(account_i.Id).get(metadata_i.Field__c)){ 
                                system.debug('***The value has changed! '); 
                                accountIds.add(account_i.Id); 
                                break;
                            }    
                        }
                    }
                    
                    /*if (account_i.Update_Tafnit_AC__c == false) {
                        accountIds.add(account_i.Id);
                        recordType = 'I';
                    } else if (!(oldMap.get(account_i.Id).Update_Tafnit_AC__c == false && account_i.Update_Tafnit_AC__c == true)) {
                        accountIds.add(account_i.Id);
                    }*/
                }
            }
        }
        /*if (accountlst.Size() > 0) {
            // uncommented by Tatiana Olekseichuk 
            // please keep it in the queueable
            //AccountServices.CheckDemography(accountlst); 
            //commented by Anatoly 08.08.2019 
            //ID jobID = System.enqueueJob(new AsyncDemography(accountlst));
        }*/

        if  (!accountIds.isEmpty() && !System.isBatch()) {
            System.debug('accountIds ' + accountIds);
            AccountServices.handleCreatePatient(accountIds, recordType); 
        }
    }

    /**
     * When updating patient details, all case related to it must be updated
     */
    public static void updateCasebyAccountFields(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.updateCasebyAccountFields...');
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountoldMap = new Map<Id, Account> ();

        for (Account account_i : newList) {
            if (account_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId()) {
               if (
                    account_i.Preferred_Channel__c != oldMap.get(account_i.Id).Preferred_Channel__c ||
                    account_i.SMS_Phone_Number__c != oldMap.get(account_i.Id).SMS_Phone_Number__c ||
                    account_i.PersonEmail != oldMap.get(account_i.Id).PersonEmail ||
                    account_i.Phone != oldMap.get(account_i.Id).Phone ||
                    // use all fields which use in formula field payer_factor_ID__c
                    account_i.Insurer_factor__c != oldMap.get(account_i.Id).Insurer_factor__c ||
                    account_i.Other_Health_Services__c != oldMap.get(account_i.Id).Other_Health_Services__c ||
                    account_i.Payer_Factor_Insurance__c != oldMap.get(account_i.Id).Payer_Factor_Insurance__c
                ) {
                    accountIds.add(account_i.Id); 
                    accountoldMap.put(account_i.Id, oldMap.get(account_i.Id));
                } 
            }
        }

        if (!accountIds.isEmpty() && !accountoldMap.isEmpty()) {
            System.debug('accountIds: size: ' + accountIds.size() + ' values: ' + accountIds);
            System.debug('accountoldMap: size: ' + accountoldMap.size() + ' values: ' + accountoldMap);
            AccountServices.updateCasebyAccountFields(accountIds, accountoldMap);
        }
    }

    /**
     * Throw an error if SMS_Phone_Number__c is erased
     */
    public static void validateSMSPhoneNumber(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.validateSMSPhoneNumber...');
        List<LogEvent__e> logEvents = new List<LogEvent__e>();
        Id userId = UserInfo.getUserId();

        for (Account acct_i : newList) {
            if (
                acct_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId() &&
                (
                    acct_i.SMS_Phone_Number__c == null && acct_i.Phone == null &&
                    (
                        oldMap.get(acct_i.Id).SMS_Phone_Number__c != null || oldMap.get(acct_i.Id).Phone != null
                    )
                )
            ) {
                logEvents.add(
                    new LogEvent__e(
                        Class__c = 'AccountTriggerDispatcher',
                        Message__c = 'Modification of the Phone or SMS phone number is not allowed.',
                        Method__c = 'validateSMSPhoneNumber',
                        RecordId__c = acct_i.Id,
                        UserId__c = userId
                    )
                );
                if (Boolean.valueOf(System.Label.Enable_addError_on_Phone_validation)) {
                    acct_i.addError(System.Label.Null_Phone_is_not_allowed);
                }
            }
        }
        System.debug('logEvents: size: ' + logEvents.size() + ' value: ' + logEvents);

        EventBus.publish(logEvents);
    }


    /**
     * Check if there are available slots for account to become Doc Advisor Promoted
     */
    public static void checkPromotedDocAdvisorDocAmount(List<Account> newList, Map<Id, Account> oldMap) {
        List<Account> accsForCheck = new List<Account>();
        System.debug('AccountTriggerDispatcher.checkPromotedDocAdvisorDocAmount...');
        for(Account acc :newList){
            if(acc.RecordTypeId == acctRTMap.get('Doctor_Account').getRecordTypeId() && (oldMap == null ||
            oldMap.get(acc.Id).Promoted_doctor_DA__c == false ||  oldMap.get(acc.Id).Promoted_doctor_DA__c == null) &&
            acc.Promoted_doctor_DA__c == true){
                accsForCheck.add(acc);
            }
        }
        if(!accsForCheck.isEmpty()){
            AccountServices.checkPromotedDocAdvisorDocAmount(accsForCheck);
        }
    }

    /**
     * Check if the value in postal code fields contains only numbers, if it doesn't:
     * if the user is from integration profile- empty the value
     * for any other user - throw an error
     */
    public static void postalCodeFields(List<Account> newList, Map<Id, Account> oldMap){
        System.debug('AccountTriggerDispatcher.postalCodeFields...');
        List<Account> accounts = new List<Account>();
        for(Account acc : newList){
            if(oldMap == null || 
            acc.PersonMailingPostalCode != oldMap.get(acc.Id).PersonMailingPostalCode ||
            acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode){
                accounts.add(acc);
            }
        }
        system.debug('accounts: ' + accounts);
        if(!accounts.isEmpty()){
            AccountServices.postalCodeFields(accounts);
        }
    }

    
    /**
     * Fill account X360_Coordinator__c field from linked Case's First_user_to_own_the_case__c field
     */
    public static void fill360Coordinator(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('AccountTriggerDispatcher.fill360Coordinator...');
        Map<Id, Account> caseToAccountMap = new Map<Id, Account>();

        for (Account acc_i : newList) {
            if (acc_i.Case_360__c != null
                    && acc_i.X360_Coordinator__c == null
                    && (oldMap == null 
                        || (acc_i.Case_360__c != oldMap.get(acc_i.Id).Case_360__c) 
                            || acc_i.X360_Coordinator__c != oldMap.get(acc_i.Id).X360_Coordinator__c)) {
                caseToAccountMap.put(acc_i.Case_360__c, acc_i);
            }
        }

        System.debug('caseToAccountMap: size: ' + caseToAccountMap.size() + ' values: ' + caseToAccountMap);
        if (!caseToAccountMap.isEmpty()) {
            AccountServices.fill360Coordinator(caseToAccountMap);
        }
    }

    /**
     * Copy mailing approval info to the Lead and Account with the same comm channel
     */
    public static void handleMailingApproval(List<Account> pNewList, Map<Id, Account> pOldMap) {
        System.debug('TR Account handleMailingApproval ... start');
        Map<String, Account> partialMatchAccountMap = new Map<String, Account>();
        Map<String, Account> exactMatchAccountMap = new Map<String, Account>();
        Set<String> commChannelSet = new Set<String>();

        for (Account account_i : pNewList) {
            if (account_i.Mailing_approval__c != null
                    && account_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId()
                    && (pOldMap == null || pOldMap.get(account_i.Id).Mailing_approval__c != account_i.Mailing_approval__c)) {
                if (account_i.OTP_EMAIL_HIDDEN__c != null || account_i.SMS_Phone_Number__c != null) {
                    exactMatchAccountMap.put(account_i.OTP_EMAIL_HIDDEN__c + account_i.SMS_Phone_Number__c, account_i);
                    partialMatchAccountMap.put(account_i.OTP_EMAIL_HIDDEN__c, account_i);
                    partialMatchAccountMap.put(account_i.SMS_Phone_Number__c, account_i);
                    commChannelSet.add(account_i.OTP_EMAIL_HIDDEN__c);
                    commChannelSet.add(account_i.SMS_Phone_Number__c);
                }
            }
        }
        commChannelSet.remove(null);
        partialMatchAccountMap.remove(null);
        System.debug('TR Account commChannelSet [' + commChannelSet.size() + ']: ' + commChannelSet);
        System.debug('TR Account partialMatchAccountMap [' + partialMatchAccountMap.size() + ']: ' + partialMatchAccountMap);
        System.debug('TR Account exactMatchAccountMap [' + exactMatchAccountMap.size() + ']: ' + exactMatchAccountMap);

        if (!commChannelSet.isEmpty()) {
            AccountServices.handleMailingApproval(commChannelSet, exactMatchAccountMap, partialMatchAccountMap);
        }
    }

    public static void checkEndUser(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('TR Account checkEndUser ... start');
        List<Account> accountList = new List<Account>();
        Map<Id, String> accountMap = new Map<Id, String>();

        for (Account account_i : newList) {
            if (account_i.SMS_Phone_Number__c != null
                    && account_i.RecordTypeId == acctRTMap.get('PersonAccount').getRecordTypeId()
                    && (oldMap == null || oldMap.get(account_i.Id).SMS_Phone_Number__c != account_i.SMS_Phone_Number__c)) {
                if (oldMap != null && oldMap.get(account_i.Id).SMS_Phone_Number__c != null) {
                    accountMap.put(account_i.Id, oldMap.get(account_i.Id).SMS_Phone_Number__c);
                }
                accountList.add(account_i);
            }
        }
        System.debug('TR Account accountList [' + accountList.size() + ']: ' + accountList);
        System.debug('TR Account accountMap [' + accountMap.size() + ']: ' + accountMap);

        if (!accountList.isEmpty()) {
            AccountServices.checkEndUser(accountList, accountMap);
        }
    }

    /**
     * Creating new Survey for each new Doctor
     */
    public static void createSurveyForDoctors(List<Account> newList) {
        System.debug('TR Account createSurveyForDoctors ... start');
        Set<Id> doctorIds = new Set<Id>();
        for (Account acc :newList){
            if(acc.RecordTypeId == acctRTMap.get('Doctor_Account').getRecordTypeId()){
                doctorIds.add(acc.Id);
            }
        }
        System.debug('TR Account doctorIds [' + doctorIds.size() + ']: ' + doctorIds);
        if (!doctorIds.isEmpty()){
            AccountServices.createSurveyForDoctors(doctorIds);
        }
    }
}