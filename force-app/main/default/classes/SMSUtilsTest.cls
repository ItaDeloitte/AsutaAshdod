@isTest
private class SMSUtilsTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        insert TestDataFactory.getCalendars1(5);
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
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
        appt.sms_reminder_sent__c = true;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_status__c = 'אין מענה';
        appt.Appointment_Date_Time__c = Date.today().addDays(1);
        appt.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        insert appt;
        SmsTemplate__c smsTemp = TestDataFactory.getSmsTemplate();
        insert smsTemp;  
    }

    @isTest
    static void getBusinessDaysMapTest() {
        Test.startTest();
        SMSUtils.getBusinessDaysMap();
        Test.stopTest();
    }

    @isTest
    static void getDomainCodeTest() {
        Appointment__c appt = [
            SELECT Id
                 , Domain__c
                 , Domain__r.DomainCode__c
                 , Medical_Procedure__r.Domain__c
                 , Medical_Procedure__r.Domain__r.DomainCode__c
              FROM Appointment__c
             LIMIT 1];

        Test.startTest();
        SMSUtils.getDomainCode(appt);
        Test.stopTest();
    }

    @isTest
    static void prepareSMSTest() {
        String smsTemplate = [SELECT DeveloperName__c FROM SmsTemplate__c WHERE DeveloperName__c = 'new_appointment'].DeveloperName__c;
        Appointment__c appt = [
            SELECT Id
                 , doc_from_try__c
                 , link_memo_text__c
                 , AppointmentTime__c
                 , Formula_for_weekday_kit__c
                 , formtitan_arrival_link__c
                 , Site__c
                 , Site__r.Name
                 , Clinic__r.Name
                 , Case__c
                 , Case__r.SMS_Phone_Number__c
                 , RecordType.DeveloperName
                 , Patient_Account__r.FirstName
                 , Patient_Account__r.SMS_Phone_number__c
                 , Site__r.Site_Code__c
              FROM Appointment__c
             LIMIT 1];

        Test.startTest();
        SMSUtils.prepareSMS(appt, smsTemplate, true);
        Test.stopTest();
    }
}