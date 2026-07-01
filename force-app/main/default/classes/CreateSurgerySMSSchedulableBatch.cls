public class CreateSurgerySMSSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String whatsAppContent = 'אנו מאחלים לך בהצלחה בניתוח. חשוב מאוד להקפיד על ההנחיות לניתוח המפורטות בקישור הבא: https://Mysurgery.assuta.co.il/?aid={0}';

    String query = 'SELECT Id'
                      + ', Case__c'
                      + ', SendingMessage__c'
                      + ', sendingByWhatsApp__c'
                      + ', Patient_Account__r.Phone'
                      + ', Patient_Account__r.SMS_Phone_Number__c'
                + ' FROM Appointment__c'
                + ' WHERE Need_to_send_sms_before_surgery__c = true'
                + ' AND Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c = true'
                + ' AND (Medical_Procedure1__r.Domain__r.ReferenceDigitalLobby__c = true OR Medical_Procedure1__c = null)'
                + ' AND (Medical_Procedure2__r.Domain__r.ReferenceDigitalLobby__c = true OR Medical_Procedure2__c = null)'
                + ' AND (Medical_Procedure3__r.Domain__r.ReferenceDigitalLobby__c = true OR Medical_Procedure3__c = null)'
                + ' AND (Medical_Procedure4__r.Domain__r.ReferenceDigitalLobby__c = true OR Medical_Procedure4__c = null)'
                + ' ORDER BY CreatedDate DESC';

    public CreateSurgerySMSSchedulableBatch() {}

    public CreateSurgerySMSSchedulableBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CreateSurgerySMSSchedulableBatch.start ...');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('CreateSurgerySMSSchedulableBatch.execute ...');
        String channelId;
        String channelName;
        Map<String, Id> phoneNumberToEndUser = new Map<String, Id>();
        Map<Id, String> appIdToPhoneNumber = new  Map<Id, String>();
        List<WhatsApp__c> waToInsertList = new List<WhatsApp__c>();
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

        for (Appointment__c appointment_i : scope) {
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
                                                                ,'luck_surgerywa'
                                                                , 'CreateSurgerySMSSchedulableBatch'                                                                
                                                                , phoneNumberToEndUser.containsKey(appIdToPhoneNumber.get(appointment_i.Id)) ? phoneNumberToEndUser.get(appIdToPhoneNumber.get(appointment_i.Id)) : null
                                                                , System.now()
                                                                , channelName
                                                                , null));
            } else { 
                SMS__c sms_i = SMSUtils.prepareSMS('Message__twenty_four_h_before_Surgery', appointment_i.Patient_Account__r.Phone, appointment_i.Id, false);
                sms_i.Automation_name__c = 'CreateSurgerySMSSchedulableBatch';
                smsToInsertList.add(sms_i);
            }
        }
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);

        Set<Id> insertedWAIdSet = AsyncUtil.doInsert(waToInsertList);

        for (WhatsApp__c wa_i : [SELECT Id
                                  , Appointment__c 
                               FROM WhatsApp__c 
                              WHERE Id 
                                 IN :insertedWAIdSet]) {
            appointmentToUpdateList.add(new Appointment__c(
                Id = wa_i.Appointment__c,
                Message_24h_before_surgery__c = true
            ));
        }
        System.debug('insertedWAIdSet: size: ' + insertedWAIdSet.size() + ' value: ' + insertedWAIdSet);

        Set<Id> insertedSMSIdSet = AsyncUtil.doInsert(smsToInsertList);

        for (SMS__c sms_i : [SELECT Id
                                  , Appointment__c 
                               FROM SMS__c 
                              WHERE Id 
                                 IN :insertedSMSIdSet]) {
            appointmentToUpdateList.add(new Appointment__c(
                Id = sms_i.Appointment__c,
                Message_24h_before_surgery__c = true
            ));
        }
        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);

        AsyncUtil.doUpdate(appointmentToUpdateList);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CreateSurgerySMSSchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateSurgerySMSSchedulableBatch(), 25);
    }
}