@isTest
public with sharing class RequiredDucumentsIndicator_LWCtrlTest {

    @TestSetup
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
        
        dBuilder.buildProcedure('proc2', '99400')
            .setField('Reminder_required__c', true)
            .setField('Voice_Reminder__c', '3')
            .setField('SMS_Reminder__c', '1')
            .setField('Humen__c', '3')
            .setField('remainder1WA__c', '4')
            .setField('remainder2WA__c', '5')  
            .build();
       
        dBuilder.buildDoctorMedicalProcedure('proc2')
            .setField('House_doctor__c', true)
            .build();

        dBuilder.buildSiteDomain(null)
            .setField('accurate_site__c', dBuilder.site.Id)
            .build();

        dBuilder.addCalendar1(20, 60);
        
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @isTest
    public static void getRequiredDocInfoTest(){
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Test.setMock(HttpCalloutMock.class, new getAmbulatoryCommitment_Mock());

        Account doctor = [SELECT Id FROM Account WHERE Doctor_Code__c = '0012661' LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Guidelines__c guid = new Guidelines__c(
            Status__c = 'active',
            Guideline_Type__c = 'D',
            Required_documents__c = '5;14;137'
        );
        insert guid;

        Guidance_Scenario__c guidlineScenario = new Guidance_Scenario__c(
            Medical_Procedure__c = procedure.Id, 
            Payer_Factor__c = TestDataFactory.PFACTOR_CODE, 
            Status__c = 'active',
            Guideline1__c = guid.Id);
        insert guidlineScenario;
        
        Appointment__c appointment = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appointment.Appointment_Date_Time__c = Date.today().addDays(38);
        appointment.Doctor_Account__c = doctor.Id;
        appointment.Guidance_Scenario__c = guidlineScenario.Id;
        insert appointment;

        File__c file = new File__c(
                Name = 'test',
                File_Type__c = '14',
                Appointment__c = appointment.Id);
        insert file;
        String reqDocs = RequiredDucumentsIndicator_LWCtrl.getRequiredDocInfo(appointment.Id);
    }
}