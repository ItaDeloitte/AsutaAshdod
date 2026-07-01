@isTest
public with sharing class ws_GetCampaigns_REST_Test {

    @TestSetup
    static void setup() {
        insert TestDataFactory.getENV();
    }

    // Build a realistic 200 OK body (Status=Success)
    private static String successBody() {
        return JSON.serialize(new Map<String, Object>{
            'SessionId' => 'sess-123',
            'Status'    => 'Success',
            'Error'     => null,
            'Message'   => 'OK',
            'Data'      => new Map<String, Object>{
                'FirstName' => 'Klara',
                'LastName'  => 'Chefetz',
                'Email'     => 'test@example.com',
                'Status'    => 'Active',
                'CampaignStatistics' => new Map<String, Object>{
                    'Sent' => '10', 'UniqueOpened' => '7', 'UnOpened' => '3',
                    'ClicksCount' => '5', 'ErrorCount' => '0', 'RemovedCount' => '0'
                },
                'Campaigns' => new List<Object>{
                    new Map<String, Object>{
                        'CampaignId' => 'cmp-001', 'CampaignName' => 'Welcome',
                        'FromEmail'  => 'agent@company.com', 'FromName' => 'Agent A',
                        'StatusId'   => '3', 'Status' => 'SENT',
                        'SendDate'   => '2025-01-01', 'Subject' => 'Hello',
                        'OpenCount'  => '2', 'UniqueOpenCount' => '2',
                        'OpeningDate'=> '2025-01-02', 'PreviewLink' => 'https://example/prev',
                        'ErrorType'  => null
                    }
                }
            }
        });
    }

    // Generic Http mock you can parametrize
    private class ParamHttpMock implements HttpCalloutMock {
        Integer code;
        String body;
        HttpRequest lastReq; // captured for assertions

        ParamHttpMock(Integer code, String body) {
            this.code = code; this.body = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            lastReq = req;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setHeader('Content-Type', 'application/json');
            if (body != null) res.setBody(body);
            return res;
        }
    }

    // Mock that throws to exercise catch block
    private class ThrowingMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a network/callout exception
            throw new CalloutException('Simulated callout failure');
        }
    }

    // --- Tests ---

    @IsTest
    static void getCampaigns_success_returnsMapWithData() {
        // Prepare request body (whatever your caller would pass)
        ws_GetCampaigns_REST.GetCampaignReportByReceipientsRequest req =
            new ws_GetCampaigns_REST.GetCampaignReportByReceipientsRequest();
        req.Email = 'test@example.com';
        req.IsIncludeSenderInfo = true;

        Test.setMock(HttpCalloutMock.class, new ParamHttpMock(200, successBody()));

        Test.startTest();
        ws_GetCampaigns_REST api = new ws_GetCampaigns_REST(JSON.serialize(req));
        Map<String, Object> result = api.getCampaigns();
        Test.stopTest();

        // Assert the controller parsed and mapped fields
        System.assertEquals('Success', (String)result.get('ResultStatus'));
        System.assertEquals('OK', (String)result.get('Message'));
        System.assert(result.containsKey('Data'), 'Data should be present on success');
        System.assertNotEquals(null, result.get('Data'));
    }

    @IsTest
    static void getCampaigns_non200_returnsMapWithoutData() {
        // 500 error with some body (ignored by method for mapping)
        Test.setMock(HttpCalloutMock.class, new ParamHttpMock(500, '{"Status":"Error","Message":"Internal"}'));

        Test.startTest();
        ws_GetCampaigns_REST api = new ws_GetCampaigns_REST('{"Email":"x@y.com","IsIncludeSenderInfo":true}');
        Map<String, Object> result = api.getCampaigns();
        Test.stopTest();

        // Should not throw; should *not* include Data
        System.assert(!result.containsKey('Data'), 'Data should not be returned on non-200');
        // It won’t set ResultStatus on non-200 (only logs), so just verify map exists
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void getCampaigns_exception_captured_putsMessage() {
        Test.setMock(HttpCalloutMock.class, new ThrowingMock());

        Test.startTest();
        ws_GetCampaigns_REST api = new ws_GetCampaigns_REST('{"Email":"boom@example.com","IsIncludeSenderInfo":true}');
        Map<String, Object> result = api.getCampaigns();
        Test.stopTest();

        System.assert(result.containsKey('message'), 'Exception message should be captured');
        System.assert(((String)result.get('message')).contains('Simulated callout failure'));
    }
}