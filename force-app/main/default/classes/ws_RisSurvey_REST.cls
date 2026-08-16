/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * GetIsAnswerdQuestionsList REST Apex class to get the answered questions per Appointment and Survey
 * 
 * Test                 ws_RisSurveyTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-08-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class ws_RisSurvey_REST {

    private static final ENV__c ENV = ENV__c.getInstance();
    private static final String NAMED_CREDENTIAL = 'callout:Ensemble_Rest_' + ENV.Env_value__c;
    private static final String REST_RESOURCE = '/SFQuestionnaire/GetIsAnswerdQuestionsList';
    private static final String ENDPOINT = NAMED_CREDENTIAL + REST_RESOURCE;

    public static GetSurveyFromRisResponse getSurveyFromRis(String accessionNumber, String surveyCode) {
        System.debug('ws_RisSurvey_REST.getSurveyFromRis ...');

        String reqBody = JSON.serialize(new GetSurveyFromRisRequest(accessionNumber, surveyCode));
        System.debug('ws_RisSurvey_REST.getSurveyFromRis Request: ' + reqBody);

        try {
            HttpResponse hRes = doGet(reqBody);
            System.debug('ws_RisSurvey_REST.getSurveyFromRis Status: ' + hRes.getStatus());
            System.debug('ws_RisSurvey_REST.getSurveyFromRis StatusCode: ' + hRes.getStatusCode());

            String resBody = hRes.getBody();
            System.debug('ws_RisSurvey_REST.getSurveyFromRis Response: ' + resBody);

            if (hRes.getStatusCode() == 200) {
                return (GetSurveyFromRisResponse) JSON.deserialize(resBody, GetSurveyFromRisResponse.class);
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to ' + REST_RESOURCE + ':' + e.getMessage());
        }

        return new GetSurveyFromRisResponse();
    }

    private static HttpResponse doGet(String body) {
        Http http = new Http();
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Content-Type', 'application/json');
        hReq.setEndpoint(ENDPOINT);
        hReq.setTimeout(2000);
        hReq.setMethod('GET');
        hReq.setBody(body);
        return http.send(hReq);
    }

    /** WRAPPERS */
    public class GetSurveyFromRisRequest {
        public String AccessionNumber;
        public String SurveyCode;

        public GetSurveyFromRisRequest(String accessionNumber, String surveyCode) {
            this.AccessionNumber = accessionNumber;
            this.SurveyCode = surveyCode;
        }
    }

    public class GetSurveyFromRisResponse {
        public String Success;
        public String ErrorMessage;
        public List<QuestionStatus> ListOfQuestionStatus;
    }

    public class QuestionStatus {
        public String QuestionName;
        public Boolean IsQuestionAnswered;
    }

    /** MOCK */
    global class ws_RisSurvey_RESTHttpMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            GetSurveyFromRisResponse mock = new GetSurveyFromRisResponse();
            mock.Success = '1';
            mock.ListOfQuestionStatus = new List<QuestionStatus>{new QuestionStatus()};
            mock.ListOfQuestionStatus.get(0).IsQuestionAnswered = true;
            mock.ListOfQuestionStatus.get(0).QuestionName = 'QuestionName';

            HttpResponse hRes = new HttpResponse();
            hRes.setHeader('Content-Type', 'application/json');
            hRes.setBody(JSON.serialize(mock));
            hRes.setStatusCode(200);
            return hRes;
        }
    }
}