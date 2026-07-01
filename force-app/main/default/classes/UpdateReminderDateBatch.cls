// Test: UpdateReminderDateBatchTest
public class UpdateReminderDateBatch implements Database.Batchable<sObject>, Database.Stateful {

    public final String query;
    public List<String> errors = new List<String>();

    public UpdateReminderDateBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        AppointmentTriggerDispatcher.updateReminderDate(scope, null);
        List<Database.SaveResult> results = Database.update(scope, false);

        for (Database.SaveResult result_i : results) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + JSON.serialize(result_i.getErrors()));
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('errors: ' + JSON.serialize(errors));
    }
}