@isTest
private class TaskTriggerTest {

    @isTest
    static void populateLogFromUUITest() {
        Test.startTest();
        insert new Task();
        TaskTriggerHandler.handleTrigger(new List<Task>{new Task(UUI__c = 'test;test;10_10;test;test')}, System.TriggerOperation.BEFORE_INSERT);
        TaskTriggerHandler.handleTrigger(new List<Task>{new Task()}, System.TriggerOperation.AFTER_INSERT);
        TaskTriggerDispatcher.fillLanguage(new Map<String, Map<String, String>>{'test1' => new Map<String, String>{'reserved' => '1'},
            																	'test2' => new Map<String, String>{'reserved' => '2'},
                                                                                'test3' => new Map<String, String>{'reserved' => '3'},
                                                                                'test4' => new Map<String, String>{'reserved' => '4'}},
                                           new Map<String, Task>{'test1' => new Task(UUI__c = 'test;test;10_10;test;test'),
                                               					 'test2' => new Task(UUI__c = 'test;test;10_10;test;test'),
                                               					 'test3' => new Task(UUI__c = 'test;test;10_10;test;test'),
                                               					 'test4' => new Task(UUI__c = 'test;test;10_10;test;test')});
        Test.stopTest();
    }
}