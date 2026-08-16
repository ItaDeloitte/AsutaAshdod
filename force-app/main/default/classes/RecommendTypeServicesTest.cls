// Test for: RecommendTypeTrigger, RecommendTypeTriggerHandler, RecommendTypeTriggerDispatcher, RecommendTypeServices
@isTest
private class RecommendTypeServicesTest {

    @testSetup
    static void setup() {
        RecommendationsTypeAfterExam__c recommendType = new RecommendationsTypeAfterExam__c();
        insert recommendType;
        Recommendations_after_exam__c recommendation = new Recommendations_after_exam__c(RecommendationsType__c = recommendType.Id);
        insert recommendation;
    }

    @isTest
    static void convertRecommendationTest() {
        RecommendationsTypeAfterExam__c recommendType = [SELECT Id, action_type__c FROM RecommendationsTypeAfterExam__c];

        Test.startTest();
        recommendType.action_type__c = 'אוטומציה פתיחת קייס';
        update recommendType;
        Test.stopTest();
    }
}