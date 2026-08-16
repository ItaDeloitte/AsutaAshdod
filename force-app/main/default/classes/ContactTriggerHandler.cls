// Test: ContactServicesTest
// Created: Evgeniy Kravchuk
// Date: 27.05.2019
public class ContactTriggerHandler {

    public static void handleTrigger(List<Contact> newList, Map<Id, Contact> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ContactTriggerHandler.handleTrigger...');
        
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                ContactTriggerDispatcher.validateIdNumber(newList, null);
                ContactTriggerDispatcher.checkIdNumberUniqueness(newList);
                ContactTriggerDispatcher.assignGeneralAccount(newList);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                ContactTriggerDispatcher.validateIdNumber(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }

}