/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        22-07-2019
* @modified       DD-MM-YYYY
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for running a flow which changes the status of the sms message to 'no
* answer' and stops messages from being sent out from a certain time before the appointment.
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class RunKillSmsBeforeAptIfNoAnswerFlow implements Schedulable {
    global void execute(SchedulableContext SC) {
        new Flow.Interview.kill_sms_before_app_if_no_answer(new Map<String, Object>()).start();
    }
}