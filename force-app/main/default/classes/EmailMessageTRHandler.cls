// Test: EmailMessageTRTest
public with sharing class EmailMessageTRHandler {

    public static void handleTrigger(List<EmailMessage> newList, Map<Id, EmailMessage> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('EmailMessageTRHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                EmailMessageTRDispatcher.validateTemplateMergeField(newList);
                EmailMessageTRDispatcher.updateFromAddress(newList);
                EmailMessageTRDispatcher.fillSubjectAndBodyFromTemplate(newList);
            }
        }
    }
}