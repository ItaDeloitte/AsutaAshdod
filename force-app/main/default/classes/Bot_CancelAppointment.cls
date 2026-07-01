global without sharing class Bot_CancelAppointment {

    public class Bot_CancelAppointmentException extends Exception{}

    global class CancelAppointmentRequestWrapper {
        @InvocableVariable(label='appointmentId' description='Sf id of appointment' required=true)
        public String appointmentId;
    }


    @InvocableMethod(label='Cancel appointmnet')
    public static List<Bot_Response> cancelAppointments(List<CancelAppointmentRequestWrapper> inList) {
        List<Bot_Response> responseList = new List<Bot_Response>();
        try {
            if (inList.isEmpty()) {
                throw new Bot_CancelAppointmentException('Params is blank');
            }

            Set<Id> apptIds = new Set<Id>();
            String apptId = inList.get(0).appointmentId;

            List<Appointment__c> appts = [SELECT Id, Appointment_Status__c, agent_reason_to_cancel__c, Canceled_Reason__c FROM Appointment__c
                                          WHERE (Id =: apptId AND Is_Hidden_Appointment__c = false) OR (after_appointment__r.Id =: apptId AND Is_Hidden_Appointment__c = true)];

            for (Appointment__c appt_i : appts) {
                apptIds.add(appt_i.Id);
            }

            CancelApptInFuture.execute(apptIds, '5', 'ביטול המטופל');

            responseList.add(new Bot_Response(new List<String>{apptId}));
        } catch (Exception e) {
            responseList.add(new Bot_Response(e));
        }
        return responseList;
    }

}