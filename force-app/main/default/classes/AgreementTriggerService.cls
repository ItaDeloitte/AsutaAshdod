public class AgreementTriggerService {
    @Future
    public static void updatePromotedDoctors(Set<Id> agreementsIds) {
        Set<Id> docIds = new Set<Id>();
        Map<Id,Boolean> AccountPromotedMap = new Map<Id,Boolean>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Agreement__c> agreements = [SELECT Id,Promoted_Agreement__c,Doctor_Account__c FROM Agreement__c WHERE Id IN:agreementsIds];
        for (Agreement__c agreement : agreements){
            if(agreement.Promoted_Agreement__c){
                AccountPromotedMap.put(agreement.Doctor_Account__c,true);
            }else{
                AccountPromotedMap.put(agreement.Doctor_Account__c,false);
            }
            docIds.add(agreement.Doctor_Account__c);
        }
        
        for(Account account : [SELECT Id,Promoted_doctor__c  FROM Account WHERE Id IN:docIds]){
            if(account.Promoted_doctor__c!=null){
                String[] promotedCriterias = account.Promoted_doctor__c.split(';');
                if(AccountPromotedMap.get(account.id) && !promotedCriterias.contains('Agreement')){
                    promotedCriterias.add('Agreement');
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }else if(!AccountPromotedMap.get(account.id) && promotedCriterias.contains('Agreement')){
                    promotedCriterias.remove(promotedCriterias.indexOf('Agreement'));
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }
            }else{
                if(AccountPromotedMap.get(account.id)){
                    account.Promoted_doctor__c = 'Agreement';
                    accountsToUpdate.add(account);
                }
            }
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}