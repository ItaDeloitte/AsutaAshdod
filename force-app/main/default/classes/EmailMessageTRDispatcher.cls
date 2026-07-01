// Test: EmailMessageTRTest
public with sharing class EmailMessageTRDispatcher {

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Check that if Template Merge Field is not null then appropriate lookup field is not null too
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created          28-07-2021                  <evgeniy.kravchuk@synebo.io>
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void validateTemplateMergeField(List<EmailMessage> newList) {
        System.debug('LOG EmailMessage validateTemplateMergeField ... start');
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for (EmailMessage emailMessage_i : newList) {
            if (emailMessage_i.EmailTemplateId != null &&
                    emailMessage_i.TemplateMergeField__c != null &&
                    emailMessage_i.ExpectedSendingDateTime__c != null) {
                emailMessages.add(emailMessage_i);
            }
        }
        System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);

        if (!emailMessages.isEmpty()) {
            EmailMessageTRService.validateTemplateMergeField(emailMessages);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Check if FromAddress is an appropriate org-wide address and override it with 'nonreply@assuta.co.il' if it's not
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created          23-04-2021                  <evgeniy.kravchuk@synebo.io>
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void updateFromAddress(List<EmailMessage> newList) {
        System.debug('LOG EmailMessage updateFromAddress ... start');
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        Set<String> fromAddresses = new Set<String>{'nonreply@assuta.co.il'};

        for (EmailMessage emailMessage_i : newList) {
            if (emailMessage_i.ExpectedSendingDateTime__c != null) {
                emailMessages.add(emailMessage_i);
                fromAddresses.add(emailMessage_i.FromAddress);
            }
        }
        System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);
        System.debug('fromAddresses: size: ' + fromAddresses.size() + ' value: ' + fromAddresses);

        if (!emailMessages.isEmpty()) {
            EmailMessageTRService.updateFromAddress(emailMessages, fromAddresses);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Fill ContactId field with value from an Account object linked via AccountId field
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created          21-04-2021                  <evgeniy.kravchuk@synebo.io>
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillSubjectAndBodyFromTemplate(List<EmailMessage> newList) {
        System.debug('LOG EmailMessage fillSubjectAndBodyFromTemplate ... start');
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for (EmailMessage emailMessage_i : newList) {
            if (emailMessage_i.EmailTemplateId != null &&
                    emailMessage_i.ExpectedSendingDateTime__c != null) {
                emailMessages.add(emailMessage_i);
            }
        }
        System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);

        if (!emailMessages.isEmpty()) {
            EmailMessageTRService.fillSubjectAndBodyFromTemplate(emailMessages);
        }
    }
}