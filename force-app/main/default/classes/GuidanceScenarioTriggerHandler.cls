public with sharing class GuidanceScenarioTriggerHandler {

    public static void handleTrigger(List<Guidance_Scenario__c> newList, Map <id, Guidance_Scenario__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('GuidanceScenarioTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                GuidanceScenarioTriggerDispatcher.checkDuplicates(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                GuidanceScenarioTriggerDispatcher.checkDuplicates(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }

}