// Test: UpdateCommunicationDetailsTest
public class UpdateCommunicationDetails implements Database.Batchable<sObject> {

    public final String query;

    public UpdateCommunicationDetails(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<String> errors = new List<String>();
        List<Case> cases = new List<Case>();
        Set<Id> caseIds = new Set<Id>();

        for (Appointment__c appt_i : scope) {
            if (caseIds.contains(appt_i.Case__c)) {
                continue;
            }
            Case case_i = new Case(Id = appt_i.Case__c);
            if (appt_i.Patient_Account__r.Preferred_Channel__c != null) {
                case_i.preferd_chanal_case__c = appt_i.Patient_Account__r.Preferred_Channel__c;
            }
            if (appt_i.Patient_Account__r.SMS_Phone_Number__c != null) {
                case_i.SMS_Phone_Number__c = appt_i.Patient_Account__r.SMS_Phone_Number__c;
            }
            if (appt_i.Patient_Account__r.PersonEmail != null) {
                case_i.email_from_patient__c = appt_i.Patient_Account__r.PersonEmail;
            }
            if (appt_i.Patient_Account__r.Phone != null) {
                case_i.phone__c = appt_i.Patient_Account__r.Phone;
            }
            caseIds.add(case_i.Id);
            cases.add(case_i);
        }
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        List<Database.SaveResult> results = Database.update(cases, false);

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