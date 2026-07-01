// Test for: AppointmentTrigger, AppointmentTriggerHandler, AppointmentTriggerDispatcher, AppointmentTriggerService
@isTest
private class AppointmentTriggerServiceTest {

    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
            
        Account doctor1 = dBuilder.doctor;
        doctor1.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor1.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor1.Doctor_Code__c = '0012661';
        doctor1.Experts_center__c = true;

        Account patient1 = dBuilder.patient;
        patient1.Asthma__c = 'כן';
        patient1.PersonBirthdate = Date.valueOf('1980-10-10');
        patient1.Gender__c = 'נ';

        Site__c site = dBuilder.site;
        site.Maccabi_Code__c = '101701';
        site.Name = 'אסותא באר שבע';
        site.Address__c = 'הברזל 10';
        site.Site_Code__c = '20';

        Doctor_in_Clinic__c doctorInClinic = dBuilder.docClinic;
        doctorInClinic.Dont_send_reminder__c = true;
        
        Procedure_Plan__c pPlan = dBuilder.procedurePlan;
        pPlan.ProcedurePlanCode__c = 'test';

        Agreement__c agreement = dBuilder.agreement;
        agreement.Type_of_agreement__c = 'Surgery';

        dBuilder.initCommonData();

        dBuilder.buildAccountDoctor('doctor2')
            .setPicture('<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>')
            .setPictureURL('https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL')
            .setExpertsCenter(true)
            .setDoctorCode('0012662')
            .setField('ID_Number__c', TestDataFactory.D_ID_NUMBER_1)
            .build();

        dBuilder.buildAccountPerson('patient2')
            .setField('ID_Number__c', TestDataFactory.P_ID_NUMBER_1)
            .build();

        dBuilder.addCase('case1', 'Appointments');
        //dBuilder.addCase('case2', 'Appointments');
        
        dBuilder.addProcedure('proc1', '760904');
        dBuilder.buildProcedure('proc2', '99400')
            .setField('Reminder_required__c', true)
            .setField('Voice_Reminder__c', '3')
            .setField('SMS_Reminder__c', '1')
            .setField('Humen__c', '3')
            .setField('remainder1WA__c', '4')
            .setField('remainder2WA__c', '5')  
            .build();

        dBuilder.addProcedure('proc3', '76700');
        dBuilder.addProcedure('proc4', '13');
        dBuilder.addProcedure('proc5', '14');
        dBuilder.addProcedure('proc6', '15');
        dBuilder.addProcedure('proc7', '16');
       
        dBuilder.buildDoctorMedicalProcedure('proc2')
            .setField('House_doctor__c', true)
            .build();

        dBuilder.buildSiteDomain(null)
            .setField('accurate_site__c', dBuilder.site.Id)
            .build();

        dBuilder.addCalendar1(20, 60);

        dBuilder
            .buildSurvey('survey1')
                .setField('Gender__c', 'נ')
                .build()
            .addSurveyQuestion('survey1')
            .buildDocToAction('survey1')
                .setField('activity_code__c', '76700')
                .build()
            .buildDocToAction('survey1')
                .setField('activity_code__c', '13')
                .build()
            .buildSurveyTaker('survey1', 'case1', 'patient2')
                .setField('activity_code__c', '13')
                .build()
            .buildSurveyTaker('survey1', 'case1', null)
                .setField('activity_code__c', '76700')
                .build()
            .buildSurveyTaker('survey1', 'case1', null)
                .setField('activity_code__c', '14')
                .build()
            .buildSurveyTaker('survey1', 'case1', null)
                .setField('activity_code__c', '15')
                .build()
            .buildSurveyTaker('survey1', 'case1', null)
                .setField('activity_code__c', '16')
                .build()
            .addGuidelines('guideline1')
            .buidGuidanceScenario('proc2', 'guideline1')
                .setField('Asthma__c', false)
                .setField('Gender__c', 'ז')
                .build()
            .buidGuidanceScenario('proc2', 'guideline1')
                .setField('Asthma__c', true)
                .setField('Iodine_Sensitive__c', false)
                .setField('Blood_Dilution__c', false)
                .setField('MetalsInBody__c', false)
                .setField('diabetes__c', false)
                .build()
            .buidGuidanceScenario('proc2', 'guideline1')
                .setField('Iodine_Sensitive__c', false)
                .setField('Blood_Dilution__c', false)
                .setField('MetalsInBody__c', false)
                .setField('diabetes__c', false)
                .build()
            .buidGuidanceScenario('proc2', 'guideline1')
                .setField('Iodine_Sensitive__c', false)
                .setField('Blood_Dilution__c', false)
                .setField('MetalsInBody__c', false)
                .setField('diabetes__c', false)
                .build()
            .addImplantsToMedProd('proc2');
        
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
        ConsentForm__c cf = TestDataFactory.getConsentForm();
        insert cf;

    }

    /* Institute RT */

    @IsTest
    static void institutesTest(){

        List<Appointment__c> appointmentsToInsert = new List<Appointment__c>();
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Test.setMock(HttpCalloutMock.class, new getAmbulatoryCommitment_Mock());

        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME AND ID_Number__c = '852986371' LIMIT 1];
        Account patient2 = [SELECT Id FROM Account WHERE ID_Number__c = '999088396' LIMIT 1];
        
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE Name_of_parent__c != null LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        site.BarcodeIdentifyPatient__c = true;
        site.sendingByWhatsApp__c = true;
        update site;

        Domain__c domain = [SELECT Id FROM Domain__c WHERE DomainCode__c =: Decimal.valueOf(TestDataFactory.DOMAIN_CODE) LIMIT 1];
        domain.MaccabiRefferal__c = '1234';
        domain.DomainCode__c = 504;
        domain.sendingByWhatsApp__c = true;
        domain.BarcodeIdentifyPatient__c = true;
        update domain;

        insert new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Payer_Factor__c = TestDataFactory.PFACTOR_CODE, Status__c = 'active');
        insert new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Payer_Factor__c = TestDataFactory.PFACTOR_CODE, Status__c = 'active', Age_Range__c = '6-120', Gender__c = 'נ');
        insert new Survey_Assuta__c(Name = 'cpap_survey');

        Appointment__c apptExst = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        apptExst.Appointment_Date_Time__c =  Datetime.now().addMinutes(+3);
        apptExst.Doctor_Account__c = doctor.Id;
        appointmentsToInsert.add(apptExst);

        Appointment__c apptSurgery = TestDataFactory.getAppointmentSurgery(procedure.Id, patient.Id, calendar.Id, cas.Id);
        apptSurgery.Appointment_Date_Time__c = Date.today().addDays(38);
        appointmentsToInsert.add(apptSurgery);
        
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.PayerFactor__c = pFactor.Id;
        appt.First_Update_Caught__c = false;
        appt.Appointment_Date_Time__c = Datetime.now().addDays(+2);
        appt.Remainder_time__c = null;
        appt.Date_for_tizkorit_reminder__c = System.today().addDays(1);
        appt.Appointment_Status__c = 'NewAppointment';
        appt.more_than_14_days__c = false;
        appt.Site__c = site.Id;
        appt.Domain__c = domain.Id;    
        appt.Order_Notes__c = 'internet';
        appointmentsToInsert.add(appt);

        Test.startTest();
        insert appointmentsToInsert;
        try {
            appt.Patient_Account__c = patient.Id;
            update appt;
        } catch (Exception e) {
            String err = 'Update failed. First exception on row 0 with id '+ appt.Id +'; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The Patient has another appointment at the same time: []';
            System.assertEquals(err, e.getMessage());
        }
        try {
            appt.Patient_Account__c = patient2.Id;
            appt.Doctor_Account__c = doctor.Id;
            appt.Appointment_Date_Time__c = Datetime.now();
            appt.manualRunWAR__c = 'test';
            update appt;
        } catch (Exception e) {
            String err = 'Update failed. First exception on row 0 with id '+ appt.Id +'; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The Doctor has another appointment at the same time: []';
            System.assertEquals(err, e.getMessage());
        }

        Appointment__c apptSurgery1 = TestDataFactory.getAppointmentInstitutes(procedure.Id, patient.Id, calendar.Id, cas.Id);
        apptSurgery1.Domain__c = domain.Id;        
        insert apptSurgery1;

        apptSurgery1.Appointment_Status__c = 'Canceled';
        apptSurgery1.Canceled_reason__c = 'test';
        apptSurgery1.SendSurvey__c = true;
        update apptSurgery1;
        Test.stopTest();
    }
    @isTest
    static void sendingWhatsAppTest(){
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.sendingByWhatsApp__c = true;
        appt.Accession_Number__c = 'R1234';
        appt.sent_kit_confirmation__c = false;
        appt.PatientType__c = null;

        Test.startTest();
        insert appt;
        Test.stopTest();
    }
    
     @isTest
    static void urgentAppointmentTest(){
        List<Appointment__c> appointmentsToInsert = new List<Appointment__c>();
        Test.setMock(HttpCalloutMock.class, new ws_RisRemarksTest.updateRemark_Mock());
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
                    
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE Name_of_parent__c != null LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id, Name FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME AND ID_Number__c = '852986371' LIMIT 1];
        Account patient2 = [SELECT Id FROM Account WHERE ID_Number__c = '999088396' LIMIT 1];


        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c = Date.today().addDays(50);
        appt.Is_Urgent__c = true;
        appt.UrgentReason__c = '2'; 
        appt.PayerFactor__c = pFactor.Id;       
        appt.Appointment_Status__c = 'NewAppointment';       
        appt.Site__c = site.Id;                
        appointmentsToInsert.add(appt);
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient2.Id, calendar.Id, cas.Id);
        appt2.Appointment_Date_Time__c = Date.today().addDays(10);
        appt2.Is_Urgent__c = true;
        appt2.UrgentReason__c = '2';
        appt2.Duration__c = 30;
        appt2.PayerFactor__c = pFactor.Id;       
        appt2.Appointment_Status__c = 'NewAppointment';       
        appt2.Site__c = site.Id;        
        appointmentsToInsert.add(appt2);
		
        insert appointmentsToInsert;
        
        Test.startTest();
        appt2.UrgentApptSaveSlot__c = true;
        
        update appt2;
        
        appt.UrgentAppointment__c = appt2.Id; 
        appt.UrgentApptStatus__c = 'Early';  
        update appt;        
        Test.stopTest();      
    }

    @isTest
    static void linkAppointmentsTest() {
        List<Appointment__c> appointmentsToInsert = new List<Appointment__c>();
        Test.setMock(HttpCalloutMock.class, new ws_RisRemarksTest.updateRemark_Mock());
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
                    
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE Name_of_parent__c != null LIMIT 1];        
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME AND ID_Number__c = '852986371' LIMIT 1];        
        Medical_Procedure__c procedure1 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Medical_Procedure__c procedure2 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        procedure2.Procedure_Code__c = '2565';
        update procedure2;

        Domain__c domain = [SELECT Id FROM Domain__c WHERE DomainCode__c =: Decimal.valueOf(TestDataFactory.DOMAIN_CODE) LIMIT 1];       
        domain.DomainCode__c = 303;
        update domain;
        
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c = Date.today().addDays(50);        
        appt.Domain__c = domain.Id;   
        //appt.Site__c = site.Id;       
        appointmentsToInsert.add(appt);
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure2.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Appointment_Date_Time__c = Date.today().addDays(10);
        appt2.PayerFactor__c = pFactor.Id;       
        appt2.Appointment_Status__c = 'NewAppointment';       
        appt2.Site__c = site.Id;        
        appointmentsToInsert.add(appt2);
        insert appointmentsToInsert;   
    }

    /*  ExpertsRT  */
    @isTest
    static void expertsTest(){
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.D_ID_NUMBER AND Doctor_Code__c = '0012661' LIMIT 1];

        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        procedure.Procedure_Code__c = '99400';
        update procedure;
        
        Clinic__c clinic = [SELECT Id FROM Clinic__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c WHERE DomainCode__c =: Decimal.valueOf(TestDataFactory.DOMAIN_CODE) LIMIT 1];
        
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        calendar.Doctor__c = doctor.Id;
        calendar.Excellent_Clinics__c = true;
        calendar.BranchName__c = site.Id;
        update calendar;

        Appointment__c apptPrevious = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        apptPrevious.Doctor_Account__c = doctor.Id;
        apptPrevious.Clinic__c = clinic.Id;
        apptPrevious.OrderKey__c = '1';
        insert apptPrevious;
        insert new cases_and_appoitments__c(Case__c = cas.Id, Appointment__c = apptPrevious.Id);
        insert new cases_and_appoitments__c(Case__c = cas.Id, Appointment__c = apptPrevious.Id);

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Appointment_Date_Time__c = Datetime.now();
        appt.clinic_Email__c = 'Test@assuta.co.il';
        appt.Payer_Factor_Code__c = TestDataFactory.PFACTOR_CODE;
        appt.Accession_Number__c = '234567';
        appt.Site__c = site.Id;
        appt.OrderKey__c = '1';
        appt.Domain__c = domain.Id;
        appt.Order_Notes__c = 'internet';

        Test.startTest();
        insert appt;
        appt.Doctor_Account__c = doctor.Id;
        appt.Clinic__c = clinic.Id;
        appt.Appointment_Date_Time__c = Datetime.now().addDays(+1);
        appt.Appointment_Type__c = 'Experts';
        update appt;

        appt.Appointment_Status__c = 'Canceled';
        appt.Canceled_reason__c = '18';
        appt.reason__c = 'reason X';
        update appt;

        try {
            appt.Appointment_Date_Time__c = Datetime.now().addDays(+20);
            update appt;
        } catch (Exception e) {
            String err = 'Update failed.';
            System.assert(e.getMessage().contains(err));
        }
        Test.stopTest();
    }

    /*  SurgeriesRT  */
    @isTest
    static void retServiceReferralsTest(){
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.D_ID_NUMBER LIMIT 1];
        Payer_Factor__c payer =  TestDataFactory.getPFactor('3');
        insert payer;

        Test.startTest();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = payer.Id;
        appt.Doctor_Account__c = doctor.Id;
        insert appt;

        appt.Agreement_with_assuta__c = 'Y';

        ExcludedParameters__c exPar = new ExcludedParameters__c();
        exPar.Status__c = 'Active';
        exPar.Site__c = site.Id;
        exPar.DoctorName__c = doctor.Id;
        exPar.MedicalProcedure__c = procedure.Id;
        insert exPar;
        
        update appt;
        Test.stopTest();
    }

    @isTest 
    static void surgeriesTest(){
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.D_ID_NUMBER LIMIT 1];

        Medical_Procedure__c procedure = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        domain.DomainCode__c = 504;
        update domain;

        SpinCal__c spincal = new SpinCal__c();
        spincal.Name = '12345';
        insert spincal;
        Referral_from_doctor_website__c referral = new Referral_from_doctor_website__c();
        insert referral;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Medical_Procedure__c = procedure.Id;
        appt.Medical_Procedure2__c = procedure.Id;
        appt.Medical_Procedure3__c = procedure.Id;
        appt.Medical_Procedure4__c = procedure.Id;
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Appointment_Date_Time__c = Datetime.now().addDays(28);
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Commitment_Status__c = '0';
        appt.Case_Hidden__c = cas.Id;
        appt.Payer_factor__c = '3';
        appt.Case__c = cas.Id;
        appt.Domain__c = domain.Id; 
        appt.Spincal__c = spincal.Id;
        appt.Referral_from_doctor_website__c = referral.Id;

        appt.Procedure_Plan_Text__c = [SELECT ProcedurePlanCode__c FROM Procedure_Plan__c LIMIT 1].ProcedurePlanCode__c;
        appt.Medical_Procedure_Text__c = procedure.Procedure_Code__c;
        appt.Site_Text__c = [SELECT Id, Site_Code__c FROM Site__c LIMIT 1].Site_Code__c;

        Test.startTest();
        insert appt;
        Appointment__c appt1 = TestDataFactory.getAppointmentSurgery(procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt1;
        Test.stopTest();
    }

    @isTest 
    static void createKITFileWithEmailTest() {
        Account patient1 = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1];
        patient1.Preferred_Channel__c = 'Email';
        patient1.Email__c = 'test@gmail.com';
        update patient1;

        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas1 = [SELECT Id FROM Case LIMIT 1];
        Payer_Factor__c payer1 =  TestDataFactory.getPFactor('4');
        insert payer1;
       
        Test.startTest();
        List<Appointment__c> appointmentToInsert = new List<Appointment__c>();
        Appointment__c app3 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient1.Id, calendar.Id, cas1.Id);
        app3.Appointment_Status__c = 'בטיפול אדמיניסטרטיבי';
        app3.Patient_Mail__c = 'test@gmail.com';
        app3.Agreement_with_assuta__c = 'Y';
        app3.PayerFactor__c = payer1.Id;
        appointmentToInsert.add(app3);
        insert appointmentToInsert;
        Test.stopTest();
    }

    @isTest
    static void updateShikumBaitCasesTest() {        
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt;
        cas.Surgery_Name__c = appt.Id;
        update cas;
        appt.Shikum_Bait_Approval__c = 'Approves_Shikum';
        update appt;
        Test.stopTest();     
    }

    @isTest
    static void relatedImplantsMpToApp() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = '999088396' LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];

        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '99400'  LIMIT 1];

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Datetime.now();
        appt.Prevent_Automation__c = true;
        appt.Domain__c = domain.Id;
        appt.Site__c = site.Id;
        appt.Accession_Number__c = 'R1234';
        appt.Medical_Procedure2__c = procedure.Id;
        appt.Medical_Procedure3__c = procedure.Id;
        appt.Medical_Procedure4__c = procedure.Id;
        appt.Doctor_Account__c = doctor.Id;

        Test.startTest();
        insert appt;
        Test.stopTest();
    }

    @isTest
    static void relatedSurgeryToPreSurgeryTest() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];                
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];        
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        domain.DomainCode__c = 504;
        update domain;

        Appointment__c appt = TestDataFactory.getAppointmentInstitutes(procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Domain__c = domain.Id; 
        appt.Appointment_Date_Time__c = Date.today().addDays(28);     
        insert appt;
        
        Test.startTest();
        Appointment__c appt1 = TestDataFactory.getAppointmentSurgery(procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt1;
        Test.stopTest();
    }

    @isTest 
    static void createKITFileTest() {
        Account patient1 = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1];
        patient1.Preferred_Channel__c = null;
        update patient1;
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas1 = [SELECT Id FROM Case LIMIT 1];

        Payer_Factor__c payer1 =  TestDataFactory.getPFactor('1');
        insert payer1;
        Payer_Factor__c payer2 =  TestDataFactory.getPFactor('4');
        insert payer2;

        Test.startTest();
        List<Appointment__c> appointmentToInsert = new List<Appointment__c>();
        Appointment__c app1 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient1.Id, calendar.Id, cas1.Id);
        app1.PayerFactor__c = payer1.Id;
        appointmentToInsert.add(app1);

        Appointment__c app2 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient1.Id, calendar.Id, cas1.Id);
        app2.PayerFactor__c = payer2.Id;
        appointmentToInsert.add(app2);

        insert appointmentToInsert;
        Test.stopTest();
    }

    /*@IsTest
    static void createSurveyTest() {
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = '852986371' LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        survey.QueryForAnswersRequired__c = true;
        survey.name = 'BloodTransfusionAndAnesthesia';
        update survey;

        Doc_to_action__c docToAction = [SELECT Id, Survey__c FROM Doc_to_action__c WHERE Survey__c = :survey.Id LIMIT 1];
        Survey_To_Site__c surveyToSite = TestDataFactory.getSurveyToSite(site.Id, docToAction.Survey__c);
        insert surveyToSite;

        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '76700'  LIMIT 1];

        Medical_Procedure_in_Sites__c medInSites = TestDataFactory.getProcedureSite(procedure.Id, site.Id);
        medInSites.Digital_Survey1__c = survey.Id;
        medInSites.DigitalSignConsentForm__c = survey.Id;
        medInSites.DigitalSignConsentForm1__c = survey.Id;
        insert medInSites;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Datetime.now();
        appt.Prevent_Automation__c = true;
        appt.Domain__c = domain.Id;
        appt.Site__c = site.Id;
        appt.Accession_Number__c = 'R1234';
        appt.Doctor_Account__c = doctor.Id;

        Test.startTest();
        insert appt;
        appt.Appointment_Date_Time__c = Datetime.now() + 1;
        update appt;
        Test.stopTest();
    }*/

    @IsTest
    static void createSurveyTest1() {
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = '852986371' LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        survey.QueryForAnswersRequired__c = true;
        update survey;

        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '76700'  LIMIT 1];

        Medical_Procedure_in_Sites__c medInSites = TestDataFactory.getProcedureSite(procedure.Id, site.Id);
        medInSites.Digital_Survey1__c = survey.Id;
        insert medInSites;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Datetime.now();
        appt.Prevent_Automation__c = true;
        appt.Domain__c = domain.Id;
        appt.Site__c = site.Id;
        appt.Accession_Number__c = 'R1234';
        appt.Doctor_Account__c = doctor.Id;

        Test.startTest();
        insert appt;
        Test.stopTest();
    }

    @IsTest
    static void createSurveyTest2() {
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account patient2 = [SELECT Id FROM Account WHERE ID_Number__c = '999088396' LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Doc_to_action__c docToAction = [SELECT Id, Survey__c FROM Doc_to_action__c LIMIT 1];

        Survey_To_Site__c surveyToSite = TestDataFactory.getSurveyToSite(site.Id, docToAction.Survey__c);
        insert surveyToSite;

        Medical_Procedure__c procedure2 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '13'  LIMIT 1];
        Medical_Procedure__c procedure3 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '14'  LIMIT 1];
        Medical_Procedure__c procedure4 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '15'  LIMIT 1];
        Medical_Procedure__c procedure5 = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '16'  LIMIT 1];

        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure2.Id, patient2.Id, calendar.Id, cas.Id);
        appt2.Appointment_Date_Time__c =  Datetime.now();
        appt2.Prevent_Automation__c = true;
        appt2.Domain__c = domain.Id;
        appt2.Site__c = site.Id;
        appt2.Accession_Number__c = 'R1235';
        appt2.Medical_Procedure2__c = procedure3.Id;
        appt2.Medical_Procedure3__c = procedure4.Id;
        appt2.Medical_Procedure4__c = procedure5.Id;
        appt2.Doctor_Account__c = doctor.Id;

        Test.startTest();
        insert appt2;
        Test.stopTest();
    }

    @isTest
    static void linkProcedurePlanTest() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME AND ID_Number__c = '852986371' LIMIT 1];
        Account patient2 = [SELECT Id FROM Account WHERE ID_Number__c = '999088396' LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];

        Medical_Procedure__c ultrasound = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '760904' LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        
        Appointment__c apptExst = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        apptExst.Appointment_Date_Time__c =  Datetime.now().addHours(1);
        apptExst.Doctor_Account__c = doctor.Id;
        apptExst.OrderKey__c = '123';
        insert apptExst;

        cases_and_appoitments__c junction = new cases_and_appoitments__c(Case__c = cas.Id, Appointment__c = apptExst.Id);
        insert junction;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, ultrasound.Id, patient2.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Datetime.now();
        appt.Prevent_Automation__c = true;
        appt.Domain__c = domain.Id;
        appt.OrderKey__c = '123';
        appt.Site__c = site.Id;

        Test.startTest();
        insert appt;
        Test.stopTest();
    }

    @IsTest
    static void anyRTTest() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = '999657950' LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Clinic__c clinic = [SELECT Id FROM Clinic__c LIMIT 1];
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Payer_Factor__c payer1 =  TestDataFactory.getPFactor('3');
        insert payer1;

        Appointment__c appt1 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);//Master
        appt1.RecordTypeId = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('ClosedExperts').getRecordTypeId();
        appt1.Clinic__c = clinic.Id;
        appt1.Canceled_Reason__c = '4';
        appt1.PayerFactor__c = payer1.Id;
        appt1.Opportunity__c = oppt.Id;
        appt1.Appointment_Date_Time__c =  Datetime.now().addHours(1);
        appt1.Doctor_Account__c = doctor.Id;
        appt1.OrderKey__c = '123';
        insert appt1;

        cases_and_appoitments__c junction = new cases_and_appoitments__c(Case__c = cas.Id, Appointment__c = appt1.Id);
        insert junction;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.RecordTypeId = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('ClosedExperts').getRecordTypeId();
        appt.Canceled_Reason__c = '4';
        appt.Clinic__c = clinic.Id;
        appt.PayerFactor__c = payer1.Id;
        appt.Opportunity__c = oppt.Id;
        appt.theLatestAppointment__c = true;
        appt.Appointment_Status__c = 'Canceled';
        appt.Appointment_Date_Time__c = Datetime.now();
        appt.Prevent_Automation__c = true;
        appt.Domain__c = domain.Id;
        appt.OrderKey__c = '123';
        appt.Site__c = site.Id;

        Test.startTest();
        insert appt;  
        appt.Remainder_status__c = 'השיב להודעה בשלילה';
        appt.Creditwasmade__c = true;
        appt.applicationforcredit__c = true;
        update appt;
        Test.stopTest();
    }

    @isTest
    static void fillRelatedDocument() {
        Account patient1 = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas1 = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        site.Site_Code__c = '62';
        update site;
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Payer_Factor__c payer1 =  TestDataFactory.getPFactor('3');
        insert payer1;

        patient1.PersonEmail = 'test@gmail.com';
        patient1.Asthma__c = 'לא';
        patient1.Iodine_Sensitivity__c = 'לא';
        patient1.Preferred_Language_Service__c = '1';
        update patient1;
        Related_document__c relDoc = TestDataFactory.getRelatedDoc(procedure.Id, 'אסותא השלום');
        relDoc.Asthma__c = 'לא';
        relDoc.Iodine_Sensitivity__c = 'לא';
        relDoc.FromHour__c = null;
        relDoc.ToHour__c = null;
        relDoc.Site__c = '62';
        relDoc.AppointmentRecordType__c = TestDataFactory.APPT_S_RT_NAME;
        insert relDoc;
        ContentVersion contVers = TestDataFactory.getContentVersion();
        insert contVers;
        ContentDocumentLink contDocLink = TestDataFactory.getContentDocLink(relDoc.Id);
        contDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contVers.Id LIMIT 1].ContentDocumentId;
        insert contDocLink;

        Test.startTest();
        Appointment__c app1 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient1.Id, calendar.Id, cas1.Id);
        app1.PayerFactor__c = payer1.Id;
        app1.Opportunity__c = oppt.Id;
        app1.Site__c = site.Id;        
        app1.Accession_Number__c = '234567';
        app1.Appointment_Status__c = 'WaitingForAppointment';
        insert app1;
        Test.stopTest();
    }

    @isTest
    static void createConsentFormTakenTest(){
        Account patient1 = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas1 = [SELECT Id FROM Case LIMIT 1];
        Payer_Factor__c payer1 =  TestDataFactory.getPFactor('3');
        insert payer1;
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        ConsentForm__c cf = [SELECT Id FROM ConsentForm__c LIMIT 1];
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        Medical_Procedure_in_Sites__c medPInSite = new Medical_Procedure_in_Sites__c(Medical_Procedure__c = procedure.Id, 
                                                                                    Site__c = site.Id, 
                                                                                    DigitalSignConsentForm__c = cf.Id,
                                                                                    DigitalSignConsentForm1__c = cf.Id,
                                                                                    Digital_Survey1__c = survey.Id);
        insert medPInSite;
            Test.startTest();
            Appointment__c app1 = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient1.Id, calendar.Id, cas1.Id);
            app1.PayerFactor__c = payer1.Id;
            app1.Site__c = site.Id;        
            app1.Accession_Number__c = '234567';
            app1.Appointment_Status__c = 'WaitingForAppointment';
            insert app1;
        Test.stopTest();
    }
}