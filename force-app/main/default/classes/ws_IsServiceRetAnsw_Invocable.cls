global with sharing class ws_IsServiceRetAnsw_Invocable {

    @InvocableMethod
    global static void isServiceRetAns(List<ID> appIds) {
        List<Appointment__c> appList = [SELECT Id, IDNumber__c, Number_of_commitment__c FROM Appointment__c WHERE Id IN:appIds];

        try{
            System.debug('START schedule class ');
            // ws_IsServiceRetAnsw_Schedule isRetAns = new ws_IsServiceRetAnsw_Schedule(appList);
            // DateTime myDateTime = System.now().addSeconds(20);
            // Integer second = myDateTime.second();
            // Integer minute = myDateTime.minute();
            // Integer hour = myDateTime.hour();
            // Integer day = myDateTime.day();
            // Integer month = myDateTime.month();
            // Integer year = myDateTime.year();
            // String sch = second+' '+minute+' '+hour+' '+day+' '+month+' ? '+year;
            // System.debug('START schedule class ws_IsServiceRetAnsw_Schedule: '+sch);
            // String jobID = system.schedule('IsRetAns'+appList[0].Id+myDateTime, sch, isRetAns);
            // System.debug('START schedule class ws_IsServiceRetAnsw_Schedule jobID: '+jobID);

        } catch(Exception ex){
            System.debug('Error - can`t schedule class ws_IsServiceRetAnsw_Schedule : ' + ex);
        }  
    }

}