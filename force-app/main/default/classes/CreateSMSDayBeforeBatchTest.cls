@isTest
private class CreateSMSDayBeforeBatchTest {

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
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new CreateSMSDayBeforeBatch(
                'SELECT Id'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', Remainder_type__c'
                      + ', AppointmentTime__c'
                      + ', Appointment_Date_Time__c'
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
                      + ', Site__r.Site_Code__c'
                      + ', Clinic__r.Name'                       
                      + ', Calendar__c'                      
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.ID_Number__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Medical_Procedure__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'
                      + ', Medical_Procedure__r.Domain__c'
                      + ', Medical_Procedure__r.Domain__r.DomainCode__c'
                      + ', Medical_Procedure__r.Telemedicine_Action__c'
                      + ', Domain__c'
                      + ', Domain__r.DomainCode__c'
                  + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test'); 
        Test.startTest();
        System.schedule('Test Job SMS Day Before', '20 30 8 10 2 ?', new CreateSMSDayBeforeBatch());
        Test.stopTest();
    }
}