public with sharing class CalendarTriggerDispatcher {
    
    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * first time that the doctor has a value. only need to check 'has_QFLOW_calendar'
    * else- need to search if there is a qflow calendar for old doctor 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @author           Avia Hillel            <aviah@assuta.co.il>
    * @created          08-08-2021
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void onlineSummon(List<Calendar__c> newList, Map<Id, Calendar__c> oldMap) {
        //doctors in the new list value
        Set<Id> docs = new Set<Id>();
        //doctors in the old map
        Set<Id> oldDoc = new Set<Id>();
        for(Calendar__c cal : newList){
            System.debug('oldMap.get(cal.Id).Doctor__c: ' + oldMap.get(cal.Id).Doctor__c);
            System.debug('cal.Doctor__c: ' + cal.Doctor__c);
            if(cal.AppointmentSys__c == 'QFLOW' && cal.IsexpertCalender__c == true && 
              (oldMap.get(cal.Id).Doctor__c != cal.Doctor__c || oldMap.get(cal.Id).IsexpertCalender__c != cal.IsexpertCalender__c)){
                System.debug('CalendarTriggerDispatcher: enter first if');
                docs.add(cal.Doctor__c);
                if(oldMap.get(cal.Id).Doctor__c != null){
                    oldDoc.add(oldMap.get(cal.Id).Doctor__c);
                }
            }
            if(cal.AppointmentSys__c == 'QFLOW' && oldMap.get(cal.Id).IsexpertCalender__c != cal.IsexpertCalender__c && cal.IsexpertCalender__c == false){
                oldDoc.add(oldMap.get(cal.Id).Doctor__c);
            }
        }
        System.debug('docs: ' + docs);
        System.debug('oldDoc: ' + oldDoc);
        if(!docs.isEmpty() || !oldDoc.isEmpty()){
            CalendarTriggerService.onlineSummon(docs, oldDoc);
        }
    }
}