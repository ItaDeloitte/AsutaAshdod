/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        17-07-2019
* @modified       DD-MM-YYYY
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for running a flow which checks for recurring cases of the same type
* for the same patients.
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class RunRecurringCaseForAccountsFlow implements Schedulable {
    global void execute(SchedulableContext SC) {
        new Flow.Interview.check_all_accounts_every_day(new Map<String, Object>()).start();
    }
}