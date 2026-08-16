/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Scheduling Screen Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public without sharing class LC_DoctorScreenTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.doctor.Experts_center__c = true;
        dBuilder.pFactor.Insurance_Company__c = false;
        dBuilder.oppt.AccountId = dBuilder.doctor.Id;
        dBuilder.initCommonData();

        Case caseE = dBuilder.createCase('caseE', 'DOC_expert');
        caseE.Channel__c = 'קופה';
        caseE.Expertise__c = dBuilder.expertise.Id;
        caseE.Sub_Expertise__c = dBuilder.subExpertise.Id;

        Medical_Procedure__c procedure =  dBuilder.createProcedure('proc1', '99400');

        dBuilder
            .addAppoitment(TestDataFactory.APPT_S_RT_NAME, 'proc1', 'caseE')
            .addDoctorMedicalProcedure('proc1')
            .addDoctorsStatistics('proc1')
            .addCaseRecDoc('caseE')
            .addDocSite();

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();

        cData.docClinic.Payer_Factor__c = cData.pFactor.Id;
        update cData.docClinic;

        caseE.Medical_Procedure__c = procedure.Id;
        update caseE;
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_DoctorScreenController().executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void isAvailableTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'isAvailable',
            'caseId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void initTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'init',
            'caseId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void searchExpertisesTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchExpertises',
            'caseId' => cas.Id,
            'keyword' => TestDataFactory.KEYWORD
        });
        Test.stopTest();
    }

    @IsTest
    static void searchSubExpertisesTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Expertise__c expertise = [SELECT Id FROM Expertise__c LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchSubExpertises',
            'caseId' => cas.Id,
            'expertiseId' => expertise.Id,
            'keyword' => TestDataFactory.KEYWORD
        });
        Test.stopTest();
    }

    @IsTest
    static void searchProceduresTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchProcedures',
            'caseId' => cas.Id,
            'subExpertiseId' => subExpertise.Id,
            'keyword' => TestDataFactory.KEYWORD
        });
        Test.stopTest();
    }

    @IsTest
    static void searchDoctorsTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Expertise__c expertise = [SELECT Id FROM Expertise__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchDoctors',
            'caseId' => cas.Id,
            'procedureId' => procedure.Id,
            'expertiseId' => expertise.Id,
            'subExpertiseId' => subExpertise.Id,
            'arrangments' => JSON.serialize(new List<String>{'3', '4'}),
            'onlyRecommended' => false
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainClosestAvailableSlotInfoTest() {
        Test.setMock(HttpCalloutMock.class, new ws_ClosestExpertAppointment.ws_ClosestExpertAppointmentHttpMock());
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Expertise__c expertise = [SELECT Id FROM Expertise__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainClosestAvailableSlotInfo',
            'caseId' => cas.Id,
            'doctorIds' => JSON.serialize(new Set<String>{doctor.Id}),
            'expertiseId' => expertise.Id,
            'subExpertiseId' => subExpertise.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void recommendDoctorsTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'recommendDoctors',
            'caseId' => cas.Id,
            'doctorIds' => JSON.serialize(new List<String>{doctor.Id})
        });
        Test.stopTest();
    }

    @IsTest
    static void sendDoctorAdvisorTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'sendDoctorAdvisor',
            'caseId' => cas.Id,
            'doctorIds' => JSON.serialize(new List<String>{doctor.Id})
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainClinicsTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME];
        Doctor_in_Clinic__c docClinic = [SELECT Id, Schedule_System__c, PayerFactorMulti__c FROM Doctor_in_Clinic__c LIMIT 1];
        docClinic.Schedule_System__c = 'QFlow';
        docClinic.PayerFactorMulti__c = '3';
        update docClinic;
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Calendar__c calendar = [SELECT Id, BranchName__c, Doctor__c FROM Calendar__c LIMIT 1];
        calendar.BranchName__c = site.Id;
        calendar.Doctor__c = doctor.Id;
        update calendar;
        Clinic__c clinic = [SELECT Id, Site__c FROM Clinic__c LIMIT 1];
        clinic.Site__c = site.Id;
        update clinic;
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        insert TestDataFactory.getCalendarProcedure(calendar.Id, procedure.Id);
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainClinics',
            'caseId' => cas.Id,
            'doctorId' => doctor.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void chooseClinicTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Doctor_in_Clinic__c docClinic = [SELECT Id FROM Doctor_in_Clinic__c LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'chooseClinic',
            'caseId' => cas.Id,
            'clinicId' => docClinic.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void scheduleTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_DoctorScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'schedule',
            'caseId' => cas.Id,
            'selectedDoctorId' => doctor.Id,
            'arrangementId' => '3',
            'doctorIds' => JSON.serialize(new List<String>{doctor.Id})
        });
        Test.stopTest();
    }
}