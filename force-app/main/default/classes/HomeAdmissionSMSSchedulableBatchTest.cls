@isTest
private  class HomeAdmissionSMSSchedulableBatchTest {
    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
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
        
        List<Appointment__c> appLst = new List<Appointment__c>();
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
        appt.Didkitsent__c = true;
        appt.Appointment_Status__c ='WaitingForAppointment';
        appt.TAF_Future_Case__c='3125415';
        appt.Process_Status_From_Site__c='1';
        appt.Dont_send_reminder__c = false;
    	appLst.add(appt);
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Site__c = site.Id;
        appt2.PayerFactor__c = pFactor.Id;
        appt2.Accession_Number__c = 'Q12346';
        appt2.Remainder_status__c = 'אין מענה';
        appt2.Remainder_time__c = Date.today();
        appt2.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt2.Date_for_tizkorit_reminder__c = Date.today();
        appt2.Date_for_human_reminder__c = Date.today();
        DateTime todayPlus3Days = date.today().adddays(+3);
        appt2.Appointment_Date_Time__c = todayPlus3Days;
        appt2.appointment_hour__c = appt2.Appointment_Date_Time__c.time();
        appt2.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt2.Didkitsent__c = true;
        appt2.Appointment_Status__c ='WaitingForAppointment';
        appt2.TAF_Future_Case__c='3125416';
        appt2.Process_Status_From_Site__c='0';
        appt2.Dont_send_reminder__c = false;
        appLst.add(appt2);
        
        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt3.Site__c = site.Id;
        appt3.PayerFactor__c = pFactor.Id;
        appt3.Accession_Number__c = 'Q12347';
        appt2.Remainder_status__c = 'אין מענה';
        appt3.Remainder_time__c = Date.today();
        appt3.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt3.Date_for_tizkorit_reminder__c = Date.today();
        appt3.Date_for_human_reminder__c = Date.today();
        DateTime todayPlus1Days = date.today().adddays(+1);
        appt3.Appointment_Date_Time__c = todayPlus1Days;
        appt3.appointment_hour__c = appt3.Appointment_Date_Time__c.time();
        appt3.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt3.Didkitsent__c = true;
        appt3.Appointment_Status__c ='WaitingForAppointment';
        appt3.TAF_Future_Case__c='3125417';
        appt3.Process_Status_From_Site__c='5';
        appt3.Dont_send_reminder__c = false;
        appt3.Process_Finished__c = true;
        appLst.add(appt3);
        
        Appointment__c appt4 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt4.Site__c = site.Id;
        appt4.PayerFactor__c = pFactor.Id;
        appt4.Accession_Number__c = 'Q12348';
        appt4.Remainder_status__c = 'אין מענה';
        appt4.Remainder_time__c = Date.today();
        appt4.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt4.Date_for_tizkorit_reminder__c = Date.today();
        appt4.Date_for_human_reminder__c = Date.today();
        DateTime todayPlus7Days = date.today().adddays(+7);
        appt4.Appointment_Date_Time__c = todayPlus7Days;
        appt4.appointment_hour__c = appt4.Appointment_Date_Time__c.time();
        appt4.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt4.Didkitsent__c = true;
        appt4.Appointment_Status__c ='WaitingForAppointment';
        appt4.TAF_Future_Case__c='3125417';
        appt4.Process_Status_From_Site__c=null;
        appt4.Dont_send_reminder__c = false;
        appt4.Process_Finished__c = false;
        appLst.add(appt4);
        insert appLst;
        
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new HomeAdmissionSMSSchedulableBatch(
                'SELECT Id'
                + ', IDNumber__c'
                + ', Appointment_Status__c'
                + ', Spincal__c'
                + ', Didkitsent__c'
                + ', Process_Status_From_Site__c'
                + ', Edited__c'
                + ', TAF_Future_Case__c' 
                + ', Appointment_Date_Time__c'
                + ', Case__r.SMS_Phone_Number__c'
                + ', Patient_Account__r.FirstName'
                + ', Patient_Account__r.SMS_Phone_number__c'
                + ', Process_Finished__c'
             + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job SMS', '20 30 8 10 2 ?', new HomeAdmissionSMSSchedulableBatch(false));
        Test.stopTest();
    }

    
}