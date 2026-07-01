// Test for: LC_PatientEmailController
@isTest
private class LC_PatientEmailControllerTest {

    @testSetup
    static void makeData() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);      
        insert patient;
    }
   
    @isTest
    static void setPatientEmailTest() {
        Account acc = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Test.startTest();
        LC_PatientEmailController controller = new LC_PatientEmailController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setPatientEmail', 'patientId' => acc.ID_Number__c, 'idType' => acc.ID_Type__c, 'email' => TestDataFactory.KEYWORD + 'email@gmail.com'}
        );
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_PatientEmailController controller = new LC_PatientEmailController();
        try {controller.executeAction(new Map<String, Object>{'actionName' => 'wrong'});} catch (Exception e) {}
        Test.stopTest();
    }
}