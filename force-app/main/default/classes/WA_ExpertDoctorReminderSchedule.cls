//WA_ExpertDoctorReminderScheduleTest
global class WA_ExpertDoctorReminderSchedule implements Database.Batchable<sObject>, Schedulable {
    
    String query = 'SELECT Id '
                    + ', Site__c' 
                    + ', Calendar__c'
                    + ', Doctor_Account__c' 
                    + ', Medical_Procedure__c'                                         
                    + ', Appointment_Date_Time__c'                                     
                    + ', Doctor_Account__r.Phone_ETL__c'   
                    + ', Doctor_Account__r.PhoneToSendVoucher__c'                    
                + ' FROM Appointment__c'
                + ' WHERE Doctor_Account__c != null'
                + ' AND Doctor_Account__r.Experts_center__c = true'
                + ' AND Appointment_Date_Time__c >= TODAY'            
                + ' AND RecordType.DeveloperName = \'Experts\''                                                                  
                + ' AND IsExpertsDoctorReminderSent__c = false'              
                + ' AND ExpertsDoctorReminderDate__c = TODAY'
                + ' AND Appointment_Status__c NOT IN (\'Canceled\', \'2\', \'5\', \'CanceledFailed\', \'not_arrived\', \'4\', \'3\')';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('WA_ExpertDoctorReminderSchedule ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('WA_ExpertDoctorReminderSchedule ... execute');
        System.debug('scope: [' + scope.size() + '] value: ' + scope); 
        if (scope.isEmpty()) return; 
        
        Boolean isPreventMessage;
        Map<Id, String> doctorToPhone = new  Map<Id, String>();
        Map<Id, List<Appointment__c>> doctorIdToAppointments = new Map<Id, List<Appointment__c>>();               
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);
        
        for (Appointment__c appt : scope) {
            //check if messaging is prevented if so, skip and do NOT send WhatsApp 
            isPreventMessage = preventMap.get(appt.Id);
            System.debug('isPreventMessage: ' + isPreventMessage);
            if (isPreventMessage) {
                System.debug('Messaging prevented for appointment ' + appt.Id);
                continue; 
            }
            
            if (!doctorIdToAppointments.containsKey(appt.Doctor_Account__c)) {
                doctorIdToAppointments.put(appt.Doctor_Account__c, new List<Appointment__c>());
                doctorToPhone.put(appt.Doctor_Account__c, WhatAppUtils.getValidPhone(String.isNotBlank(appt.Doctor_Account__r.PhoneToSendVoucher__c) ? 
                                                            appt.Doctor_Account__r.PhoneToSendVoucher__c : appt.Doctor_Account__r.Phone_ETL__c));
            }
            doctorIdToAppointments.get(appt.Doctor_Account__c).add(appt);
            
        }
        System.debug('doctorToPhone: size: ' + doctorToPhone.size() + ' value: ' + doctorToPhone);
        if (doctorToPhone.isEmpty()) return;

        List<MessagingChannel> mesChannels = WhatAppUtils.getMessagingChannel('WHATSAPP_US_661176770420244');
        if (mesChannels.isEmpty()) return;

        String channelName = mesChannels.get(0).MasterLabel;
        String  channelId = mesChannels.get(0).Id; 

        //Get EndUsers
        Map<String, Id> phoneToEndUser = WhatAppUtils.getMessagingEndUser(doctorToPhone, channelId);
        System.debug('phoneToEndUser: size: ' + phoneToEndUser.size() + ' value: ' + phoneToEndUser);

        List<WhatsApp__c> waToInsertList = new List<WhatsApp__c>();
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();
        for (Id doctorId : doctorIdToAppointments.keySet()) {  
            String phone = doctorToPhone.get(doctorId);
            Id endUserId = phoneToEndUser.get(phone);          
           
            waToInsertList.add(
                WhatAppUtils.prepareWhatApp( 
                    doctorId
                    , 'reminder_for_doctors_experts'
                    , 'WA_ExpertDoctorReminderSchedule'                                                                                                                     
                    , endUserId
                    , System.now()
                    , channelName
                    , phone
                )
            );                               
                
            // DML appointment
            for (Appointment__c appt : doctorIdToAppointments.get(doctorId)) {
                appointmentToUpdateList.add(new Appointment__c(
                    Id = appt.Id,
                    IsExpertsDoctorReminderSent__c = true
                ));
            }
        }        
        AsyncUtil.doInsert(waToInsertList);
        AsyncUtil.doUpdate(appointmentToUpdateList);

        System.debug('Inserted WhatsApps: ' + waToInsertList.size());
        System.debug('Updated Appointments: ' + appointmentToUpdateList.size());
    } 
    
    global void finish(Database.BatchableContext BC) {
        System.debug('WA_ExpertDoctorReminderSchedule ... finish');
    }

    global void execute(SchedulableContext SC) {
        Integer runHour =  WhatAppUtils.checkBusinessDay(Date.today());    
        Boolean isRun = (runHour != null && Datetime.now().hour() == runHour) || Test.isRunningTest();  
        if (isRun) { 
            Database.executeBatch(new WA_ExpertDoctorReminderSchedule(), 100);
        }
    }   
}