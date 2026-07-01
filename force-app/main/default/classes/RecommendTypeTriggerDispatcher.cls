// Test: RecommendTypeServicesTest
public class RecommendTypeTriggerDispatcher {

    public static void convertRecommendation(List<RecommendationsTypeAfterExam__c> newList, Map<Id, RecommendationsTypeAfterExam__c> oldMap) {
        System.debug('RecommendTypeTriggerDispatcher.convertRecommendation...');
        Set<Id> recommendTypeIds = new Set<Id>();

        for (RecommendationsTypeAfterExam__c recommendType_i : newList) {
            if (recommendType_i.action_type__c == 'אוטומציה פתיחת קייס' && (oldMap == null || oldMap.get(recommendType_i.Id).action_type__c != recommendType_i.action_type__c)) {
                recommendTypeIds.add(recommendType_i.Id);
            }
        }

        System.debug('recommendTypeIds: size: ' + recommendTypeIds.size() + ' value: ' + recommendTypeIds);
        if (!recommendTypeIds.isEmpty()){
            RecommendTypeServices.convertRecommendation(recommendTypeIds);
        }
    }
}