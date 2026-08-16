@isTest
private class LC_SurgeriesAppointmentTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();

        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;

        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('CaseAfterSale', 'Case');
        insert cas;
        Opportunity oppt = TestDataFactory.getOpportunity();
        oppt.Case__c = cas.Id;
        insert oppt;
    }

    @IsTest
    static void isAvailableTest() {
        LC_SurgeriesAppointment controller = new LC_SurgeriesAppointment();
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'isAvailable', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void prepopulateFieldTest() {
        LC_SurgeriesAppointment controller = new LC_SurgeriesAppointment();
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'prepopulateField', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        LC_SurgeriesAppointment controller = new LC_SurgeriesAppointment();

        Test.startTest();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }
}