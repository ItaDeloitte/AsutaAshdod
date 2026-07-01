public class ReminderTriggerHandler {

    public static void handleTrigger(List<Reminder__c> newList, Map<Id, Reminder__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ReminderTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                ReminderTriggerDispatcher.receiveAnswer(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                ReminderTriggerDispatcher.receiveAnswer(newList, oldMap);
                ReminderTriggerDispatcher.updateReminderStatus(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}