// Test for: DisabilityServices, DisabilityTriggerHandler, DisabilityTriggerDispatcher

@isTest
private class DisabilityServicesTest {

    @testSetup
    static void setup() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        insert new List<Disabilities__c>{
            TestDataFactory.getDisability(patient.Id, '70; 80'),
            TestDataFactory.getDisability(patient.Id, '70; 90'),
            TestDataFactory.getDisability(patient.Id, '100')
        };
    }
    
    @isTest 
    static void disabilityTriggerTest() { 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Test.setMock(WebServiceMock.class, new CreatePatientMock());
        Disabilities__c  disability = [SELECT Id, Permanency__c FROM Disabilities__c Limit 1];
        disability.Permanency__c = 'P';
        update disability;
        delete disability;
        Test.stopTest();        
    }
}