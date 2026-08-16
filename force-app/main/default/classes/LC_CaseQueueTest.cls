// Test for: LC_CaseQueue
// Created: Evgeniy Kravchuk
// Date: 12.02.2020
@isTest
public class LC_CaseQueueTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account acct = new Account(Name = 'test account', ID_Number__c = '123456789', RoleCode__c = 15);
        insert acct;
        Site__c site = TestDataFactory.getSite();
        insert site;
        Case cas = new Case(Site__c = site.Id, description_history__c = 'description history');
        insert cas;
        Group queue = new Group(Type = 'Queue', Name = 'test queue');
        insert queue;
        Opportunity oppt = TestDataFactory.getOpportunity();
        insert oppt;
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_CaseQueue().executeAction(new Map<String, Object>{
                'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void obtainQueuesTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_CaseQueue().executeAction(new Map<String, Object>{
            'actionName' => 'obtainQueues',
            'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void transferOpptTest() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1];

        Test.startTest();
        new LC_CaseQueue().executeAction(new Map<String, Object>{
            'actionName' => 'transferCase',
            'recordId' => oppt.Id,
            'queueId' => queue.Id});
        Test.stopTest();
    }

    @isTest
    static void transferCasTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1];

        Test.startTest();
        new LC_CaseQueue().executeAction(new Map<String, Object>{
            'actionName' => 'transferCase',
            'recordId' => cas.Id,
            'queueId' => queue.Id});
        Test.stopTest();
    }
}