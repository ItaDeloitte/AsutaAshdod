// Test: CreateRemindersSchedulableBatchTest
global class CreateRemindersSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean runNextJob = false;
    String query = 'SELECT Id'
                      + ', Remainder_type__c'
                      + ', sent_to_tizkurit__c'
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c > TODAY'
                + ' AND Appointment_Status__c = \'וידוא הגעה לפגישה\''
                + ' AND Remainder_status__c != \'השיב להודעה בשלילה\''
                + ' AND Remainder_status__c != \'השיב להודעה בחיוב\''
                + ' AND Medical_Procedure__c != null'
                + ' AND Patient_Account__c != null'
                + ' AND Case__c != null'
                + ' AND Medical_Procedure__r.Reminder_required__c = true'
                + ' AND Medical_Procedure__r.Confidentiality__c = false'
                + ' AND Date_for_tizkorit_reminder__c = LAST_N_DAYS:4'
                + ' AND sent_to_tizkurit__c = false'
                + ' ORDER BY Remainder_time__c, Date_for_tizkorit_reminder__c, Date_for_human_reminder__c';

    global CreateRemindersSchedulableBatch() {}

    global CreateRemindersSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global CreateRemindersSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<Reminder__c> tizkoritList = new List<Reminder__c>();
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<String> errors = new Set<String>();
        Set<Id> tizkoritIds = new Set<Id>();

        for (Appointment__c appt_i : scope) {
            tizkoritList.add(
                new Reminder__c(
                    Reminder_Status__c = '0',
                    Appointment__c = appt_i.Id
                )
            );
        }
        System.debug('tizkoritList: size: ' + tizkoritList.size() + ' value: ' + tizkoritList);

        for (Database.SaveResult result_i : Database.insert(tizkoritList, false)) {
            if (result_i.isSuccess()) {
                tizkoritIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }

        for (Reminder__c reminder_i : [SELECT Id, Appointment__c FROM Reminder__c WHERE Id IN: tizkoritIds]) {
            appts.add(
                new Appointment__c(
                    Id = reminder_i.Appointment__c,
                    Remainder_type__c = 'תזכורית',
                    sent_to_tizkurit__c = true
                )
            );
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Database.SaveResult result_i : Database.update(appts, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
        // run a batch with next reminders
        if (runNextJob) {
            Database.executeBatch(new CreateHumanSchedulableBatch(), 25);
        }
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateRemindersSchedulableBatch(runNextJob), 25);
    }
}