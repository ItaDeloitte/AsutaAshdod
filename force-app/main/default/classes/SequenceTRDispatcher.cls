// Test: SequenceTRTest
public class SequenceTRDispatcher {

    public static void createGeneralRecord(List<Sequence__c> newList, Map<Id, Sequence__c> oldMap) {
        System.debug('LOG Sequence__c createGeneralRecord ... start');
        List<Sequence__c> sequences = new List<Sequence__c>();
        Set<Id> firstProcedureIds = new Set<Id>();
        Set<Id> secondProcedureIds = new Set<Id>();
        Set<Id> thirdProcedureIds = new Set<Id>();

        for (Sequence__c sequence_i : newList) {
            if (sequence_i.Site_Codes__c != null && (oldMap == null || oldMap.get(sequence_i.Id).Site_Codes__c == null)) {
                sequences.add(sequence_i);
                firstProcedureIds.add(sequence_i.first_medical_procedure__c);
                secondProcedureIds.add(sequence_i.second_medical_procedure__c);
                thirdProcedureIds.add(sequence_i.third_medical_procedure__c);
            }
        }
        System.debug('sequences: size: ' + sequences.size() + ' value: ' + sequences);

        if (!sequences.isEmpty()) {
            SequenceTRService.createGeneralRecord(sequences, firstProcedureIds, secondProcedureIds, thirdProcedureIds);
        }
    }
}