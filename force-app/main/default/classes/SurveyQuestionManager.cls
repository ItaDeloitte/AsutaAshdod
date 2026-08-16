@RestResource(urlMapping='/SurveyQuestions/*')
global with sharing class SurveyQuestionManager implements Queueable {

    private RequestWrp request;

    private SurveyQuestionManager(RequestWrp request) {
        this.request = request;
    }

    @HttpPost
    global static void post() {
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            System.debug('jsonBody: ' + jsonBody);

            if (String.isBlank(jsonBody)) {
                setResponse('No requestBody was provided.', 500);
                return;
            }

            RequestWrp request = (RequestWrp) JSON.deserialize(jsonBody, RequestWrp.class);
            System.debug('request: ' + request);

            switch on request.operationType {
                when 'getSQRsByTakerId' {
                    getSQRsByTakerId(request.takerId, request.pageNumber);
                }
                when 'updateSQRs' {
                    System.enqueueJob(new SurveyQuestionManager(request));
                    setResponse('{"status":"true"}', 200);
                }
                when 'updateSQRsFinish' {
                    updateSQRs(request);
                    setResponse('{"status":"true"}', 200);
                }
                when else {
                    setResponse('Not supported operationType.', 500);
                }
            }
        } catch (Exception e) {
            setResponse(e.getMessage(), 500);
        }
    }

    public void execute(QueueableContext context) {
        System.debug('SurveyQuestionManager.updateSQRs ...');
        updateSQRs(request);       
    }

    private static void getSQRsByTakerId(String takerId, String pageNumber) {
        System.debug('SurveyQuestionManager.getSQRsByTakerId ...');
        List<SQRWrp> sqrWrpList = new List<SQRWrp>();

        if (takerId == null) {
            setResponse('No takerId was provided.', 500);
            return;
        }

        String query = 'SELECT Page__c'
                        + ', Order__c'
                        + ', UnShow__c'
                        + ', Response__c'
                        + ', Response_2__c'
                        + ', Response_3__c'
                        + ', Question_1__c'
                        + ', Question_2__c'
                        + ', Question_3__c'
                        + ', SurveyTaker__c'
                        + ', QuestionName__c'
                    + ' FROM SurveyQuestionResponse__c'
                    + ' WHERE SurveyTaker__c = :takerId';

        if (pageNumber != null) {
            query += ' AND Page__c = :pageNumber';
        }

        for (SurveyQuestionResponse__c sqr_i : Database.query(query + ' ORDER BY Page__c, Order__c')) {
            sqrWrpList.add(new SQRWrp(sqr_i));
        }
        System.debug('sqrWrpList: size: ' + sqrWrpList.size() + ' value: ' + sqrWrpList);

        setResponse(JSON.serialize(sqrWrpList), 200);
    }

    private static void updateSQRs(RequestWrp request) {
        System.debug('SurveyQuestionManager.updateSQRs ...');
        List<SurveyQuestionResponse__c> sqrToUpdateList = new List<SurveyQuestionResponse__c>();

        for (SQRWrp sqrWrp_i : request.payload) {
            sqrToUpdateList.add(sqrWrp_i.toSObject());
        }
        System.debug('sqrToUpdateList: size: ' + sqrToUpdateList.size() + ' value: ' + sqrToUpdateList);

        AsyncUtil.doUpdate(sqrToUpdateList);
    }

    private static void setResponse(String payload, Integer code) {
        System.debug(code + ' ' + payload);
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(payload);
        RestContext.response.statusCode = code;
    }

    public class RequestWrp {
        public String operationType;
        public String takerId;
        public String pageNumber;
        public List<SQRWrp> payload;
    }

    public class SQRWrp {
        public String sqrId;
        public String takerId;
        public String questionName;
        public String question1;
        public String question2;
        public String question3;
        public String response1;
        public String response2;
        public String response3;
        public Boolean unshow;
        public Integer order;
        public String page;

        public SQRWrp(SurveyQuestionResponse__c sqr) {
            this.sqrId = sqr.Id;
            this.takerId = sqr.SurveyTaker__c;
            this.questionName = sqr.QuestionName__c;
            this.question1 = sqr.Question_1__c;
            this.question2 = sqr.Question_2__c;
            this.question3 = sqr.Question_3__c;
            this.response1 = sqr.Response__c;
            this.response2 = sqr.Response_2__c;
            this.response3 = sqr.Response_3__c;
            this.unshow = sqr.UnShow__c;
            this.order = Integer.valueOf(sqr.Order__c);
            this.page = sqr.Page__c;
        }

        public SurveyQuestionResponse__c toSObject() {
            return new SurveyQuestionResponse__c(
                Id = this.sqrId,
                Response__c = this.response1,
                Response_2__c = this.response2,
                Response_3__c = this.response3);
        }
    }
}