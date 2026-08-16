public class DisabilityTriggerHandler {

   public static void handleTrigger(List<Disabilities__c> newList, Map<Id, Disabilities__c> oldMap, System.TriggerOperation triggerEvent) {
      System.debug('DisabilityTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                DisabilityTriggerDispatcher.updatePatient(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                DisabilityTriggerDispatcher.updatePatient(newList, oldMap);
            }
            when AFTER_DELETE {
                System.debug('AFTER_DELETE');
                DisabilityTriggerDispatcher.updatePatient(null, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}