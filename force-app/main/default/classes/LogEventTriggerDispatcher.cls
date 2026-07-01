// Test: LogEventTriggerTest
public class LogEventTriggerDispatcher {

/*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Create Log__c for each LogEvent__e record
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
    * @created          14-08-2020
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void createLogs(List<LogEvent__e> newList) {
        System.debug('LogEventTriggerDispatcher.createLogs...');
        List<LogEvent__e> logEvents = new List<LogEvent__e>();

        for (LogEvent__e logEvent_i : newList) {
            logEvents.add(logEvent_i);
        }
        System.debug('logEvents: size: ' + logEvents.size() + ' value: ' + logEvents);

        LogEventTriggerService.createLogs(logEvents);
    }
}