@isTest
private class DeleteLogBatchTest {

    @TestSetup
    static void makeData() {
        Log__c log = new Log__c(UserId__c = UserInfo.getUserId(), Message__c = 'test');
        insert log;
        Test.setCreatedDate(log.Id, System.now().addMonths(-2));
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new DeleteLogBatch());
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        Test.startTest();
        System.schedule('Delete Log Test', '0 0 0 * * ?', new DeleteLogBatch());
        Test.stopTest();
    }
}