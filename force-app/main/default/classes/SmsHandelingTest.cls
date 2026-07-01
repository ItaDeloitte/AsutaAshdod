// Created: Ortal kazum
// Date: 06.03.2022
// Test for: SmsHandeling
@isTest
public class SmsHandelingTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.Appointment_Date__c = Date.today();
    	insert appt;
        SmsTemplate__c smsApp = new SmsTemplate__c(
            developerName__c = 'new_appointment', 
            Sms_content__c = 'שלום רב, נקבע לך תור לבדיקה שתתקיים ב{0}. בתאריך {1}. יש להצטייד בת.ז. ', 
            apiNames__c = 'site__r.Name,day_date_hour__c', 
            ObjectName__c = 'Appointment__c'
        );
        insert smsApp;
    }

    @isTest
    static void createSmsContentTest() {
        SmsHandeling.SmsHandelingRequestWrapper wrapper = new SmsHandeling.SmsHandelingRequestWrapper();
        wrapper.smsTemplateId = [SELECT Id FROM SmsTemplate__c LIMIT 1].Id;
        wrapper.appointmentId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        Test.startTest();
        SmsHandeling.createSmsContent(new List<SmsHandeling.SmsHandelingRequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void createSmsContentExceptionTest() {
        SmsHandeling.SmsHandelingRequestWrapper wrapper = new SmsHandeling.SmsHandelingRequestWrapper();
        wrapper.appointmentId = '';

        Test.startTest();
        try {
            SmsHandeling.createSmsContent(new List<SmsHandeling.SmsHandelingRequestWrapper>{wrapper});
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void createSmsContentException2Test() {
        Test.startTest();
        try {
            SmsHandeling.createSmsContent(new List<SmsHandeling.SmsHandelingRequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }
}