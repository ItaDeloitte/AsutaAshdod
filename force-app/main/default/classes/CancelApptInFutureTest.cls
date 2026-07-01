// Test for: CancelApptInFuture
@isTest
private class CancelApptInFutureTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Appointment__c appt1 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt1.Accession_Number__c = 'R12345';
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        insert new List<Appointment__c>{appt1, appt2};
    }

    @isTest
    static void executeTest() {
        Set<Id> apptIds = new Set<Id>();
        for (Appointment__c appt_i : [SELECT Id FROM Appointment__c]) {
            apptIds.add(appt_i.Id);
        }
        Test.startTest();
        CancelApptInFuture.execute(apptIds, '4', 'ביטול המטופל');
        Test.stopTest();
    }
}