// Test: UpdateApptStatusBatchTest
public class UpdateApptStatusBatch implements Database.Batchable<sObject> {

    public final String query;

    public UpdateApptStatusBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<String> errors = new List<String>();

        for (Appointment__c appt_i : scope) {
            appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
        }
        List<Database.SaveResult> results = Database.update(scope, false);

        for (Database.SaveResult result_i : results) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + JSON.serialize(result_i.getErrors()));
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
}