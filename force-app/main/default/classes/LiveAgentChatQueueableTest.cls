@isTest
private class LiveAgentChatQueueableTest {

    @isTest
    static void methodOneTest() {
        Test.setMock(HttpCalloutMock.class, new HttpGoodMock());
        SMS_Parent_Session__c smsParent = new SMS_Parent_Session__c();
        insert smsParent;
        SMS__c sms = new SMS__c(SMS_Parent_Session__c = smsParent.Id, Content__c = 'it\'s good 11:07');
        insert sms;
        LiveAgentChatUtil.SessionWrapper wrapper = new LiveAgentChatUtil.SessionWrapper();
        wrapper.key = 'key';
        wrapper.clientPollTimeout = 1;
        wrapper.affinityToken = 'affinityToken';
        wrapper.id = 'id';
        LiveAgentChatUtil.MessageWrapper message = new LiveAgentChatUtil.MessageWrapper();
        message.text = 'hello';
        message.name = 'name';
        message.agentId = 'agentId';
        LiveAgentChatUtil.IncommingMessageWrapper incMessage = new LiveAgentChatUtil.IncommingMessageWrapper();
        incMessage.type = 'ChatMessage';
        incMessage.message = message;
        Test.startTest();
        LiveAgentChatQueueable job = new LiveAgentChatQueueable(smsParent);
        System.enqueueJob(job);
        job.session = wrapper;
        System.enqueueJob(job);
        job.firstAgentResponse = incMessage;
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    private class HttpGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"messages":[{"type":"ChatMessage","message":{"text":"hello","name":"Anatoly","schedule":{"responseDelayMilliseconds":0.0},"agentId":"0058E000004B14r"}}],"sequence":6,"offset":49343374}');
            response.setStatusCode(200);
            return response; 
        }
    }
}