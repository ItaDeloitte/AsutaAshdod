public with sharing class ConsentFormTakenTriggerHandler {
    public static void handleTrigger(List<ConsentFormTaken__c> newList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                ConsentFormTakenTriggerDispatcher.populateUUID(newList);
            }
            when else {
                System.debug('do nothing on other trigger events');
            }
        }
    }
}