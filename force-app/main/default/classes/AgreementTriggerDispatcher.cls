public class AgreementTriggerDispatcher {
    public static void updatePromotedDoctors(List<Agreement__c> newList, Map<Id, Agreement__c> oldMap) {
        System.debug('AgreementTriggerDispatcher.updatePromotedDoctors...');
        Set<Id> validAgreementsIds = new Set<Id>();
            for (Agreement__c agreement : newList) {
                if (agreement.Promoted_Agreement__c != oldMap.get(agreement.Id).Promoted_Agreement__c) { // compare new list with old map
                    validAgreementsIds.add(agreement.Id);
                }
            }
        System.debug('doctorIds: size: ' + validAgreementsIds.size());
        if (!validAgreementsIds.isEmpty()) {
            AgreementTriggerService.updatePromotedDoctors(validAgreementsIds);
        }
    }
}