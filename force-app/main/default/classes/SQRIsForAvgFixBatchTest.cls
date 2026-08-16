/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Is For Avg Checkbox Filling Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             19-01-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class SQRIsForAvgFixBatchTest {

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

        SurveyTaker__c st = new SurveyTaker__c(
            RecordTypeId = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName().get('Doc_Advisor').getRecordTypeId(),
            Account__c = patient.Id,
            Survey__c = survey.Id,
            Doctor__c = doctor.Id,
            Status__c = 'active',
            Taken__c = 'true');
        insert st;

        Survey_Question__c sq = new Survey_Question__c(
            Survey__c = survey.Id,
            Name = 'Professionalism',
            Question__c = 'question',
            Type__c = 'DropDown',
            Target__c = 'נשים',
            OrderNumber__c = 1,
            IsForAvg__c = true);
        insert sq;

        SurveyQuestionResponse__c surveyQuestionResponse = new SurveyQuestionResponse__c(
            Survey_Question__c = sq.Id,
            SurveyTaker__c = st.Id,
            rate__c = 1);
        insert surveyQuestionResponse;
    }

    @IsTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new SQRIsForAvgFixBatch());
        Test.stopTest();
    }
}