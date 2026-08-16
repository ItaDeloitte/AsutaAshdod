global class ws_insertDocMToPortal_Schedule implements Schedulable{
    public ws_insertDocMToPortal_Schedule() {}

    global void execute(SchedulableContext SC) {
        Integer min = Integer.valueOf(System.Label.ScheduleMinutesInsertDoc);
        DateTime myDateTime = System.now().addMinutes(min);
        Integer second = myDateTime.second();
        Integer minute = myDateTime.minute();
        Integer hour = myDateTime.hour();
        Integer day = myDateTime.day();
        Integer month = myDateTime.month();
        Integer year = myDateTime.year();
        String sch = second+' '+minute+' '+hour+' '+day+' '+month+' ? '+year;
        if(!Test.isRunningTest()){
            ws_insertDocMToPortal_Schedule insertDocSched = new ws_insertDocMToPortal_Schedule();
            String jobID = system.schedule('InsertDoc'+myDateTime, sch, insertDocSched);
        }
        ws_insertDocMaccabiToPortalREST wsInsertDoc = new ws_insertDocMaccabiToPortalREST();
        System.enqueueJob(wsInsertDoc);
    }
}