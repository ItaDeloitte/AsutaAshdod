// Test: ChatTranscriptServiceTest
public without sharing class ChatTranscriptTriggerHandller {

    public static void handleTrigger(List<LiveChatTranscript> newList, Map<Id, LiveChatTranscript> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ChatTranscriptTriggerHandller.handleTrigger...');
        
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                ChatTranscriptTriggerDispatcher.updateCaseRtIdOnTranscritpId(newList);
                ChatTranscriptTriggerDispatcher.updateAccountIdOnTranscript(newList);
              
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}