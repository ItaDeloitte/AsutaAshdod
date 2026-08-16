// Test for: DocMedProcedureTrigger, DocMedProcedureTriggerHandler, DocMedProcedureTriggerDispatcher, DocMedProcedureServices
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
@isTest
private class DocMedProcedureServicesTest {

    @testSetup
    static void setup() {
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
    }

    @isTest
    static void updateMedProceduresOnAccountTest() {
        Account doctor = [SELECT Id FROM Account LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Doctor_Medical_Procedure__c junction = TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        Test.startTest();
        insert junction;
        delete junction;
        Test.stopTest();
    }
}