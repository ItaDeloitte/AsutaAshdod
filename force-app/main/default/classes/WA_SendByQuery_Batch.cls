global with sharing class WA_SendByQuery_Batch implements Database.Batchable<sObject>{

    public final String query;

    global WA_SendByQuery_Batch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('WA_SendByQuery_Batch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('WA_SendByQuery_Batch ... execute');
        System.debug('scope: [' + scope.size() + '] value: ' + scope);
        String channelId;
        String channelName;
        Map<String, Id> phoneNumberToEndUser = new Map<String, Id>();
        Map<Id, String> appIdToPhoneNumber = new  Map<Id, String>();
        List<WhatsApp__c> waToInsertList = new List<WhatsApp__c>();
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

        for (Appointment__c appointment_i : scope) {
            String phone_i = WhatAppUtils.validPhoneNumber(appointment_i.Patient_Account__r.SMS_Phone_Number__c);
            appIdToPhoneNumber.put(appointment_i.Id, phone_i);
        }
        
        System.debug('appIdToPhoneNumber: size: ' + appIdToPhoneNumber.size() + ' value: ' + appIdToPhoneNumber);
        if (!appIdToPhoneNumber.isEmpty()) {
            List<MessagingChannel> mesChannels = WhatAppUtils.getMessagingChannel('Assuta_Enhanced_Bot');
            if (!mesChannels.isEmpty()) {
                channelName = mesChannels.get(0).MasterLabel;
                channelId = mesChannels.get(0).Id;
            }
            phoneNumberToEndUser = WhatAppUtils.getMessagingEndUser(appIdToPhoneNumber, channelId); 
        }

        for (Appointment__c appointment_i : scope) {      
            String dateApp = String.valueOf(appointment_i.Appointment_Date__c).left(11);
            waToInsertList.add(WhatAppUtils.prepareWhatApp(appointment_i 
                                                            , 'cancel_appointment_emergency'
                                                            , 'WA_SendByQuery_Batch'                                                                                                                     
                                                            , phoneNumberToEndUser.containsKey(appIdToPhoneNumber.get(appointment_i.Id)) ? phoneNumberToEndUser.get(appIdToPhoneNumber.get(appointment_i.Id)) : null
                                                            , System.now()
                                                            , channelName
                                                            , 'formtitan_id_2:' + appointment_i.formtitan_id_2__c + '^' + 'Appointment_Date_In_Text:' + dateApp + '^' + 'site:' + appointment_i.Site__r.Name + '^'));            
        }

        Set<Id> insertedWAIdSet = AsyncUtil.doInsert(waToInsertList);
        System.debug('insertedWAIdSet: size: ' + insertedWAIdSet.size() + ' value: ' + insertedWAIdSet);
    }   

    global void finish(Database.BatchableContext BC) {
        System.debug('WA_SendByQuery_Batch ... finish');
    }

}