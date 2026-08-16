// Test for: UpdateLeadInQueueBatch
@isTest
private class UpdateLeadInQueueBatchTest {
	
    @testSetup
    private static void testSetup() {
        insert TestDataFactory.getLead();
    }
    
    @isTest
    private static void schedulerTest() {
        Test.startTest();
        Datetime workTime = System.now().addMinutes(1);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour() + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
        System.debug('CRONEXP ' + CRONEXP);
        System.schedule('UpdateLeadInQueueBatch Scheduler Test', CRONEXP, new UpdateLeadInQueueBatch());
        Test.stopTest();
    }
}