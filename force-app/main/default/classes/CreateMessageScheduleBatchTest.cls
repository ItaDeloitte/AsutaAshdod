@isTest
public class CreateMessageScheduleBatchTest {
    @TestSetup
    static void makeData() {
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
        cas.preferd_chanal_case__c = 'Email';
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
        procedure.Confidentiality__c = false;
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.ReminderId__c = '12345';
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Code_Tizkurit__c = '12345';
        insert site;

        Account acc = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        acc.SMS_Phone_Number__c = '05-1234567';
        insert acc;

        Appointment__c appt1 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt1.Site__c = site.Id;
        appt1.PayerFactor__c = pFactor.Id;
        appt1.sms_reminder_sent__c = true;
        appt1.Accession_Number__c = 'Q12345';
        appt1.Remainder_status__c = 'אין מענה';
        appt1.Appointment_Date_Time__c = Date.today().addDays(3);
        appt1.appointment_hour__c = appt1.Appointment_Date_Time__c.time();
        appt1.Appointment_Status__c ='WaitingForAppointment';
        appt1.RecordTypeId = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Surgeries').getRecordTypeId();
        appt1.Patient_Mail__c = 'test@test.ua';
        // appt.sendingByWhatsApp__c = true;
        // appt.SendingMessage__c  = true;
        // appt.Patient_Account__C = acc.Id;

        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt2.RecordTypeId = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Surgeries').getRecordTypeId();
        appt2.Appointment_Status__c = 'NewAppointment';
        appt2.Appointment_Date_Time__c = Date.today().addDays(3);
        appt2.appointment_hour__c = appt1.Appointment_Date_Time__c.time();
        appt2.sendingByWhatsApp__c = true;
        appt2.SendingMessage__c  = true;
        appt2.Patient_Account__C = acc.Id;
        
        // Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        // appt2.Site__c = site.Id;
        // appt2.PayerFactor__c = pFactor.Id;
        // appt2.sms_reminder_sent__c = true;
        // appt2.Accession_Number__c = 'Q12345';
        // appt2.Remainder_status__c = 'אין מענה';
        // appt2.Appointment_Status__c = 'WaitingForAppointment';
        // appt2.appointment_hour__c = appt1.Appointment_Date_Time__c.time();
        // appt2.Appointment_Status__c ='WaitingForAppointment';
        // appt2.Patient_Mail__c = 'test@test.com';
       
        // appt2.sendingByWhatsApp__c = true;
        // appt2.SendingMessage__c  = true;
        // appt2.Patient_Account__C = acc.Id;
        // appt2.Appointment_Date_Time__c = Date.today().addDays(3);

        insert new List<Appointment__c>{appt1,appt2};

        List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Guidelines_for_hygiene'];
        if (emailTemplateList.isEmpty()) {
            insert new EmailTemplate(
                isActive = true,
                Name = 'name',
                DeveloperName = 'Guidelines_for_hygiene',
                TemplateType = 'text',
                Body = 'Test',
                Subject = 'Test',
                FolderId = UserInfo.getUserId()
            );
        }
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new CreateMessageScheduleBatch());
        Test.stopTest();
    }
}