/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Apex Trigger Test class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             18-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class SurveyQuestionResponseTRTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Account patient = TestDataFactory.getAccountPerson();
        patient.Preferred_Language_Service__c = '2';
        insert patient;

        Survey__c survey = new Survey__c(SurveyCode__c = 'PreSurgery');
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
        
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        domain.DomainReminderCode__c = '12345';
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure.Reminder_required__c = true;
        procedure.SMS_Reminder__c = '1';
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.ReminderId__c = '12345';
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Code_Tizkurit__c = '12345';
        insert site;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_status__c = 'אין מענה';
        appt.Remainder_time__c = Date.today();
        appt.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt.Date_for_tizkorit_reminder__c = Date.today();
        appt.Date_for_human_reminder__c = Date.today();
        appt.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        insert appt;
    }

    @isTest
    static void mirrorPercentageTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        SurveyTaker__c taker = [SELECT Id, Appointment__c FROM SurveyTaker__c LIMIT 1];
        taker.Appointment__c = appt.Id;
        update taker;

        SurveyQuestionResponse__c enResponse = [SELECT Response__c FROM SurveyQuestionResponse__c LIMIT 1];
        enResponse.Response__c = 'Yes';
        Test.startTest();
        update enResponse;
        Test.stopTest();
    }
}