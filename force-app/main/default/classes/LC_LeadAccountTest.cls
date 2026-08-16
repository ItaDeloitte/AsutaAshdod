// Test for: LC_LeadAccount
// Created: Ortal kazum
// Date: 19.01.2021
@isTest
public class LC_LeadAccountTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Phone = '0527987458';
        patient.PersonEmail = 'test@assuta.co.il';
        insert patient;
        Lead lead = TestDataFactory.getLead();
        lead.MobilePhone = '0527987458';
        insert lead;
    }

    @isTest
    static void obtainAccounts_Test() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LC_LeadAccount controller = new LC_LeadAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'leadId' => lead.Id});
        Test.stopTest();
    }

    @isTest
    static void obtainAccounts_NoMobilePhone_Test() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        lead.MobilePhone = null;
        lead.Email = null;
        update lead;

        Test.startTest();
        LC_LeadAccount controller = new LC_LeadAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'leadId' => lead.Id});
        Test.stopTest();
    }

    @isTest
    static void setAccountTest() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        LC_LeadAccount controller = new LC_LeadAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setAccount', 'leadId' => lead.Id, 'accountId' => acct.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_Test() {
        Test.setFixedSearchResults(new List<Id>{[SELECT Id FROM Account LIMIT 1].Id});
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
      
        Test.startTest();
        LC_LeadAccount controller = new LC_LeadAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'leadId' => lead.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_NoAccounts_Test() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LC_LeadAccount controller = new LC_LeadAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'leadId' => lead.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_LeadAccount controller = new LC_LeadAccount();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}