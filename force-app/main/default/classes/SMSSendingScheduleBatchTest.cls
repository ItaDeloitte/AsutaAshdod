/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * SMS Sender Schedule Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             22-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class SMSSendingScheduleBatchTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        insert new SMS__c(
            Type__c = 'Outgoing',
            Content__c = 'Content',
            Phone_Number__c = '0500000000',
            ExpectedSendingDateTime__c = System.now());
    }

    @IsTest
    static void successTest() {
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());

        Test.startTest();
        Database.executeBatch(new SMSSendingScheduleBatch());
        Test.stopTest();

        SMS__c sms = [SELECT ActualSendingDateTime__c FROM SMS__c LIMIT 1];
        System.assert(sms.ActualSendingDateTime__c != null);
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        Database.executeBatch(new SMSSendingScheduleBatch());
        Test.stopTest();
    }
}