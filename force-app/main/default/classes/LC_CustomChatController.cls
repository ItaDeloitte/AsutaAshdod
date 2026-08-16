// Test: LC_CustomChatControllerTest
public with sharing class LC_CustomChatController implements ILCController {

    public class LC_CustomChatControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getWorkitemDescribe' {
                return this.getWorkitemDescribe((String) params.get('workitemId'));
            }
            when 'getQuickTextItems' {
                return this.getQuickTextItems();
            }
            when 'checkCloseAbility' {
                return this.checkCloseAbility((String) params.get('workitemId'));
            }
            when else {
                throw new LC_CustomChatControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    public Response getWorkitemDescribe(String workitemId) {
        System.debug('LC_CustomChatController.getWorkitemDescribe...\nworkitemId: ' + workitemId);
        if (!workitemId.startsWith('570') && !workitemId.startsWith('0Mw')) {
            throw new LC_CustomChatControllerException('WRONG ITEM ID');
        }

        if (workitemId.startsWith('570')) {
            LiveChatTranscript transcript = [SELECT Id, Name, ContactId, Contact.Name, Account__c, Account__r.Name FROM LiveChatTranscript WHERE Id =: workitemId];
            return new Response(new WorkitemDescribe(transcript));
        } else {
            MessagingSession fbSession = [SELECT Id, Name, EndUserAccountId, EndUserContactId, EndUserAccount.Name, EndUserContact.Name FROM MessagingSession WHERE Id =: workitemId];
            return new Response(new WorkitemDescribe(fbSession));
        }
    }

    public Response checkCloseAbility(String workitemId){
        System.debug('LC_CustomChatController.checkCloseAbility...\nworkitemId: ' + workitemId);
        if (!workitemId.startsWith('570') && !workitemId.startsWith('0Mw')) {
            throw new LC_CustomChatControllerException('WRONG ITEM ID');
        }

		DateTime endSession;
        if (workitemId.startsWith('570')) {
            LiveChatTranscript transcript = [SELECT Id, EndTime FROM LiveChatTranscript WHERE Id =: workitemId];
            endSession = transcript.EndTime;
        } else {
            MessagingSession fbSession = [SELECT Id, EndTime FROM MessagingSession WHERE Id =: workitemId];
            endSession = fbSession.EndTime;
        }
        return new Response((endSession != null));
    }

    public Response getQuickTextItems() {
        System.debug('LC_CustomChatController.getQuickTextItems...');
        List<QuickTextItem> qtItems = new List<QuickTextItem>();

        for (QuickText qt_i : [SELECT Id, Name, Message FROM QuickText WHERE Channel = 'Live Agent' AND IsDeleted = false]) {
            qtItems.add(new QuickTextItem(qt_i));
        }
        System.debug('qtItems: size: ' + qtItems.size() + ' value: ' + qtItems);

        return new Response(qtItems);
    }

    /* WRAPPERS */
    public class WorkitemDescribe {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}

        public WorkitemDescribe(LiveChatTranscript transcript) {
            this.id = transcript.id;
            this.name = transcript.Name;
            if (transcript.Account__c != null) {
                this.name = transcript.Account__r.Name;
            } else if (transcript.ContactId != null) {
                this.name = transcript.Contact.Name;
            }
        }

        public WorkitemDescribe(MessagingSession fbSession) {
            this.id = fbSession.id;
            this.name = fbSession.Name;
            if (fbSession.EndUserAccountId != null){
            	this.name = fbSession.EndUserAccount.Name;   
            } else if (fbSession.EndUserContactId != null){
                this.name = fbSession.EndUserContact.Name;
            }
        }
    }

    public class QuickTextItem {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String message {get;set;}

        public QuickTextItem(QuickText qt) {
            this.name = qt.Name;
            this.message = qt.Message;
        }
    }
}