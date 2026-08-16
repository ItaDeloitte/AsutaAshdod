@isTest
private  class PreSurgeryReminderSchedulableBatchTest {
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


            
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '22.4');
        procedure1.Name = 'א.א.ג-הזרקת חומר סינטטי למיתרי הקול';
        procedure1.Confidentiality__c=false;
        insert procedure1;
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '20.5');
        procedure2.Name = 'א.א.ג - אוסיקולופלסטי';
        procedure2.Confidentiality__c=true;
        insert procedure2;
        Medical_Procedure__c procedure3 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '23.11');
        procedure3.Name = 'אאג - תירואידקטומיה בגישה רובוטית';
        procedure3.Confidentiality__c= true;
        insert procedure3;
        Medical_Procedure__c procedure4 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '33.6');
        procedure4.Name = 'א.א.ג -הרחבת תעלת השמע באמצעות בלון';
        procedure4.Confidentiality__c=true;
        insert procedure4;

        
        List<Appointment__c> appLst = new List<Appointment__c>();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Appointment_Date_Time__c = Date.today().addDays(1);
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_time__c = Date.today();
        appt.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        appt.Didkitsent__c = true;
        appt.Appointment_Status__c ='WaitingForAppointment';
    	appLst.add(appt);
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Site__c = site.Id;
        appt2.PayerFactor__c = pFactor.Id;
        appt.Appointment_Date_Time__c = Date.today().addDays(1);
        appt2.Accession_Number__c = 'Q12346';
        appt2.Remainder_time__c = Date.today();
        appt2.appointment_hour__c = appt2.Appointment_Date_Time__c.time();
        appt2.Didkitsent__c = true;
        appt2.Appointment_Status__c ='WaitingForAppointment';
        appt2.Medical_Procedure2__c= procedure2.Id;
        appLst.add(appt2);

        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt3.Site__c = site.Id;
        appt3.PayerFactor__c = pFactor.Id;
        appt3.Appointment_Date_Time__c = Date.today().addDays(1);
        appt3.Accession_Number__c = 'Q12346';
        appt3.Remainder_time__c = Date.today();
        appt3.appointment_hour__c = appt2.Appointment_Date_Time__c.time();
        appt3.Didkitsent__c = true;
        appt3.Appointment_Status__c ='WaitingForAppointment';
        appt3.Medical_Procedure2__c= procedure2.Id;
        appt3.Case__c = null;
        appLst.add(appt3);


        insert appLst;
    
      
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new PreSurgeryReminderSchedulableBatch(
                'SELECT Id'
                + ', IDNumber__c'
                + ', Appointment_Status__c'
                + ', Medical_Procedure__r.Confidentiality__c'
                + ', Medical_Procedure2__r.Confidentiality__c'
                + ', Medical_Procedure3__r.Confidentiality__c'
                + ', Medical_Procedure4__r.Confidentiality__c'
                + ', Appointment_Date_Time__c'
                + ', Case__r.SMS_Phone_Number__c'
                + ', Patient_Account__r.FirstName'
                + ', Patient_Account__r.SMS_Phone_number__c'
             + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job SMS', '20 30 8 10 2 ?', new PreSurgeryReminderSchedulableBatch(false));
        Test.stopTest();
    }

    
}