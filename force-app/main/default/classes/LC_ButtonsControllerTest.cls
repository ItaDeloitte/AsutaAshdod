@IsTest
public class LC_ButtonsControllerTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Expertise_1__c = expertise.Id;
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        insert TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        Opportunity oppt = TestDataFactory.getOpportunity();
        oppt.AccountId = patient.Id;
        insert oppt;
    }

    @IsTest
    static void exceptionTest() {
        try {
            new LC_ButtonsController().executeAction(new Map<String, String>{
                'actionName' => 'exception'
            });
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION exception', e.getMessage());
        }
    }

    @IsTest
    static void getAppointmentApprovalTest() {   
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
                
        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'getAppointmentApproval',
            'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void sendDocAdvisorTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'sendDocAdvisor',
            'caseId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void sendPreAppointmentFormTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'sendPreAppointmentForm',
            'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void retriveSubExpertisesTest() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'retriveSubExpertises',
            'accountId' => acct.Id,
            'expertiseName' => 'test'
        });
        Test.stopTest();
    }

    @IsTest
    static void setSubExpertiseTest() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'setSubExpertise',
            'accountId' => acct.Id,
            'subExpertiseId' => subExpertise.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void transferToManagerTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        try {
            new LC_ButtonsController().executeAction(new Map<String, String>{
                'actionName' => 'transferToManager',
                'caseId' => cas.Id
            });
        } catch (Exception e) {
            System.assertEquals(Label.agent_doesnt_have_a_manager, e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void sendOTPTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'sendOTP',
            'recordId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void sendOTPTest2() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'sendOTP',
            'recordId' => oppt.Id
        });
        Test.stopTest();
    }

    // @IsTest
    // static void uploadFilesToClinicTest() {
    //     Case cas = [SELECT Id FROM Case LIMIT 1];

    //     Test.startTest();
    //     new LC_ButtonsController().executeAction(new Map<String, String>{
    //         'actionName' => 'uploadFilesToClinic',
    //         'caseId' => cas.Id
    //     });
    //     Test.stopTest();
    // }

    @IsTest
    static void hasFutureAppointmentsTest() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'hasFutureAppointments',
            'recordId' => acct.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void createCaseTest() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'createCase',
            'recordId' => acct.Id,
            'action' => 'create'
        });
        Test.stopTest();
    }

    @IsTest
    static void createCaseTest2() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        new LC_ButtonsController().executeAction(new Map<String, String>{
            'actionName' => 'createCase',
            'recordId' => oppt.Id,
            'action' => 'update'
        });
        Test.stopTest();
    }
}