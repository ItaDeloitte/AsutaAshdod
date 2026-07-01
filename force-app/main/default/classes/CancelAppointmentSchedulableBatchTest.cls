@isTest
public with sharing class CancelAppointmentSchedulableBatchTest {

    @TestSetup
    static void makeData() {
        Calendar__c calendar = TestDataFactory.getCalendar();
        insert calendar;

        List<Account> patients = new List<Account>();

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        patients.add(patient);
        
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.Mailing_approval__c = 'מאשר דיוור - הכל';
        patient2.ID_Number__c = '999658578';
        patients.add(patient2);
        
        Account patient3 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient3.Mailing_approval__c = 'מאשר דיוור - הכל';
        patient3.ID_Number__c = '999650781';
        patients.add(patient3);

        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;
        insert patients;

        Domain__c domain = TestDataFactory.getDomain();
        insert domain;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;

        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;

        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id);
        insert procedure;
        
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor();
        insert pFactor;

        List<Case> cases = new List<Case>();
        for (Account acc_i : patients) {
            Case case_i = TestDataFactory.getCase(doctor.Id, acc_i.Id, con.Id, pFactor.Id);
            cases.add(case_i);
        }
        insert cases;
        List<Appointment__c> appointments = new List<Appointment__c>();
        for (Case case_i : cases) {
            Appointment__c appt = TestDataFactory.getAppointment('Institutes', procedure.Id, case_i.Patient__c, calendar.Id, case_i.Id);
            appointments.add(appt);
        }
        insert appointments;
    }

    @isTest
    public static void test() {
        String query = 'SELECT Id, Appointment_Status__c FROM Appointment__c';
        Test.startTest();
        Database.executeBatch(new CancelAppointmentSchedulableBatch(query));
        Test.stopTest();
    }
}