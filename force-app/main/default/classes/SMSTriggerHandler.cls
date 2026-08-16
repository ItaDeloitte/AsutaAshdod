public class SMSTriggerHandler {

    public static void handleTrigger(List<SMS__c> newList, Map<Id, SMS__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('SMSTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                SMSTriggerDispatcher.editContentField(newList);                                                
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                SMSTriggerDispatcher.editContentFieldBySmsTemplate(newList);   
                SMSTriggerDispatcher.handleOutgoingSMS(newList, null);
                             
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');                
                SMSTriggerDispatcher.handleOutgoingSMS(newList, oldMap);                             
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}