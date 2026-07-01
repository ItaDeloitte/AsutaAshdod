@isTest
public with sharing class TStringUtilsTest {
    @isTest
    public static void testOne(){
        System.debug(TStringUtils.GetDependentOptions2('Case', 'Case_subject__c', 'sub_case_subject__c'));
    }
}