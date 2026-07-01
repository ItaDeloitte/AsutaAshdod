/*
    * @author           Ortal Kazum         <ortalk@assuta.co.il>
    * @Test             SendSMSHandlerTest
    * @modifiedBy
    * @version          1.0
    * @created          24-12-2019
    * @modified         DD-MM-YYYY
    * @description      Send SMS by ws_OutboundSMS interface
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class SendSMSHandler implements Queueable, Database.AllowsCallouts {

    public Set<Id> smsIds;

    public SendSMSHandler(Set<Id> smsIds) {
        System.debug('smsIds: size: ' + smsIds.size() + ' value: ' + smsIds);
        this.smsIds = smsIds;
    }

    public void execute(QueueableContext context) {
        List<SMS__c> smsList = [SELECT Id, Name, Phone_Number__c, Content__c , SMS_Always__c,From_Phone__c FROM SMS__c WHERE Id IN: smsIds];
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'nonreply@assuta.co.il' LIMIT 1];
        ws_OutboundSMS.AssutaSMSWSServiceSoap smsService = new ws_OutboundSMS.AssutaSMSWSServiceSoap();
        Map<Id, ws_OutboundSMS.SendText> responsesMap = new Map<Id, ws_OutboundSMS.SendText>();
        Map<String, Exception> errorsMap = new Map<String, Exception>();
        Map<String, Set<Id>> smsIdsMap = new Map<String, Set<Id>>();
        Set<Id> nextSMSIds = new Set<Id>();

        for (SMS__c sms_i : smsList) {
            if (Limits.getCallouts() < Limits.getLimitCallouts()) {
                try {
                    ws_OutboundSMS.SendText response_i = smsService.SendSMS(sms_i.Phone_Number__c, sms_i.Content__c, 16, sms_i.SMS_Always__c,sms_i.From_Phone__c);
                    responsesMap.put(sms_i.Id, response_i);
                } catch (Exception e) {
                    if (!errorsMap.containsKey(e.getMessage())) {
                        smsIdsMap.put(e.getMessage(), new Set<Id>());
                        errorsMap.put(e.getMessage(), e);
                    }
                    smsIdsMap.get(e.getMessage()).add(sms_i.Id);
                }
            } else {
                nextSMSIds.add(sms_i.Id);
            }
        }
        System.debug('responsesMap: size: ' + responsesMap.size() + ' value: ' + responsesMap);
        System.debug('nextSMSIds: size: ' + nextSMSIds.size() + ' value: ' + nextSMSIds);
        System.debug('errorsMap: size: ' + errorsMap.size() + ' value: ' + errorsMap);
        System.debug('smsIdsMap: size: ' + smsIdsMap.size() + ' value: ' + smsIdsMap);

        if (!nextSMSIds.isEmpty()) {
            System.enqueueJob(new SendSMSHandler(nextSMSIds));
        }

        if (!responsesMap.isEmpty()) {
            updateSMS(responsesMap);
        }

        if (!errorsMap.isEmpty()) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            for (String message_i : errorsMap.keySet()) {
                if (smsIdsMap.containsKey(message_i)) {
                    mails.add(prepareMail(errorsMap.get(message_i), smsIdsMap.get(message_i), owea.Id));
                }
            }
            System.debug('mails: size: ' + mails.size() + ' value: ' + mails);

            Messaging.sendEmail(mails);
        }
    }

/*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Update SMS records with response data (success/failure) from the Ensemble
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param        responsesMap        Map of ws_OutboundSMS.SendText by SMS__c Id
    * @return       ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static void updateSMS(Map<Id, ws_OutboundSMS.SendText> responsesMap) {
        List<SMS__c> smsList = new List<SMS__c>();

        for (Id smsId_i : responsesMap.keySet()) {
            smsList.add(
                new SMS__c(
                    Id = smsId_i,
                    Success__c = responsesMap.get(smsId_i).Success,
                    ErrorMessage__c = responsesMap.get(smsId_i).ErrorMessage
                )
            );
        }
        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);

        if (!smsList.isEmpty()) {
            update smsList;
        }
    }

/*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Prepare email with an ensemble's error
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param        e               Exception
    * @param        smsIds          Set of SMS__c Ids
    * @return       mail            Messaging.SingleEmailMessage
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Messaging.SingleEmailMessage prepareMail(Exception e, Set<Id> smsIds, Id oweaId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(Label.SMSSyncFailure_ToAddresses.split(','));
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setSubject('SMS Sync Failure');
        mail.setPlainTextBody('The error occurred while sending SMS into the Ensemble.'
                            + '\n' + smsIds.size() + ' record(s) failed'
                            + '\nRecord Id(s): ' + smsIds
                            + '\nMessage: ' + e.getMessage()
                            + '\nLine Number: ' + e.getLineNumber()
                            + '\nStack Trace String: ' + e.getStackTraceString());
        return mail;
    }
}