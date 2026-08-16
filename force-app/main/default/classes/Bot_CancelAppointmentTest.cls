// Created: Evgeniy Kravchuk
// Date: 03.01.2020
// Test for: Bot_CancelAppointment
@isTest
private class Bot_CancelAppointmentTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
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
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        insert TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
    }

    @isTest
    static void cancelAppointmentsTest() {
        Bot_CancelAppointment.CancelAppointmentRequestWrapper wrapper = new Bot_CancelAppointment.CancelAppointmentRequestWrapper();
        wrapper.appointmentId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        Test.startTest();
        Bot_CancelAppointment.cancelAppointments(new List<Bot_CancelAppointment.CancelAppointmentRequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void cancelAppointmentsException1Test() {
        Bot_CancelAppointment.CancelAppointmentRequestWrapper wrapper = new Bot_CancelAppointment.CancelAppointmentRequestWrapper();
        wrapper.appointmentId = '';

        Test.startTest();
        try {
            Bot_CancelAppointment.cancelAppointments(new List<Bot_CancelAppointment.CancelAppointmentRequestWrapper>{wrapper});
        } catch (Exception e) {}
        Test.stopTest();
    }
    
    @isTest
    static void cancelAppointmentsException2Test() {
        Test.startTest();
        try {
            Bot_CancelAppointment.cancelAppointments(new List<Bot_CancelAppointment.CancelAppointmentRequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }
}