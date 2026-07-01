@isTest
public with sharing class SurveyTakenTriggerTest {

    @isTest
    public static void populateUUIDTest(){
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Account patient = TestDataFactory.getAccountPerson();
        patient.Preferred_Language_Service__c = '2';
        insert patient;

        Survey__c survey = new Survey__c(SurveyCode__c = 'PreSurgery', SendByWA__c = true);
        insert survey;

        List<Survey_Question__c> questions = new List<Survey_Question__c>();
        for (Integer i = 0; i < 3; i++) {
            questions.add(new Survey_Question__c(
                OrderNumber__c = 2,
                Question__c = 'Question' + i,
                Type__c = 'RadioButton',
                Survey__c = survey.Id,
                UnShow__c = false,
                IsForAvg__c = true,
                status_question__c = true  
            ));
        }
        insert questions;

        SurveyTaker__c taker = new SurveyTaker__c(
            RecordTypeId = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName().get('Digital_Forms').getRecordTypeId(),
            Account__c = patient.Id,
            Survey__c = survey.Id,
            Doctor__c = doctor.Id,
            IsProcessed__c = true,
            Status__c = 'active',
            Taken__c = 'true');
        insert taker;
        
        SurveyTaker__c surveyInserted = [SELECT Id, UUID__c FROM SurveyTaker__c];
        System.assert(surveyInserted.UUID__c != null);
    }
}