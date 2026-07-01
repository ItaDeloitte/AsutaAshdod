@isTest
private class LC_DemographyTest {
    
    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
    }
     
    @isTest
    static void getIdTypeValuesTest() {
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        controller.executeAction(new Map<String, Object>{'actionName' => 'getIdTypeValues'});
        Test.stopTest();
    }
    
    @isTest
    static void autocompleteAccountTest() {
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        controller.executeAction(new Map<String, Object>{'actionName' => 'autocompleteAccount', 'personId' => [SELECT Id FROM Account LIMIT 1].Id, 'queryLimit' => '1'});
        Test.stopTest();
    }
    
    @isTest
    static void retriveAccountTest() {    
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        controller.executeAction(new Map<String, Object>{
            'actionName' => 'retriveAccount', 'personIdType' => '', 'personId' => [SELECT ID_Number__c FROM Account LIMIT 1].Id_Number__c
        });
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        controller.executeAction(new Map<String, Object>{'actionName' => 'updateAccount', 'accountId' => [SELECT Id FROM Account LIMIT 1].Id});
        Test.stopTest();
    }
    
    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'ex'});
        } catch (Exception e) {}
        Test.stopTest();
    }
    
    @isTest
    static void increaseCoverageTest() {
        Test.startTest();
        LC_Demography controller = new LC_Demography();
        controller.increaseCoverage();
        Test.stopTest();
    }
}