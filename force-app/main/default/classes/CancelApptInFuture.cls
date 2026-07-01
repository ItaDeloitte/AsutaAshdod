// Test: CancelApptInFutureTest
public class CancelApptInFuture {

    @future(callout=true)
    public static void execute(Set<Id> apptIds, String reason, String agentReason) {
        System.debug('CancelApptInFuture.execute...\nreason: ' + reason + '\nagentReason: ' + agentReason + '\napptIds: ' + apptIds);
        List<Appointment__c> ensembleAppts = new List<Appointment__c>();
        List<Appointment__c> localAppts = new List<Appointment__c>();

        for (Appointment__c appt_i : [SELECT Id, Accession_Number__c, Canceled_reason__c, agent_reason_to_cancel__c, Appointment_Date_Time__c, Duration__c, 
                                             Medical_Procedure__r.Name, Medical_Procedure__r.Procedure_Code__c, Calendar__c, Calendar__r.ServiceId__c, SourceSystem__c 
                                      FROM Appointment__c
                                      WHERE (Id IN: apptIds AND Is_Hidden_Appointment__c = false) OR (after_appointment__r.Id IN: apptIds AND Is_Hidden_Appointment__c = true)]) {
            appt_i.Canceled_reason__c = reason;
            if (appt_i.Accession_Number__c != null) {
                ensembleAppts.add(appt_i);
            } else {
                appt_i.agent_reason_to_cancel__c = agentReason;
                appt_i.Appointment_Status__c = 'Canceled';
                localAppts.add(appt_i);
            }
        }
        System.debug('ensembleAppts: size: ' + ensembleAppts.size() + ' value: ' + ensembleAppts);
        System.debug('localAppts: size: ' + localAppts.size() + ' value: ' + localAppts);

        ws_AppointmentNew.CancelAppointmentResponse response = LC_BackendUtils.callCancelInAnsemble(ensembleAppts);

        if (Test.isRunningTest()) {
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.ErrorDescription = 'test error description';
            result.ErrorCode = '1';
            response = new ws_AppointmentNew.CancelAppointmentResponse();
            response.CancelAppointmentResult = result;
        }

        if (response.CancelAppointmentResult.ErrorCode == '0') {
            System.debug('ensemble appointment cancel success');
            for (Appointment__c appt_i : ensembleAppts) {
                appt_i.Appointment_Status__c = 'Canceled';
                appt_i.Integration_Status__c = 'Success';
            }
        } else {
            System.debug('ensemble appointment cancel error');
            Boolean isFailed = response.CancelAppointmentResult.ErrorCode == '998' && response.CancelAppointmentResult.ErrorDescription.contains('\'Expected\'') ? false : true;
            for (Appointment__c appt_i : ensembleAppts) {
                appt_i.Integration_Message__c = response.CancelAppointmentResult.ErrorDescription;
                appt_i.Appointment_Status__c = isFailed ? 'CanceledFailed' : 'Canceled';
                appt_i.Integration_Status__c = 'Error';
            }
        }
        System.debug('ensembleAppts: size: ' + ensembleAppts.size() + ' value: ' + ensembleAppts);
        System.debug('localAppts: size: ' + localAppts.size() + ' value: ' + localAppts);

        localAppts.addAll(ensembleAppts);
        update localAppts;
    }
}