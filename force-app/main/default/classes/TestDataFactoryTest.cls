@isTest
private class TestDataFactoryTest {

    @isTest
    static void insertUserTest() {
        Test.startTest();
        insert TestDataFactory.getUser('System Administrator');
        Test.stopTest();
    }

    @isTest
    static void insertENVTest() {
        Test.startTest();
        insert TestDataFactory.getENV();
        Test.stopTest();
    }

    @isTest
    static void insertSObjectsTest() {
        Test.startTest();
        insert TestDataFactory.getENV();
        TestDataFactory.getJSONSlots(TestDataFactory.PROCEDURE_CODE);
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        insert TestDataFactory.getCaseRecDoc(doctor.Id, cas.Id);
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        insert TestDataFactory.getProcedurePlan();
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE, calendar.Id);
        insert site;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt;
        waiting_list__c waitingList = TestDataFactory.getWaitingList(appt.Id, appt.Id);
        //insert waitingList;
        insert TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        insert TestDataFactory.getDocStatistics(doctor.Id, procedure.Id);
        insert TestDataFactory.getDocSite(doctor.Id, site.Id);
        insert TestDataFactory.getSettlement();
        insert TestDataFactory.getProcedureSite(procedure.Id, site.Id);
        insert TestDataFactory.getSequence(procedure.Id, procedure.Id, procedure.Id);
        insert TestDataFactory.getCalendarProcedure(calendar.Id, procedure.Id);
        insert TestDataFactory.getAgreement(doctor.Id, pFactor.Id);
        Arrangements__c arrangement = TestDataFactory.getArrangements(pFactor.Id);
        insert arrangement;
        insert TestDataFactory.getDocArrangement(doctor.Id, arrangement.Id);
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        insert clinic;
        insert TestDataFactory.getDocClinic(doctor.Id, clinic.Id);
        insert TestDataFactory.getDocRank(doctor.Id);
        insert TestDataFactory.getRecommendations(appt.Id);
        insert TestDataFactory.getRecommendations(patient.Id, cas.Id);
        insert TestDataFactory.getRecommendationsType();
        ContentVersion cVersion = TestDataFactory.getContentVersion();
        insert cVersion;
        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(cVersion.Id);
        //insert cDocLink;
        File__c file = TestDataFactory.getFile(cas, procedure.Id);
        //insert file;
        Reminder__c reminder = TestDataFactory.getReminder(appt.Id);
        //insert reminder;
        insert TestDataFactory.getCalendar1();
        insert TestDataFactory.getCalendars1(1);
        insert TestDataFactory.getCalendars1_days(2, 1);
        insert TestDataFactory.getLiveChatTranscript();
        insert TestDataFactory.getLogACall(UserInfo.getUserId(), false, 'UUI', 'OriginalCallObjectId');
        insert TestDataFactory.getDisability(doctor.Id, '100');
        Survey_Assuta__c survey = new Survey_Assuta__c(Name = 'Test Survey');
        insert survey;
        insert TestDataFactory.getAgentSurvey(patient.Id, cas.Id, survey.Id);
        Nursery__c nursey = TestDataFactory.getNursery();
        insert nursey;
        insert TestDataFactory.getImplantsToMedProd(nursey.Id, procedure.Id);
        insert TestDataFactory.getSchParameter(procedure.Id, domain.Id);
        Test.stopTest();
    }

    @IsTest
    static void insertCommonDataTest() {
        TestDataFactory.insertCommonData();
        System.assertEquals(0, [SELECT Id FROM Appointment__c].size());
    }

    @IsTest
    static void insertCommonDataWithSApptTest() {
        TestDataFactory.insertCommonData(TestDataFactory.APPT_S_RT_NAME);
        List<Appointment__c> appts = [SELECT Id, RecordTypeId FROM Appointment__c];
        System.assertEquals(1, appts.size());
        System.assertEquals(TestDataFactory.getRTId(TestDataFactory.APPT_S_RT_NAME, 'Appointment__c'), appts.get(0).RecordTypeId);
    }

    @IsTest
    static void insertCommonDataWithEApptTest() {
        TestDataFactory.insertCommonData(TestDataFactory.APPT_E_RT_NAME);
        List<Appointment__c> appts = [SELECT Id, RecordTypeId FROM Appointment__c];
        System.assertEquals(1, appts.size());
        System.assertEquals(TestDataFactory.getRTId(TestDataFactory.APPT_E_RT_NAME, 'Appointment__c'), appts.get(0).RecordTypeId);
    }

    @IsTest
    static void insertCommonDataWithIApptTest() {
        TestDataFactory.insertCommonData(TestDataFactory.APPT_I_RT_NAME);
        List<Appointment__c> appts = [SELECT Id, RecordTypeId FROM Appointment__c];
        System.assertEquals(1, appts.size());
        System.assertEquals(TestDataFactory.getRTId(TestDataFactory.APPT_I_RT_NAME, 'Appointment__c'), appts.get(0).RecordTypeId);
    }

    @IsTest
    static void insertCommonDataWithAllApptTest() {
        TestDataFactory.insertCommonData(TestDataFactory.APPT_ALL_RT);
        System.assertEquals(3, [SELECT Id FROM Appointment__c].size());
    }

    @IsTest
    static void buildCommonDataTest() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData()
            .initCommonData();
        
        Case caseGI = dBuilder.createCase('General_Info');
        caseGI.Case_subject__c = 'מועמד ל-360';

        Case case360 = dBuilder.createCase('Assuta_360');
        case360.Surgeon_Doctor__c = dBuilder.doctor.Id;
        case360.AccountId = dBuilder.patient.Id;

        Case caseS = dBuilder.createCase('caseS', 'Surgery');
        caseS.AccountId = dBuilder.patient.Id;
          
        dBuilder
            .addAccountDoctor('doctor1', TestDataFactory.D_ID_NUMBER_1)
            .addAccountPerson('person1', TestDataFactory.P_ID_NUMBER_1)
            .addCase('caseE', 'DOC_expert')
            .addCase('caseA', 'Appointments')
            .addCase('CaseAfterSale')
            .addCase('transfer_to_secretaries')
            .addProcedure('procI', '70551')
            .addProcedure('procE', '99400')
            .addProcedure('procS', '70124')
            .addAppoitment(TestDataFactory.APPT_I_RT_NAME, 'procI', 'caseA')
            .addAppoitment(TestDataFactory.APPT_E_RT_NAME, 'procE', 'caseE')
            .addAppoitment(TestDataFactory.APPT_S_RT_NAME, 'procS', 'caseS')
            .addDoctorsStatistics('procI')
            .addDoctorMedicalProcedure('procI')
            .addDocSite()
            .addCaseRecDoc('caseS')
            .addProcedureSite('procI')
            .addCalendarProcedure('procI')
            .addSequence('procI', 'procE')
            .addCalendar1(15, 32)
            .addGroup('Queue1', 'Queue')
            .addSiteDomain('Queue1')
            .addSurvey('survey1')
            .addSurveyQuestion('survey1')
            .addDocToAction('survey1')
            .addSurveyTaker('survey1', 'caseS', 'person1')
            .buildSurveyTaker('survey1', 'caseS', 'person1')
                .setField('activity_code__c', '76700')
                .build()
            .addGuidelines('guidline1')
            .buildGuidelines('guidline2')
                .setField('Status__c', 'active')
                .build()
            .addGuidanceScenario('procI', 'guidline1')
            .buidGuidanceScenario('procI', 'guidline1')
                .setField('Asthma__c', false)
                .build()
            .addImplantsToMedProd('procI')
            .buildImplantsToMedProd('procE')
                .setField('notes__c', 'Test notes')
                .build();

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @IsTest
    static void buildCommonDataBuildersKeyTest() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();

        dBuilder.initCommonData();
        Case case360 =  dBuilder.createCase('Assuta_360');
        case360.Surgeon_Doctor__c = dBuilder.doctor.Id;
        case360.AccountId = dBuilder.patient.Id;
        case360.Sub_Expertise__c = dBuilder.subExpertise.Id;
        case360.Expertise__c = dBuilder.expertise.Id;
        
        TestDataFactory.CommonData cData =  dBuilder.insertCommonData();

        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER LIMIT 1];
        Expertise__c expertise = [SELECT Id FROM Expertise__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        case360 = [SELECT Id, Surgeon_Doctor__c, Sub_Expertise__c, Expertise__c, AccountId FROM Case WHERE RecordTypeId = :TestDataFactory.getRTId('Assuta_360', 'Case') LIMIT 1];
        System.assertEquals(doctor.Id, case360.Surgeon_Doctor__c);
        System.assertEquals(patient.Id, case360.AccountId);
        System.assertEquals(expertise.Id, case360.Expertise__c);
        System.assertEquals(subExpertise.Id, case360.Sub_Expertise__c);

        cData.docClinic.Payer_Factor__c = cData.pFactor.Id;
        update cData.docClinic;

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CHILD_CODE LIMIT 1];
        Doctor_in_Clinic__c docClinic = [SELECT Id, Payer_Factor__c FROM Doctor_in_Clinic__c LIMIT 1];
        System.assertEquals(pFactor.Id, docClinic.Payer_Factor__c);
    }

    @IsTest
    static void buildCommonDataCreatePutTest() {
        TestDataFactory.DataBuilder dBuilder =  TestDataFactory.buildCommonData();

        dBuilder.pFactor.Insurance_Company__c = false;
        dBuilder.initCommonData();

        Case caseGI = dBuilder.createCase('General_Info');
        caseGI.Case_subject__c = 'מועמד ל-360';

        Case caseS = dBuilder.createCase('Surgery');
        caseS.AccountId = dBuilder.patient.Id;
        
        Case case360 = dBuilder.createCase('Assuta_360');
        case360.Surgeon_Doctor__c = dBuilder.doctor.Id;
        case360.AccountId = dBuilder.patient.Id;

        dBuilder.insertCommonData();

        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER LIMIT 1];

        caseGI = [SELECT Id, Case_subject__c FROM Case WHERE RecordTypeId = :TestDataFactory.getRTId('General_Info', 'Case') LIMIT 1];
        System.assertEquals('מועמד ל-360', caseGI.Case_subject__c);

        caseS = [SELECT Id, AccountId FROM Case WHERE RecordTypeId = :TestDataFactory.getRTId('Surgery', 'Case') LIMIT 1];
        System.assertEquals(patient.Id, caseS.AccountId);

        case360 = [SELECT Id, AccountId, Surgeon_Doctor__c FROM Case WHERE RecordTypeId = :TestDataFactory.getRTId('Assuta_360', 'Case') LIMIT 1];
        System.assertEquals(patient.Id, case360.AccountId);
        System.assertEquals(doctor.Id, case360.Surgeon_Doctor__c);

        Payer_Factor__c pFactor = [SELECT Id, Insurance_Company__c FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CHILD_CODE LIMIT 1];
        System.assertEquals(false, pFactor.Insurance_Company__c);
    }

    @IsTest
    static void buildCommonDataTest1() {
        String picture = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        String pictureURL = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';

        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData()
            .initCommonData()
            .buildAccountDoctor('doctor1')
                .setField('ID_Number__c', TestDataFactory.D_ID_NUMBER_1)
                .build()
            .buildAccountPerson('person1')
                .setPicture(picture)
                .setDoctorCode('0012661')
                .setField('ID_Number__c', TestDataFactory.P_ID_NUMBER_1)

                .setField('Picture_URL__c', pictureURL)
                .setField('Experts_center__c', true)
                .build();
            
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();

        List<Account> pers1 = [SELECT Id, ID_Number__c, Experts_center__c, Doctor_Code__c, Picture_URL__c, Picture__c FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER_1 LIMIT 1];
        System.assert(!pers1.isEmpty());

        System.assertEquals(TestDataFactory.P_ID_NUMBER_1, pers1.get(0).ID_Number__c);
        System.assertEquals(pictureURL, pers1.get(0).Picture_URL__c);
        System.assertEquals(true, pers1.get(0).Experts_center__c);
        System.assertEquals('0012661', pers1.get(0).Doctor_Code__c);
    }
}