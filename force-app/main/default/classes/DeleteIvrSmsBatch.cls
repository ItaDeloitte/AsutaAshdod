// Test: DeleteIvrSmsBatchTest
global inherited sharing class DeleteIvrSmsBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                  + ', SmsTemplate__c'
                  + ', CreatedDate'
                  + ' FROM SMS__c'
                  + ' WHERE SmsTemplate__c = \'IVR_Chat_General\''
                  + ' OR SmsTemplate__c = \'IVR_Chat_Expert\''
                  + ' ORDER BY CreatedDate';

    global DeleteIvrSmsBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SMS__c> scope) {
		Set<String> errors = new Set<String>();
        for (Database.DeleteResult result_i : Database.delete(scope, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));        
    }

    global void finish(Database.BatchableContext BC) {       
        System.debug('DeleteIvrSmsBatch ... finish');        
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new DeleteIvrSmsBatch(), 50);
    }
}