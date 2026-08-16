@isTest
private class ShowDocFromPortalTest {

    @isTest
    static void methodTest() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Case cas = new Case();
        insert cas;
        File__c fileCase = new File__c(Case__c = cas.Id, URL__c = 'url');
        insert fileCase;
        ShowDocFromPortal controller1 = new ShowDocFromPortal(new ApexPages.StandardController(fileCase));
        File__c fileAcct = new File__c(Account__c = patient.Id, URL__c = 'url');
        insert fileAcct;
        ShowDocFromPortal controller2 = new ShowDocFromPortal(new ApexPages.StandardController(fileAcct));
    }

    @isTest
    static void getPDFTest() {
        Test.startTest();
        ShowDocFromPortal.getPDF('url', 'idNumber');
        Test.stopTest();
    }
}