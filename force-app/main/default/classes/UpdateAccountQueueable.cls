public class UpdateAccountQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> accountIds;
    
    public UpdateAccountQueueable(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public void execute(QueueableContext context) {
        /*
        System.debug('UpdateAccountQueueable.execute...');
        List<Account> accountsToUpdate = new List<Account>();
        List<Disabilities__c> disabilitiesToUpsert = new List<Disabilities__c>();
        List<DemographyManager.AccountWithDisabilities> wrappers = new List<DemographyManager.AccountWithDisabilities>();

        List<Account> accounts = [SELECT Id, ID_Number__c, ID_Type__c, DisableValidation__c, Insurance_is_valid__c
                                  FROM Account WHERE Id IN :accountIds AND ID_Number__c != NULL AND ID_Type__c != NULL];

        for (Account account_i : accounts) {
            wrappers.add(DemographyManager.updateAccountWithExtendedDetails(account_i, account_i.ID_Number__c, account_i.ID_Type__c));
        }

        if (!wrappers.isEmpty()) {
            System.debug('wrappers ' + wrappers);
            for (DemographyManager.AccountWithDisabilities wrapper_i : wrappers) {
                accountsToUpdate.add(wrapper_i.acct);
                if (wrapper_i.disabilities != null && !wrapper_i.disabilities.isEmpty()) {
                    for (Disabilities__c disability_i : wrapper_i.disabilities) {
                        disability_i.Patient_Account__c = wrapper_i.acct.Id;
                    }
                    disabilitiesToUpsert.addAll(wrapper_i.disabilities);
                }
            }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(accountsToUpdate, dml);
            //update accountsToUpdate;

            if (!disabilitiesToUpsert.isEmpty()) {
                System.debug('disabilitiesToUpsert '+disabilitiesToUpsert);
                upsert disabilitiesToUpsert;
            }
        }
        */
    }

}