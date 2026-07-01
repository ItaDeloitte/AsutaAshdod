// Test: LogEventTriggerTest
trigger LogEventTrigger on LogEvent__e (after insert) {
    LogEventTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}