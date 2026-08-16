public class AccConRelationTriggerDispatcher {

    public static void updatePatient(List<AccountContactRelation> newList, Map<Id, AccountContactRelation> oldMap) {
        System.debug('AccConRelationTriggerDispatcher.updatePatient...');
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> escortContactIds = new Set<Id>();
        
        Id escortRecordId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Escort' AND SobjectType = 'Contact' LIMIT 1].Id;
        
        if (newList != null) { // INSERT, UPDATE
            for (AccountContactRelation AccCon_i : newList) {
                contactIds.add(AccCon_i.ContactId);
            }
            for (Contact con_i : [SELECT Id FROM Contact WHERE Id IN :contactIds AND RecordTypeId = :escortRecordId]) {
                escortContactIds.add(con_i.Id);
            }
            if(!escortContactIds.isEmpty()){
                for (AccountContactRelation AccCon_i : newList) {
                    if (String.isNotBlank(AccCon_i.AccountId) && (oldMap == null || oldMap.get(AccCon_i.Id).AccountId != AccCon_i.AccountId 
                        || oldMap.get(AccCon_i.Id).ContactId != AccCon_i.ContactId) && escortContactIds.contains(AccCon_i.ContactId)) {
                        accountIds.add(AccCon_i.AccountId);
                    }
                }
            }
        } else if (newList == null && oldMap != null) { // DELETE
            for (AccountContactRelation AccCon_i : oldMap.values()) {
                contactIds.add(AccCon_i.ContactId);
            }
            for (Contact con_i : [SELECT Id FROM Contact WHERE Id IN :contactIds AND RecordTypeId = :escortRecordId]) {
                escortContactIds.add(con_i.Id);
            }
            if(!escortContactIds.isEmpty()){
                for (AccountContactRelation AccCon_i : oldMap.values()) {
                    if (String.isNotBlank(AccCon_i.AccountId) && escortContactIds.contains(AccCon_i.ContactId)) {
                        accountIds.add(AccCon_i.AccountId);
                    }
                }
            }
        }

        if (!accountIds.isEmpty() && !System.isFuture() && !System.isBatch()) {
            System.debug('accountIds ' + accountIds);
            AccConRelationServices.updatePatient(accountIds);
        }  
    }

    public static void fillFormtitanId(List<AccountContactRelation> newList, Map<Id, AccountContactRelation> oldMap){

        for (AccountContactRelation accCont_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            accCont_i.formtitan_id_2__c = randomStr;
        }
    }
}