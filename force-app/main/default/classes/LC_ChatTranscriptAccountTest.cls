// Test for: LC_ChatTranscriptAccount
// Created: Evgeniy Kravchuk
// Date: 28.05.2020
@isTest
public class LC_ChatTranscriptAccountTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.SMS_Phone_Number__c = '12345';
        insert patient;
        LiveChatTranscript chat = TestDataFactory.getLiveChatTranscript();
        chat.SMS_Phone__c = '12345';
        insert chat;
    }

    @isTest
    static void obtainAccounts_Test() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];

        Test.startTest();
        LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'chatId' => chat.Id});
        Test.stopTest();
    }

    @isTest
    static void obtainAccounts_NoSMSPhone_Test() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        chat.SMS_Phone__c = null;
        update chat;

        Test.startTest();
        LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'obtainAccounts', 'chatId' => chat.Id});
        Test.stopTest();
    }

    @isTest
    static void setAccountTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'setAccount', 'chatId' => chat.Id, 'accountId' => acct.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_Test() {
        Test.setFixedSearchResults(new List<Id>{[SELECT Id FROM Account LIMIT 1].Id});
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        chat.No_Account__c = true;
        update chat;

        Test.startTest();
        LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'chatId' => chat.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccount_NoAccounts_Test() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];

        Test.startTest();
        LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'chatId' => chat.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_ChatTranscriptAccount controller = new LC_ChatTranscriptAccount();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong action'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}