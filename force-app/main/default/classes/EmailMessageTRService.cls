// Test: EmailMessageTRTest
public with sharing class EmailMessageTRService {

    public static void validateTemplateMergeField(List<EmailMessage> emailMessages) {
        Boolean logicExecuted = false;

        for (EmailMessage emailMessage_i : emailMessages) {
            if (emailMessage_i.get(emailMessage_i.TemplateMergeField__c) == null) {
                emailMessage_i.addError(Label.EmailMessage_TR_validateTemplateMergeField_Error);
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('LOG EmailMessage validateTemplateMergeField ... logic has been executed');
        }
    }

    public static void updateFromAddress(List<EmailMessage> emailMessages, Set<String> fromAddresses) {
        Map<String, OrgWideEmailAddress> fromAddressToOWEAMap = new Map<String, OrgWideEmailAddress>();

        for (OrgWideEmailAddress owea_i : [SELECT Address
                                                , DisplayName
                                             FROM OrgWideEmailAddress
                                            WHERE Address IN: fromAddresses]) {
            fromAddressToOWEAMap.put(owea_i.Address, owea_i);
        }
        System.debug('fromAddressToOWEAMap: size: ' + fromAddressToOWEAMap.size() + ' value: ' + fromAddressToOWEAMap);

        for (EmailMessage emailMessage_i : emailMessages) {
            OrgWideEmailAddress owea_i = fromAddressToOWEAMap.containsKey(emailMessage_i.FromAddress)
                ? fromAddressToOWEAMap.get(emailMessage_i.FromAddress)
                : fromAddressToOWEAMap.get('nonreply@assuta.co.il');
            emailMessage_i.FromAddress = owea_i.Address;
            emailMessage_i.FromName = owea_i.DisplayName;
        }
        System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);
        System.debug('LOG EmailMessage updateFromAddress ... logic has been executed');
    }

    public static void fillSubjectAndBodyFromTemplate(List<EmailMessage> emailMessages) {
        for (EmailMessage emailMessage_i : emailMessages) {
            Messaging.SingleEmailMessage mail_i = Messaging.renderStoredEmailTemplate(emailMessage_i.EmailTemplateId, null, getWhatId(emailMessage_i));

            emailMessage_i.Subject = mail_i.getSubject();
            emailMessage_i.HtmlBody = mail_i.getHtmlBody();
        }
        System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);
        System.debug('LOG EmailMessage fillSubjectAndBodyFromTemplate ... logic has been executed');
    }

    private static Id getWhatId(EmailMessage emailMessage) {
        Id whatId;
        if (emailMessage.TemplateMergeField__c != null && emailMessage.get(emailMessage.TemplateMergeField__c) != null) {
            whatId = Id.valueOf((String) emailMessage.get(emailMessage.TemplateMergeField__c));
        } else {
            /** Priority: AppointmentId__c or ParentId or AccountId__c or Survey_Taker__c */
            if (emailMessage.AppointmentId__c != null) {
                whatId = emailMessage.AppointmentId__c;
            } else if (emailMessage.ParentId != null) {
                whatId = emailMessage.ParentId;
            } else if (emailMessage.AccountId__c != null) {
                whatId = emailMessage.AccountId__c;
            } else if (emailMessage.Survey_Taker__c != null) {
                whatId = emailMessage.Survey_Taker__c;
            }
        }
        return whatId;
    }
}