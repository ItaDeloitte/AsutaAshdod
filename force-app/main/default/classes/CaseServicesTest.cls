// Created: Evgeniy Kravchuk
// Updated date: 29.05.2019
@isTest
public class CaseServicesTest {

    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();

        Site__c site1 = TestDataFactory.getSite('85');
        insert site1;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Patient_has_open_case__c = false;
        patient.DisableValidation__c = true;
        patient.Primary_Site__c = site1.Id;
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.sched_sys_doc_clinics__c = 'RIS';
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Opportunity oppt = TestDataFactory.getOpportunity();
        oppt.AccountId = patient.Id;
        insert oppt;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactorParent;
        Payer_Factor__c pFactorChild1 = TestDataFactory.getPFactor('12345');
        pFactorChild1.Name_of_parent__c = pFactorParent.Id;
        insert pFactorChild1;
        Payer_Factor__c pFactorChild2 = TestDataFactory.getPFactor('54321');
        pFactorChild2.Name_of_parent__c = pFactorParent.Id;
        insert pFactorChild2;
        Agreement__c agreement = TestDataFactory.getAgreement(doctor.Id, pFactorChild1.Id);
        insert agreement;
        Arrangements__c arrangement = TestDataFactory.getArrangements(pFactorChild1.Id);
        insert arrangement;
        Doctor_Arrangement__c docArrangement = TestDataFactory.getDocArrangement(doctor.Id, arrangement.Id);
        insert docArrangement;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.NEW_DOCTOR_PROCEDURE_CODE);
        insert procedure;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild1.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Maccabi_Code__c = '101701';
        insert site;
        Appointment__c appt = TestDataFactory.getAppointmentExperts(procedure.Id, patient.Id, null, cas.Id); 
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Doctor_Account__c = doctor.Id;
        appt.Site__c = site.Id;
        insert appt;
        Survey__c survey = new Survey__c();
        insert survey;
        Survey_Question__c sq = new Survey_Question__c();
        sq.OrderNumber__c = 2;
        sq.Question__c = 'Can you please stop answering this survey for god sake?';
        sq.Type__c = 'RadioButton';
        sq.Survey__c = survey.id;
        insert sq;
        Doc_to_action__c dta = new Doc_to_action__c();
        dta.activity_code__c = TestDataFactory.NEW_DOCTOR_PROCEDURE_CODE;
        dta.status__c = true;
        dta.survey__c = survey.id;
        insert dta;
        survey_to_site__c sts = new survey_to_site__c();
        sts.site__c = site.Id;
        sts.Survey__c = survey.id;
        insert sts;
        SmsTemplate__c smsPartner = new SmsTemplate__c(
            developerName__c = 'IVF_Partner', 
            Sms_content__c = 'Test {0}', 
            apiNames__c = 'DigitalForm_IVF_Partner_Link__c', 
            ObjectName__c = 'Case__c'
        );
        SmsTemplate__c smsPatient = new SmsTemplate__c(
            developerName__c = 'IVF_Patient', 
            Sms_content__c = 'Test {0}', 
            apiNames__c = 'DigitalForm_IVF_Patient_Link__c', 
            ObjectName__c = 'Case__c'
        );
        insert new List<SmsTemplate__c>{smsPartner, smsPatient};
    }

    @isTest
    static void hasOpenCaseCheckTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        Test.startTest();
        Case cas = new Case(AccountId = patient.Id, Status = 'New');
        insert cas;
        System.assertEquals(true, [SELECT Id, Patient_has_open_case__c FROM Account WHERE Id = :patient.Id].Patient_has_open_case__c);

        delete cas;
        System.assertEquals(false, [SELECT Id, Patient_has_open_case__c FROM Account WHERE Id = :patient.Id].Patient_has_open_case__c);
        Test.stopTest();
    }

    @isTest
    static void updateStatusByOwnerTest() {
        Group queue = new Group(Name = 'Test queue', Type = 'Queue');
        insert queue;
        insert new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)) {
            
            Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
            Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Case cas = new Case(
                AccountId = patient.Id,
                Status = 'New',
                Origin = 'Chat',
                ContactId = con.Id,
                Case_subject__c = 'זימון תור חדש',
                Recommended_doc__c = doctor.Id,
                OwnerId = queue.Id,
                RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case'),
                Case_Recordtype_TMP__c = TestDataFactory.getRTId('DOC_expert', 'Case'),
                Send_DocAdvisor__c = true,
                preferd_chanal_case__c = 'SMS',
                SMS_Phone_Number__c = '0525518983',
                send_link_for_referral__c = false,
                Is_Donating__c = true
            );
            insert cas;
            Test.startTest();
            cas.OwnerId = UserInfo.getUserId();
            update cas;
            Test.stopTest();
        }
    }

    @isTest
    static void validateRecDoctorTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Payer_Factor__c pFactorParent = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Payer_Factor__c pFactorChild1 = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = '12345'];
        Payer_Factor__c pFactorChild2 = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = '54321'];
        Agreement__c agreement = [SELECT Id FROM Agreement__c LIMIT 1];
        Arrangements__c arrangement = [SELECT Id FROM Arrangements__c LIMIT 1];
        Doctor_Arrangement__c docArrangement = [SELECT Id FROM Doctor_Arrangement__c LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild2.Id);
        cas.Recommended_doc__c = doctor.Id;

        Test.startTest();
        insert cas;
        Test.stopTest();
    }

    @isTest
    static void completeMilestonesTest() {
        Case cas1 = new Case(Status = 'Closed');
        Case cas2 = new Case(
            Case_Status_Shikum_Bait__c = 'First_Visit_Scheduled',
            Case_Phase__c = 'In_Process',
            RecordTypeId = TestDataFactory.getRTId('Shikum_Bait', 'Case')
        );
        Test.startTest();
        insert new List<Case>{cas1, cas2};
        Test.stopTest();
    }

    @isTest
    static void changeOwnerToManagerTest() {
        Case cas = new Case(
            Status = 'Escalated', 
            help_transfer_to_manager__c = false, 
            First_user_to_own_the_case__c = UserInfo.getUserId());
        
        Test.startTest();
        insert cas;
        Test.stopTest();
    }

    @IsTest 
    static void sendOPTTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = new Case(
            send_OTP__c = true,
            SMS_Phone_Number__c = '0525518983', 
            ContactId = con.Id,
            AccountId = doctor.Id
        );
        
        Test.startTest();
        insert cas;
        cas.SMS_Phone_Number__c = null;
        cas.send_OTP__c = true;
        cas.email_from_patient__c = 'test@gmail.com';
        update cas;
        Test.stopTest();
    }

    @IsTest 
    static void createRecommendedDoctorTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        Test.startTest();
        Case oldCase = new Case(
            sub_case_subject__c = 'המלצה על רופא מומחה',
            AccountId = patient.Id
        );
        insert oldCase;

        Case_Recommended_Doctor__c docRecomen = new Case_Recommended_Doctor__c(
            Case__c = oldCase.Id,
            Doctor__c = doctor.Id
        );
        insert docRecomen;
        
        List<Case> caseToInsert = new List<Case>{
            new Case(
                sub_case_subject__c = 'זימון תור לאחר המלצה',
                AccountId = patient.Id,
                call_flow_connect_rec_case_to__c = false
            ),
            new Case(
                sub_case_subject__c = 'זימון תור לאחר המלצה',
                AccountId = patient.Id,
                call_flow_connect_rec_case_to__c = false
            )
        };
        insert caseToInsert;
        Test.stopTest();
        Case case1 = [SELECT Id, call_flow_connect_rec_case_to__c FROM Case WHERE Id = :caseToInsert.get(0).Id];
        System.assertEquals(true, case1.call_flow_connect_rec_case_to__c);
        Case case2 = [SELECT Id, call_flow_connect_rec_case_to__c FROM Case WHERE Id = :caseToInsert.get(1).Id];
        System.assertEquals(true, case2.call_flow_connect_rec_case_to__c);

        case1.call_flow_connect_rec_case_to__c = false;
        case2.call_flow_connect_rec_case_to__c = false;
        update new List<Case>{case1, case2};

        case1 = [SELECT Id, call_flow_connect_rec_case_to__c FROM Case WHERE Id = :caseToInsert.get(0).Id];
        System.assertEquals(true, case1.call_flow_connect_rec_case_to__c);
        case2 = [SELECT Id, call_flow_connect_rec_case_to__c FROM Case WHERE Id = :caseToInsert.get(1).Id];
        System.assertEquals(true, case2.call_flow_connect_rec_case_to__c);
    }

    @IsTest 
    static void setDoctorArrangementTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Arrangements__c arrangement = [SELECT Id FROM Arrangements__c LIMIT 1];
        Doctor_Arrangement__c docArrangement = [SELECT Id FROM Doctor_Arrangement__c WHERE Doctor__c = :doctor.Id AND Arrangement__c = :arrangement.Id];

        Test.startTest();
        doctor.Experts_center__c = true;
        update doctor;
        arrangement.Name = 'מומחים';
        update arrangement;

        Case caseDocExpert = new Case(
            Doctor_Arrangement__c = null,
            RecordTypeId = TestDataFactory.getRTId('DOC_expert', 'Case'), 
            Recommended_doc__c = doctor.Id
        );
        Case caseAssuta360 = new Case(
            Doctor_Arrangement__c = null, 
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case'), 
            Recommended_doc__c = doctor.Id
        );
        Case caseAfterSale = new Case(
            Doctor_Arrangement__c = null, 
            RecordTypeId = TestDataFactory.getRTId('CaseAfterSale', 'Case'), 
            Recommended_doc__c = doctor.Id
        );
        insert new List<Case> {caseDocExpert, caseAssuta360, caseAfterSale};
        Test.stopTest();

        caseDocExpert = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseDocExpert.Id];
        System.assertEquals(docArrangement.Id, caseDocExpert.Doctor_Arrangement__c);
        caseAssuta360 = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseAssuta360.Id];
        System.assertEquals(docArrangement.Id, caseAssuta360.Doctor_Arrangement__c);
        caseAfterSale = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseAfterSale.Id];
        System.assertEquals(docArrangement.Id, caseAfterSale.Doctor_Arrangement__c);

        caseDocExpert.Doctor_Arrangement__c = null;
        caseDocExpert.Recommended_doc__c = null;
        caseAssuta360.Doctor_Arrangement__c = null;
        caseAssuta360.Recommended_doc__c = null;
        caseAfterSale.Doctor_Arrangement__c = null;
        caseAfterSale.Recommended_doc__c = null;
        update new List<Case>{caseDocExpert, caseAssuta360, caseAfterSale};

        caseDocExpert.Recommended_doc__c = doctor.Id;
        caseAssuta360.Recommended_doc__c = doctor.Id;
        caseAfterSale.Recommended_doc__c = doctor.Id;
        update new List<Case>{caseDocExpert, caseAssuta360, caseAfterSale};

        caseDocExpert = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseDocExpert.Id];
        System.assertEquals(docArrangement.Id, caseDocExpert.Doctor_Arrangement__c);
        caseAssuta360 = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseAssuta360.Id];
        System.assertEquals(docArrangement.Id, caseAssuta360.Doctor_Arrangement__c);
        caseAfterSale = [SELECT Id, Doctor_Arrangement__c FROM Case WHERE Id = :caseAfterSale.Id];
        System.assertEquals(docArrangement.Id, caseAfterSale.Doctor_Arrangement__c);
    }

    @IsTest 
    static void setDoctorArrangmentNotPrivateHiddenTest() {
        Account doctor = [SELECT Id, (SELECT Id, Arrangement__r.PayerFactor__c, payer_for_arrangement__c FROM doc_arrangement__r) FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Payer_Factor__c pFactor = [SELECT Id, Name FROM Payer_Factor__c WHERE Id = :doctor.doc_arrangement__r.get(0).payer_for_arrangement__c];
        Doctor_Arrangement__c docArrange = [SELECT Id FROM Doctor_Arrangement__c WHERE Doctor__c = :doctor.Id AND payer_for_arrangement__c = :doctor.doc_arrangement__r.get(0).payer_for_arrangement__c];
       
        Test.startTest();
        pFactor.Name = 'פרטי';
        update pFactor;
        Case cas1 = new Case(
            Doctor_Arrangement__c = doctor.doc_arrangement__r.get(0).Id,
            Recommended_doc__c = doctor.Id,
            Channel__c = 'פרטי',
            PayerFactor__c = pFactor.Id
        );
        insert cas1;
        cas1.doc_arrangment_not_private_hidden__c = null;
        update cas1;
        Test.stopTest();
        cas1 = [SELECT Id, doc_arrangment_not_private_hidden__c FROM Case WHERE Id = :cas1.id];
        System.assertEquals(docArrange.Id, cas1.doc_arrangment_not_private_hidden__c);
    }

    @IsTest 
    static void fillFirstUserTest() {
        Case case1 = new Case(
            First_user_to_own_the_case__c = null, 
            OwnerId = UserInfo.getUserId()
        );

        insert case1;
        case1 = [SELECT Id, OwnerId, First_user_to_own_the_case__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(case1.OwnerId, case1.First_user_to_own_the_case__c);

        case1.First_user_to_own_the_case__c = null;
        update case1;
        case1 = [SELECT Id, OwnerId, First_user_to_own_the_case__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(case1.OwnerId, case1.First_user_to_own_the_case__c);
    }

    @IsTest 
    static void setPayerFactorTest() {
        Account doctor = [SELECT Id, payer_factor_ID__c, Insurer_factor__c, ID_Type__c FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        doctor.Other_Health_Services__c = '15';
        update doctor;

        doctor = [SELECT Id, payer_factor_ID__c, Insurer_factor__c, ID_Type__c FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        System.assert(doctor.payer_factor_ID__c != null);

        Case case1 = new Case(
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case'),
            PayerFactor__c = null,
            ContactId = con.Id,
            AccountId = doctor.Id
        );
        Case case2 = new Case(
            RecordTypeId = TestDataFactory.getRTId('DOC_expert', 'Case'),
            PayerFactor__c = null,
            ContactId = con.Id,
            AccountId = doctor.Id
        );
        insert new List<Case>{case1, case2};
        Test.stopTest();

        case1 = [SELECT Id, PayerFactor__c FROM Case WHERE Id = :case1.Id];
        System.assert(case1.PayerFactor__c != null);
        System.assertEquals(doctor.payer_factor_ID__c, case1.PayerFactor__c);

        case2 = [SELECT Id, PayerFactor__c FROM Case WHERE Id = :case2.Id];
        System.assert(case2.PayerFactor__c != null);
        System.assertEquals(doctor.payer_factor_ID__c, case2.PayerFactor__c);

        case1.PayerFactor__c = null;
        case2.PayerFactor__c = null;
        update new List<Case>{case1, case2};

        case1 = [SELECT Id, PayerFactor__c FROM Case WHERE Id = :case1.Id];
        System.assert(case1.PayerFactor__c != null);
        System.assertEquals(doctor.payer_factor_ID__c, case1.PayerFactor__c);

        case2 = [SELECT Id, PayerFactor__c FROM Case WHERE Id = :case2.Id];
        System.assert(case2.PayerFactor__c != null);
        System.assertEquals(doctor.payer_factor_ID__c, case2.PayerFactor__c);
    }

    @IsTest 
    static void sendDocAdvisorTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        insert new List<Case> {
            new Case(
                Send_DocAdvisor__c = true,
                RecordTypeId = TestDataFactory.getRTId('DOC_expert', 'Case'), 
                preferd_chanal_case__c = 'SMS', 
                SMS_Phone_Number__c = '0525518983', 
                ContactId = con.Id
            ),
            new Case(
                Send_DocAdvisor__c = true, 
                RecordTypeId = TestDataFactory.getRTId('CaseAfterSale', 'Case'), 
                preferd_chanal_case__c = 'Email', 
                email_from_patient__c = 'test@gmail.com', 
                ContactId = con.Id
            )
        };
        Test.stopTest();    
    }

    @IsTest 
    static void closing360Test() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        patient.X360_patient_checkbox__c = true;
        update patient;
        Case cas = new Case(
            Status = 'New', 
            AccountId = patient.Id, 
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case')
        );
        
        Test.startTest();
        insert cas;
        patient.Case_360__c = cas.Id;
        update patient;
        cas.Reason = 'Test';
        cas.Status = 'סגירת אירוע אוטומטית';
        update cas;
        Test.stopTest();
    }

    @IsTest 
    static void setContactDoctorTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];

        Test.startTest();
        insert new Case(
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case'),
            surgeon_doctor__c = doctor.Id,
            Contact_doctor__c = null
        );
        Test.stopTest();
    }

    @IsTest 
    static void markCaseAsReturningTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        Test.startTest();    
        insert new Case(
            AccountId = patient.Id, 
            sub_case_subject__c = 'זימון תור חדש',
            RecordTypeId = TestDataFactory.getRTId('transfer_to_secretaries', 'Case')
        );  
        insert new Case(
            AccountId = patient.Id, 
            sub_case_subject__c = 'זימון תור חדש'
        );
        Test.stopTest();
    }

    @IsTest 
    static void sendLinkForReferralTest() {
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
     
        Test.startTest();
        insert new List<Case> {
            new Case(
                ContactId = con.Id,
                send_link_for_referral__c = true,
                preferd_chanal_case__c = 'SMS',
                SMS_Phone_Number__c = '0525518983'
            ),
            new Case(
                ContactId = con.Id,
                send_link_for_referral__c = true,
                preferd_chanal_case__c = 'Email',
                email_from_patient__c = 'test@gmail.com'
            )
        };
        Test.stopTest();
    }

    @IsTest
    static void createAgentSurveyTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        String caseJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/Case/5002600000O3pYSAAZ"},"Id":"5002600000O3pYSAAZ","Status":"New","CreatedDate":"2021-10-01T17:54:26.000+0000"}'; 
        Case c = (Case) JSON.deserialize(caseJSON, Case.class); 
        System.debug('Test case:' + c.createdDate); 
        System.debug('Test caseId:' + c.Id); 
        System.debug('Test caseStatus:' + c.status); 

        Case closedInstitutesCase = new Case(
           // Id = c.Id,
            Status = 'New', 
            AccountId = patient.Id,
            Dont_send_survey__c = false,
            RecordTypeId = TestDataFactory.getRTId('ClosedInstitutes', 'Case')
        );
        Case opptCase = new Case(
            Status = 'New', 
            Opportunity__c = oppt.Id
        );
        
        Test.startTest();
        insert new List<Case>{
            closedInstitutesCase,
            opptCase
        };
        closedInstitutesCase.Status = 'Closed';
        opptCase.Status= 'Closed';
        update new List<Case> {
            closedInstitutesCase,
            opptCase
        };
        Test.stopTest();
    }

    @IsTest 
    static void fill360CoordinatorTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Case cas = new Case(
            Status = 'New', 
            AccountId = patient.Id, 
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case')
        );
        
        Test.startTest();
        insert cas;
        patient.Case_360__c = cas.Id;
        patient.X360_Coordinator__c = null;
        update patient;
        cas.First_user_to_own_the_case__c = UserInfo.getUserId();
        update cas;
        Test.stopTest();
    }

    @IsTest
    static void setBiopsyResultsTest() {
        Case cas = new Case(
            Status = 'ממתין לתוצאות ביופסיה', 
            biopsy_result__c = 'חיובי', 
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case')
        );

        Test.startTest();
        insert cas;
        Test.stopTest();
    }

    @IsTest 
    static void setAppointmentToDoctorTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        insert new Case(
            RecordTypeId = TestDataFactory.getRTId('DOC_expert', 'Case'),
            AccountId = patient.Id,
            Recommended_doc__c = doctor.Id
        );
        Test.stopTest();
    }

    @IsTest
    static void fillContactTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Case cas = new Case(Status = 'New');
        
        Test.startTest();
        insert cas;
        cas.AccountId = patient.Id;
        update cas;
        Test.stopTest();
    }

    @IsTest
    static void fillPartnerInfoTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Case cas = new Case(Status = 'New', Partner_Name__c = patient.Id);
         
        Test.startTest();
        insert cas;
        Test.stopTest();
    }

    @IsTest
    static void setCurrentUserAsOwnerTest() {
        Test.startTest();
        insert new List<Case>{
            new Case(
                Status = 'In_Progress', 
                Case_Status_Shikum_Bait__c = 'New',
                Case_Phase__c = 'New',
                RecordTypeId = TestDataFactory.getRTId('PublicInquiries', 'Case')
            ),
            new Case(
                Status = 'In_Progress', 
                Case_Status_Shikum_Bait__c = 'New',
                Case_Phase__c = 'New',
                RecordTypeId = TestDataFactory.getRTId('IVF_Freezing_Eggs', 'Case')
            ),
            new Case(
                Case_Status_Shikum_Bait__c = 'New',
                Case_Phase__c = 'New',
                RecordTypeId = TestDataFactory.getRTId('Shikum_Bait', 'Case')
            )
        };
        Test.stopTest();
    }

    @IsTest 
    static void createDailyTasksLogIVFTest() {
        Test.startTest();
        insert new List<Case>{
            new Case(
                Send_Man_Kit__c = true, 
                male_identification_answer__c = 'test'),
            new Case(
                Send_First_Kit__c = true,
                female_identification_answer__c = 'test'),
            new Case(Case_Stage__c = 'Decision'),
            new Case(Partner_Stage__c = 'Decision'),
            new Case(Female_Stage__c = 'Decision'),
            new Case(Payment_Done__c = true),
            new Case(
                Status = 'Closed', 
                RecordTypeId = TestDataFactory.getRTId('IVF_Freezing_Eggs', 'Case')),
            new Case(
                Sensitive_Case__c = true, 
                RecordTypeId = TestDataFactory.getRTId('IVF_Freezing_Eggs', 'Case'))
        };
        Test.stopTest();
    }

    @IsTest
    static void fillDecisionStageDateTest() { 
        Case case1 = new Case(Case_Stage__c = 'Decision', Case_Status__c = 'Research_Donation');
        Case case2 = new Case(Case_Stage__c = 'Decision', Case_Status__c = 'UnControlled_Defrost');
        Case case3 = new Case(Case_Stage__c = 'Decision', Case_Status__c = 'No_Conception_HealthDepartment_Transfer');
        
        Test.startTest();
        insert new List<Case>{
            case1,
            case2,
            case3
        };

        Test.stopTest();
        case1 = [SELECT Id, Research_Transfer_Date__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(System.today(), case1.Research_Transfer_Date__c);
        case2 = [SELECT Id, Thawing_Date__c FROM Case WHERE Id = :case2.Id];
        System.assertEquals(System.today(), case2.Thawing_Date__c);
        case3 = [SELECT Id, Ministry_Of_Health_Transfer_Date__c FROM Case WHERE Id = :case3.Id];
        System.assertEquals(System.today(), case3.Ministry_Of_Health_Transfer_Date__c);

        case1.Research_Transfer_Date__c = null;
        case2.Thawing_Date__c = null;
        case3.Ministry_Of_Health_Transfer_Date__c = null;
        update new List<Case>{case1, case2, case3};

        case1 = [SELECT Id, Research_Transfer_Date__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(System.today(), case1.Research_Transfer_Date__c);
        case2 = [SELECT Id, Thawing_Date__c FROM Case WHERE Id = :case2.Id];
        System.assertEquals(System.today(), case2.Thawing_Date__c);
        case3 = [SELECT Id, Ministry_Of_Health_Transfer_Date__c FROM Case WHERE Id = :case3.Id];
        System.assertEquals(System.today(), case3.Ministry_Of_Health_Transfer_Date__c);
    }

    @IsTest
    static void fillPayerRecommendationTest() {
        List<Case> casesToInsert = new List<Case> {
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'Payed_Freezing', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'Payed_Freezing'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'Payed_Freezing', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'UnControlled_Defrost'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'UnControlled_Defrost', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'Payed_Freezing'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'UnControlled_Defrost', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'Research_Donation'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'UnControlled_Defrost', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'UnControlled_Defrost'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Decision', 
                Female_Status__c = 'Research_Donation', 
                Partner_Stage__c = 'Decision', 
                Partner_Status__c = 'Research_Donation'
            ),
            new Case(
                Case_Route__c = 'Seperate_Route', 
                Female_Stage__c = 'Documents_Management', 
                Female_Status__c = 'No_Reply', 
                Partner_Stage__c = 'Documents_Management', 
                Partner_Status__c = 'No_Reply'
            )   
        };
         
        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, Payer__c, Recommendation__c FROM Case WHERE Id IN :casesToInsert]);
        System.assertEquals('יש לבדוק', cases.get(casesToInsert[0].Id).Payer__c);
        System.assertEquals('Payment_Freezing', cases.get(casesToInsert[0].Id).Recommendation__c);
        System.assertEquals('Woman', cases.get(casesToInsert[1].Id).Payer__c);
        System.assertEquals('Payment_Freezing', cases.get(casesToInsert[1].Id).Recommendation__c);
        System.assertEquals('Man', cases.get(casesToInsert[2].Id).Payer__c);
        System.assertEquals('Payment_Freezing', cases.get(casesToInsert[2].Id).Recommendation__c);
        System.assertEquals('לא רלוונטי', cases.get(casesToInsert[3].Id).Payer__c);
        System.assertEquals('HealthDepartment _Reference_defrost_Approval_Request', cases.get(casesToInsert[3].Id).Recommendation__c);
        System.assertEquals('לא רלוונטי', cases.get(casesToInsert[4].Id).Payer__c);
        System.assertEquals('Defrost', cases.get(casesToInsert[4].Id).Recommendation__c);
        System.assertEquals('לא רלוונטי', cases.get(casesToInsert[5].Id).Payer__c);
        System.assertEquals('Research_Transfer', cases.get(casesToInsert[5].Id).Recommendation__c);
        System.assertEquals('לא רלוונטי', cases.get(casesToInsert[6].Id).Payer__c);
        System.assertEquals('Repeating_Trials', cases.get(casesToInsert[6].Id).Recommendation__c);

        cases.get(casesToInsert[0].Id).Payer__c = null;
        cases.get(casesToInsert[0].Id).Recommendation__c = null;
        update new List<Case>{cases.get(casesToInsert[0].Id)};
        
        cases = new Map<Id, Case>([SELECT Id, Payer__c, Recommendation__c FROM Case WHERE Id IN :casesToInsert]);
        System.assertEquals('יש לבדוק', cases.get(casesToInsert[0].Id).Payer__c);
        System.assertEquals('Payment_Freezing', cases.get(casesToInsert[0].Id).Recommendation__c);
    }

    @IsTest
    static void fillFirstNameTest() {
        Account patient = [SELECT Id, FirstName FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        System.assert(patient.FirstName != null);
        Case caseFemale = new Case(
            AccountId = patient.Id, 
            First_Call_Made_Female__c = true,   
            First_Call_Made_Partner__c = false
        );
        Case casePartner = new Case(
            AccountId = patient.Id, 
            First_Call_Made_Female__c = false,   
            First_Call_Made_Partner__c = true,
            Partner_Name__c = patient.Id
        );
        Test.startTest();
        insert new List<Case>{caseFemale, casePartner};

        caseFemale = [SELECT Id, Female_First_Name__c FROM Case WHERE Id = :caseFemale.Id];
        System.assertEquals(patient.FirstName, caseFemale.Female_First_Name__c);
        casePartner = [SELECT Id, Male_First_Name__c FROM Case WHERE Id = :casePartner.Id];
        System.assertEquals(patient.FirstName, casePartner.Male_First_Name__c);
        Test.stopTest();
    }

    @IsTest 
    static void sendCustomNotificationTest() {
        User usr1 = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND LastName != 'SSIS' LIMIT 1];
        Case cas = new Case(
            OwnerId = UserInfo.getUserId(),
            Origin = 'פייסבוק מסנג\'ר'
        );

        Test.startTest();
        insert cas;
        cas.OwnerId = usr1.Id;
        update cas;
        Test.stopTest();
    }

    @IsTest
    static void sendManKitEmailTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account patient = [SELECT Id, FirstName FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        Case case1 = new Case(
            ContactId = con.Id,
            Send_Man_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            Partner_Email__c = 'test@gmail.com',
            male_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null,
            Primary_Phone_Partner__c = '0525518983',
            Partner_Name__c = patient.Id
        );
        Case case2 = new Case(
            ContactId = con.Id,
            Send_Man_Kit__c = true, 
            Case_site__c = 'Rishon_Letzion', 
            Partner_Email__c = 'test@gmail.com',
            male_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null,
            Primary_Phone_Partner__c = '0525518983',
            Partner_Name__c = patient.Id
        );

        Test.startTest();
        insert new List<Case>{case1, case2};
        Test.stopTest();

        case1 = [SELECT Id, Kit_Sent_Partner__c, Send_Man_Kit__c, Kit_Sending_Date_Partner_IVF__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(true, case1.Kit_Sent_Partner__c);
        System.assertEquals(false, case1.Send_Man_Kit__c);
        System.assert(case1.Kit_Sending_Date_Partner_IVF__c != null);

        case2 = [SELECT Id, Kit_Sent_Partner__c, Send_Man_Kit__c, Kit_Sending_Date_Partner_IVF__c FROM Case WHERE Id = :case2.Id];
        System.assertEquals(true, case2.Kit_Sent_Partner__c);
        System.assertEquals(false, case2.Send_Man_Kit__c);
        System.assert(case2.Kit_Sending_Date_Partner_IVF__c != null);
    }

    @IsTest 
    static void sendFirstKitEmailTest() {
        Account patient = [SELECT Id, FirstName FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case case1 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Seperate_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            Partner_Name__c = patient.Id,
            Primary_Phone_Partner__c = '0525518983',
            Partner_Email__c = 'test@gmail.com', 
            First_Call_Made_Partner__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case2 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Seperate_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Rishon_Letzion', 
            Partner_Name__c = patient.Id,
            Primary_Phone_Partner__c = '0525518983',
            Partner_Email__c = 'test@gmail.com', 
            First_Call_Made_Partner__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case3 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Seperate_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Rishon_Letzion', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case4 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Seperate_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com',
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case5 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Double_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case6 = new Case(               
            ContactId = con.Id,
            Case_Route__c = 'Double_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Rishon_Letzion', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case7 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Donation_Route', 
            Send_First_Kit__c = true, 
            Case_site__c = 'Rishon_Letzion', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case8 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Donation_Route',
            Send_First_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Partner_IVF__c = null
        );
        Case case9 = new Case(
            ContactId = con.Id,
            Case_Route__c = 'Seperate_Route',
            Send_First_Kit__c = true, 
            Case_site__c = 'Ramat_Hahayal', 
            AccountId = patient.Id,
            SMS_Phone_Number__c = '0525518983',
            email_from_patient__c = 'test@gmail.com', 
            First_Call_Made_Female__c = true,
            female_identification_answer__c = 'test',
            Kit_Sending_Date_Female_IVF__c = null,
            Kit_Sending_Date_Partner_IVF__c = null,
            Partner_Email__c = 'test@gmail.com', 
            First_Call_Made_Partner__c = true
        );
      
        Test.startTest();
        insert new List<Case>{case1, case2, case3, case4, case5, case6, case7, case8, case9};
        Test.stopTest();
       
        case1 = [SELECT Id, Kit_Sending_Date_Partner_IVF__c, Kit_Sent_Partner__c, Send_First_Kit__c, Partner_Name__c FROM Case WHERE Id = :case1.Id];
        System.assert(case1.Kit_Sending_Date_Partner_IVF__c != null);
        System.assertEquals(true, case1.Kit_Sent_Partner__c);
        System.assertEquals(false, case1.Send_First_Kit__c);

        case2 = [SELECT Id, Kit_Sending_Date_Partner_IVF__c, Kit_Sent_Partner__c, Send_First_Kit__c, Partner_Name__c FROM Case WHERE Id = :case2.Id];
        System.assert(case2.Kit_Sending_Date_Partner_IVF__c != null);
        System.assertEquals(true, case2.Kit_Sent_Partner__c);
        System.assertEquals(false, case2.Send_First_Kit__c);

        case3 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Female__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case3.Id];
        System.assert(case3.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case3.Kit_Sent_Female__c);
        System.assertEquals(false, case3.Send_First_Kit__c);
       
        case4 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Female__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case4.Id];
        System.assert(case4.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case4.Kit_Sent_Female__c);
        System.assertEquals(false, case4.Send_First_Kit__c);

        case5 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Couple__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case5.Id];
        System.assert(case5.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case5.Kit_Sent_Couple__c);
        System.assertEquals(false, case5.Send_First_Kit__c);

        case6 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Couple__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case6.Id];
        System.assert(case6.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case6.Kit_Sent_Couple__c);
        System.assertEquals(false, case6.Send_First_Kit__c);
       
        case7 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Couple__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case7.Id];
        System.assert(case7.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case7.Kit_Sent_Couple__c);
        System.assertEquals(false, case7.Send_First_Kit__c);
      
        case8 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sent_Couple__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case8.Id];
        System.assert(case8.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case8.Kit_Sent_Couple__c);
        System.assertEquals(false, case8.Send_First_Kit__c);

        case9 = [SELECT Id, Kit_Sending_Date_Female_IVF__c, Kit_Sending_Date_Partner_IVF__c, Kit_Sent_Female__c, Kit_Sent_Partner__c, Send_First_Kit__c, AccountId FROM Case WHERE Id = :case9.Id];
        System.assert(case9.Kit_Sending_Date_Female_IVF__c != null);
        System.assertEquals(true, case9.Kit_Sent_Female__c);
        System.assert(case9.Kit_Sending_Date_Partner_IVF__c != null);
        System.assertEquals(true, case9.Kit_Sent_Partner__c);
        System.assertEquals(false, case9.Send_First_Kit__c);
    }

    @IsTest 
    static void createSecondReminderTaskTest() {
        List<Task> tasksBefore = [SELECT Id FROM Task];

        Case case1 = new Case(Second_Reminder_Sent_Female_Couple__c = true);
        Case case2 = new Case(Second_Reminder_Sent_Partner__c = true);
        
        Test.startTest();
        insert new List<Case>{case1, case2};
        Test.stopTest();

        List<Task> tasksAfter = [SELECT Id FROM Task];
        System.assertEquals(tasksBefore.size() + 2, tasksAfter.size());
    }

    @IsTest 
    static void createDocumentsReceivedTaskTest() {
        Test.startTest();
        insert new List<Case> {
            new Case(
                Last_file_attachment_date_Female__c = System.now(), 
                Case_Route__c = 'Seperate_Route', 
                Female_Status__c = 'Documents_Holds', 
                Female_Stage__c = 'Documents_Management'
            ),
            new Case(
                Last_file_attachment_date_Partner__c = System.now(), 
                Case_Route__c = 'Seperate_Route', 
                Partner_Stage__c = 'Documents_Management', 
                Partner_Status__c = 'Documents_Holds'
            ),
            new Case(
                Last_file_attachment_date_Female__c = System.now(), 
                Case_Route__c = 'Donation_Route', 
                Case_Stage__c = 'Documents_Management', 
                Case_Status__c = 'Documents_Holds'
            )                  
        };
        Test.stopTest();
    }

    @IsTest 
    static void sendShikumBaitStatusChangedTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        doctor.Doctor_personal_phone__c = '0525518983';
        update doctor;
        Case cas = new Case(
            ContactId = con.Id,
            Case_Status_Shikum_Bait__c = 'Pending_Doctor_Approval', 
            Case_Phase__c = 'Service_Adaption', 
            Approving_Doctor_Name__c = doctor.Id, 
            RecordTypeId = TestDataFactory.getRTId('Shikum_Bait', 'Case')
        );

        Test.startTest();
        insert cas;
        cas.Case_Status_Shikum_Bait__c = 'Received_Doctor_Response';
        cas.OwnerId = UserInfo.getUserId();
        update cas;
        Test.stopTest();
    }
    
    @IsTest 
    static void updateShikumBaitStatusTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case cas = new Case(
            ContactId = con.Id,
            Shikum_Bait_Approval__c = 'Approves_Shikum', 
            RecordTypeId = TestDataFactory.getRTId('Shikum_Bait', 'Case')
        );

        Test.startTest();
        insert cas;
        cas.Shikum_Bait_Approval__c = 'Not_Approved_Shikum';
        update cas;
        cas.Shikum_Bait_Approval__c = null;
        cas.Release_Date__c = System.now() + 31;
        cas.OwnerId = UserInfo.getUserId();
        update cas;
        Test.stopTest();
    }
    
    @IsTest
    static void fillAccountTest() {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];
        oppt.AccountId = patient.Id;
        update oppt;

        Case opptCase = new Case(Status = 'New', Opportunity__c = oppt.Id );

        Test.startTest();
        insert opptCase;        
        Test.stopTest();
    }   

    /*@IsTest
    static void validateCaseDoctorSiteTest(){
        Site__c site1 = [SELECT Id FROM Site__c WHERE Site_Code__c ='85' LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.Developername = 'PersonAccount' LIMIT 1];
        patient.Patient_has_open_case__c = false;
        patient.DisableValidation__c = true;
        patient.Primary_Site__c = site1.Id;
        List<String> unsupportedProfiles = new List<String>{'System Administrator','SalesForceDoctors','Integration Profile'};
        Account patient1 = [SELECT Id FROM Account WHERE Recordtype.developername='PersonAccount' LIMIT 1];
        List<Case> caseList = [SELECT Id FROM Case];
        Case c1 = new Case(
            Memo_refferal_doctor__c=patient1.Id,
            RecordTypeId = TestDataFactory.getRTId('Medical_staff', 'Case')
        );
        Test.startTest();
        try{
            insert c1;
        }catch(Exception e){
            System.debug(e.getTypeName());
        }
        List<Case> caseListNew = [SELECT Id FROM Case];
        Profile currProfile = [SELECT Id,Name FROM Profile WHERE Id=:userinfo.getProfileid()];
        if(unsupportedProfiles.contains(currProfile.Name)){
            System.assertEquals(1,caseListNew.size());
        }else{
            System.assertEquals(0,caseListNew.size());
        }
        Test.stopTest();
    }*/
}