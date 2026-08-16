// Test for: PicklistUtil
@isTest
private class PicklistUtilTest {

    @isTest
    static void methodTest() {
        Test.startTest();
        PicklistUtil.buildPicklistMapping('Account', 'ID_Type__c');
        PicklistUtil.buildDependedPicklistSchema('Account', 'ID_Type__c', 'ID_Type__c');
        Test.stopTest();
    }
}