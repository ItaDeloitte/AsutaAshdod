public with sharing class CalendarTriggerService {
    
    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * update has_QFLOW_calendar__c checkbox on account
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @author           Avia Hillel            <aviah@assuta.co.il>
    * @created          08-08-2021
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void onlineSummon(Set<Id> docs, Set<Id> oldDoc) {
       List<Account> docsToUpdate = new List<Account>(); 
       //for old docs- check if they still have a qflow calendar
       Set<Id> truedocs = new Set<Id>();
       for(Calendar__c qflowCal : [SELECT Id, Doctor__c, AppointmentSys__c FROM Calendar__c WHERE AppointmentSys__c = 'QFLOW' AND IsexpertCalender__c = true AND Doctor__c IN : oldDoc]){
            truedocs.add(qflowCal.Doctor__c);
       }
       System.debug('truedocs: ' + truedocs);
       //update doctors that are in the new value on the calendar
       for(Account doc : [SELECT Id, has_QFLOW_calendar__c FROM Account WHERE Id IN : docs]){
            if(doc.has_QFLOW_calendar__c != true){
                docsToUpdate.add(new Account(Id = doc.Id, has_QFLOW_calendar__c = true));
            }
       }
       //if doc doesnt have a calendar- update has_QFLOW_calendar__c to false
       for(Account doc : [SELECT Id, Experts_center__c, has_QFLOW_calendar__c FROM Account WHERE Id IN : oldDoc]){
            if(!truedocs.contains(doc.Id)){
                docsToUpdate.add(new Account(Id = doc.Id, has_QFLOW_calendar__c = false));
            }
       }
       System.debug('docToUpdate: ' + docsToUpdate);
        if(!docsToUpdate.isEmpty()){
            update docsToUpdate;
        }
    }
}