@IsTest
public with sharing class LeadTRTest {

    @TestSetup
    static void makeData() {
        Account account = TestDataFactory.getAccountPerson();
        account.OTP_EMAIL_HIDDEN__c = null;
        account.SMS_Phone_Number__c = '0527987458';
        account.Status__c = 'פ';
        insert account;
        Lead lead = TestDataFactory.getLead();
        lead.Email = null;
        lead.Phone = '0527987458';
        insert lead;
    }

    @IsTest
    static void handleMailingApprovalTest() {
        Lead lead = [SELECT ApprovesMailing__c FROM Lead LIMIT 1];

        Test.startTest();
        lead.ApprovesMailing__c = 'מאשר דיוור - הכל';
        update lead;
        Test.stopTest();
    }
}