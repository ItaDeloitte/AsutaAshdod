@isTest
private class LC_Case360ControllerTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Doctors_Emails_Hidden__c = 'docTestetst@fkd.dfs';
        doctor.Doctor_personal_phone__c = '0546354186';
        doctor.Doctors_Phones_Hidden__c = '0546354184';
        doctor.Email__c = 'do@fkd.dfs';
        insert doctor;

        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE, calendar.Id);
        insert site;
        Clinic__c clinic = new Clinic__c(Name = 'test', Site__c = site.Id, clinic_email__c = 'example@gmail.com');
        insert clinic;   
        insert new Doctor_in_Clinic__c(Clinic__c = clinic.Id, Doctors__c = doctor.Id);
        List<Expertise__c> expertises = new List<Expertise__c>{TestDataFactory.getExpertise(), TestDataFactory.getExpertise()};
        insert expertises;
        doctor.Expertise_1__c = expertises.get(0).Id;
        doctor.Expertise_2__c = expertises.get(1).Id; 
        update doctor;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertises.get(0).Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt;
        Recommendations_after_exam__c recommendations = TestDataFactory.getRecommendations(patient.Id, cas.Id);
        recommendations.Related_Appointment__c = appt.Id;
        recommendations.Referral_Doctor__c = doctor.Id;
        insert recommendations;
        insert new List<QuickText>{new QuickText(Message = '{!Case.IsClosed}', Name = '1'), new QuickText(Message = '{!Account.Name}', Name = '3')};
    }

    @isTest
    static void convert_Recommendation_Test() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'convert', 'recordId' => [SELECT Id FROM Recommendations_after_exam__c LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void convert_Case_Test() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'convert', 'recordId' => [SELECT Id FROM Case LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void convert_Exception_Test() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        try {
        	Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'convert', 'recordId' => [SELECT Id FROM Account LIMIT 1].Id});
        } catch (Exception e) {
            System.assertEquals('Something went wrong. Please, check button condition.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getCases', 'recordId' => [SELECT Id FROM Recommendations_after_exam__c LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void linkRecommendationTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'linkRecommendation', 'recordId' => [SELECT Id FROM Recommendations_after_exam__c LIMIT 1].Id, 'caseId' => [SELECT Id FROM Case LIMIT 1].Id
        });
        Test.stopTest();
    }

    @isTest
    static void getCloseDataTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getCloseData'});
        Test.stopTest();
    }

    @isTest
    static void closeRecommendationTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(
            new Map<String, Object>{'actionName' => 'closeRecommendation', 'recordId' => [SELECT Id FROM Recommendations_after_exam__c LIMIT 1].Id, 'closeReason' => 'הושלם'}
        );
        Test.stopTest();
    }

    @isTest
    static void getContactDoctorDataTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getContactDoctorData', 'recordId' => [SELECT Id FROM Case LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void doctorSearchTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'doctorSearch', 'keyWord' => TestDataFactory.KEYWORD});
        Test.stopTest();
    }

    @isTest
    static void getDoctorInfoTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getDoctorInfo', 'doctorId' => [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1].Id}
        );
        Test.stopTest();
    }

    @isTest
    static void contactDoctorTest() {
        Test.startTest();
        LC_Case360Controller controller = new LC_Case360Controller();
        Response res = controller.executeAction(
            new Map<String, Object>{
                'actionName' => 'contactDoctor',
                'recordId' => [SELECT Id FROM Case LIMIT 1].Id,
                'doctorId' => [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1].Id,
                'text' => 'test text',
                'phone' => '0937845346',
                'email' => 'test@test.com',
                'saveInfo' => true}
        );
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_Case360Controller controller = new LC_Case360Controller();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'ex'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION ex', e.getMessage());
        }
        Test.stopTest();
    }

    private class HttpGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": "success"}');
            response.setStatusCode(200);
            return response; 
        }
    }
}