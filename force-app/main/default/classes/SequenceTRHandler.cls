// Test: SequenceTRTest
public class SequenceTRHandler {

    public static void handleTrigger(List<Sequence__c> newList, Map<Id, Sequence__c> oldMap, Map<Id, Sequence__c> newMap, System.TriggerOperation triggerEvent) {
        System.debug('SequenceTRHandler.handleTrigger...');
        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                SequenceTRDispatcher.createGeneralRecord(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                SequenceTRDispatcher.createGeneralRecord(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}