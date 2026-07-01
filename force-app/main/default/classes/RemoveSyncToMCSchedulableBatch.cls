// Test: RemoveSyncToMCSchedulableBatchTest
global inherited sharing class RemoveSyncToMCSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                  + ', SyncToMC__c '
                  + ', SyncToMC_Off_After_180_Days__c'
                  + ' FROM Lead'
                  + ' WHERE SyncToMC__c  = true'
                  + ' AND SyncToMC_Off_After_180_Days__c = LAST_N_DAYS:7'
                  + ' ORDER BY SyncToMC_Off_After_180_Days__c';

    global RemoveSyncToMCSchedulableBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<Lead> leadToUpdate = new List<Lead>();
		for (Lead lead_i : scope) {
            leadToUpdate.add(new Lead(Id = lead_i.Id, SyncToMC__c = false));
        }    
        System.debug('leadToUpdate: size: ' + leadToUpdate.size() + ' value: ' + leadToUpdate);
        update(leadToUpdate);
    }

    global void finish(Database.BatchableContext BC) {       
        System.debug('RemoveSyncToMCSchedulableBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
       Database.executeBatch(new RemoveSyncToMCSchedulableBatch(), 100);
    }
}