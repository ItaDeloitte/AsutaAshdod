global class WA_SendingBarcodeIdentifySchedule implements Database.Batchable<sObject>, Schedulable {
       
    Datetime currentDateTime = System.now();
    String query = 'SELECT Id '
                    + ', Case__c'
                    + ', First_Name__c'   
                    + ', Patient_Account__c'   
                    + ', formtitan_id_2__c'                                   
                    + ', Patient_Mail__c'                    
                    + ', sendingByWhatsApp__c'
                    + ', Appointment_Date_Time__c'
                    + ', Case__r.SMS_Phone_Number__c'
                    + ', Case__r.preferd_chanal_case__c'
                    + ', Patient_Account__r.SMS_Phone_number__c'                    
                + ' FROM Appointment__c'              
                + ' WHERE sendingByWhatsApp__c = true'  
                + ' AND SendingMessage__c = true'             
                + ' AND RecordType.DeveloperName = \'Institutes\''
                + ' AND Patient_Account__r.SMS_Phone_Number__c != null'  
                + ' AND Patient_Account__r.Age_Number__c >= 18'                    
                + ' AND BarcodeIdentificationSent__c = false'
                + ' AND Appointment_Date_Time__c >= TODAY'
                + ' AND BarcodeIdentifyTime__c <= :currentDateTime'
                + ' AND Appointment_Status__c NOT IN (\'Canceled\', \'2\', \'5\', \'CanceledFailed\', \'not_arrived\', \'4\', \'3\')';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('WA_SendingBarcodeIdentifySchedule ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('WA_SendingBarcodeIdentifySchedule ... execute');
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
            waToInsertList.add(WhatAppUtils.prepareWhatApp(appointment_i 
                                                            , 'patient_Identification'
                                                            , 'WA_SendingBarcodeIdentifySchedule'                                                                                                                     
                                                            , phoneNumberToEndUser.containsKey(appIdToPhoneNumber.get(appointment_i.Id)) ? phoneNumberToEndUser.get(appIdToPhoneNumber.get(appointment_i.Id)) : null
                                                            , System.now()
                                                            , channelName
                                                            , 'firstname:' + appointment_i.First_Name__c + '^' + 'formtitan_id_2:' + appointment_i.formtitan_id_2__c + '^'));            
        }

        Set<Id> insertedWAIdSet = AsyncUtil.doInsert(waToInsertList);
        System.debug('insertedWAIdSet: size: ' + insertedWAIdSet.size() + ' value: ' + insertedWAIdSet);
        for (WhatsApp__c wa_i : [SELECT Id
                                  , Appointment__c 
                               FROM WhatsApp__c 
                              WHERE Id 
                                 IN :insertedWAIdSet]) {
            appointmentToUpdateList.add(new Appointment__c(
                Id = wa_i.Appointment__c,
                BarcodeIdentificationSent__c = true
            ));
        }
        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);
        AsyncUtil.doUpdate(appointmentToUpdateList);
    }   
               
    global void finish(Database.BatchableContext BC) {
        System.debug('WA_SendingBarcodeIdentifySchedule ... finish');
        Datetime now = System.now().addMinutes(60);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('WhatsApp Barcode Identify Patient #' + now.getTime(), CRONEXP, new WA_SendingBarcodeIdentifySchedule());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new WA_SendingBarcodeIdentifySchedule(), 25);
    }
 }