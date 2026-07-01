// Test: LC_SurgeryCancelTest
public class LC_SurgeryCancel implements ILCController {

    public class LC_SurgeryCancelException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getAppointments' {
                return this.getAppointments((String) params.get('recordId'));
            }
            when 'cancelAppointment' {
                return this.cancelAppointment((String) params.get('recordId'));
            }
            when else {
                throw new LC_SurgeryCancelException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getAppointments(String caseId) {
        System.debug('LC_SurgeryCancel.getAppointments...\ncaseId: ' + caseId);
        return new Response([SELECT Id, Name, Appointment_Date_Time__c, Site__r.Name, Site__r.Site_code__c, Doctor_Account__r.Name FROM Appointment__c WHERE Case__c =: caseId AND Case__c != null AND Appointment_Status__c != 'Canceled']); // AND Name != null AND Appointment_Date_Time__c != null AND Site__c != null AND Doctor_Account__c != null
    }

    private Response cancelAppointment(String appointmentId) {
        System.debug('LC_SurgeryCancel.cancelAppointment...\nappointmentId: ' + appointmentId);
        Boolean isEnsemble = true;

        Appointment__c appointment = [SELECT Id, Case__c, Canceled_reason__c, Accession_Number__c, Appointment_Status__c, reason__c, Appointment_Date_Time__c, Duration__c, Medical_Procedure__c, Medical_Procedure__r.Name, Medical_Procedure__r.Procedure_Code__c, Calendar__c, Calendar__r.ServiceId__c, SourceSystem__c FROM Appointment__c WHERE Id =: appointmentId AND Appointment_Status__c != 'Canceled'];
        appointment.Appointment_Status__c = 'Canceled';
        appointment.Canceled_reason__c = '36'; // 'בוטל ע“י נציג';
        if (appointment.Accession_Number__c == null) {
            appointment.agent_reason_to_cancel__c = 'ביטול המטופל';
            isEnsemble = false;
        }

        cases_and_appoitments__c newJunction = new cases_and_appoitments__c(Case__c = appointment.Case__c, Appointment__c = appointment.id, type__c = 'ביטול תור');

        if (!isEnsemble) {
            update appointment;
            insert newJunction;
        } else {
            if (!Test.isRunningTest()) {
                ws_AppointmentNew.CancelAppointmentResponse response = LC_BackendUtils.callCancelInAnsemble(new List<Appointment__c>{appointment});
                if (response.CancelAppointmentResult.ErrorCode == '0') {
                    update appointment;
                    insert newJunction;
                } else {
                    return LC_BackendUtils.wrapEnsembleError(response.CancelAppointmentResult, '8');
                }
            }
        }

        return new Response('Appointment was canceled.');
    }
}