@isTest
public class LC_CaseContactTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        Account doctor2 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor2.ID_Number__c = TestDataFactory.P_ID_NUMBER;
        insert new List<Account>{doctor1, doctor2};

        Contact con1 = TestDataFactory.getContact(doctor1.Id);
        Contact con2 = TestDataFactory.getContact(doctor1.Id);
        con2.ID_Number__c = '301301818';
        insert new List<Contact>{con1, con2};

        insert new List<AccountContactRelation>{
            new AccountContactRelation(AccountId = doctor2.Id, ContactId = con1.Id, title__c = 'מחמיר', status__c = 'מאושר'),
            new AccountContactRelation(AccountId = doctor2.Id, ContactId = con2.Id, title__c = 'מחמיר', status__c = 'מאושר')
        };

        insert new Case(AccountId = doctor2.Id, Case_subject__c = 'זימון רופא מומחה', ContactId = con1.Id);
    }

    @isTest
    static void obtainContactsTest() {
        Case cas = [SELECT Id, Case_subject__c FROM Case LIMIT 1];
        Map<String, Object> params = new Map<String, Object>{'actionName' => 'obtainContacts', 'caseId' => cas.Id, 'contactName' => 'test'};

        Test.startTest();
        LC_CaseContact controller = new LC_CaseContact();
        Response res1 = controller.executeAction(params);
        cas.Case_subject__c = 'עדכון תור קיים';
        update cas;
        Response res2 = controller.executeAction(params);
        cas.Case_subject__c = 'בירור תוצאות בדיקה';
        update cas;
        Response res3 = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void setContact() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Contact con = new Contact(AccountId = acct.Id, LastName = 'test contact', ID_Number__c = '1156');
        insert con;

        Test.startTest();
        LC_CaseContact controller = new LC_CaseContact();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setContact', 'caseId' => [SELECT Id FROM Case LIMIT 1].Id, 'contactId' => con.Id});
        Test.stopTest();
    }

    @isTest
    static void getContact() {
        Test.startTest();
        LC_CaseContact controller = new LC_CaseContact();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getContact', 'caseId' => [SELECT Id FROM Case LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_CaseContact controller = new LC_CaseContact();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}