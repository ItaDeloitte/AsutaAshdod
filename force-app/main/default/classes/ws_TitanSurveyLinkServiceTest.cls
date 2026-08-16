@IsTest
public with sharing class ws_TitanSurveyLinkServiceTest {

    @TestSetup
    static void setupData() {
        Form_Titan_Domain__c cs = new Form_Titan_Domain__c(
            Domain__c = 'test.formtitan.com'
        );
        insert cs;

        Survey__c survey = new Survey__c(
            Name = 'Test Survey',
            titan_project_id__c = 'PROJECT123',
            titan_token_expiration_time__c = '60',
            formtitan_salt__c = 'ps',
            formtitan_param__c = 't'
        );
        insert survey;

        SurveyTaker__c st = new SurveyTaker__c(
            Survey__c = survey.Id
        );
        insert st;
    }

    @IsTest
    static void testGetSurveyLink_Success() {
        // Mock callout
        Test.setMock(HttpCalloutMock.class, new TitanSuccessMock());        // Get SurveyTaker
        SurveyTaker__c st = [
            SELECT Id FROM SurveyTaker__c LIMIT 1
        ];

        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/titan/getSurveyLink';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"surveyTaker":"' + st.Id + '"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String response = ws_TitanSurveyLinkService.getSurveyLink();
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assert(
            response.contains('TEST_TOKEN_123'),
            'Returned link should contain the token'
        );
    }

    @IsTest
    static void testMissingSurveyTaker() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/titan/getSurveyLink';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String response = ws_TitanSurveyLinkService.getSurveyLink();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(response.contains('Missing surveyTaker'));
    }

    @IsTest
    static void testInvalidJson() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/titan/getSurveyLink';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{invalid json');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String response = ws_TitanSurveyLinkService.getSurveyLink();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(response.contains('Invalid JSON'));
    }

        private class TitanSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true, "data": {"token": "TEST_TOKEN_123"}}');
            return res;
        }
    }
}