@isTest
private class LogSettingServiceTest {

    @isTest
    static void prepareLogTest() {
        Test.startTest();
        LogSettingService instance = LogSettingService.getInstance();
        try {
            insert new Account();
        } catch (Exception e) {
            instance.prepareLog('className', e);
            instance.prepareLog('className', 'methodName', e, 'recordId');
        }
        instance.prepareLog('className', 'methodName', 'recordId');
        instance.prepareLog('className', 'methodName', 'recordId', 'requestJson', 'responseJson');
        instance.prepareLog('className', 'methodName', 'requestJson', 'responseJson');
        Test.stopTest();
    }
}