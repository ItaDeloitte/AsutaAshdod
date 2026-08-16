public class DisabilityTriggerDispatcher {

    public static void updatePatient(List<Disabilities__c> newList, Map<Id, Disabilities__c> oldMap) {
        system.debug('DisabilityTriggerDispatcher.updatePatient...');
        Set<Id> accountIds = new Set<Id>();

        if (newList != null) { // INSERT, UPDATE
            for (Disabilities__c disability_i : newList) {
                if (String.isNotBlank(disability_i.Patient_Account__c)) {
                    accountIds.add(disability_i.Patient_Account__c);
                }
            }
        } else if (newList == null && oldMap != null) { // DELETE
            for (Disabilities__c disability_i : oldMap.values()) {
                if (String.isNotBlank(disability_i.Patient_Account__c)) {
                    accountIds.add(disability_i.Patient_Account__c);
                }
            }
        }

        if (!accountIds.isEmpty()) {
            System.debug('accountIds ' + accountIds);
            DisabilityServices.updatePatient(accountIds);
        }
    }
}