@isTest
private class DoctorSummaryReportBatchTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Dont_Send_Monthly_Summary__c = false;
        doctor.Doctor_marketing_email__c = 'test@test.com';
        doctor.Experts_Center__c = true;
        doctor.Status__c = 'פ';
        insert doctor;
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(new DoctorSummaryReportBatch([SELECT Id FROM Account LIMIT 1].Id));
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job Doctor Summary Report', '20 30 8 10 2 ?', new DoctorSummaryReportBatch());
        Test.stopTest();
    }
}