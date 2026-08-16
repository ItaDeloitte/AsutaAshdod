// Test: DocInClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 30.01.2020
public class DocInClinicTriggerHandler {

    public static void handleTrigger(List<Doctor_in_Clinic__c> newList, Map<Id, Doctor_in_Clinic__c> oldMap, System.TriggerOperation triggerEvent) {
      System.debug('DocInClinicTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                DocInClinicTriggerDispatcher.fillFormtitanId(newList);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                DocInClinicTriggerDispatcher.updateDocFields(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                DocInClinicTriggerDispatcher.updateDocFields(newList, oldMap);
            }
            when AFTER_DELETE {
                System.debug('AFTER_DELETE');
                DocInClinicTriggerDispatcher.updateDocFields(null, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}