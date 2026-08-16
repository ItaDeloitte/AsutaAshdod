// Test for: LC_JunctionsQueue
// Created: Evgeniy Kravchuk
// Date: 16.01.2020
@isTest
public class LC_JunctionsQueueTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData().initCommonData();
          
        dBuilder
            .addProcedure('procI', '70551')
            .addGroup('Queue1', 'Queue')
            .addSiteDomain('Queue1')
            .addProcedureSite('procI');
            
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @isTest
    static void obtainQueuesTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'obtainQueues');
        params.put('recordId', [SELECT Id FROM Medical_Procedure_in_Sites__c LIMIT 1].Id);
        params.put('keyWord', 'test');

        Test.startTest();
        LC_JunctionsQueue controller = new LC_JunctionsQueue();
        Response res1 = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void setQueueTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'setQueue');
        params.put('recordId', [SELECT Id FROM Site_Domain__c LIMIT 1].Id);
        params.put('queueId', [SELECT Id FROM Group  WHERE Type = 'Queue' LIMIT 1].Id);

        Test.startTest();
        LC_JunctionsQueue controller = new LC_JunctionsQueue();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void getQueueTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getQueue');
        params.put('recordId', [SELECT Id FROM Site_Domain__c LIMIT 1].Id);

        Test.startTest();
        LC_JunctionsQueue controller = new LC_JunctionsQueue();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'wrong action');

        Test.startTest();
        try {
            LC_JunctionsQueue controller = new LC_JunctionsQueue();
            Response res = controller.executeAction(params);
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}