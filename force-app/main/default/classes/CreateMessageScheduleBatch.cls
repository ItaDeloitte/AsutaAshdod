public class CreateMessageScheduleBatch implements Database.Batchable<sObject>, Schedulable {
    String HYGIENE_TEMPLATE = 'Guidelines_for_hygiene';
    String query = 'SELECT Id '
                      + ', Case__c'
                      + ', Patient_Account__c'
                      + ', Patient_Mail__c'
                      + ', SendingMessage__c'
                      + ', sendingByWhatsApp__c'
                      + ', Appointment_Date_Time__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Case__r.preferd_chanal_case__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                  + ' FROM Appointment__c'
                 + ' WHERE ((sendingByWhatsApp__c = true AND SendingMessage__c = true) OR (Case__r.preferd_chanal_case__c = \'SMS\' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)) '
                 + ' OR (Case__r.preferd_chanal_case__c = \'Email\' AND Patient_Mail__c != null))'
                   + ' AND RecordType.DeveloperName = \'Surgeries\''
                   + ' AND Appointment_Status__c NOT IN (\'Canceled\', \'2\', \'5\', \'CanceledFailed\', \'not_arrived\', \'4\', \'3\')'
                   + ' AND Medical_Procedure__r.Domain__r.DomainCode__c NOT IN (26, 311, 313, 11, 24, 300, -1, 420, 171, 101, 99, 27, 330, 10, 1, 563, 217, 225, 380, 382, 230, 173, 223, 422, 181, 252, 432, 25, 29, 560)'
                   + ' AND Medical_Procedure__r.Confidentiality__c = false'
                   + ' AND Administrative_Status__c != \'הושלם\''
                   + ' AND Site__r.Site_Code__c != \'33\''
                   + ' AND Appointment_Date_time__c = NEXT_N_DAYS:3'
                   + ' AND Appointment_Date_time__c > NEXT_N_DAYS:2';

    public CreateMessageScheduleBatch() {}

    public CreateMessageScheduleBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('MessageSendingScheduleBatch ... start');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('MessageSendingScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        List<WhatsApp__c> waToInsertList = new List<WhatsApp__c>();
        List<EmailMessage> emailMessageToInsertList = new List<EmailMessage>();
        Map<String, Id> phoneNumberToEndUser = new Map<String, Id>();
        Map<Id, String> appIdToPhoneNumber = new  Map<Id, String>();
        String channelName;
        String channelId;

        EmailTemplate hygieneTemplate = obtainEmailTemplate();
		
        for (Appointment__c appointment_i : scope) {
            System.debug(appointment_i.sendingByWhatsApp__c + ' ' + appointment_i.SendingMessage__c);
            if (appointment_i.sendingByWhatsApp__c && appointment_i.SendingMessage__c) {
                String phone_i = WhatAppUtils.validPhoneNumber(appointment_i.Patient_Account__r.SMS_Phone_Number__c);
                appIdToPhoneNumber.put(appointment_i.Id, phone_i);
            }
        }
        System.debug('appIdToPhoneNumber: size: ' + appIdToPhoneNumber.size() + ' value: ' + appIdToPhoneNumber);

        if (!appIdToPhoneNumber.isEmpty()) {
            List<MessagingChannel> mesChannels = WhatAppUtils.getMessagingChannel('Surgery_Bot');
            if (!mesChannels.isEmpty()) {
                channelName = mesChannels.get(0).MasterLabel;
                channelId = mesChannels.get(0).Id;
            }
            phoneNumberToEndUser = WhatAppUtils.getMessagingEndUser(appIdToPhoneNumber, channelId); 
        }

        for (Appointment__c appointment_i : scope) {
            if (appointment_i.sendingByWhatsApp__c && appointment_i.SendingMessage__c) {
                waToInsertList.add(WhatAppUtils.prepareWhatApp(appointment_i 
                                                                ,'instructions_infections_new'
                                                                , 'CreateMessageScheduleBatch'                                                               
                                                                , phoneNumberToEndUser.containsKey(appIdToPhoneNumber.get(appointment_i.Id)) ? phoneNumberToEndUser.get(appIdToPhoneNumber.get(appointment_i.Id)) : null
                                                                , datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1, 8, 0, 0)
                                                                , channelName
                                                                , ''));
            } else if (appointment_i.Case__r.preferd_chanal_case__c != null) {
                switch on appointment_i.Case__r.preferd_chanal_case__c {
                    when 'SMS' {
                        smsToInsertList.add(SMSUtils.prepareSMS(appointment_i, this.HYGIENE_TEMPLATE, true));
                    }
                    when 'Email' {
                        if (hygieneTemplate == null) {
                            continue;
                        }

                        emailMessageToInsertList.add(new EmailMessage(
                            ToAddress = appointment_i.Patient_Mail__c,
                            FromAddress = 'nonreply@assuta.co.il',
                            TemplateMergeField__c = 'AppointmentId__c',
                            AccountId__c = appointment_i.Patient_Account__c,
                            AppointmentId__c = appointment_i.Id,
                            ExpectedSendingDateTime__c = Datetime.now(),
                            EmailTemplateId = hygieneTemplate.Id,
                            EmailTemplateDeveloperName__c = hygieneTemplate.DeveloperName,
                            Automation_name__c = 'CreateMessageScheduleBatch'
                        ));
                    }
                }
            }
        }

        System.debug('waToInsertList: size: ' + waToInsertList.size() + ' value: ' + waToInsertList);
        if (!waToInsertList.isEmpty()) {
            AsyncUtil.doInsert(waToInsertList);
        }

        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);
        if (!smsToInsertList.isEmpty()) {
            AsyncUtil.doInsert(smsToInsertList);
        }

        System.debug('emailMessageToInsertList: size: ' + emailMessageToInsertList.size() + ' value: ' + emailMessageToInsertList);
        if (!emailMessageToInsertList.isEmpty()) {
            AsyncUtil.doInsert(emailMessageToInsertList);
        }
    }

    private EmailTemplate obtainEmailTemplate() {
        List<EmailTemplate> emailTemplateList = [SELECT Id
                                                      , DeveloperName 
                                                   FROM EmailTemplate 
                                                  WHERE DeveloperName = :this.HYGIENE_TEMPLATE];

        return emailTemplateList.isEmpty() ? null : emailTemplateList.get(0);
    }

    private String obtainSMSTemplate() {
        List<SmsTemplate__c> smsTemplateList = [SELECT Sms_content__c
                                                   FROM SmsTemplate__c
                                                  WHERE developerName__c = :this.HYGIENE_TEMPLATE];

        return smsTemplateList.isEmpty() ? null : smsTemplateList.get(0).Sms_content__c;
    }



    public void finish(Database.BatchableContext BC) {
        System.debug('MessageSendingScheduleBatch ... finish');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(this);
    }
}