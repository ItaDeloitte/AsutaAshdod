@isTest
private class UpdateActiveGuidlinesOnApptBatchTest {
  
    @TestSetup
    static void makeData(){

       Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor1.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor1.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor1.Doctor_Code__c = '0012661';
        doctor1.Experts_center__c = true;
        Account doctor2 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor2.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor2.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor2.ID_Number__c = '999657950';
        doctor2.Doctor_Code__c = '0012662';
        doctor2.Experts_center__c = true;
        insert new List<Account>{doctor1, doctor2};

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c ultrasound = new Medical_Procedure__c(Procedure_Code__c = '760904');
        insert ultrasound;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '3';
        procedure.SMS_Reminder__c = '1';
        procedure.Humen__c = '3';
        insert procedure;
        Doctor_Medical_Procedure__c docProcedure = TestDataFactory.getDocProcedure(doctor1.Id, procedure.Id);
        docProcedure.House_doctor__c = true;
        insert docProcedure;

        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        insert clinic;
        Doctor_in_Clinic__c docClinic = TestDataFactory.getDocClinic(doctor1.Id, clinic.Id);
        docClinic.Dont_send_reminder__c = true;
        insert docClinic;

        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.ID_Number__c = '852986371';
        patient1.Asthma__c = 'כן';
        patient1.PersonBirthdate = Date.valueOf('1980-10-10');
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.ID_Number__c = '999088396';
        insert new List<Account>{patient1, patient2};

        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Maccabi_Code__c = '101701';
        insert site;
        insert new Site_Domain__c(Site__c = site.Id, Domain__c = domain.Id, accurate_site__c = site.Id);
        Calendar__c calendar = TestDataFactory.getCalendar('test');
        insert calendar;
        List<Calendar1__c> calendars = TestDataFactory.getCalendars1_days(20, 60);
        insert calendars;
        Procedure_Plan__c pPlan = TestDataFactory.getProcedurePlan();
        pPlan.ProcedurePlanCode__c = 'test';
        insert pPlan;
        Payer_Factor__c ppFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        ppFactor.Insurance_Company__c = true;
        insert ppFactor;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = ppFactor.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;
        Agreement__c agreement = TestDataFactory.getAgreement(doctor1.Id, pFactor.Id);
        agreement.Type_of_agreement__c = 'Surgery';
        insert agreement;
        Contact con = TestDataFactory.getContact(doctor1.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor1.Id, patient1.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;

        Guidelines__c guidline = new Guidelines__c();
        guidline.Status__c = 'active';
        insert guidline;
        Guidance_Scenario__c guidlineScenario = new Guidance_Scenario__c();
        guidlineScenario.Medical_Procedure__c = procedure.Id;
        guidlineScenario.Guideline1__c = guidline.Id;
        guidlineScenario.Asthma__c = false;
        guidlineScenario.Site__c = site.Id;
        guidlineScenario.Gender__c = 'ז';
        Guidance_Scenario__c guidlineScenario1 = new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Site__c = site.Id, Guideline1__c = guidline.Id, Asthma__c = true, Iodine_Sensitive__c = false, Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false);
        Guidance_Scenario__c guidlineScenario2 = new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Site__c = site.Id, Guideline1__c = guidline.Id, Iodine_Sensitive__c = false, Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false);
        Guidance_Scenario__c guidlineScenario3 = new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Site__c = site.Id, Guideline1__c = guidline.Id, Iodine_Sensitive__c = false, Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false);
        insert guidlineScenario;
        insert guidlineScenario1;
        insert guidlineScenario2;
        insert guidlineScenario3;

        Nursery__c nursery = TestDataFactory.getNursery();
        insert nursery;
        Implants_to_med_prod__c implantsToMedProd = TestDataFactory.getImplantsToMedProd(nursery.Id, procedure.Id);
        insert implantsToMedProd;

        
    }

    @IsTest
    static void testGuidlines(){
        
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE Name_of_parent__c != null LIMIT 1];
        insert new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Payer_Factor__c = TestDataFactory.PFACTOR_CODE, Status__c = 'active');
        insert new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Payer_Factor__c = TestDataFactory.PFACTOR_CODE, Status__c = 'active', Age_Range__c = '6-120', Gender__c = 'נ');
        
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.PayerFactor__c = pFactor.Id;
        appt.First_Update_Caught__c = false;
        appt.Appointment_Date_Time__c = Datetime.now().addDays(+2);
        appt.Remainder_time__c = null;
        appt.Date_for_tizkorit_reminder__c = System.today().addDays(1);
        appt.Appointment_Status__c = 'NewAppointment';
        appt.more_than_14_days__c = false;
        appt.Site__c = site.Id;
        
        insert appt;
        appt.Appointment_Date_Time__c = Datetime.now().addDays(+3);

        Test.startTest();
        Database.executeBatch(new UpdateActiveGuidlinesOnApptBatch());
        Test.stopTest();
    }
}