@isTest
public class WA_ExpertDoctorReminderScheduleTest {

    @testSetup 
    static void setupData() {   
        insert TestDataFactory.getCalendars1(5);
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Phone_ETL__c = '0501234567';
        doctor.PhoneToSendVoucher__c = '0529876543';
        doctor.Experts_center__c = true;
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);       
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);       
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);       
        procedure.Procedure_Code__c = '99400';
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);        
        calendar.Doctor__c = doctor.Id;
        insert calendar;
        Clinic__c clinic = TestDataFactory.getClinic();
        insert clinic;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Doctor_Account__c = doctor.Id;
        appt.Appointment_Date_Time__c = Datetime.now().addHours(2);       
        appt.Appointment_Type__c = 'Experts';
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Clinic__c = clinic.Id;
        insert appt;
        appt.ExpertsDoctorReminderDate__c = Date.today();
        appt.IsExpertsDoctorReminderSent__c = false;
        update appt;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();              
        WA_ExpertDoctorReminderSchedule batch = new WA_ExpertDoctorReminderSchedule();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        // Assert that WhatsApp__c was created and Appointment updated
        List<WhatsApp__c> msgs = [SELECT Id, Name, Messaging_Template__c FROM WhatsApp__c];
        System.assertEquals(1, msgs.size(), 'Expected 1 WhatsApp message');

        List<Appointment__c> apps = [SELECT Id, IsExpertsDoctorReminderSent__c FROM Appointment__c];
        System.assert(apps[0].IsExpertsDoctorReminderSent__c, 'Appointment should be updated');
    }

    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        System.schedule('TestSchedulable', '0 0 18 * * ?', new WA_ExpertDoctorReminderSchedule());
        Test.stopTest();        
    }
}