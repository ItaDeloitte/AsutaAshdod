// Test for: RecommendExamTrigger, RecommendExamTriggerHandler, RecommendExamTriggerDispatcher, RecommendExamServices
@isTest
private class RecommendExamServicesTest {

    @testSetup
    static void setup() {
        RecommendationsTypeAfterExam__c recommendType = new RecommendationsTypeAfterExam__c(action_type__c = 'אוטומציה פתיחת קייס');
        insert recommendType;
        Recommendations_after_exam__c recommendation = new Recommendations_after_exam__c();
        insert recommendation;
    }

    @isTest
    static void convertRecommendationTest() {
        RecommendationsTypeAfterExam__c recommendType = [SELECT Id FROM RecommendationsTypeAfterExam__c];
        Recommendations_after_exam__c recommendation = [SELECT Id, RecommendationsType__c FROM Recommendations_after_exam__c];

        Test.startTest();
        recommendation.RecommendationsType__c = recommendType.Id;
        update recommendation;
        Test.stopTest();
    }
}