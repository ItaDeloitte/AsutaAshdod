@isTest
public class displayHistoricCallsTest {

    @testSetup
    static void makeData() {
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
    }

    @isTest
    static void displayHistory() {
		List<Account> getIdNumber = [SELECT Id, ID_Number__c FROM Account LIMIT 1];
        Test.startTest();
        for (Account acc: getIdNumber) {
            displayHistoricCalls.checkHistoricCalls(acc.Id);
        }
        Test.stopTest();
    }
}