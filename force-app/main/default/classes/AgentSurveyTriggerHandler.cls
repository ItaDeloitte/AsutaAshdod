public with sharing class AgentSurveyTriggerHandler {

    public static void handleTrigger(List<Agent_survey__c> newList, Map<Id, Agent_survey__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('AccountTriggerHandler.handleTrigger...');
        
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                AgentSurveyTriggerDispatcher.fillFormtitanId(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}