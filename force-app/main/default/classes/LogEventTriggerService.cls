// Test: LogEventTriggerTest
public class LogEventTriggerService {

    public static void createLogs(List<LogEvent__e> logEvents) {
        System.debug('LogEventTriggerService.createLogs...');
        List<Log__c> logs = new List<Log__c>();

        for (LogEvent__e logEvent_i : logEvents) {
            logs.add(
                new Log__c(
                    Class__c = logEvent_i.Class__c,
                    Message__c = logEvent_i.Message__c,
                    Method__c = logEvent_i.Method__c,
                    RecordId__c = logEvent_i.RecordId__c,
                    UserId__c = logEvent_i.UserId__c
                )
            );
        }
        System.debug('logs: size: ' + logs.size() + ' value: ' + logs);

        insert logs;
    }
}