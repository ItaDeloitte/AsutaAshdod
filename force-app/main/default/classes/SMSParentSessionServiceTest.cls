// Test for  SMSParentSessionTriggerHandler, SMSParentSessionTrigerrDispatcher; SMSParentSessionService
@isTest
public class SMSParentSessionServiceTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        insert TestDataFactory.getContact(doctor.Id);
    }

    @isTest
    static void runJobTest() {
        Test.setMock(HttpCalloutMock.class, new HttpGoodMock());
        SMS_Parent_Session__c session = new SMS_Parent_Session__c();
        session.Last_Session_Activity__c = Datetime.now();
        session.Session_ended__c = true;
        session.Name = 'Test';
        
        Test.startTest();
        insert session;
        System.enqueueJob(new LiveAgentChatQueueable([SELECT Id, Last_Session_Activity__c, Phone__c FROM SMS_Parent_Session__c WHERE Id =: session.Id]));
        Test.stopTest();
    }

    private class HttpGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"key": "5961f1f1-17f9-43d7-93dc-0dc4ca843aad!1568903823676!PcF7nDpUQ1nEWQivHbpiNszqdWI=","id": "5961f1f1-17f9-43d7-93dc-0dc4ca843aad","clientPollTimeout": 40,"affinityToken": "96631fa0"}');
            response.setStatusCode(200);
            return response;
        }
    }
}