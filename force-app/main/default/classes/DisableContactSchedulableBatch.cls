global class DisableContactSchedulableBatch implements Database.Batchable<sObject>, Schedulable {
    
    Boolean runNextJob = false;

    // we query all appointments that are part of HomeAdmission process 
    //and that were released from surgery yesterday
    String query = 'SELECT Id'
                      + ', Patient_Account__c '
                      + ', TAF_Future_Case_Status__c '
                + ' FROM Appointment__c'
                + ' WHERE Release_Date__c = YESTERDAY'
                + ' AND TAF_Future_Case_Status__c != null';

    global DisableContactSchedulableBatch() {}

    global DisableContactSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global DisableContactSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<Appointment__c> appts = new List<Appointment__c>();
        List<AccountContactRelation> accConRelationsToDelete = new List<AccountContactRelation>();
        Set<String> errors = new Set<String>();
        Set<Id> accountIds = new Set<Id>();

        Id escortRecordId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Escort' AND SobjectType = 'Contact' LIMIT 1].Id;

        for (Appointment__c appt_i : scope) {
            appts.add(
                new Appointment__c(
                    Id = appt_i.Id,
                    TAF_Future_Case_Status__c = '4' // we want to update all HomeAdmission appointments status to "CLOSED" HomeAdmission status
                )
            );
            accountIds.add(appt_i.Patient_Account__c);
        }

        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('accountIds: size: ' + accountIds.size() + ' value: ' + accountIds);

        for (Database.SaveResult result_i : Database.update(appts, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));

        // deleting all relations between contact and account when the surgery is already finished
        for (AccountContactRelation accConRelation: [SELECT Id, AccountId, ContactId, Contact.RecordTypeId FROM accountContactRelation 
                                                            WHERE AccountId IN: accountIds AND Contact.RecordTypeId=:escortRecordId]) {
            accConRelationsToDelete.add(accConRelation);
        }

        System.debug('accConRelationsToDelete: size: ' + accConRelationsToDelete.size() + ' value: ' + accConRelationsToDelete);

        if (!accConRelationsToDelete.isEmpty()){
            for(Database.DeleteResult result_i : Database.delete(accConRelationsToDelete, false)) {
                if (!result_i.isSuccess()) {
                    errors.add(result_i.getId() + ': ' + result_i.getErrors());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);

        if (runNextJob) {
            Database.executeBatch(new DisableContactSchedulableBatch(), 25);
        }
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DisableContactSchedulableBatch(runNextJob), 25);
    }
}