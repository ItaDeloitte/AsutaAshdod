// Test for: LC_CaseAgreement
// Created: Evgeniy Kravchuk
// Date: 15.01.2020
@isTest
public class LC_CaseAgreementTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
        Account acct = new Account(Name = 'test account', ID_Number__c = '123456789', RoleCode__c = 15);
        insert acct;
        
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Agreement__c agreement = TestDataFactory.getAgreement(acct.Id, pFactor.Id);
        insert agreement;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(acct.Id, patient.Id, con.Id, pFactor.Id);
        cas.Agreement__c = agreement.Id;
        cas.Channel__c = 'קופה';
        insert cas;
        Opportunity oppt = TestDataFactory.getOpportunity();
        oppt.Agreement__c = agreement.Id;
        oppt.Channel__c = 'קופה';
        insert oppt;
    }

    @isTest
    static void obtainAgreementsCaseTest() {
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => [SELECT Id FROM Case LIMIT 1].Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void obtainAgreementsOpptTest() {
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => [SELECT Id FROM Opportunity LIMIT 1].Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void obtainAgreementsNoPFactorCaseTest() {
        Case cas = [SELECT Id, PayerFactor__c FROM Case LIMIT 1];
        cas.PayerFactor__c = null;
        update cas;
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => cas.Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void obtainAgreementsNoPFactorOpptTest() {
        Opportunity oppt = [SELECT Id, PayerFactor__c FROM Opportunity LIMIT 1];
        oppt.PayerFactor__c = null;
        update oppt;
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => oppt.Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void obtainAgreementsRecommendedDocCaseTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        doctor.sched_sys_doc_clinics__c = 'QFlow';
        update doctor;
        Case cas = [SELECT Id, Recommended_doc__c FROM Case LIMIT 1];
        cas.Recommended_doc__c = doctor.Id;
        update cas;
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => cas.Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void obtainAgreementsRecommendedDocOpptTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        doctor.sched_sys_doc_clinics__c = 'QFlow';
        update doctor;
        Opportunity oppt = [SELECT Id, Recommended_doc__c FROM Opportunity LIMIT 1];
        oppt.Recommended_doc__c = doctor.Id;
        update oppt;
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res1 = controller.executeAction(
            new Map<String, Object>{'recordId' => oppt.Id, 'actionName' => 'obtainAgreements', 'agreementName' => 'test'}
        );
        Test.stopTest();
    }

    @isTest
    static void setAgreementCaseTest() {
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setAgreement', 'recordId' => [SELECT Id FROM Case LIMIT 1].Id, 'agreementId' => [SELECT Id FROM Agreement__c LIMIT 1].Id}
        );
        Test.stopTest();
    }

    @isTest
    static void setAgreementOpptTest() {
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setAgreement', 'recordId' => [SELECT Id FROM Opportunity LIMIT 1].Id, 'agreementId' => [SELECT Id FROM Agreement__c LIMIT 1].Id}
        );
        Test.stopTest();
    }

    @isTest
    static void getAgreementTest() {
        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAgreement', 'recordId' => [SELECT Id FROM Case LIMIT 1].Id});
        Test.stopTest();
    }
    
    @isTest
    static void getAgreementChannelSameTest() {
        Account doctor = [SELECT Id FROM Account WHERE sched_sys_doc_clinics__c != null LIMIT 1];
		Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c =: TestDataFactory.PFACTOR_CODE LIMIT 1];
        insert new Agreement__c(Name = 'sameAgreement', Doctor_Account__c = doctor.Id, PayerFactor__c = pFactor.Id);
        Case cas = [SELECT Id, Agreement__c FROM Case LIMIT 1];
        cas.Recommended_doc__c = doctor.Id;
        cas.Agreement__c = null;
        update cas;

        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAgreement', 'recordId' => cas.Id});
        Test.stopTest();
    }
    
    @isTest
    static void getAgreementChannelParentTest() {
        Account doctor = [SELECT Id FROM Account WHERE sched_sys_doc_clinics__c != null LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c =: TestDataFactory.PFACTOR_CODE LIMIT 1];
        Payer_Factor__c parentPF = new Payer_Factor__c(Name = 'parentPF', InsuranceCode__c = '0', Name_of_parent__c = pFactor.Id);
        insert parentPF;
        insert new Agreement__c(Name = 'parentAgreement', Doctor_Account__c = doctor.Id, PayerFactor__c = parentPF.Id);
        Case cas = [SELECT Id, Agreement__c FROM Case LIMIT 1];
        cas.Recommended_doc__c = doctor.Id;
        cas.Agreement__c = null;
        update cas;

        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAgreement', 'recordId' => cas.Id});
        Test.stopTest();
    }
    
    @isTest
    static void getAgreementChannelZeroTest() {
        Account doctor = [SELECT Id FROM Account WHERE sched_sys_doc_clinics__c != null LIMIT 1];
        Payer_Factor__c zeroPF = new Payer_Factor__c(Name = 'zeroPF', InsuranceCode__c = '0');
        insert zeroPF;
        insert new Agreement__c(Name = 'zeroAgreement', Doctor_Account__c = doctor.Id, PayerFactor__c = zeroPF.Id);
        Case cas = [SELECT Id, Agreement__c FROM Case LIMIT 1];
        cas.Recommended_doc__c = doctor.Id;
        cas.Agreement__c = null;
        update cas;

        Test.startTest();
        LC_CaseAgreement controller = new LC_CaseAgreement();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAgreement', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_CaseAgreement controller = new LC_CaseAgreement();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}