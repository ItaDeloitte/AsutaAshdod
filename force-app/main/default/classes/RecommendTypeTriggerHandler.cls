// Test: RecommendTypeServicesTest
public class RecommendTypeTriggerHandler {

    public static void handleTrigger(List<RecommendationsTypeAfterExam__c> newList, Map<Id, RecommendationsTypeAfterExam__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('RecommendTypeTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                RecommendTypeTriggerDispatcher.convertRecommendation(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                RecommendTypeTriggerDispatcher.convertRecommendation(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}