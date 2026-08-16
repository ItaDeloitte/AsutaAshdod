public with sharing class CalendarTriggerHandler {
    public static void handleTrigger(List<Calendar__c> newList, Map<Id, Calendar__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('CalendarTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                CalendarTriggerDispatcher.onlineSummon(newList, oldMap);
            }            
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}