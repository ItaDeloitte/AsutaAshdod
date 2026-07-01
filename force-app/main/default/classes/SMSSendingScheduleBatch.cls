/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * SMS Sender Schedule Batch Apex class to send SMS asynchronously
 *
 * Test                 SMSSendingScheduleBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             22-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class SMSSendingScheduleBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    Datetime currentDateTime = System.now();
    String query = 'SELECT Content__c'
                      + ', SMS_Always__c'
                      + ', From_Phone__c'
                      + ', Phone_Number__c'
                      + ', ActualSendingDateTime__c'
                      + ', ExpectedSendingDateTime__c'
                  + ' FROM SMS__c'
                 + ' WHERE Type__c = \'Outgoing\''
                   + ' AND Phone_Number__c != null'
                   + ' AND ActualSendingDateTime__c = null'
                   + ' AND ExpectedSendingDateTime__c != null' +
                   + ' AND ExpectedSendingDateTime__c <= :currentDateTime'
              + ' ORDER BY CreatedDate DESC';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('SMSSendingScheduleBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SMS__c> scope) {
        System.debug('SMSSendingScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        ws_OutboundSMS.AssutaSMSWSServiceSoap service = new ws_OutboundSMS.AssutaSMSWSServiceSoap();

        Map<Id, ws_OutboundSMS.SendText> responseMap = new Map<Id, ws_OutboundSMS.SendText>();
        Map<String, Exception> errorMap = new Map<String, Exception>();
        Map<String, Set<Id>> smsIdsMap = new Map<String, Set<Id>>();

        for (SMS__c sms_i : scope) {
            if (sms_i.Content__c == null) {
                continue;
            }

            try {
                responseMap.put(sms_i.Id, service.SendSMS(sms_i.Phone_Number__c, sms_i.Content__c, 16, sms_i.SMS_Always__c,sms_i.From_Phone__c));
            } catch (Exception e) {
                if (!errorMap.containsKey(e.getMessage())) {
                    smsIdsMap.put(e.getMessage(), new Set<Id>());
                    errorMap.put(e.getMessage(), e);
                }
                smsIdsMap.get(e.getMessage()).add(sms_i.Id);
            }
        }
        System.debug('responseMap: size: ' + responseMap.size() + ' value: ' + responseMap);
        System.debug('smsIdsMap: size: ' + smsIdsMap.size() + ' value: ' + smsIdsMap);
        System.debug('errorMap: size: ' + errorMap.size() + ' value: ' + errorMap);

        if (!responseMap.isEmpty()) {
            updateSMS(responseMap);
        }

        if (!errorMap.isEmpty()) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'nonreply@assuta.co.il' LIMIT 1];

            for (String message_i : errorMap.keySet()) {
                if (smsIdsMap.containsKey(message_i)) {
                    mails.add(prepareMail(errorMap.get(message_i), smsIdsMap.get(message_i), owea.Id));
                }
            }
            System.debug('mails: size: ' + mails.size() + ' value: ' + mails);

            Messaging.sendEmail(mails);
        }
    }

    private static void updateSMS(Map<Id, ws_OutboundSMS.SendText> responseMap) {
        List<SMS__c> smsList = new List<SMS__c>();

        for (Id smsId_i : responseMap.keySet()) {
            smsList.add(
                new SMS__c(
                    Id = smsId_i,
                    Success__c = responseMap.get(smsId_i).Success,
                    ErrorMessage__c = responseMap.get(smsId_i).ErrorMessage,
                    ActualSendingDateTime__c = System.now()
                )
            );
        }
        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);

        AsyncUtil.doUpdate(smsList);
    }

    private static Messaging.SingleEmailMessage prepareMail(Exception e, Set<Id> smsIds, Id oweaId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(Label.SMSSyncFailure_ToAddresses.split(','));
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setSaveAsActivity(false);
        mail.setSubject('SMS Sync Failure');
        mail.setPlainTextBody('The error occurred while sending SMS into the Ensemble.'
            + '\n' + smsIds.size() + ' record(s) failed'
            + '\nRecord Id(s): ' + smsIds
            + '\nMessage: ' + e.getMessage()
            + '\nLine Number: ' + e.getLineNumber()
            + '\nStack Trace String: ' + e.getStackTraceString());
        return mail;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('SMSSendingScheduleBatch ... finish');
        Datetime now = System.now().addMinutes(5);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('SMS Messages Sender #' + now.getTime(), CRONEXP, new SMSSendingScheduleBatch());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new SMSSendingScheduleBatch(), 100);
    }
}