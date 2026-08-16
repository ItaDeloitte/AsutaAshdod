/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Advisor Grade Calculation Schedule Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             24-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class DocAdvisorGradeScheduleBatchTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();

        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Account patient = TestDataFactory.getAccountPerson();
        patient.PersonBirthdate = Date.valueOf('1990-10-10');
        insert patient;

        Survey__c survey = new Survey__c(SurveyCode__c = 'DocAdvisor');
        insert survey;

        SurveyTaker__c surveyTaker = new SurveyTaker__c(
            RecordTypeId = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName().get('Doc_Advisor').getRecordTypeId(),
            Account__c = patient.Id,
            Survey__c = survey.Id,
            Doctor__c = doctor.Id,
            Status__c = 'active',
            Taken__c = 'true');
        insert surveyTaker;

        List<Survey_Question__c> questions = new List<Survey_Question__c>();
        for (String questionType_i : new List<String>{'Courtesy', 'Availability', 'Professionalism', 'General_impression'}) {
            questions.add(new Survey_Question__c(Survey__c = survey.Id, Name = questionType_i, OrderNumber__c = 1, Question__c = 'question', Type__c = 'DropDown', Target__c = 'נשים'));
        }
        insert questions;

        List<SurveyQuestionResponse__c> grades = new List<SurveyQuestionResponse__c>();
        for (Survey_Question__c question_i : questions) {
            grades.add(new SurveyQuestionResponse__c(SurveyTaker__c = surveyTaker.Id, Survey_Question__c = question_i.Id, rate__c = 1));
        }
        insert grades;
    }

    @IsTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new DocAdvisorGradeScheduleBatch('SELECT Doctor__c FROM SurveyTaker__c LIMIT 1'));
        Test.stopTest();
    }
}