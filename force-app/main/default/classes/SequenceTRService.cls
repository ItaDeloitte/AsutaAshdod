// Test: SequenceTRTest
public class SequenceTRService {

    public static void createGeneralRecord(List<Sequence__c> sequences, Set<Id> firstProcedureIds, Set<Id> secondProcedureIds, Set<Id> thirdProcedureIds) {
        List<Sequence__c> sequencesToInsert = new List<Sequence__c>();
        Set<String> sequenceIdentifiers = new Set<String>();

        List<Sequence__c> sequencesInSystem = [
            SELECT Ashdod__c
                 , first_medical_procedure__c
                 , second_medical_procedure__c
                 , third_medical_procedure__c
              FROM Sequence__c
             WHERE IsGeneral__c = true
               AND first_medical_procedure__c IN: firstProcedureIds
               AND second_medical_procedure__c IN: secondProcedureIds
               AND third_medical_procedure__c IN: thirdProcedureIds];
        System.debug('sequencesInSystem: size: ' + sequencesInSystem.size() + ' value: ' + sequencesInSystem);

        for (Sequence__c sequence_i : sequencesInSystem) {
            sequenceIdentifiers.add(getSequenceIdentifier(sequence_i));
        }
        System.debug('sequenceIdentifiers: size: ' + sequenceIdentifiers.size() + ' value: ' + sequenceIdentifiers);

        for (Sequence__c sequence_i : sequences) {
            if (!sequenceIdentifiers.contains(getSequenceIdentifier(sequence_i))) {
                sequencesToInsert.add(
                    new Sequence__c(
                        IsGeneratedAutomatically__c = true,
                        calendar__c = sequence_i.calendar__c,
                        first_medical_procedure__c = sequence_i.first_medical_procedure__c,
                        second_medical_procedure__c = sequence_i.second_medical_procedure__c,
                        third_medical_procedure__c = sequence_i.third_medical_procedure__c,
                        Ashdod__c = sequence_i.Ashdod__c
                    )
                );
            }
        }
        System.debug('sequencesToInsert: size: ' + sequencesToInsert.size() + ' value: ' + sequencesToInsert);

        if (!sequencesToInsert.isEmpty()) {
            System.debug('LOG Sequence__c createGeneralRecord ... logic has been executed');
            insert sequencesToInsert;
        }
    }

    private static String getSequenceIdentifier(Sequence__c sequence) {
        return sequence.Ashdod__c + '-' + sequence.first_medical_procedure__c + '-' + sequence.second_medical_procedure__c + '-' + sequence.third_medical_procedure__c;
    }
}