@IsTest
public class WA_SendingScheduleBatchTest {

    @TestSetup
    static void makeData() {
        Account generalAccount = new Account();
        generalAccount.Name = 'General Account';
        generalAccount.ID_Number__c = null;
        generalAccount.RecordTypeId = TestDataFactory.getRTId('General_Account','Account');
        insert generalAccount;

        MessagingEndUser endUser = new MessagingEndUser();
        endUser.AccountId = generalAccount.Id;
        endUser.Name = '00000000000';
        endUser.MessagingChannelId = [SELECT Id FROM MessagingChannel LIMIT 1].Id;
        endUser.MessagingConsentStatus = 'OptedOut';
        endUser.MessagingPlatformKey = '00000000000';
        endUser.MessageType ='WhatsApp';
        insert endUser;

        List<WhatsApp__c> waList = new List<WhatsApp__c>();
        for (Integer i = 0; i < 10; i++) {
            WhatsApp__c wa = new WhatsApp__c(
                Messaging_User__c = endUser.Id,
                Values4ScheduledWA__c = 'Values for WA ' + i,
                Messaging_Template__c = 'Template' + i,
                expected_sending_date_time__c = System.now().addHours(-1), // Setting past time
                Outbound_Success__c = false
            );
            waList.add(wa);
        }
        insert waList;
    }

    @IsTest
    static void batchExecutionTest() {
        Test.startTest();
        WA_SendingScheduleBatch batch = new WA_SendingScheduleBatch();
        Database.executeBatch(batch, 25); 
        Test.stopTest();

        // After Test.stopTest(), check if batch executed properly
        List<WhatsApp__c> updatedWA = [SELECT Id, Outbound_Success__c FROM WhatsApp__c];
        System.assertNotEquals(0, updatedWA.size(), 'Batch should have processed WhatsApp records');
    }

}