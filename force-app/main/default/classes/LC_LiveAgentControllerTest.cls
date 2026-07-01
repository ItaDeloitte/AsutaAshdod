// 
@isTest
private class LC_LiveAgentControllerTest {
    @TestSetup
    static void makeData(){
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        insert TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        insert TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        Calendar1__c calendar1 = TestDataFactory.getCalendar1();
        calendar1.business_day__c = true;
        insert calendar1;
        insert TestDataFactory.getProcedurePlan();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Agreement__c agreement = TestDataFactory.getAgreement(doctor.Id, pFactor.Id);
        agreement.Type_of_agreement__c = 'Surgery';
        insert agreement;
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        clinic.Site__c = site.Id;
        insert clinic;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
    }

    @IsTest
    static void getFormDataTest() {
        Test.startTest();
        LC_LiveAgentController controller = new LC_LiveAgentController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getFormData'});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_LiveAgentController controller = new LC_LiveAgentController();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'ex'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION ex', e.getMessage());
        }
        Test.stopTest();
    }
}