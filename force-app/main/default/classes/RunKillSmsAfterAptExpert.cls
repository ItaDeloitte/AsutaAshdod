/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        22-07-2019
* @modified       DD-MM-YYYY
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for running a flow which changes the status of the sms message to 'no
* answer' after an appointment with an expert took place.
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class RunKillSmsAfterAptExpert implements Schedulable {
    global void execute(SchedulableContext SC) {
        new Flow.Interview.kill_sms_after_app_expert(new Map<String, Object>()).start();
    }
}