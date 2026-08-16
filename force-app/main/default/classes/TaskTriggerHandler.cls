public class TaskTriggerHandler {
    public static void handleTrigger(List<Task> newList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                TaskTriggerDispatcher.populateLogFromUUI(newList);
                //TaskTriggerDispatcher.popCase(newList);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                TaskTriggerDispatcher.populateWaintingTime(newList);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                //Not needed due to standard connector functionality.
                //TaskTriggerDispatcher.calculateCallDuration(newList);
            }
            when else {
                System.debug('do nothing on other trigger events');
            }
        }
    }
}