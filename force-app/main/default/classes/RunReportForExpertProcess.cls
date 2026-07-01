/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        11-09-2019
* @modified       DD-MM-YYYY
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for setting a checkbox to true on all doctor records that are checked 
* as experts. This triggers a process builder that sends a report on all of the doctor's patients
* this month.
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class RunReportForExpertProcess implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Doctor_Account' LIMIT 1];

        if(!rTypes.isEmpty()) {
            List<Account> experts = [SELECT Id FROM Account WHERE RecordTypeId = :rTypes[0].Id AND Experts_center__c = true AND Email__c != ''];

            if(!experts.isEmpty()) {
                for(Account doctor : experts) {
                    doctor.time_for_report__c = true;
                }

                update experts;
            }
        }
    }
}