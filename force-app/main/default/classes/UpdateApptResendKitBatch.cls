// Test: UpdateApptResendKitBatchTest
public class UpdateApptResendKitBatch implements Database.Batchable<sObject> {

    public final String query;

    public UpdateApptResendKitBatch() {
        this.query = 'SELECT Id'
                        + ', resend_kit__c'
                  + ' FROM Appointment__c'
                  + ' WHERE Appointment_Status__c != \'Canceled\''
                  + ' AND Appointment_Status__c != \'CanceledFailed\''
                  + ' AND Appointment_Date_Time__c >= TODAY'
                  + ' AND resend_kit__c = TRUE'
                  + ' ORDER BY Appointment_Date_Time__c';
    }

    public UpdateApptResendKitBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<String> errors = new List<String>();

        for (Appointment__c appt_i : scope) {
            appt_i.resend_kit__c = false;
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