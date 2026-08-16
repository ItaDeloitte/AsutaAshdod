// Test: RecommendExamServicesTest
public class RecommendExamTriggerHandler {

    public static void handleTrigger(List<Recommendations_after_exam__c> newList, Map<Id, Recommendations_after_exam__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('RecommendExamTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                RecommendExamTriggerDispatcher.convertRecommendation(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                RecommendExamTriggerDispatcher.convertRecommendation(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}