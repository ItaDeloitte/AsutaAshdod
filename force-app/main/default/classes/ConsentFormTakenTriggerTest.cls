@isTest
public with sharing class ConsentFormTakenTriggerTest {

    @TestSetup
    static void makeData(){
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

        dBuilder.addCase('case1', 'Appointments');        
        dBuilder.addProcedure('proc1', '760904');
        dBuilder.buildSiteDomain(null)
            .setField('accurate_site__c', dBuilder.site.Id)
            .build();

        dBuilder.addCalendar1(20, 60);
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
        ConsentForm__c cf = TestDataFactory.getConsentForm();
        insert cf;
    }

    @isTest
    public static void populateUUIDTest(){
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Site__c site = [SELECT ID FROM Site__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE Name_of_parent__c != null LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '760904' LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        ConsentForm__c cf = [SELECT Id FROM ConsentForm__c LIMIT 1];

        Test.startTest();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c = Date.today().addDays(50);
        appt.PayerFactor__c = pFactor.Id;       
        appt.Appointment_Status__c = 'NewAppointment';       
        appt.Site__c = site.Id;                
        insert appt;

        ConsentFormTaken__c cft = new ConsentFormTaken__c(
            Name = 'name',
            Account__c = patient.Id,
            Appointment__c = appt.Id,
            Site__c = site.Id,
            ConsentForm__c = cf.Id
        );
        insert cft;
        Test.stopTest();

        ConsentFormTaken__c cftAfter = [SELECT Id, UUID__c FROM ConsentFormTaken__c LIMIT 1];
        Assert.isTrue(cftAfter.UUID__c != null);    
    }
}