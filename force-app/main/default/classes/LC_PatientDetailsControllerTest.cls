// Test for: LC_PatientDetailsController
@isTest
private class LC_PatientDetailsControllerTest {

    @testSetup
    static void makeData() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.ID_Type__c = '1';
        patient.Asthma__c = 'כן';
        patient.Metals_in_body__c = 'רסיסים';
        patient.Iodine_sensitivity__c = 'Mild';
        patient.Diabetic__c = 'כן';
        patient.Dust__c = 'Severe';
        patient.Blood_Dilution__c = 'לא';
        patient.Weight__c = 'בין 140 ל-200';
        patient.Gender__c = 'נ';
        insert patient;
    }
   
    @isTest
    static void getSetPatientDetailsTest() {
        Account acc = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Test.startTest();
        LC_PatientDetailsController controller = new LC_PatientDetailsController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getPatientDetails', 'patientId' => acc.ID_Number__c, 'idType' => acc.ID_Type__c}
        );
        Response setRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setPatientDetails', 'patientId' => acc.ID_Number__c, 'idType' => acc.ID_Type__c, 'sensitivitiesData' => 
            new Map<Object, Object>{'asthma' => 'לא', 'metalsInBody' => 'מתכות', 'iodineSensitivity' => 'כן', 'diabetic' => 'לא', 'dust' => 'לא', 'bloodDilution' => 'כן', 'weight' => 'מעל 200', 'gender' => 'ז'}}
        );
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_PatientDetailsController controller = new LC_PatientDetailsController();
        try {controller.executeAction(new Map<String, Object>{'actionName' => 'wrong'});} catch (Exception e) {}
        Test.stopTest();
    }
}