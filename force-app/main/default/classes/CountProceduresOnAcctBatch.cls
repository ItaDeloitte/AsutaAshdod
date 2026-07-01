public class CountProceduresOnAcctBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CountProceduresOnAcctBatch.start...');
        String query = 'SELECT Id, Doctor__c, Medical_Procedure__c FROM Doctor_Medical_Procedure__c';
        System.debug('query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Doctor_Medical_Procedure__c> scope) {
        System.debug('CountProceduresOnAcctBatch.execute...');
        try {
            Map<Id, Set<Id>> doctorToProcedureIds = new Map<Id, Set<Id>>();

            for (Doctor_Medical_Procedure__c junction_i : scope) {
                if (!doctorToProcedureIds.containsKey(junction_i.Doctor__c)) {
                    doctorToProcedureIds.put(junction_i.Doctor__c, new Set<Id>());
                }
                doctorToProcedureIds.get(junction_i.Doctor__c).add(junction_i.Medical_Procedure__c);
            }

            List<Account> doctors = [SELECT Id, All_medical_procedures_ids__c FROM Account WHERE Id IN: doctorToProcedureIds.keySet()];
            for (Account doctor_i : doctors) {
                if (doctorToProcedureIds.containsKey(doctor_i.Id)) {
                    List<Id> procedureIds = doctor_i.All_medical_procedures_ids__c != null ? doctor_i.All_medical_procedures_ids__c.split(',') : new List<Id>();
                    for (Id procedureId_i : doctorToProcedureIds.get(doctor_i.Id)) {
                        if (!procedureIds.contains(procedureId_i)) {
                            procedureIds.add(procedureId_i);
                        }
                    }
                    doctor_i.All_medical_procedures_ids__c = String.join(procedureIds, ',');
                }
            }
            if (!doctors.isEmpty()) {
                update doctors;
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CountProceduresOnAcctBatch.finish...');
    }
}