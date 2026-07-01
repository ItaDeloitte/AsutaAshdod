/*
* @author         Ortal Kazum   <ortalk@assuta.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        01-06-2019
* @modified       DD-MM-YYYY
* @see            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AccConRelationServices {

    public static void updatePatient(Set<Id> accountIds) {
        System.debug('AccConRelationServices.updatePatient...');
        Set<Id> accountIdsToTafnit = new Set<Id>();
        
        for (Account account_i : [SELECT Id FROM Account WHERE Id IN :accountIds AND RecordType.DeveloperName = 'PersonAccount']) {
            accountIdsToTafnit.add(account_i.Id);
        }

        if (!accountIdsToTafnit.isEmpty()) {
            System.debug('accountIdsToTafnit ' + accountIdsToTafnit);
            CreatePatientTafnitIntegration.createPatientInTafnit(accountIdsToTafnit, 'U', 'Contact');
        }
    }
}