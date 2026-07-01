// Test: RecommendExamServicesTest
public class RecommendExamTriggerDispatcher {

    public static void convertRecommendation(List<Recommendations_after_exam__c> newList, Map<Id, Recommendations_after_exam__c> oldMap) {
        System.debug('RecommendExamTriggerDispatcher.convertRecommendation...');
        List<Recommendations_after_exam__c> recommendWithType = new List<Recommendations_after_exam__c>();
        Set<Id> recommendTypeIds = new Set<Id>();

        for (Recommendations_after_exam__c recommendation_i : newList) {
            if (String.isNotBlank(recommendation_i.RecommendationsType__c) && (oldMap == null || oldMap.get(recommendation_i.Id).RecommendationsType__c != recommendation_i.RecommendationsType__c)) {
                recommendTypeIds.add(recommendation_i.RecommendationsType__c);
                recommendWithType.add(recommendation_i);
            }
        }

        System.debug('recommendWithType: size: ' + recommendWithType.size() + ' value: ' + recommendWithType);
        System.debug('recommendTypeIds: size: ' + recommendTypeIds.size() + ' value: ' + recommendTypeIds);
        if (!recommendWithType.isEmpty() && !recommendTypeIds.isEmpty()){
            RecommendExamServices.convertRecommendation(recommendWithType, recommendTypeIds);
        }
    }
}