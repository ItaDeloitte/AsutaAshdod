// Test: ChatTranscriptTriggerDispatcher, ChatTranscriptService, ChatTranscriptTriggerHandller
// author: Avraham Dasa
// created date : 18/9/2019
@isTest
public class ChatTranscriptServiceTest {

    @isTest
    static void fillRTLabelTest() {
        LiveChatTranscript chatTranscript = TestDataFactory.getLiveChatTranscript();
        chatTranscript.Case_Recordtype_TMP__c = TestDataFactory.getRTId('General_Info', 'Case');
        chatTranscript.Pre_chat_RT__c = TestDataFactory.getRTId('General_Info', 'Case');
        chatTranscript.Location = 'Tel Aviv, TA, Israel';
        chatTranscript.Browser= 'Chrome 72.0.3626.121';
        chatTranscript.SMS_Phone__c = '0931233123123';
        chatTranscript.Pre_chat_ID__c = '123456789';
        chatTranscript.body = 'test test body';
        chatTranscript.Platform ='Win10';

        Test.startTest();
        insert chatTranscript;
        Test.stopTest();
    }
}