public with sharing class Implants_mp_aptTriggerDispatcher {
    
    //when imlants is added or implan's prices or status changes- calculate
    //min and max prices for the appointment and update it
    public static void calculateImplantsForApp(List<Implants_mp_apt__c> newList, Map<Id, Implants_mp_apt__c> oldMap) {
        Set<Id> appsIds = new Set<Id>();
        for(Implants_mp_apt__c implant : newlist){
            if(oldMap == null ||
            implant.status__c != oldMap.get(implant.Id).status__c ||
            implant.min_price__c != oldMap.get(implant.Id).min_price__c ||
            implant.max_price__c != oldMap.get(implant.Id).max_price__c){
                appsIds.add(implant.Appointment__c);
            }
        }

        if(!appsids.isEmpty()){
            Implants_mp_aptTriggerService.calculateImplantsForApp(appsIds);
        }
    }
}