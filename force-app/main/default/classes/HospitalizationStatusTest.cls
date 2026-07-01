/*
    ERRORS
    Process Builder - change_appointment_status
    2nd condition
    update appointment__c.Patient_Hospitalization_Status__c to bad picklist value
*/
@isTest
public class HospitalizationStatusTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new CreatePatientMock());
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;

        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.Case_subject__c = 'עדכון תור קיים';
        cas.AccountId = patient.Id;
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Admission_Date__c = DateTime.now();
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Site__c = site.Id;
        insert appt;
    }

    @isTest
    static void admissionStatusTest() {
        Test.startTest();
        DateTime now = DateTime.now();
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Hospitalization_Status__e event = new Hospitalization_Status__e(
            Tafnit_Case_Number__c = '4658357',
            Appointment_ID__c = appt.Id,
            Status_Date_Time__c = now,
            Status_Code__c = '1'
        );
        Database.SaveResult result = EventBus.publish(event);
        Test.stopTest();
    }

    @isTest
    static void tafnitCaseCancelStatusTest() {
        Test.startTest();
        DateTime now = DateTime.now();
        Appointment__c appt = [SELECT Id, Admission_Date__c FROM Appointment__c LIMIT 1];

        Hospitalization_Status__e event = new Hospitalization_Status__e(
            Tafnit_Case_Number__c = '4658357',
            Appointment_ID__c = appt.Id,
            Status_Date_Time__c = now,
            Status_Code__c = '2'
        );
        Database.SaveResult result = EventBus.publish(event); 
        Test.stopTest();
    }

    @isTest
    static void patientReleaseStatusTest() {
        Test.startTest();
        DateTime now = DateTime.now();
        Appointment__c appt = [SELECT Id, Admission_Date__c FROM Appointment__c LIMIT 1];

        Hospitalization_Status__e event = new Hospitalization_Status__e(
            Tafnit_Case_Number__c = '4658357',
            Appointment_ID__c = appt.Id,
            Status_Date_Time__c = now,
            Status_Code__c = '3'
        );
        Database.SaveResult result = EventBus.publish(event); 
        Test.stopTest();
    }

    @isTest
    static void CancelOfTafnitCaseCancelStatusTest() {
        Test.startTest();
        DateTime now = DateTime.now();
        Appointment__c appt = [SELECT Id, Admission_Date__c FROM Appointment__c LIMIT 1];

        Hospitalization_Status__e event = new Hospitalization_Status__e(
            Tafnit_Case_Number__c = '4658357',
            Appointment_ID__c = appt.Id,
            Status_Date_Time__c = now,
            Status_Code__c = '4'
        );
        Database.SaveResult result = EventBus.publish(event); 
        Test.stopTest();
    }

    @isTest
    static void CancelOfpatientReleaseStatusTest() {
        Test.startTest();
        DateTime now = DateTime.now();
        Appointment__c appt = [SELECT Id, Admission_Date__c FROM Appointment__c LIMIT 1];

        Hospitalization_Status__e event = new Hospitalization_Status__e(
            Tafnit_Case_Number__c = '4658357',
            Appointment_ID__c = appt.Id,
            Status_Date_Time__c = now,
            Status_Code__c = '5'
        );
        Database.SaveResult result = EventBus.publish(event); 
        Test.stopTest();
    }
}