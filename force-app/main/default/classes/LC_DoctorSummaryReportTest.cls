@isTest
private class LC_DoctorSummaryReportTest {

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
    static void exceptionTest() {
        LC_DoctorSummaryReportController controller = new LC_DoctorSummaryReportController();
        Test.startTest();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void reportButtonAvailableTest() {
        LC_DoctorSummaryReportController controller = new LC_DoctorSummaryReportController();
        Account doctor = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'reportButtonAvailable', 'doctorId' => doctor.Id});
        Test.stopTest();
    }

    @isTest
    static void sendReportTest() {
        LC_DoctorSummaryReportController controller = new LC_DoctorSummaryReportController();
        Account doctor = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'sendReport', 'doctorId' => doctor.Id});
        Test.stopTest();
    }
}