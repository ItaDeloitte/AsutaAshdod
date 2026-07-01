// Created: Evgeniy Kravchuk
// Date: 21.01.2020
// Test: Bot_UpdateTranscriptTest
global without sharing class Bot_UpdateTranscript {

    public class Bot_UpdateTranscriptException extends Exception {}

    global class UpdateTranscriptRequestWrapper {
        @InvocableVariable(label='transcriptId' description='SF id of a live chat transcript' required=true)
        public String transcriptId;
        @InvocableVariable(label='accountId' description='SF id of an account' required=false) //Dima's request
        public String accountId;
        @InvocableVariable(label='caseId' description='SF id of a case' required=false)
        public String caseId;
        @InvocableVariable(label='LeadId' description='SF id of a Lead' required=false)
        public String leadId;
    }

    @InvocableMethod(label='Update LiveChatTranscript')
    public static void updateTranscript(List<UpdateTranscriptRequestWrapper> inList) {
        try {
            if (inList.isEmpty()) {
                throw new Bot_UpdateTranscriptException('Params is blank');
            }
            updateInFuture(inList.get(0).transcriptId, inList.get(0).caseId, inList.get(0).accountId, inList.get(0).leadId);
        } catch (Exception e) {
            throw new Bot_UpdateTranscriptException('Line: ' + e.getLineNumber() + ' Message: ' + e.getMessage());
        }
    }

    @future
    public static void updateInFuture(String recordId, String caseId, String accountId, String leadId) {
        if (Id.valueOf(recordId).getSobjectType() == LiveChatTranscript.getSObjectType()) {
            LiveChatTranscript transcript = new LiveChatTranscript(Id = recordId, Case__c = caseId, Account__c = accountId, leadId = leadId);
            System.debug('LiveChatTranscript: ' + transcript);
            update transcript;
        } else if (Id.valueOf(recordId).getSobjectType() == MessagingSession.getSObjectType()) {
            MessagingSession session = new MessagingSession(Id = recordId, New_Case__c = caseId, New_Account__c = accountId, leadId = leadId);
            System.debug('MessagingSession: ' + session);
            update session;
        }
    }
}