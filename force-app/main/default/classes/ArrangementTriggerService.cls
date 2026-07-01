public class ArrangementTriggerService {
    @Future
    public static void updatePromotedDoctors(Set<Id> validArrangementsIds) {
        System.debug('ArrangementTriggerService.updatePromotedDoctors...');
        Map<Id,Boolean> arrangementPromotedMap = new Map<Id,Boolean>();
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> arrangementIds = new Set<Id>();
        Set<Id> accountsIds = new Set<Id>();
        Map<Id,Id> accountArrangementMap = new Map<Id,Id>();
        List<Arrangements__c> arrangementsList = [SELECT Id,Promoted_arrangement__c FROM Arrangements__c WHERE Id IN: validArrangementsIds];
        for(Arrangements__c arrang : arrangementsList){
            if(arrang.Promoted_arrangement__c){
                arrangementPromotedMap.put(arrang.Id,true);
            }else{
                arrangementPromotedMap.put(arrang.Id,false);
            }
            arrangementIds.add(arrang.Id);
        }
        // query junction table to update junction records
        List<Doctor_arrangement__c> docArrangements = [SELECT id,Doctor__c,Arrangement__c FROM Doctor_arrangement__c WHERE Arrangement__c IN: arrangementIds];
        for(Doctor_arrangement__c da : docArrangements){
            accountsIds.add(da.Doctor__c);
            accountArrangementMap.put(da.Doctor__c,da.Arrangement__c);
            da.Promoted_doctor_arrangement__c = arrangementPromotedMap.get(da.Arrangement__c);
        }

        List<Account> accounts = [SELECT Id,Promoted_doctor__c FROM Account WHERE Id IN :accountsIds];
        for(Account account : accounts){
            if(account.Promoted_doctor__c!=null){ // manage promoted doctor inside the multiPicklist
                String[] promotedCriterias = account.Promoted_doctor__c.split(';');
                if(arrangementPromotedMap.get(accountArrangementMap.get(account.id)) && !promotedCriterias.contains('Arrangement')){
                    promotedCriterias.add('Arrangement');
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }else if(!arrangementPromotedMap.get(accountArrangementMap.get(account.id)) && promotedCriterias.contains('Arrangement')){
                    promotedCriterias.remove(promotedCriterias.indexOf('Arrangement'));
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }
            }else{
                if(arrangementPromotedMap.get(accountArrangementMap.get(account.id))){
                    account.Promoted_doctor__c = 'Arrangement';
                    accountsToUpdate.add(account);
                }
            }
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
        if(docArrangements!=null){
            update docArrangements;
        }
    }
}