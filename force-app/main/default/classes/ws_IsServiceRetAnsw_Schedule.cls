global class ws_IsServiceRetAnsw_Schedule implements Schedulable{

    public List<Appointment__c> appointmentsList = new List<Appointment__c>();

    public ws_IsServiceRetAnsw_Schedule (List<Appointment__c> appList) {
        appointmentsList = appList;
    }

    global void execute(SchedulableContext SC) {
        // Database.executeBatch(new ws_IsServiceRetAnsw_Batchable(appointmentsList), 200);
    }

}