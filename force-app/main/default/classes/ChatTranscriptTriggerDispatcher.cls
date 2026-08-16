// Test: ChatTranscriptServiceTest
public without sharing class ChatTranscriptTriggerDispatcher {

    public static void updateCaseRtIdOnTranscritpId(List<LiveChatTranscript> newList) {
        System.debug('ChatTranscriptTriggerDispatcher.updateCaseRtIdOnTranscritpId...');
        List<LiveChatTranscript> filtredTranscriptFields = new List<LiveChatTranscript>();

        for (LiveChatTranscript transcript_i : newList) {
            if (String.isNotBlank(transcript_i.Pre_chat_RT__c)) {
                filtredTranscriptFields.add(transcript_i);
            }
        }

        System.debug('filtredTranscriptFields.size ' + filtredTranscriptFields.size());
        if (!filtredTranscriptFields.isEmpty()) {
            ChatTranscriptService.fillRTLabel(filtredTranscriptFields);
        }
    }

    public static void updateAccountIdOnTranscript(List<LiveChatTranscript> newList) {
        System.debug('ChatTranscriptTriggerDispatcher.updateAccountIdOnTranscript...');
        List<LiveChatTranscript> filtredTranscriptFields = new List<LiveChatTranscript>();

        for (LiveChatTranscript transcript_i : newList) {
            if (String.isNotBlank(transcript_i.SMS_Phone__c)) {
                filtredTranscriptFields.add(transcript_i);
            }
        }

        System.debug('filtredTranscriptFields.size ' + filtredTranscriptFields.size());
        if (!filtredTranscriptFields.isEmpty()) {
            ChatTranscriptService.updateAccountIdByPhone(filtredTranscriptFields);
        }
    }
}