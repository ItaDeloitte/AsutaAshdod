// Test: LC_ChatTranscriptAccountTest
// Created: Evgeniy Kravchuk
// Date: 28.05.2020
public class LC_ChatTranscriptAccount implements ILCController {

    public class LC_ChatTranscriptAccountException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainAccounts' {
                return this.obtainAccounts((String) params.get('chatId'), (String) params.get('accountName'));
            }
            when 'setAccount'{
                return this.setAccount((String) params.get('chatId'), (String) params.get('accountId'));
            }
            when 'getAccount'{
                return this.getAccount((String) params.get('chatId'));
            }
            when else {
                throw new LC_ChatTranscriptAccountException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainAccounts(String chatId, String accountName) {
        System.debug('LC_ChatTranscriptAccount.obtainAccounts...\nchatId: ' + chatId + '\naccountName: ' + accountName);
        LiveChatTranscript chat = [SELECT Id, SMS_Phone__c, No_Account__c FROM LiveChatTranscript WHERE Id =: chatId];
        accountName = '%' + accountName + '%';
        System.debug('chat: ' + chat);

        if (chat.SMS_Phone__c == null) {
            return new Response(new List<Account>());
        }

        List<List<Account>> accts = [FIND :chat.SMS_Phone__c IN PHONE FIELDS RETURNING Account(Id, Name WHERE RecordType.DeveloperName = 'PersonAccount' AND Name LIKE: accountName) LIMIT 50];
        System.debug('accts: size: ' + accts.get(0).size() + ' value: ' + accts.get(0));

        return new Response(accts.get(0));
    }

    private Response setAccount(String chatId, String accountId) {
        System.debug('LC_ChatTranscriptAccount.setAccount...\nchatId: ' + chatId + '\naccountId: ' + accountId);
        LiveChatTranscript chat = new LiveChatTranscript(Id = chatId, Account__c = String.isBlank(accountId) ? null : accountId);
        update chat;
        System.debug('chat: ' + chat);

        return new Response('success');
    }

    private Response getAccount(String chatId) {
        System.debug('LC_ChatTranscriptAccount.getAccount...\nchatId: ' + chatId);
        LiveChatTranscript chat = [SELECT Id, No_Account__c, Account__c, Account__r.Name FROM LiveChatTranscript WHERE Id =: chatId];
        System.debug('chat: ' + chat);
        Boolean isUpdate = false;

        List<Account> accts = (List<Account>) this.obtainAccounts(chatId, '').responseObj;
        // assign account if only single one found
        if (accts.size() == 1) {
            chat.Account__c = accts.get(0).Id;
            chat.Account__r = accts.get(0);
            isUpdate = true;
        }
        // change No_Account__c if the wrong value detected
        if (accts.isEmpty() && !chat.No_Account__c) {
            chat.No_Account__c = true;
            isUpdate = true;
        } else if (!accts.isEmpty() && chat.No_Account__c) {
            chat.No_Account__c = false;
            isUpdate = true;
        }
        if (isUpdate) {
            update chat;
        }

        if (chat.Account__c == null) {
            return new Response(new Account());
        }

        return new Response(new Account(Id = chat.Account__c, Name = chat.Account__r.Name));
    }
}