public with sharing class ConsentFormTakenTriggerDispatcher {
    public static void populateUUID(List<ConsentFormTaken__c> newList){
        for(ConsentFormTaken__c cft : newList){
            cft.UUID__c = UUID.randomUUID().toString();
        }
    }
}