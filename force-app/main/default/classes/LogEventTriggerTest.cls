@isTest
private class LogEventTriggerTest {

    @isTest
    static void createLogsTest() {
        Id userId = UserInfo.getUserId();
        Test.startTest();
        EventBus.publish(
            new LogEvent__e(
                Class__c = 'LogEventTriggerTest',
                Message__c = 'Test LogEvent__e insertion',
                Method__c = 'createLogsTest',
                UserId__c = userId
            )
        );
        Test.stopTest();
    }
}