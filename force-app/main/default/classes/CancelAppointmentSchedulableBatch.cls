public with sharing class CancelAppointmentSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Id institutesRT = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Institutes').getRecordTypeId();

    String query = 'SELECT Id'
                      + ', Appointment_Status__c'
                      + ', agent_reason_to_cancel__c'
                      + ', Canceled_reason__c'
                + ' FROM Appointment__c'
                + ' WHERE RecordTypeId = :institutesRT'
                + ' AND Accession_Number__c = null'
                + ' AND CreatedBy.Name != \'SSIS\''
                + ' AND Appointment_Status__c NOT IN (\'Canceled\', \'Urgent_WaitingList\', \'WaitingForCanceled\', \'CanceledFailed\')'
                + ' ORDER BY CreatedDate DESC';

    public CancelAppointmentSchedulableBatch() {}

    public CancelAppointmentSchedulableBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CancelAppointmentSchedulableBatch.start...');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('CancelAppointmentSchedulableBatch.execute...');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        for (Appointment__c appointment_i : scope) {
            appointment_i.Appointment_Status__c = 'Canceled';
            appointment_i.agent_reason_to_cancel__c = 'נציג לא קבע תור בצורה תקינה';
            appointment_i.Canceled_reason__c = '55';
        }
        AsyncUtil.doUpdate(scope);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CancelAppointmentSchedulableBatch.finish...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CancelAppointmentSchedulableBatch(), 25);
    }
}