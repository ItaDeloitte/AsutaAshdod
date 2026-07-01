global  class IVFNewCaseSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean runNextJob = false;
    Integer nextMonth = date.today().addMonths(1).month();
    Integer currentYear = date.today().year();
    
    String query = 'SELECT Id'
                      + ', Female_Status__c'
                      + ', Partner_Status__c'
                      + ', Case_Route__c'
                      + ', Case_Status__c'
                      + ', Freezing_Date__c'
                      + ', AccountId'
                      + ', Partner_Name__c'
                + ' FROM Case'
                + ' WHERE RecordType.DeveloperName = \'IVF_Freezing_Eggs\''
                + ' AND  ((CALENDAR_MONTH(Future_End_Freezing_Date__c) = '+nextMonth 
                + ' AND  CALENDAR_YEAR(Future_End_Freezing_Date__c) = '+currentYear +')'
                + ' OR (CALENDAR_YEAR(Future_End_Freezing_Date__c) = '+(currentYear+1)+' AND CALENDAR_MONTH(Future_End_Freezing_Date__c) = 1))';

    global IVFNewCaseSchedulableBatch(Boolean runNextJob){
        this.runNextJob = runNextJob;
    }
    global IVFNewCaseSchedulableBatch(String query){
        this.query = query;
    }
    global IVFNewCaseSchedulableBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Case '));
        System.debug('next month: '+nextMonth);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> cases){
        List<Case> newCases = new List<Case>();
        List<String> errors = new List<String>();
        Set<Id> casesIds = new Set<Id>();
        RecordType IVFRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'IVF_Freezing_Eggs' AND SobjectType = 'Case'];
        System.debug('recordType IVF: '+IVFRecordType);
        for (Case currCase : cases){
            newCases.add(
                new Case(ParentId=currCase.id,
                        RecordTypeId=IVFRecordType.Id,
                        Case_Stage__c='First_Treatment_Details_Completion',
                        Case_Status__c='Treatment_Hold',
                        Previous_Freezing_Date__c=currCase.Freezing_Date__c,
                        Partner_Name__c=currCase.Partner_Name__c,
                        AccountId=currCase.AccountId
                )
            );
            
        }

        System.debug('newCases: size: ' + newCases.size() + ' value: ' + newCases);
        for (Database.SaveResult result_i : Database.insert(newCases, false)) {
            if (result_i.isSuccess()) {
                casesIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }        
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
         
        if (runNextJob) {
            Database.executeBatch(new IVFNewCaseSchedulableBatch(true), 25);
        }
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new IVFNewCaseSchedulableBatch(runNextJob), 25);
    }


    
}