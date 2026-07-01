// Test: ChatTranscriptServiceTest
public without sharing class ChatTranscriptService {
    
    public static List<LiveChatTranscript> fillRTLabel(List<LiveChatTranscript> newList) {
        System.debug('ChatTranscriptService.fillRTLabel...');
        Map<Id, RecordType> caseRTMap = new Map<Id, RecordType> ([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Case']);

        for (LiveChatTranscript transcript_i : newList) {
            if (String.isNotBlank(transcript_i.Pre_chat_RT__c) && caseRTMap.containsKey(transcript_i.Pre_chat_RT__c)) {
                transcript_i.Pre_chat_RT__c = caseRTMap.get(transcript_i.Pre_chat_RT__c).Name;
            }
        }

        return newList;
    }

    public static List<LiveChatTranscript> updateAccountIdByPhone (List<LiveChatTranscript> newList) {
        System.debug('ChatTranscriptService.updateAccountId...');
        /*Set<String> phoneSet = new Set<String>();
        for (LiveChatTranscript transcript : newList) {
            phoneSet.add(transcript.SMS_Phone__c);
        }
		
        RecordType presonRT = [SELECT ID FROM RecordType WHERE DeveloperName = 'PersonAccount' AND sObjectType = 'Account'];
        // dirty fix, don't use it if you don't understand impact
        List <User> allUsers = [SELECT ID FROM User];
        System.debug('allUsers.size '+allUsers.size());
        System.debug('presonRT '+presonRT);
        Map<String, Account> phoneToAccountMap = new Map<String, Account> ();
        for (Account acc_i : [SELECT Id, Phone FROM Account WHERE Phone IN: phoneSet AND RecordTypeId =: presonRT.id AND OwnerId IN: allUsers]) {
            phoneToAccountMap.put(acc_i.Phone, acc_i);
        }
        
        System.debug('phoneToAccountMap.size '+phoneToAccountMap.size());
        for (LiveChatTranscript transcript_i : newList) {
            if (String.isNotBlank(transcript_i.SMS_Phone__c) && phoneToAccountMap.containsKey(transcript_i.SMS_Phone__c)) {
              	 transcript_i.AccountId = phoneToAccountMap.get(transcript_i.SMS_Phone__c).Id;
            }
        }*/
		
        return newList; 
    }
    
  
}