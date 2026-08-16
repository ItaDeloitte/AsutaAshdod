// Test: CreateHumanSchedulableBatchTest
global class CreateHumanSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                      + ', Remainder_type__c'
                      + ', human_reminder_transferred__c'
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c >= TODAY'
                + ' AND Appointment_Status__c = \'וידוא הגעה לפגישה\''
                + ' AND Remainder_status__c != \'השיב להודעה בשלילה\''
                + ' AND Remainder_status__c != \'השיב להודעה בחיוב\''
                + ' AND Medical_Procedure__c != null'
                + ' AND Patient_Account__c != null'
                + ' AND Case__c != null'
                + ' AND Medical_Procedure__r.Reminder_required__c = true'
                + ' AND Medical_Procedure__r.Confidentiality__c = false'
                + ' AND Date_for_human_reminder__c = LAST_N_DAYS:4'
                + ' AND human_reminder_transferred__c = false'
                + ' ORDER BY Remainder_time__c, Date_for_tizkorit_reminder__c, Date_for_human_reminder__c';

    global CreateHumanSchedulableBatch() {}

    global CreateHumanSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        Set<String> errors = new Set<String>();

        for (Appointment__c appt_i : scope) {
            appt_i.human_reminder_transferred__c = true;
            appt_i.Remainder_type__c = 'אנושי';
        }

        for (Database.SaveResult result_i : Database.update(scope, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateHumanSchedulableBatch(), 25);
    }
}