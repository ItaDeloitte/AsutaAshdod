// Test: OpportunityTriggerDispatcherTest
// Created: Ortal kazum
// Created date: 01.02.2021
public class OpportunityTriggerHandler {
	public static void handleTrigger(List<Opportunity> newList, Map<Id, Opportunity> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('OpportunityTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                OpportunityTriggerDispatcher.fillFormtitanId(newList);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
		}
   }
}