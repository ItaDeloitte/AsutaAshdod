@isTest
private class SObjectWrapperTest {

    @isTest
    static void constructorTest() {
        Test.startTest();
        new SObjectWrapper('objectApiName', 'recordTypeId', new Map<String, Object>(), 'customDetails');
        new SObjectWrapper('objectApiName', new Map<String, Object>(), 'customDetails');
        new SObjectWrapper('objectApiName', 'recordTypeId', new Map<String, Object>());
        new SObjectWrapper('objectApiName', new Map<String, Object>());
        Test.stopTest();
    }
}