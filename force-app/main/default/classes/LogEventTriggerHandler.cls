// Test: LogEventTriggerTest
public class LogEventTriggerHandler {

    public static void handleTrigger(List<LogEvent__e> newList, Map<Id, LogEvent__e> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('LogEventTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                LogEventTriggerDispatcher.createLogs(newList);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}