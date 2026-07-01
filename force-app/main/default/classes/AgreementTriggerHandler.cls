public class AgreementTriggerHandler {
    public static void handleTrigger(List<Agreement__c> newList, Map<Id, Agreement__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('AgreementTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                AgreementTriggerDispatcher.updatePromotedDoctors(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }

}