// Test for: CountProceduresOnAcctBatch
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
@isTest
private class CountProceduresOnAcctBatchTest {

    @testSetup static void setup() {
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
        Doctor_Medical_Procedure__c junction = TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        insert junction;
        doctor.All_medical_procedures_ids__c = null;
        update doctor;
    }

    @isTest static void CountProceduresOnAcctBatchTest() {
        Test.startTest();
        Database.executeBatch(new CountProceduresOnAcctBatch());
        Test.stopTest();
    }
}