// Test for: RemoveSyncToMCSchedulableBatch
@isTest
private class RemoveSyncToMCSchedulableBatchTest {
	
    @testSetup
    private static void testSetup() {
        Lead lead = TestDataFactory.getLead();
        lead.SyncToMC__c  = true;
        lead.SyncToMC_Off_After_180_Days__c = Date.today();
        insert lead;
    }
    
    @isTest
    private static void schedulerTest() {
        Test.startTest();
        Datetime workTime = System.now().addMinutes(1);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour() + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
        System.debug('CRONEXP ' + CRONEXP);
        System.schedule('RemoveSyncToMCSchedulableBatch Scheduler Test', CRONEXP, new RemoveSyncToMCSchedulableBatch());
        Test.stopTest();
    }
}