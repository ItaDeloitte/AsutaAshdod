// Test: UpdateApptDateBatchTest
public class UpdateApptDateBatch implements Database.Batchable<sObject> {

    public final String query;

    public UpdateApptDateBatch() {
        this.query = 'SELECT Id'
                        + ', appointment_hour__c'
                        + ', Appointment_Date__c'
                        + ', Appointment_Date_Time__c'
                  + ' FROM Appointment__c'
                  + ' WHERE Appointment_Status__c != \'Canceled\''
                  + ' AND Appointment_Status__c != \'CanceledFailed\''
                  + ' AND Appointment_Date_Time__c >= TODAY'
                  + ' AND (appointment_hour__c = NULL OR Appointment_Date__c = NULL)'
                  + ' ORDER BY Appointment_Date_Time__c';
    }

    public UpdateApptDateBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<String> errors = new List<String>();

        for (Appointment__c appt_i : scope) {
            appt_i.appointment_hour__c = appt_i.Appointment_Date_Time__c.time();
            appt_i.Appointment_Date__c = appt_i.Appointment_Date_Time__c.date();
        }
        List<Database.SaveResult> results = Database.update(scope, false);

        for (Database.SaveResult result_i : results) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
}