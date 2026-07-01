@isTest
private class LC_PreSaleTest {

    @TestSetup
    static void makeData() {
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Opportunity oppt = new Opportunity(
            Name = 'Test Oppt',
            CloseDate = System.today(),
            Recommended_doc__c = doctor.Id,
            StageName = 'Waiting for patient',
            StageStatus__c = 'availability');
        insert oppt;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor();
        insert pFactor;
        Arrangements__c arrangement = TestDataFactory.getArrangements(pFactor.Id);
        insert arrangement;
        insert TestDataFactory.getDocArrangement(doctor.Id, arrangement.Id);
    }

    @isTest
    static void exceptionTest() {
        LC_PreSaleController controller = new LC_PreSaleController();

        Test.startTest();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void createCaseTest() {
        LC_PreSaleController controller = new LC_PreSaleController();
        Doctor_Arrangement__c docArrangement = [SELECT Id FROM Doctor_Arrangement__c LIMIT 1];
        Opportunity oppt = [SELECT Id, Doctor_Arrangement__c FROM Opportunity LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'createCase', 'opptId' => oppt.Id});
        oppt.Doctor_Arrangement__c = docArrangement.Id;
        update oppt;
        controller.executeAction(new Map<String, Object>{'actionName' => 'createCase', 'opptId' => oppt.Id});
        Test.stopTest();
    }
}