@isTest
private class ConcurrentSessionsPolicyConditionTest {

    @isTest
    static void methodTest() {
        Test.startTest();
        Map<String, String> eventData = new Map<String, String>();
		eventData.put('NumberOfRecords', '19');
        eventData.put('ExecutionTime', '1');
        eventData.put('EntityName', 'Lead');
        TxnSecurity.Event e = new TxnSecurity.Event(
            UserInfo.getOrganizationId(),
            UserInfo.getUserId(),
            'Lead',
            'DataExport',
            'Lead',
            null,
            Datetime.newInstance(2017, 5, 23),
            eventData);
        ConcurrentSessionsPolicyCondition controller = new ConcurrentSessionsPolicyCondition();
        controller.evaluate(e);
        Test.stopTest();
    }
}