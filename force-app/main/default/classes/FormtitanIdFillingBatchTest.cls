@isTest
private with sharing class FormtitanIdFillingBatchTest {

    @TestSetup
    static void makeData() {
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;
        doctor.formtitan_id_2__c = null;
        update doctor;
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new FormtitanIdFillingBatch(Account.getSObjectType(), Account.formtitan_id_2__c));
        Test.stopTest();
    }
}