@isTest
public with sharing class AgentSurveyTriggerDispatcherTest {

    @isTest
    static void fillFormtitanIdTest() {
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
        Survey_Assuta__c survey = new Survey_Assuta__c(Name = 'סקר לניתוח');
        insert survey;
        Agent_survey__c agServ = TestDataFactory.getAgentSurvey(patient.Id, cas.Id, survey.Id);

        Test.startTest();
        insert agServ;
        Test.stopTest();

        Agent_survey__c ag = [SELECT Id, formtitan_id_2__c FROM Agent_survey__c LIMIT 1];
        System.assert(ag.formtitan_id_2__c != '' && ag.formtitan_id_2__c != null);
    }
}