// Test: ClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 31.01.2020
public class ClinicTriggerHandler {

    public static void handleTrigger(List<Clinic__c> newList, Map<Id, Clinic__c> oldMap, System.TriggerOperation triggerEvent) {
      System.debug('ClinicTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                ClinicTriggerDispatcher.updateDocFields(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                ClinicTriggerDispatcher.updateDocFields(newList, oldMap);
                ClinicTriggerDispatcher.updatePromotedDoctors(newList,oldMap);
            }
            when AFTER_DELETE {
                System.debug('AFTER_DELETE');
                ClinicTriggerDispatcher.updateDocFields(null, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}