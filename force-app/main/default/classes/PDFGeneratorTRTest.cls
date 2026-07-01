@isTest
private class PDFGeneratorTRTest {
	
    @testSetup
    static void setup() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
    }
    
    @isTest
    static void createPDFTest() {        
        Test.startTest(); 
        Account patient = [SELECT Id FROM ACCOUNT];
        EventBus.publish(
            new PDFGenerator__e(
                RecordId__c = patient.Id               
            )
        );
        Test.stopTest();
    }
}