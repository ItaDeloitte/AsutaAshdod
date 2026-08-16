@isTest
private class SendSurveyToDoctorsScheduleBatchTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Doctors_Emails_Hidden__c = 'docTestetst@fkd.dfs';
        doctor.Doctor_personal_phone__c = '0546354186';
        doctor.Doctors_Phones_Hidden__c = '0546354184';
        doctor.Email__c = 'do@fkd.dfs';
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
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
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE, calendar.Id);
        insert site;
        Clinic__c clinic = new Clinic__c(Name = 'test', Site__c = site.Id, clinic_email__c = 'example@gmail.com'); 
        insert clinic;  
        insert new Doctor_in_Clinic__c(Clinic__c = clinic.Id, Doctors__c = doctor.Id, Email__c = 'example@gmail.com', Schedule_System__c = 'QFlow');
        Campaign cam = new Campaign(Name = 'testCampaign', DoctorSurvey__c = true);
        insert cam;
        Opportunity opp = new Opportunity(StageName = 'Closed Won', StageStatus__c = 'expert', Name = 'OpportunityTest', CloseDate = Date.today(), CampaignId = cam.Id);
        insert opp;
        List<Appointment__c> appToInsert = new List<Appointment__c>();
        Appointment__c app1 = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        app1.Doctor_Account__c = doctor.Id;
        app1.Clinic__c = clinic.Id;
        app1.Appointment_Date_Time__c = DateTime.now() + 3;
        app1.Opportunity__c = opp.Id;
        appToInsert.add(app1);
        Appointment__c app2 = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        app2.Doctor_Account__c = doctor.Id;
        app2.Clinic__c = clinic.Id;
        app2.Appointment_Date_Time__c = Datetime.now();
        app2.Opportunity__c = opp.Id;
        appToInsert.add(app2);
        Appointment__c app3 = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        app3.Doctor_Account__c = doctor.Id;
        app3.Clinic__c = clinic.Id;
        app3.Appointment_Date_Time__c = DateTime.now() - 4;
        app3.Opportunity__c = opp.Id;
        appToInsert.add(app3);
        Appointment__c app4 = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        app4.Doctor_Account__c = doctor.Id;
        app4.Clinic__c = clinic.Id;
        app4.Appointment_Date_Time__c = DateTime.now() - 30;
        app4.Opportunity__c = opp.Id;
        appToInsert.add(app4);
        insert appToInsert;
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(new SendSurveyToDoctorsScheduleBatch());
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job Send survey To Doctors', '20 30 8 10 2 ?', new SendSurveyToDoctorsScheduleBatch());
        Test.stopTest();
    }
}