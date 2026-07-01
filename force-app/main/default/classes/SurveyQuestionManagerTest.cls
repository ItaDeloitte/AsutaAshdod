@isTest
public with sharing class SurveyQuestionManagerTest {
    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Account patient = TestDataFactory.getAccountPerson();
        insert patient;

        Survey__c survey = new Survey__c(SurveyCode__c = 'test');
        insert survey;

        SurveyTaker__c taker = new SurveyTaker__c(
            RecordTypeId = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName().get('Digital_Forms').getRecordTypeId(),
            Account__c = patient.Id,
            Survey__c = survey.Id,
            Doctor__c = doctor.Id,
            IsProcessed__c = true,
            Status__c = 'active',
            Taken__c = 'true');
        insert taker;

        Survey_Question__c heQuestion = new Survey_Question__c(
            Survey__c = survey.Id,
            Type__c = 'DropDown',
            OrderNumber__c = 1,
            Question__c = 'he',
            Name = 'he');
        insert heQuestion;
        Survey_Question__c enQuestion = new Survey_Question__c(
            Survey__c = survey.Id,
            Type__c = 'DropDown',
            OrderNumber__c = 1,
            Question__c = 'en',
            Name = 'en');
        insert enQuestion;

        insert new List<SurveyQuestionResponse__c>{
            new SurveyQuestionResponse__c(SurveyTaker__c = taker.Id, Survey_Question__c = heQuestion.Id),
            new SurveyQuestionResponse__c(SurveyTaker__c = taker.Id, Survey_Question__c = enQuestion.Id)};
    }

    @isTest
    public static void getSQRsByTakerIdTest() {
        SurveyQuestionManager.RequestWrp reqWrp = new SurveyQuestionManager.RequestWrp();
        SurveyTaker__c taker = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        reqWrp.operationType = 'getSQRsByTakerId';
        reqWrp.takerId = taker.Id;
        RestRequest request = new RestRequest();
        request.requestURI = '/SurveyQuestions/test';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrp));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        SurveyQuestionManager.post();
        Test.stopTest();
    }
    
    @isTest
    public static void updateSQRsTest() {
        SurveyQuestionManager.RequestWrp reqWrp = new SurveyQuestionManager.RequestWrp();
        List<SurveyQuestionManager.SQRWrp> payload = new List<SurveyQuestionManager.SQRWrp>();
        List<SurveyQuestionResponse__c> surveyQuestionResponseList = [SELECT Page__c
                                                                           , Order__c
                                                                           , UnShow__c
                                                                           , Response__c
                                                                           , Response_2__c
                                                                           , Response_3__c
                                                                           , Question_1__c
                                                                           , Question_2__c
                                                                           , Question_3__c
                                                                           , SurveyTaker__c
                                                                           , QuestionName__c
                                                                        FROM SurveyQuestionResponse__c];
        for (SurveyQuestionResponse__c sqr_i : surveyQuestionResponseList) {
            sqr_i.Response_2__c = '123';
            payload.add(new SurveyQuestionManager.SQRWrp(sqr_i));
        }
        reqWrp.operationType = 'updateSQRs';
        reqWrp.payload = payload;
        RestRequest request = new RestRequest();
        request.requestURI = '/SurveyQuestions/test';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrp));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        SurveyQuestionManager.post();
        Test.stopTest();
    }
    
    @isTest
    public static void updateSQRsFinishTest() {
        SurveyQuestionManager.RequestWrp reqWrp = new SurveyQuestionManager.RequestWrp();
        List<SurveyQuestionManager.SQRWrp> payload = new List<SurveyQuestionManager.SQRWrp>();
        List<SurveyQuestionResponse__c> surveyQuestionResponseList = [SELECT Page__c
                                                                           , Order__c
                                                                           , UnShow__c
                                                                           , Response__c
                                                                           , Response_2__c
                                                                           , Response_3__c
                                                                           , Question_1__c
                                                                           , Question_2__c
                                                                           , Question_3__c
                                                                           , SurveyTaker__c
                                                                           , QuestionName__c
                                                                        FROM SurveyQuestionResponse__c];
        for (SurveyQuestionResponse__c sqr_i : surveyQuestionResponseList) {
            sqr_i.Response_2__c = '123';
            payload.add(new SurveyQuestionManager.SQRWrp(sqr_i));
        }
        reqWrp.operationType = 'updateSQRsFinish';
        reqWrp.payload = payload;
        RestRequest request = new RestRequest();
        request.requestURI = '/SurveyQuestions/test';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrp));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        SurveyQuestionManager.post();
        Test.stopTest();
    }
}