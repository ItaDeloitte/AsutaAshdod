@isTest
public class UpdateAccountQueueableTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
    }

    @isTest
    static void UpdateAccountQueueableTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account patient = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        System.enqueueJob(new UpdateAccountQueueable(new Set<Id>{patient.Id}));
        Test.stopTest();
    }
}