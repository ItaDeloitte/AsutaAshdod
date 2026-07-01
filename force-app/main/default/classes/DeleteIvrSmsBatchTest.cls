@isTest
private class DeleteIvrSmsBatchTest {

    @TestSetup
    static void makeData() {
        List<SMS__c> sms = new List<SMS__c>();
        sms.add(new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', smsTemplate__c = 'IVR_Chat_Expert'));
        sms.add(new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', smsTemplate__c = 'IVR_Chat_General'));
        insert sms;        
        Test.setCreatedDate(sms[0].Id, System.now().addMonths(-2));
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new DeleteIvrSmsBatch());
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        Test.startTest();
        System.schedule('Delete Log Test', '0 0 0 * * ?', new DeleteIvrSmsBatch());
        Test.stopTest();
    }
}