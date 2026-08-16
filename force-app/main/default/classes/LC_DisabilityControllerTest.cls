// Test for: LC_DisabilityController
@isTest
private class LC_DisabilityControllerTest {

    @testSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Contact_type__pc = 'עובד אסותא';
        insert patient;

        Contact con = TestDataFactory.getContact(doctor.Id);
        con.Contact_type__c = 'עובד אסותא';
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.AccountId = patient.Id;
        insert cas;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert appt;
        Disabilities__c disability = TestDataFactory.getDisability(patient.Id, '100');
        insert disability;
        insert new Medical_Aid_Appointment__c(Appointment__c = appt.Id, Patient__c = patient.Id, Disabilities__c = disability.Id);
        insert TestDataFactory.getCalendars1(31);
    }

    @isTest
    static void getSetDisabilitiesTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        LC_DisabilityController controller = new LC_DisabilityController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getDisabilities', 'caseId' => appt.Id, 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Response setRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setDisabilities', 'caseId' => cas.Id, 'jsonedParams' => JSON.serialize(getRes.responseObj), 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Test.stopTest();
    }

    @isTest
    static void getSetDisabilitiesUpdatedTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        LC_DisabilityController controller = new LC_DisabilityController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getDisabilities', 'caseId' => appt.Id, 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        for (LC_DisabilityController.MedicalAid aid_i : (List<LC_DisabilityController.MedicalAid>) getRes.responseObj) {
            for (LC_DisabilityController.Option assist_i : aid_i.assists) {
                assist_i.isSelected = assist_i.isSelected ? false : true;
            }
        }
        Response setRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setDisabilities', 'caseId' => cas.Id, 'jsonedParams' => JSON.serialize(getRes.responseObj), 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Test.stopTest();
    }

    @isTest
    static void getSetDisabilities7DaysTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id, Appointment_Date_Time__c FROM Appointment__c LIMIT 1];
        appt.Appointment_Date_Time__c = Date.today().addDays(3);
        update appt;

        Test.startTest();
        LC_DisabilityController controller = new LC_DisabilityController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getDisabilities', 'caseId' => appt.Id, 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Response setRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setDisabilities', 'caseId' => cas.Id, 'jsonedParams' => JSON.serialize(getRes.responseObj), 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Test.stopTest();
    }

    @isTest
    static void getSetDisabilities7DaysUpdatedTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id, Appointment_Date_Time__c FROM Appointment__c LIMIT 1];
        appt.Appointment_Date_Time__c = Date.today().addDays(3);
        update appt;

        Test.startTest();
        LC_DisabilityController controller = new LC_DisabilityController();
        Response getRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getDisabilities', 'caseId' => appt.Id, 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        for (LC_DisabilityController.MedicalAid aid_i : (List<LC_DisabilityController.MedicalAid>) getRes.responseObj) {
            for (LC_DisabilityController.Option assist_i : aid_i.assists) {
                assist_i.isSelected = assist_i.isSelected ? false : true;
            }
        }
        Response setRes = controller.executeAction(
            new Map<String, Object>{'actionName' => 'setDisabilities', 'caseId' => cas.Id, 'jsonedParams' => JSON.serialize(getRes.responseObj), 'appointmentIds' => JSON.serialize(new List<String>{appt.Id})}
        );
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_DisabilityController controller = new LC_DisabilityController();
        try {controller.executeAction(new Map<String, Object>{'actionName' => 'wrong'});} catch (Exception e) {}
        Test.stopTest();
    }
}