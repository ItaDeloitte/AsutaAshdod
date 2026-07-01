// Test: DocMedProcedureServicesTest
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
public class DocMedProcedureTriggerHandler {

   public static void handleTrigger(List<Doctor_Medical_Procedure__c> newList, Map<Id, Doctor_Medical_Procedure__c> oldMap, System.TriggerOperation triggerEvent) {
      System.debug('DocMedProcedureTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                DocMedProcedureTriggerDispatcher.updateMedProceduresOnAccount(newList, null);
            }
            when AFTER_DELETE {
                System.debug('AFTER_DELETE');
                DocMedProcedureTriggerDispatcher.updateMedProceduresOnAccount(null, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}