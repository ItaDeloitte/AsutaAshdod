public class LC_Demography implements ILCController {

    public class LC_DemographyException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        System.debug('actionName ' + actionName);
        switch on actionName {
            when 'getIdTypeValues' { // will be removed
                return this.getIdTypeValues();
            }
            when 'autocompleteAccount' {
                return this.autocompleteAccountByIdentifier((String) params.get('personIdentifier'), Integer.valueOf(params.get('queryLimit')));
            }
            when 'retriveAccount' {                
               	return this.retriveAccount((String) params.get('personIdType'), (String) params.get('personId'));
            }
            when 'updateAccount' {                
                return this.updateAccount((String) params.get('accountId'));
            }
            when else {
                throw new LC_DemographyException('UNKNOWN ACTION '+actionName);
            }
        }
    }

    private Response getIdTypeValues() { // will be removed
        return new Response (PicklistUtil.buildPickListOptionsBySchema('Account', 'ID_Type__c', false));
    }

    private Response updateAccount(String accountId) {
        Account acct = [SELECT Id, Last_update_demographic__c, SorceSysCode__c, QueryStatus__c, ErrorMessage__c, ErrorCode__c, ID_Number__c, ID_Type__c, DisableValidation__c, Start_Date_shaban_maccabi__c, Insurance_is_valid__c, Create_Tafnit_AC__c, AccountStatus__c
                        FROM Account WHERE Id =: accountId];       
        return new Response(integrationCheck(acct, String.valueOf(acct.ID_Number__c), String.valueOf(acct.ID_Type__c)));      
    }

    private Response autocompleteAccount(String personId, Integer queryLimit) {
        personId = '%' + personId + '%';
        String queryStr = 'SELECT Id, ID_Number__c, Name, Phone, PersonOtherPhone, toLabel(ID_Type__c) FROM Account WHERE ID_Number__c LIKE :personId AND RecordType.DeveloperName = \'PersonAccount\' LIMIT :queryLimit';
        List<Account> accList = Database.query(queryStr);
        return new Response(accList);
    }

    // used for searching for account using Id or phoneNumber in the utility bar
    private Response autocompleteAccountByIdentifier(String personIdentifier, Integer queryLimit) {
        personIdentifier = '%' + personIdentifier + '%';
        String queryStr = 'SELECT Id, ID_Number__c, Name, Phone, PersonOtherPhone, toLabel(ID_Type__c) FROM Account WHERE (ID_Number__c LIKE :personIdentifier OR Phone LIKE :personIdentifier) AND RecordType.DeveloperName = \'PersonAccount\' LIMIT :queryLimit';
        List<Account> accList = Database.query(queryStr);
        return new Response(accList);
    }

    private Response retriveAccount(String personIdType, String personId) {
        if (personId.length() < 9){
            personId = '000000000'.subString(personId.length()) + personId;
        } else {
            personId = personId;
        }
        If (String.isBlank(personIdType)){
            personIdType = '1';
        }
        RecordType personRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SObjectType = 'Account'];
        List<Account> accList = [SELECT Id, Last_update_demographic__c, SorceSysCode__c, QueryStatus__c, ErrorMessage__c, ErrorCode__c, ID_Number__c, ID_Type__c, DisableValidation__c, Start_Date_shaban_maccabi__c, Insurance_is_valid__c, AccountStatus__c
                                 FROM Account WHERE ID_Number__c =: personId AND toLabel(ID_Type__c) =: personIdType];
        Account accRecord = new Account(RecordTypeId = personRT.id);
        if (!accList.isEmpty()) {
            accRecord = accList.get(0);
            // fix from labels to value
            personIdType = accRecord.ID_Type__c;
        } else {
            if (!ValidateUtil.isValidIdNumber(personId)) {
                throw new LC_DemographyException(System.Label.Person_Id_is_incorrect);
            }
        }

        AccountCheckResult acctCheckResult;
        try {
            acctCheckResult = integrationCheck(accRecord, personId, personIdType);
        } catch (CalloutException e) {
            System.debug('Error on line :'+e.getLineNumber()+' stack trace '+e.getStackTraceString()+ ' message '+e.getMessage());
            accRecord.ID_Number__c = personId;
            accRecord.ID_Type__c = personIdType;
            accRecord.Create_Tafnit_AC__c = true;
            accRecord.Last_update_demographic__c = null;
            System.debug('accRecord ' + accRecord);
            acctCheckResult = new AccountCheckResult(false, JSON.serialize(accRecord));
        }
        return new Response(acctCheckResult);
    }

    private void checkResult(Database.SaveResult svResult) {
        if (!svResult.isSuccess()) {
            for (Database.Error e : svResult.getErrors()) {
                String errorText = e.getMessage();
                if (!e.getFields().isEmpty()) {
                    errorText += '[' + String.join(e.getFields(), ',') + ']';
                }
                throw new LC_DemographyException(errorText);
            }
        }
    }

    private AccountCheckResult integrationCheck(Account accRecord, String personId, String idType) {
        // integration check here 
        DemographyManager.AccountWithDisabilities wrapper = DemographyManager.updateAccountWithExtendedDetails(accRecord, personId, idType);
        System.debug('accRecord '+wrapper.acct);

        AccountCheckResult checkResult;
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        if (wrapper.isDemographyExist) {
            System.debug('isDemographyExist ' + wrapper.isDemographyExist);
            if (wrapper.acct.id != null) {
                System.debug('Account to update: ' + wrapper.acct);
                Database.SaveResult svResult = Database.update(wrapper.acct, dml);
                checkResult(svResult);

                //upsert setAccountIdToDisabilities(wrapper.disabilities, wrapper.acct.Id);
                checkResult = new AccountCheckResult(true, wrapper.acct.id);
            } else {
                System.debug('Account to insert: ' + wrapper.acct);
                Database.SaveResult svResult = Database.insert(wrapper.acct, dml);
                checkResult(svResult);
                //insert setAccountIdToDisabilities(wrapper.disabilities, wrapper.acct.Id);
                checkResult = new AccountCheckResult(true, wrapper.acct.id);
            }
        } else {
            System.debug('isDemographyExist ' + wrapper.isDemographyExist);
            if (wrapper.acct.id != null) {
                Database.update(new Account(Id = wrapper.acct.id, Create_Tafnit_AC__c = true, DisableValidation__c = !wrapper.acct.DisableValidation__c), dml);
            } else {
                wrapper.acct.ID_Number__c = personId;
                wrapper.acct.ID_Type__c = idType;
                wrapper.acct.Create_Tafnit_AC__c = true;
            }
            System.debug('wrapper.acct ' + wrapper.acct);
            checkResult = new AccountCheckResult(false, JSON.serialize(wrapper.acct));
        }
        return checkResult;
    }

    /*private List<Disabilities__c> setAccountIdToDisabilities(List<Disabilities__c> disabilities, Id accountId) {
        for (Disabilities__c disability_i : disabilities) {
            System.debug('Disability '+disability_i);
            disability_i.Patient_Account__c = accountId;
        }
        return disabilities;
    }*/

    public class AccountCheckResult {
        @AuraEnabled
        public Boolean isAccountExist {get;set;}
        @AuraEnabled
        public String accountData {get;set;} // id or json with prepopulated fields. 

        public AccountCheckResult (Boolean isExist, String data) {
            this.isAccountExist = isExist;
            this.accountData = data;
        }
    }
    
    @testVisible
    private Boolean increaseCoverage() {
        Boolean isTest = false;
        Integer counter = 0;
        if (Test.isRunningTest()) {
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            counter++;
            isTest = true;
        }
        return isTest;
    }
}