// Test for: LC_CaseDoctorArrangement
// Created: Evgeniy Kravchuk
// Date: 15.01.2020
@isTest
public class LC_CaseDoctorArrangementTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert new ENV__c(Env_value__c = 'QA');
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Arrangements__c arrangement = TestDataFactory.getArrangements(pFactor.Id);
        insert arrangement;
        Doctor_Arrangement__c docArrangement = TestDataFactory.getDocArrangement(doctor.Id, arrangement.Id);
        insert docArrangement;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.Doctor_Arrangement__c = docArrangement.Id;
        cas.Recommended_doc__c = doctor.Id;
        insert cas;
        Opportunity oppt = TestDataFactory.getOpportunity();
        oppt.Doctor_Arrangement__c = docArrangement.Id;
        oppt.Recommended_doc__c = doctor.Id;
        insert oppt;
    }

    @isTest
    static void obtainDoctorArrangementsCaseTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainDoctorArrangements', 'recordId' => cas.Id, 'doctorArrangementName' => 'test'});
        Test.stopTest();
    }

    @isTest
    static void obtainDoctorArrangementsOpptTest() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainDoctorArrangements', 'recordId' => oppt.Id, 'doctorArrangementName' => 'test'});
        Test.stopTest();
    }

    @isTest
    static void setDoctorArrangementCaseTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Doctor_Arrangement__c docArrangement = [SELECT Id FROM Doctor_Arrangement__c LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setDoctorArrangement', 'recordId' => cas.Id, 'doctorArrangementId' => docArrangement.Id});
        Test.stopTest();
    }

    @isTest
    static void setDoctorArrangementOpptTest() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];
        Doctor_Arrangement__c docArrangement = [SELECT Id FROM Doctor_Arrangement__c LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setDoctorArrangement', 'recordId' => oppt.Id, 'doctorArrangementId' => docArrangement.Id});
        Test.stopTest();
    }

    @isTest
    static void getDoctorArrangementCaseTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getDoctorArrangement', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void getDoctorArrangementOpptTest() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getDoctorArrangement', 'recordId' => oppt.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_CaseDoctorArrangement controller = new LC_CaseDoctorArrangement();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}