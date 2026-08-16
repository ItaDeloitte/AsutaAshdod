@isTest
public with sharing class GetCampaigns_LWCtrlTest {
// Mock for any HTTP call the ws_GetCampaigns_REST class performs.
    private class GetCampaignsHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You can assert on req.getEndpoint(), req.getMethod(), req.getBody() if you want
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            // Example payload the downstream class would return
            // (ws_GetCampaigns_REST should parse this into a Map<String,Object>)
            String body =
            '{' +
            '  "success": true,' +
            '  "total": 1,' +
            '  "campaigns": [' +
            '     {' +
            '       "id": "cmp-001",' +
            '       "name": "Welcome Series",' +
            '       "status": "SENT",' +
            '       "recipient": "test@example.com",' +
            '       "sender": {"name": "Agent A", "email": "agent@company.com"}' +
            '     }' +
            '  ]' +
            '}';
            res.setBody(body);
            return res;
        }
    }

    @IsTest
    static void getCampaigns_happyPath_returnsJsonString() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new GetCampaignsHttpMock());
        String email = 'test@example.com';

        Test.startTest();
        String jsonOut = GetCampaigns_LWCtrl.getCampaigns(email);
        Test.stopTest();

        System.assertNotEquals(null, jsonOut, 'Method should return a JSON string');

    }
}