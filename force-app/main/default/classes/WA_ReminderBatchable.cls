//WA_ReminderBatchableTest
public with sharing class WA_ReminderBatchable implements Database.Batchable<sObject>{
        
    private String query;
    private Id channelId;
    private String reminderType;    
    private Set<Decimal> sReminderDomains = new Set<Decimal>();

    public WA_ReminderBatchable(String query, String reminderType) {
        this.query = query;
        this.reminderType = reminderType;
        channelId = WhatAppUtils.getMessagingChannel('Assuta_Enhanced_Bot')[0].Id;
        if (reminderType == 'Second') {
            for (SecondReminderDomainWA__mdt d :
                [SELECT DomainCode__c FROM SecondReminderDomainWA__mdt]) {
                sReminderDomains.add(d.DomainCode__c);
            }
        }
        System.debug('sReminderDomains: size: ' + sReminderDomains.size() + ' value: ' + sReminderDomains);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore(' WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {                  
        Map<Id, String> appIdToPhone = new Map<Id, String> ();
        Map<String, Id> phoneToEndUser = new Map<String, Id> ();
        List<WA_ReminderWrapper> requestList = new List<WA_ReminderWrapper>();
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);
                                      
        for (Appointment__c appt_i : scope) {
            
            //check if messaging is prevented if so, skip and do NOT send WhatsApp 
            if (preventMap.get(appt_i.Id) == true) {
                System.debug('Messaging prevented for appointment ' + appt_i.Id);
                continue; 
            }

            String phone_i = WhatAppUtils.validPhoneNumber(
                appt_i.Patient_Account__r.SMS_Phone_Number__c
            );

            if (ValidateUtil.isValidIsraeliMobile(phone_i)) {
                appIdToPhone.put(appt_i.Id, phone_i);                       
            }
        }
        System.debug('appIdToPhone: size: ' + appIdToPhone.size());       

        if (!appIdToPhone.isEmpty()) {
            phoneToEndUser  = WhatAppUtils.getMessagingEndUser(
                appIdToPhone, 
                channelId
            );
        }
        
        if (phoneToEndUser.isEmpty()) return;
                   
        for (Appointment__c appt_i : scope) {
            String phone = appIdToPhone.get(appt_i.Id);
            String messagingEndUserId =
                phone != null ? phoneToEndUser.get(phone) : null;
            String reminder = resolveReminder(appt_i);                                            
            requestList.add(new WA_ReminderWrapper( appt_i.case__c
                                                    , appt_i.Patient_Account__c
                                                    , appt_i.Site__r.Name
                                                    , appt_i.First_Name__c
                                                    , String.valueOf(appt_i.Domain__r.DomainCode__c)
                                                    , appt_i.SMS_Address__c
                                                    , appt_i.day_date_hour__c
                                                    , appt_i.Patient_Account__r.SMS_Phone_Number__c
                                                    , appt_i.Id
                                                    , messagingEndUserId
                                                    , appt_i.formtitan_arrival_link__c 
                                                    , appt_i.Exact_Location_In_Domain__c
                                                    , appt_i.Medical_Procedure_Marketing_Name__c  
                                                    , reminder
                                                    , appt_i.Medical_Procedure__r.Virtual_Appointment__c
                                                    , 'WA_ReminderBatchable' + ' ||| ' + UserInfo.getUserName()
                                                )
                            );
        }
        System.debug('requestList: size: ' + requestList.size());
        if (requestList.isEmpty())
            return;

        Map<String,Object> params = new Map<String,Object>();
        params.put('Appointments_Data', requestList);

        /*if (reminderType == 'First') { //change flows because duplicate logic 2728529306
            Flow.Interview.Outbound_WA_for_MRI_first_reminder flow =
                new Flow.Interview.Outbound_WA_for_MRI_first_reminder(params);

            flow.start();
        } else {
            Flow.Interview.Outbound_WA_for_MRI_second_reminder flow =
                new Flow.Interview.Outbound_WA_for_MRI_second_reminder(params);
            flow.start();
        }  */ 

        Flow.Interview.Outbound_WA_For_Reminders flow = new Flow.Interview.Outbound_WA_For_Reminders(params);
        flow.start();       
    }

    private String resolveReminder(Appointment__c appt) {
        if (reminderType == 'First')
            return 'First';

        if (appt.preDateReminderWA__c == System.today()
            && appt.isPreReminderWASent__c == false)
            return 'PreReminder';
        
        return 'Second';
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('WA reminder batch finished');
    }
}