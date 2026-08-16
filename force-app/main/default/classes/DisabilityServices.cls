/*
* @author          Ortal Kazum   <ortalk@assuta.co.il>
* @created         01-06-2019
* @modifiedBy      
* @modified        
* @description     
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class DisabilityServices {

    public static void updatePatient(Set<Id> accountIds) {
        System.debug('DisabilityServices.updatePatient...');
        Set<Id> accountIdsToTafnit = new Set<Id>();

        for (Account account_i : [SELECT Id FROM Account WHERE Id IN :accountIds]) {
            accountIdsToTafnit.add(account_i.Id);
        }

        if (!accountIdsToTafnit.isEmpty()) {
            System.debug('accountIdsToTafnit ' + accountIdsToTafnit);
            CreatePatientTafnitIntegration.createPatientInTafnit(accountIdsToTafnit, 'U', 'Disability');
        }
    }
}