// Test for: LC_CasePatientAccount
// Created: Ortal kazum
// Date: 19.01.2021
@isTest
public class LC_CasePatientAccountTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Phone = '0527987458';
        patient.PersonEmail = 'test@assuta.co.il';
        insert patient;
        
        
        
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.sched_sys_doc_clinics__c = 'RIS';
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
     	Payer_Factor__c pFactorParent = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactorParent;
        Payer_Factor__c pFactorChild1 = TestDataFactory.getPFactor('12345');
        pFactorChild1.Name_of_parent__c = pFactorParent.Id;
        insert pFactorChild1;        
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild1.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        cas.SuppliedEmail = 'test@assuta.co.il';
        insert cas;
    }

    @isTest
    static void obtainAccounts_Test() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        LC_CasePatientAccount controller = new LC_CasePatientAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void obtainAccounts_SuppliedEmail_Test() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        cas.SuppliedEmail = null;
        update cas;

        Test.startTest();
        LC_CasePatientAccount controller = new LC_CasePatientAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void setAccountTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        LC_CasePatientAccount controller = new LC_CasePatientAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setAccount', 'caseId' => cas.Id, 'accountId' => acct.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_Test() {
        Test.setFixedSearchResults(new List<Id>{[SELECT Id FROM Account LIMIT 1].Id});
        Case cas = [SELECT Id FROM Case LIMIT 1];
      
        Test.startTest();
        LC_CasePatientAccount controller = new LC_CasePatientAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_NoAccounts_Test() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        LC_CasePatientAccount controller = new LC_CasePatientAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'caseId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_CasePatientAccount controller = new LC_CasePatientAccount();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}