// Created: Evgeniy Kravchuk
// Date: 21.01.2020
// Test for: Bot_UpdateTranscript
@isTest
public class Bot_UpdateTranscriptTest {

    @testSetup
    static void setup() {
        insert new MessagingChannel(
            MessagingPlatformKey = 'whatsapp:+123456789',
            DeveloperName = 'WhatsApp',
            MasterLabel = 'WhatsApp',
            MessageType = 'WhatsApp'
        );
    }

    @isTest
    static void updateTranscriptTest() {
        insert TestDataFactory.getENV();
        LiveChatTranscript chatTranscript = TestDataFactory.getLiveChatTranscript();
        insert chatTranscript;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;

        Bot_UpdateTranscript.UpdateTranscriptRequestWrapper wrapper = new Bot_UpdateTranscript.UpdateTranscriptRequestWrapper();
        wrapper.transcriptId = chatTranscript.Id;
        wrapper.accountId = patient.Id;
        wrapper.caseId = cas.Id;

        Test.startTest();
        Bot_UpdateTranscript.updateTranscript(new List<Bot_UpdateTranscript.UpdateTranscriptRequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void updateMsgSessionTest() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser msgUser = new MessagingEndUser(
            MessagingPlatformKey = 'whatsapp:+123456789',
            MessagingChannelId = msgChannel.Id,
            Name = 'whatsapp:+123456789',
            MessageType = 'WhatsApp');
        insert msgUser;
        MessagingSession msgSession = new MessagingSession(
            MessagingChannelId = msgChannel.Id,
            MessagingEndUserId = msgUser.Id,
            Status = 'Active');
        insert msgSession;

        Bot_UpdateTranscript.UpdateTranscriptRequestWrapper wrapper = new Bot_UpdateTranscript.UpdateTranscriptRequestWrapper();
        wrapper.transcriptId = msgSession.Id;
        wrapper.accountId = patient.Id;
        wrapper.caseId = cas.Id;

        Test.startTest();
        Bot_UpdateTranscript.updateTranscript(new List<Bot_UpdateTranscript.UpdateTranscriptRequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void updateTranscriptException2Test() {
        Test.startTest();
        try {
            Bot_UpdateTranscript.updateTranscript(new List<Bot_UpdateTranscript.UpdateTranscriptRequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }
}