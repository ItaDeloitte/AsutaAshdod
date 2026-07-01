public class ArrangementTriggerHandler {
    public static void handleTrigger(List<Arrangements__c> newList, Map<Id, Arrangements__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ArrangementTriggerHandler.handleTrigger...');
          switch on triggerEvent {
              when AFTER_UPDATE {
                  System.debug('AFTER_UPDATE');
                  ArrangementTriggerDispatcher.updatePromotedDoctors(newList,oldMap);
              }
              when else {
                  System.debug('do nothing on others trigger events');
              }
          }
      }
}