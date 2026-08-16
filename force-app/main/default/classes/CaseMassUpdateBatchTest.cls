@isTest
public with sharing class CaseMassUpdateBatchTest {

    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();

        Site__c site1 = TestDataFactory.getSite('85');
        insert site1;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Patient_has_open_case__c = false;
        patient.DisableValidation__c = true;
        patient.Primary_Site__c = site1.Id;
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.sched_sys_doc_clinics__c = 'RIS';
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactorParent;
        Payer_Factor__c pFactorChild1 = TestDataFactory.getPFactor('12345');
        pFactorChild1.Name_of_parent__c = pFactorParent.Id;
        insert pFactorChild1;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild1.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Test.setCreatedDate(cas.Id, Date.today().addDays(-10));
    }

    @isTest
    static void caseMassUpdateBatchTest() {
        Test.startTest();
            Database.executeBatch(new CaseMassUpdateBatch());
        Test.stopTest();
    }
}