// Test for: UpdateCommunicationDetails
@isTest
private class UpdateCommunicationDetailsTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        insert TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(
            new UpdateCommunicationDetails(
                'SELECT Id, Case__c, Patient_Account__c, Patient_Account__r.Preferred_Channel__c, Patient_Account__r.SMS_Phone_Number__c, Patient_Account__r.PersonEmail, Patient_Account__r.Phone FROM Appointment__c'
            )
        );
        Test.stopTest();
    }
}