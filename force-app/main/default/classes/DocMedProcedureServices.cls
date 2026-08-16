// Test: DocMedProcedureServicesTest
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
public class DocMedProcedureServices {

    public static void updateMedProceduresOnAccount(Map<Id, Set<Id>> doctorToProcedureIds) {
        System.debug('DocMedProcedureServices.updateMedProceduresOnAccount...');
        List<Account> doctors = [SELECT Id, All_medical_procedures_ids__c FROM Account WHERE Id IN: doctorToProcedureIds.keySet()];

        for (Account doctor_i : doctors) {
            if (doctorToProcedureIds.containsKey(doctor_i.Id)) {
                List<Id> procedureIds = doctor_i.All_medical_procedures_ids__c != null ? doctor_i.All_medical_procedures_ids__c.split(',') : new List<Id>();
                for (Id procedureId_i : doctorToProcedureIds.get(doctor_i.Id)) {
                    if (!procedureIds.contains(procedureId_i)) {
                        procedureIds.add(procedureId_i);
                    } else {
                        procedureIds.remove(procedureIds.indexOf(procedureId_i));
                    }
                }
                doctor_i.All_medical_procedures_ids__c = String.join(procedureIds, ',');
            }
        }

        System.debug('doctors: size: ' + doctors.size() + ' values: ' + doctors);
        if (!doctors.isEmpty()) {
            update doctors;
        }
    }
}