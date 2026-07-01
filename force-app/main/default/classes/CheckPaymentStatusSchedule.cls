/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Payment Status Checking Schedule Apex class to update an appointment or cancel it if a payment wasn't completed
 *
 * Test                 CheckPaymentStatusScheduleTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-02-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global without sharing class CheckPaymentStatusSchedule implements Schedulable {

    Set<Id> apptIds = new Set<Id>();

    global CheckPaymentStatusSchedule(Set<Id> apptIds) {
        this.apptIds = apptIds;
    }

    global void execute(SchedulableContext SC) {
        System.debug('CheckPaymentStatusSchedule ... execute');
        List<Appointment__c> apptsToUpdate = new List<Appointment__c>();
        Set<Id> apptIdsToCancel = new Set<Id>();

        List<Appointment__c> appts = [
            SELECT ReceiptNum__c
                 , PaymentStatus__c
                 , Appointment_Status__c
              FROM Appointment__c
             WHERE Id IN :apptIds];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Appointment__c appt_i : appts) {
            if (appt_i.ReceiptNum__c == null) {
                appt_i.PaymentStatus__c = 'Cancelled';
                apptsToUpdate.add(appt_i);
                apptIdsToCancel.add(appt_i.Id);
            }
        }
        System.debug('apptsToUpdate: size: ' + apptsToUpdate.size() + ' value: ' + apptsToUpdate);
        System.debug('apptIdsToCancel: size: ' + apptIdsToCancel.size() + ' value: ' + apptIdsToCancel);

        Set<Id> apptIds = AsyncUtil.doUpdate(apptsToUpdate);
        CancelApptInFuture.execute(apptIdsToCancel, '39', 'ביטול המטופל');

        System.abortJob(SC.getTriggerId());
    }
}