// Test: EmailSendingScheduleBatchTest
global class EmailSendingScheduleBatch implements Database.Batchable<sObject>, Schedulable {

    Datetime currentDateTime = System.now();
    String query = 'SELECT ParentId'
                      + ', FromName'
                      + ', ToAddress'
                      + ', FromAddress'
                      + ', CcAddress'
                      + ', BccAddress'        
                      + ', LeadId__c'
                      + ', AccountId__c'
                      + ', Survey_Taker__c'
                      + ', AppointmentId__c'
                      + ', OpportunityId__c'                      
                      + ', TemplateMergeField__c'                      
                      + ', ActualSendingDateTime__c'
                      + ', Medical_Aid_Appointment__c'
                      + ', ExpectedSendingDateTime__c'                      
                      + ', EmailTemplateDeveloperName__c'
                  + ' FROM EmailMessage'
                 + ' WHERE ToAddress != null'
                   + ' AND FromAddress != null'
                   + ' AND EmailTemplateDeveloperName__c != null'
                   + ' AND (ParentId != null'
                        + ' OR LeadId__c != null'
                        + ' OR AccountId__c != null'
                        + ' OR Survey_Taker__c != null'
                        + ' OR AppointmentId__c != null'        				
                        + ' OR OpportunityId__c != null'
        				+ ' OR Medical_Aid_Appointment__c != null)'
                   + ' AND ActualSendingDateTime__c = null'
                   + ' AND ExpectedSendingDateTime__c != null' +
                   + ' AND ExpectedSendingDateTime__c <= :currentDateTime';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('EmailSendingScheduleBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<EmailMessage> scope) {
        System.debug('EmailSendingScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String, OrgWideEmailAddress> oweaMap = new Map<String, OrgWideEmailAddress>();
        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        Map<Id, List<String>> emailMessageIdToVersionIds = new Map<Id, List<String>>();
        List<EmailMessage> filteredEmailMessages = new List<EmailMessage>();
        List<EmailMessage> sentEmailMessages = new List<EmailMessage>();
        Set<String> templateNames = new Set<String>();
        Set<String> fromAddresses = new Set<String>();
        Set<Id> emailMessageIds = new Set<Id>();

        for (EmailMessage emailMessage_i : scope) {
            emailMessageIds.add(emailMessage_i.Id);
            fromAddresses.add(emailMessage_i.FromAddress);
            templateNames.add(emailMessage_i.EmailTemplateDeveloperName__c);
        }
        System.debug('emailMessageIds: size: ' + emailMessageIds.size() + ' value: ' + emailMessageIds);
        System.debug('fromAddresses: size: ' + fromAddresses.size() + ' value: ' + fromAddresses);
        System.debug('templateNames: size: ' + templateNames.size() + ' value: ' + templateNames);

        for (OrgWideEmailAddress owea_i : [SELECT Address
                                             FROM OrgWideEmailAddress
                                            WHERE Address IN :fromAddresses]) {
            oweaMap.put(owea_i.Address, owea_i);
        }
        System.debug('oweaMap: size: ' + oweaMap.size() + ' value: ' + oweaMap);

        for (EmailTemplate template_i : [SELECT Body
                                              , Subject
                                              , HtmlValue
                                              , DeveloperName
                                           FROM EmailTemplate
                                          WHERE DeveloperName IN :templateNames]) {
            templateMap.put(template_i.DeveloperName, template_i);
        }
        System.debug('templateMap: size: ' + templateMap.size() + ' value: ' + templateMap);

        for (ContentDocumentLink cdl_i : [SELECT LinkedEntityId
                                               , ContentDocument.LatestPublishedVersionId
                                            FROM ContentDocumentLink
                                           WHERE LinkedEntityId IN :emailMessageIds]) {
            if (!emailMessageIdToVersionIds.containsKey(cdl_i.LinkedEntityId)) {
                emailMessageIdToVersionIds.put(cdl_i.LinkedEntityId, new List<String>());
            }
            emailMessageIdToVersionIds.get(cdl_i.LinkedEntityId).add(cdl_i.ContentDocument.LatestPublishedVersionId);
        }
        System.debug('emailMessageIdToVersionIds: size: ' + emailMessageIdToVersionIds.size() + ' value: ' + emailMessageIdToVersionIds);

        for (EmailMessage emailMessage_i : scope) {
            if (oweaMap.containsKey(emailMessage_i.FromAddress) && templateMap.containsKey(emailMessage_i.EmailTemplateDeveloperName__c)) {
                mails.add(prepareMail(
                    emailMessage_i,
                    templateMap.get(emailMessage_i.EmailTemplateDeveloperName__c),
                    oweaMap.get(emailMessage_i.FromAddress).Id,
                    emailMessageIdToVersionIds.get(emailMessage_i.Id)));
                filteredEmailMessages.add(emailMessage_i);
            }
        }
        System.debug('filteredEmailMessages: size: ' + filteredEmailMessages.size() + ' value: ' + filteredEmailMessages);
        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails, false);
        for (Messaging.SendEmailResult result_i : results) {
            if (result_i.isSuccess()) {
                EmailMessage emailMessage_i = filteredEmailMessages.get(results.indexOf(result_i));
                emailMessage_i.ActualSendingDateTime__c = System.now();
                sentEmailMessages.add(emailMessage_i);
            } else {
                System.debug('Result Errors: ' + result_i.getErrors());
            }
        }
        System.debug('sentEmailMessages: size: ' + sentEmailMessages.size() + ' value: ' + sentEmailMessages);

        AsyncUtil.doUpdate(sentEmailMessages);
    }

    private static Messaging.SingleEmailMessage prepareMail(EmailMessage emailMessage, EmailTemplate template, Id oweaId, List<String> versionIds) {
        Id targetId = getTargetId(emailMessage);

        Messaging.SingleEmailMessage mail = targetId.getSobjectType() == Lead.getSObjectType()
            ? Messaging.renderStoredEmailTemplate(template.Id, targetId, null, Messaging.AttachmentRetrievalOption.NONE)
            : Messaging.renderStoredEmailTemplate(template.Id, null, targetId, Messaging.AttachmentRetrievalOption.NONE);

        mail.setToAddresses(emailMessage.ToAddress.deleteWhitespace().split(';'));
        
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setSaveAsActivity(false);
        if (versionIds != null) {
            mail.setEntityAttachments(versionIds);
        }
        if (emailMessage.CcAddress != null) {
          mail.setCcAddresses(emailMessage.CcAddress.deleteWhitespace().split(';'));
        }
        if (emailMessage.BccAddress != null) {
          mail.setBccAddresses(emailMessage.BccAddress.deleteWhitespace().split(';'));  
        }

        return mail;
    }

    private static Id getTargetId(EmailMessage emailMessage) {
        Id targetId;
        if (emailMessage.TemplateMergeField__c != null && emailMessage.get(emailMessage.TemplateMergeField__c) != null) {
            targetId = Id.valueOf((String) emailMessage.get(emailMessage.TemplateMergeField__c));
        } else {
            /** Priority: AppointmentId__c or ParentId or AccountId__c or Survey_Taker__c or OpportunityId__c or LeadId__c or Medical_Aid_Appointment__c */
            if (emailMessage.AppointmentId__c != null) {
                targetId = emailMessage.AppointmentId__c;
            } else if (emailMessage.ParentId != null) {
                targetId = emailMessage.ParentId;
            } else if (emailMessage.AccountId__c != null) {
                targetId = emailMessage.AccountId__c;
            } else if (emailMessage.Survey_Taker__c != null) {
                targetId = emailMessage.Survey_Taker__c;
            } else if (emailMessage.OpportunityId__c != null) {
                targetId = emailMessage.OpportunityId__c;
            } else if (emailMessage.LeadId__c != null) {
                targetId = emailMessage.LeadId__c;
            } else if (emailMessage.Medical_Aid_Appointment__c != null) {
                targetId = emailMessage.Medical_Aid_Appointment__c;
            }
        }
        return targetId;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('EmailSendingScheduleBatch ... finish');
        Datetime now = System.now().addMinutes(5);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('Email Messages Sender #' + now.getTime(), CRONEXP, new EmailSendingScheduleBatch());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new EmailSendingScheduleBatch(), 95);
    }
}