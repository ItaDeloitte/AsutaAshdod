@isTest
public with sharing class GetAccountDemographyTest {
    
    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);        
    }

    @isTest
    public static void getDemographyTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GetAccountDemography.RequestWrp reqWrp = new GetAccountDemography.RequestWrp();
        Account acc = [SELECT Id, ID_Number__c FROM Account LIMIT 1];
        reqWrp.idNumber = acc.ID_Number__c;        
        RestRequest request = new RestRequest();
        request.requestURI = '/AccountDemography/test';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrp));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        GetAccountDemography.post();
        Test.stopTest();
    }       
}