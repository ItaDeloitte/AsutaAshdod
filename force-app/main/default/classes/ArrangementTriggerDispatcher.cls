public class ArrangementTriggerDispatcher {
    public static void updatePromotedDoctors(List<Arrangements__c> newList, Map<Id, Arrangements__c> oldMap){
        System.debug('ArrangementTriggerDispatcher.updatePromotedDoctors...');
        Set<Id> validArrangementsIds = new Set<Id>();
            for (Arrangements__c arrang : newList) {
                if (arrang.Promoted_arrangement__c != oldMap.get(arrang.Id).Promoted_arrangement__c) { // compare new list with old map
                    validArrangementsIds.add(arrang.Id);
                }
            }
        System.debug('doctorIds: size: ' + validArrangementsIds.size());
        if (!validArrangementsIds.isEmpty()) {
            ArrangementTriggerService.updatePromotedDoctors(validArrangementsIds);
        }
    }
}