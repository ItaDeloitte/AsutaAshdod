// Test for: LC_CustomChatController
@isTest
private class LC_CustomChatControllerTest {

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
    static void getWorkitemDescribe_LiveChatTranscript_Test() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        LiveChatTranscript chatTranscript = TestDataFactory.getLiveChatTranscript();
        chatTranscript.ContactId = con.Id;
        insert chatTranscript;
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        controller.executeAction(new Map<String, Object>{'actionName' => 'getWorkitemDescribe', 'workitemId' => chatTranscript.Id});
        Test.stopTest();
    }

    @isTest
    static void getWorkitemDescribe_MessagingSession_Test() {
        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser msgUser = new MessagingEndUser(MessagingPlatformKey = 'whatsapp:+123456789', MessagingChannelId = msgChannel.Id, Name = 'whatsapp:+123456789', MessageType = 'WhatsApp');
        insert msgUser;
        MessagingSession msgSession = new MessagingSession(MessagingChannelId = msgChannel.Id, MessagingEndUserId = msgUser.Id, Status = 'Active');
        insert msgSession;
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        controller.executeAction(new Map<String, Object>{'actionName' => 'getWorkitemDescribe', 'workitemId' => msgSession.Id});
        Test.stopTest();
    }

    @isTest
    static void getWorkitemDescribe_Exception_Test() {
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        try {
        	controller.executeAction(new Map<String, Object>{'actionName' => 'getWorkitemDescribe', 'workitemId' => 'wrong Id'});
        } catch (Exception e) {
            System.assertEquals('WRONG ITEM ID', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void checkCloseAbility_LiveChatTranscript_Test() {
        LiveChatTranscript chatTranscript = TestDataFactory.getLiveChatTranscript();
        insert chatTranscript;
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkCloseAbility', 'workitemId' => chatTranscript.Id});
        Test.stopTest();
    }

    @isTest
    static void checkCloseAbility_MessagingSession_Test() {
        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser msgUser = new MessagingEndUser(MessagingPlatformKey = 'whatsapp:+123456789', MessagingChannelId = msgChannel.Id, Name = 'whatsapp:+123456789', MessageType = 'WhatsApp');
        insert msgUser;
        MessagingSession msgSession = new MessagingSession(MessagingChannelId = msgChannel.Id, MessagingEndUserId = msgUser.Id, Status = 'Active');
        insert msgSession;
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkCloseAbility', 'workitemId' => msgSession.Id});
        Test.stopTest();
    }

    @isTest
    static void checkCloseAbility_Exception_Test() {
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        try {
        	controller.executeAction(new Map<String, Object>{'actionName' => 'checkCloseAbility', 'workitemId' => 'wrong Id'});
        } catch (Exception e) {
            System.assertEquals('WRONG ITEM ID', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void getQuickTextItems_Test() {
        insert new QuickText(Name = 'name', Message = 'message', Channel = 'Live Agent');
        Test.startTest();
        LC_CustomChatController controller = new LC_CustomChatController();
        controller.executeAction(new Map<String, Object>{'actionName' => 'getQuickTextItems'});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        try {
            LC_CustomChatController controller = new LC_CustomChatController();
            controller.executeAction(new Map<String, Object>{'actionName' => 'error'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION error', e.getMessage());
        }
    }
}