@isTest
private class CoronaReminderSchedulableBatchTest {
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
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;

        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;

        Case cas2 = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas2.SMS_Phone_Number__c = null;
        insert cas2;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;

        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;

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
        

        Datetime currdatetime = Datetime.now();

        List<Appointment__c> appLst = new List<Appointment__c>();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_time__c = Date.today();
        appt.Appointment_Date_Time__c = Datetime.newInstance(currdatetime.year(), currdatetime.month(), currdatetime.day(), 14, 0, 0);
        appt.Appointment_Status__c ='WaitingForAppointment';
        appt.Dont_send_reminder__c = false;
        appt.Domain__c = domain.Id;
    	appLst.add(appt);
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas2.Id);
        appt2.Site__c = site.Id;
        appt2.PayerFactor__c = pFactor.Id;
        appt2.Accession_Number__c = 'Q12346';
        appt2.Remainder_time__c = Date.today();
        appt2.Appointment_Date_Time__c = Datetime.newInstance(currdatetime.year(), currdatetime.month(), currdatetime.day(), 9, 0, 0).addDays(+1);
        appt2.Appointment_Status__c ='WaitingForAppointment';
        appt2.Dont_send_reminder__c = false;
        appt2.Domain__c = domain.Id;
        appLst.add(appt2);
        
       
        insert appLst;

        Medical_Procedure_in_Sites__c mpis = new Medical_Procedure_in_Sites__c();
        mpis.Site__c=site.Id;
        mpis.Medical_Procedure__c=procedure.Id;
        insert mpis;

        Site_Domain__c sd = new Site_Domain__c();
        sd.Site__c=site.Id;
        sd.Domain__c=domain.Id;
        insert sd;
    }

    @isTest
    static void batchTest(){
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new CoronaReminderSchedulableBatch(
                 'SELECT Id'
                    + ', IDNumber__c'
                      + ', Appointment_Status__c'
                      + ', Appointment_Date_Time__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', Site__c'
                      + ', Medical_Procedure__c'
                      + ', Domain__c'
                      + ', Site__r.Name'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Patient_Account__r.Corona_questionnaire__c'
                	  + ', Patient_Account__r.Sms_sent_time__c'
        			  + ', Patient_Account__r.formtitan_id_2__c'
          + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }
    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Datetime currdatetime = Datetime.now();
        Integer day = currdatetime.day();
        Integer month = currdatetime.month();
        Integer year = currdatetime.year();
        Test.startTest();
        System.schedule('Test Job Corona', '20 30 14 10 2 ?', new CoronaReminderSchedulableBatch(false));
        Test.stopTest();
    }

}