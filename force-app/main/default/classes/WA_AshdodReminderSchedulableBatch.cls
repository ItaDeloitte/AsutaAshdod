// Test: WA_AshdodReminderSchedulableBatchTest
global class WA_AshdodReminderSchedulableBatch implements Database.Batchable<sObject>, Schedulable {
    
    String query = 'SELECT Id'
                      + ', IDNumber__c'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', Remainder_type__c'
                      + ', AppointmentTime__c'
                      + ', day_date_hour__c'                       
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', Days_Until_Appointment__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
         			  + ', Site__r.Site_Code__c'
                      + ', Clinic__r.Name'
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Patient_Account__r.Number_not_Kosher__c'                      
                      + ', Patient_Account__r.AshdodPreferredChannel__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'                                         
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c >= TODAY'            
                + ' AND Site__r.Site_Code__c = \'33\''
                + ' AND (Appointment_Status__c = \'וידוא הגעה לפגישה\''
                + ' OR Appointment_Status__c = \'WaitingForAppointment\')'
                + ' AND Remainder_status__c != \'השיב להודעה בשלילה\''
                + ' AND Remainder_status__c != \'השיב להודעה בחיוב\''
                + ' AND Medical_Procedure__c != null'
                + ' AND Patient_Account__c != null'
                + ' AND Medical_Procedure__r.Reminder_required__c = true'
                + ' AND Medical_Procedure__r.Confidentiality__c = false'
                + ' AND Dont_send_reminder__c = false'
                + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)'
                + ' AND (Site__c != null OR Clinic__c != null)'
                + ' AND Remainder_time__c = LAST_N_DAYS:4'
                + ' AND sms_reminder_sent__c = false'  
                + ' AND (PatientType__c = \'2\' OR PatientType__c = \'3\' OR PatientType__c = \'\')'             
                + ' ORDER BY Remainder_time__c, Date_for_tizkorit_reminder__c, Date_for_human_reminder__c';

    global WA_AshdodReminderSchedulableBatch() {}    

    global WA_AshdodReminderSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {        
        //Collect procedures & phone numbers
        Set<Id> procedureIds = new Set<Id>();
        Map<Id, String> appIdToPhone = new Map<Id, String>();

        for (Appointment__c app : scope) {
            procedureIds.add(app.Medical_Procedure__c);            
            if (app.Patient_Account__r.SMS_Phone_number__c != null) {
                appIdToPhone.put(app.Id, WhatAppUtils.getValidPhone(app.Patient_Account__r.SMS_Phone_number__c));
            }   
        }
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);
        System.debug('appIdToPhone: size: ' + appIdToPhone.size() + ' value: ' + appIdToPhone);

        //Get EndUsers 
        Map<String, Id> phoneToEndUser = new Map<String, Id>();
        if (!appIdToPhone.isEmpty()) {
            phoneToEndUser = WhatAppUtils.getMessagingEndUser(
                appIdToPhone,
                WhatAppUtils.getMessagingChannel('Assuta_Ashdod_Enhanced_Bot').get(0).Id
            );
        }
        System.debug('phoneToEndUser: size: ' + phoneToEndUser.size() + ' value: ' + phoneToEndUser);


        //Load reminders by procedure
        Map<Id, List<SMSReminder__c>> procIdToReminders = new Map<Id, List<SMSReminder__c>>();
        if (!procedureIds.isEmpty()) {
            for (SMSReminder__c sms : [
                SELECT Site__c, SiteType__c, SMSVersion__c, RecordType__c, SmsTemplate__c,
                       MedicalProcedure__c, SmsTemplate__r.DeveloperName__c
                FROM SMSReminder__c
                WHERE MedicalProcedure__c IN :procedureIds
                AND Site__c includes('33')
            ]) {
                if (!procIdToReminders.containskey(sms.MedicalProcedure__c)) {
                    procIdToReminders.put(sms.MedicalProcedure__c, new List<SMSReminder__c>());
                }
                procIdToReminders.get(sms.MedicalProcedure__c).add(sms);
            }   
        }
        System.debug('procIdToReminders: size: ' + procIdToReminders.size() + ' values: ' + procIdToReminders);


        // Build WhatsApp messages ---
        List<WA_AshdodWrapper> wrappers = new List<WA_AshdodWrapper>();
        List<Appointment__c> appointmentToUpdate = new List<Appointment__c>();

        for (Appointment__c app : scope) {
            String smsTemplate = getTemplate(app, procIdToReminders.get(app.Medical_Procedure__c)); 
            String reminderType = app.Patient_Account__r.Number_not_Kosher__c && (app.Patient_Account__r.AshdodPreferredChannel__c == 'WA' || app.Patient_Account__r.AshdodPreferredChannel__c == null) ? 'WA' : 'SMS';        
            String phone = appIdToPhone.get(app.Id);
            String endUserId = phoneToEndUser.containsKey(appIdToPhone.get(app.Id)) ? 
                               phoneToEndUser.get(phone) : null;
            if (endUserId == null) {
                continue; 
            }            
            wrappers.add(new WA_AshdodWrapper(
                app,
                smsTemplate != null ? smsTemplate : 'General_Reminder_Ashdod',
                'WA_AshdodReminderSchedulableBatch',
                endUserId,
                reminderType
            ));

            appointmentToUpdate.add(new Appointment__c(
                                        Id = app.Id,
                                        SMS_Reminder_Process__c = true,
                                        sms_reminder_sent__c = true,
                                        Remainder_type__c = reminderType == 'WA' ? 'WhatsApp' : 'SMS'
            ));
        }       

        //Call Flow
        Map<String, Object> params = new Map<String, Object>{
            'MessageTime' => 'Apex',
            'Appointments_Data' => wrappers
        };
        Flow.Interview.Outbound_Whatsapp_Ashdod_Centers flow = 
            new Flow.Interview.Outbound_Whatsapp_Ashdod_Centers(params);
        flow.start();

        System.debug('appointmentToUpdate: size: ' + appointmentToUpdate.size() + ' value: ' + appointmentToUpdate);
        if (!appointmentToUpdate.isEmpty()) {
            AsyncUtil.doUpdate(appointmentToUpdate);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
    }

    // ==========================
    // === Schedulable Method ===
    // ==========================
    global void execute(SchedulableContext sc) {
          // skip if this job run in J_Holiday
        if (SMSUtils.checkBusinessDay(Date.today())) {
            Database.executeBatch(new WA_AshdodReminderSchedulableBatch(), 25);
        }
    }

    private static String getTemplate(Appointment__c app, List<SMSReminder__c> reminders) {
        if (reminders == null) return null;

        for (SMSReminder__c sms : reminders) {
            Set<String> recordTypes = new Set<String>(sms.RecordType__c.split(';'));
            Set<String> smsVersions = sms.SMSVersion__c != null ? new Set<String>(sms.SMSVersion__c.split(';')) : new Set<String>();

            Boolean recordMatch = recordTypes.contains(app.RecordType.DeveloperName);
            Boolean siteMatch = (
                sms.SiteType__c == 'ALL' ||
                (sms.SiteType__c == 'Private' && sms.Site__c.split(';').contains(app.Site__r.Site_Code__c)) ||
                (sms.SiteType__c == 'Public'  && sms.Site__c == app.Site__r.Site_Code__c)
            );
            Boolean versionMatch = (sms.SMSVersion__c == null ||
                smsVersions.contains(app.IDNumber__c.right(1)));

            if (recordMatch && siteMatch && versionMatch) {
                return sms.SmsTemplate__r.DeveloperName__c;
            }
        }
        return null;
    }
}