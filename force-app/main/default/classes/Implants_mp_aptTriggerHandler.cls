public with sharing class Implants_mp_aptTriggerHandler {
    public static void handleTrigger(List<Implants_mp_apt__c> newList, Map<Id, Implants_mp_apt__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('Implants_mp_aptTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                Implants_mp_aptTriggerDispatcher.calculateImplantsForApp(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                Implants_mp_aptTriggerDispatcher.calculateImplantsForApp(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}