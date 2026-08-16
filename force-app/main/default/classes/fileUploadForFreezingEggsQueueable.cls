global without sharing class fileUploadForFreezingEggsQueueable implements Queueable ,Database.AllowsCallouts{
    
    public String siteName;
    public List<fileUploadForFreezingEggsController.recordDetails> records;
    public Id logId;

    public fileUploadForFreezingEggsQueueable(List<fileUploadForFreezingEggsController.recordDetails> csvFileLines ,String sName, Id logId) {
        System.debug('csvFileLines: size: ' + csvFileLines.size() + 'csvFileLines' + csvFileLines + ' sName: ' + sName);
        this.siteName = sName;
        this.records = csvFileLines;
        this.logId = logId;
    }

    public void execute(QueueableContext context) {
        Integer i = 0;
        List<fileUploadForFreezingEggsController.recordDetails> wrapList = new List<fileUploadForFreezingEggsController.recordDetails>();
        System.debug('this.records in execute: size ' + this.records.size());
        for (fileUploadForFreezingEggsController.recordDetails record :this.records) {
            wrapList.add(record);
            if (i == 10) {
                System.debug('i == 10 ');
                break;
            }
            i++;
        } 
        runLogic(wrapList, this.siteName, this.logId);
        removeRecords(this.records, i);
        if (!Test.isRunningTest() && !this.records.isEmpty()) {
            system.debug('this.records next time' + this.records +'\n this.records size ' + this.records.size());
            System.enqueueJob(new fileUploadForFreezingEggsQueueable(this.records, siteName, logId));
        }
    }
    
    private static void removeRecords(List<fileUploadForFreezingEggsController.recordDetails> records, Integer size){
        for(Integer i = 0; i < size ; i++){
            records.remove(0);
        }
    }

    public static void runLogic (List<fileUploadForFreezingEggsController.recordDetails> records, String siteName, Id logId) {
        system.debug('this.records size ' + records.size() + '\nrecords ' + records);
        Log__c log = [SELECT Id, Message__c FROM Log__c WHERE Id = : logId LIMIT 1];
        Map<String, fileUploadForFreezingEggsController.recordDetails> recordDataMap = new Map <String, fileUploadForFreezingEggsController.recordDetails> ();
        List<Case> caseToInsert = new List<Case>();
        List<Account> accountToInsert = new List<Account>();
        Set<String> idNumbers = new Set<String>();
        Map<String, Id> accMap = new Map<String, Id> ();

        for (fileUploadForFreezingEggsController.recordDetails record :records) {
            system.debug('record.accId ' + record.accId);
            recordDataMap.put(record.accId, record);              
            idNumbers.add(record.accId); 
            if(record.PartnerName != null && record.PartnerName != ''){
                idNumbers.add(record.PartnerName); 
            }
        }
        System.debug('recordDataMap.size '+ recordDataMap.size() + 'values ' + recordDataMap);
        System.debug('idNumbers.size '+ idNumbers.size() + 'values ' + idNumbers);

        if(!idNumbers.isEmpty()){
            accMap = getAccounts(idNumbers);
        }

        System.debug('accMap1.size '+ accMap.size() + 'values ' + accMap);

        for (String line :recordDataMap.keySet()) {
            fileUploadForFreezingEggsController.recordDetails record = recordDataMap.get(line);
            if(!(accMap.containsKey(record.accId) && accMap.get(record.accId) != null)){
                accountToInsert.add(createPatient(record.accId));
            }
            if((record.PartnerName != null && record.PartnerName != '') && !(accMap.containsKey(record.PartnerName) && accMap.get(record.PartnerName) != null)){
                accountToInsert.add(createPatient(record.PartnerName));
            }
        }
        
        System.debug('accountToInsert.size '+ accountToInsert.size() + 'values ' + accountToInsert);

        if(!accountToInsert.isEmpty()){
            insertSObject(accountToInsert, 'Account', log);
        }

        accMap = getAccounts(idNumbers);

        System.debug('accMap2.size '+ accMap.size() + 'values ' + accMap);

        for (String line :recordDataMap.keySet()) {
            fileUploadForFreezingEggsController.recordDetails record = recordDataMap.get(line);
            System.debug('record: ' + record);
            if(accMap.containsKey(record.accId)){
                caseToInsert.add(createCase(
                                            accMap.get(record.accId),
                                            record.accPhone, 
                                            record.accEmail, 
                                            (record.partnerName != '') && accMap.containsKey(record.partnerName) ? accMap.get(record.partnerName) : null, 
                                            record.partnerPhone, 
                                            record.partnerEmail, 
                                            record.previousDate,
                                            record.amount, 
                                            record.isDonating,
                                            siteName
                                            )
                                );    
            } else {
                System.debug('Account not found in system for account Id ' + record.accId );
            }           
        }

        System.debug('caseToInsert.size '+ caseToInsert.size() + 'values ' + caseToInsert);

        if(!caseToInsert.isEmpty()){
            insertSObject(caseToInsert, 'Case', log);
        }
        
        update log;
    }
        
    private static Map<String, Id> getAccounts(Set<String> idNumbers) {
        Map<String, Id> accMap = new Map<String, Id>();
        for (Account acc_i : [SELECT Id, ID_Number__c FROM Account WHERE ID_Number__c IN :idNumbers AND ID_Type__c = '1']) {
            accMap.put(acc_i.ID_Number__c, acc_i.Id);
        }
        return accMap;
    }

    private static Account createPatient(String idNumber) {
        Account patient = new Account();
        patient.RecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account' LIMIT 1].ID;
        patient.ID_Number__c = idNumber;
        patient.ID_Type__c = '1';
        DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(patient, patient.ID_Number__c, patient.ID_Type__c);
        if (accountWithDemography.IsDemographyExist) {
            return accountWithDemography.acct;
        }
        return patient;
    }

    private static Case createCase(Id accId, String accPhone, String accEmail,  Id PartnerName, String partnerPhone, String partnerEmail, Date previousDate, Integer amount, Boolean isDonating, String siteName) {
        Case cas = new Case();
        cas.Status = 'New';
        cas.RecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'IVF_Freezing_Eggs' AND SobjectType = 'Case' LIMIT 1].ID;
        cas.AccountId = accId;
        cas.phone__c = accPhone;
        cas.email_from_patient__c = accEmail;
        cas.Partner_Name__c = PartnerName;
        cas.Primary_Phone_Partner__c = partnerPhone;
        cas.Partner_Email__c = partnerEmail;
        cas.Previous_Freezing_Date__c = previousDate;
        cas.Eggs_Amount__c = amount;
        cas.Is_Donating__c = isDonating;
        cas.Case_site__c = siteName;
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Cases Record type and Origin Assignment' LIMIT 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        cas.setOptions(dmlOpts);
        return cas;
    }

    private static void insertSObject(List<SObject> recordsToInsertInsert, String objName, Log__c log) {
        Set<Database.Error> errors = new Set<Database.Error>();
        Set<String> objIds = new Set<String>();
        Map<Id, List<Database.Error>> errorMap = new Map<Id, List<Database.Error>>();
        String message;
        
        Schema.SObjectType sObjectType = recordsToInsertInsert.getSObjectType();
        if (sObjectType != null)
        {
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(recordsToInsertInsert);
             
            List<Database.SaveResult> results = Database.insert(castRecords, false);
            for(Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    objIds.add(results[i].getId());
                }else{
                    errors.addAll(results[i].getErrors());
                    if(objName == 'Case'){
                        errorMap.put((Id)(castRecords[i].get('AccountId')), results[i].getErrors());
                    } else {
                        message = 'For ID Number ' + String.valueOf(castRecords[i].get('ID_Number__c')) + ' the error: '+ results[i].getErrors();
                        log.Message__c = log.Message__c + ' '+ message + '\n';
                    }                                                         
                }
            }

            System.debug('errorMap ' + errorMap);
            System.debug('objIds '+ objIds);
            System.debug('errors '+ errors);

            if(!errorMap.isEmpty()) {
                Map<Id, String> accMap = new  Map<Id, String>();
                for(Account acc: [SELECT Id, ID_Number__c FROM Account WHERE Id IN :errorMap.keySet()]){
                    accMap.put(acc.Id, acc.ID_Number__c);
                }

                for(Id  accId : errorMap.keySet()){
                    if(accMap.containsKey(accId)){
                        message = 'For ID Number ' + String.valueOf(accMap.get(accId)) + ' the error: ' + errorMap.get(accId);
                        log.Message__c = log.Message__c + ' '+ message + '\n'; 
                    }
                }
            }
        }
    }
}