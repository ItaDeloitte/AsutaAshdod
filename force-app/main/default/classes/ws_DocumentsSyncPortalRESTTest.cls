@isTest
private class ws_DocumentsSyncPortalRESTTest {

    @isTest
    static void methodTest() {
        Test.setMock(HttpCalloutMock.class, new HttpGoodMock());
        Test.startTest();
        ws_DocumentsSyncPortalREST.portalGetPages('123456789', '1');
        ws_DocumentsSyncPortalREST.portalGetDocument('docPath', '1');
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