// Test: DocMedProcedureServicesTest
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
public class DocMedProcedureTriggerDispatcher {

    public static void updateMedProceduresOnAccount(List<Doctor_Medical_Procedure__c> newList, Map<Id, Doctor_Medical_Procedure__c> oldMap) {
        System.debug('DocMedProcedureTriggerDispatcher.updateMedProceduresOnAccount...');
        Map<Id, Set<Id>> doctorToProcedureIds = new Map<Id, Set<Id>>();

        if (newList != null && oldMap == null) { // INSERT
            for (Doctor_Medical_Procedure__c junction_i : newList) {
                if (!doctorToProcedureIds.containsKey(junction_i.Doctor__c)) {
                    doctorToProcedureIds.put(junction_i.Doctor__c, new Set<Id>());
                }
                doctorToProcedureIds.get(junction_i.Doctor__c).add(junction_i.Medical_Procedure__c);
            }
        } else if (newList == null && oldMap != null) { // DELETE
            for (Doctor_Medical_Procedure__c junction_i : oldMap.values()) {
                if (!doctorToProcedureIds.containsKey(junction_i.Doctor__c)) {
                    doctorToProcedureIds.put(junction_i.Doctor__c, new Set<Id>());
                }
                doctorToProcedureIds.get(junction_i.Doctor__c).add(junction_i.Medical_Procedure__c);
            }
        }

        System.debug('doctorToProcedureIds: size: ' + doctorToProcedureIds.size() + ' values: ' + doctorToProcedureIds);
        if (!doctorToProcedureIds.isEmpty()) {
            DocMedProcedureServices.updateMedProceduresOnAccount(doctorToProcedureIds);
        }
    }
}