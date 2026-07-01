public class AccContactRelationTriggerHandler {

    public static void handleTrigger(List<AccountContactRelation> newList, Map<Id, AccountContactRelation> oldMap, System.TriggerOperation triggerEvent) {
      System.debug('AccContactRelationTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                AccConRelationTriggerDispatcher.fillFormtitanId(newList, null);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                AccConRelationTriggerDispatcher.updatePatient(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                AccConRelationTriggerDispatcher.updatePatient(newList, oldMap);
            }
            when AFTER_DELETE {
                System.debug('AFTER_DELETE');
                AccConRelationTriggerDispatcher.updatePatient(null, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}