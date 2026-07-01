// Test: AssutaEmployeeTriggerDispatcherTest
// Created: Ortal kazum
// Created date: 01.07.2021
public class AssutaEmployeeTriggerHandler {
	public static void handleTrigger(List<Assuta_Employee__c> newList, Map<Id, Assuta_Employee__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('OpportunityTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                AssutaEmployeeTriggerDispatcher.fillFormtitanId(newList);
                AssutaEmployeeTriggerDispatcher.validateIdNumber(newList, null);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                AssutaEmployeeTriggerDispatcher.createContact(newList, null);                
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                AssutaEmployeeTriggerDispatcher.validateIdNumber(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                AssutaEmployeeTriggerDispatcher.createContact(newList, oldMap);                
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
		}
   }
}