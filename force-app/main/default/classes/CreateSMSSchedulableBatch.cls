// Test: CreateSMSSchedulableBatchTest
global class CreateSMSSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean runNextJob = false;
    String query = 'SELECT Id'
                      + ', IDNumber__c'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', Remainder_type__c'
                      + ', AppointmentTime__c'
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
         			  + ', Site__r.Site_Code__c'
                      + ', Clinic__r.Name'                       
                      + ', Calendar__c'
                      + ', Medical_Procedure__c'
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'                                         
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c >= TODAY'  
                + ' AND Site__r.Site_Code__c != \'33\''        
                + ' AND Appointment_Status__c = \'וידוא הגעה לפגישה\''
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
                + ' AND sendingByWhatsApp__c = false'
                + ' ORDER BY Remainder_time__c, Date_for_tizkorit_reminder__c, Date_for_human_reminder__c';

    global CreateSMSSchedulableBatch() {}

    global CreateSMSSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global CreateSMSSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {        
        Set<Id> smsIds = new Set<Id>();
        Set<String> errors = new Set<String>();
        Set<Id> procedureIdSet = new Set<Id>();
        List<SMS__c> smsList = new List<SMS__c>();
        List<Appointment__c> appts = new List<Appointment__c>();
        Map<Id, List<SMSReminder__c>> procedureIdToRemindersMap = new Map<Id, List<SMSReminder__c>>();
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);

        for (Appointment__c appt_i : scope) {
            procedureIdSet.add(appt_i.Medical_Procedure__c);
        }    
        System.debug('procedureIdSet: size: ' + procedureIdSet.size() + ' value: ' + procedureIdSet);

        if(!procedureIdSet.isEmpty()) {
            for (SMSReminder__c sms_i : [SELECT Site__c
                                                    , SiteType__c 
                                                    , SMSVersion__c
                                                    , RecordType__c
                                                    , SmsTemplate__c                                                    
                                                    , MedicalProcedure__c 
                                                    , SmsTemplate__r.DeveloperName__c              
                                              FROM SMSReminder__c
                                              WHERE MedicalProcedure__c IN :procedureIdSet]) {
                if (!procedureIdToRemindersMap.containskey(sms_i.MedicalProcedure__c)) {
                    procedureIdToRemindersMap.put(sms_i.MedicalProcedure__c, new List<SMSReminder__c>());
                }
                procedureIdToRemindersMap.get(sms_i.MedicalProcedure__c).add(sms_i);
            }
            System.debug('procedureIdToRemindersMap: size: ' + procedureIdToRemindersMap.size() + ' values: ' + procedureIdToRemindersMap);
        }
        

        for (Appointment__c appt_i : scope) {
            //check if messaging is prevented if so, skip and do NOT send message 
            if (preventMap.get(appt_i.Id)) {
                System.debug('Messaging prevented for appointment ' + appt_i.Id);
                continue; 
            }
            String smsTemplate = null;
            if (procedureIdToRemindersMap.containsKey(appt_i.Medical_Procedure__c)) {
                for (SMSReminder__c sms_i : procedureIdToRemindersMap.get(appt_i.Medical_Procedure__c)) {
                    if (sms_i.RecordType__c.split(';').contains(appt_i.RecordType.DeveloperName)
                            && (sms_i.SiteType__c == 'ALL'
                                || (sms_i.SiteType__c == 'Private'
                                    && sms_i.Site__c.split(';').contains(appt_i.Site__r.Site_Code__c))
                                || (sms_i.SiteType__c == 'Public'
                                    && sms_i.Site__c == appt_i.Site__r.Site_Code__c))
                            && (sms_i.SMSVersion__c == null
                                || (sms_i.SMSVersion__c != null  
                                    && sms_i.SMSVersion__c.split(';').contains(appt_i.IDNumber__c.substring(appt_i.IDNumber__c.length()-1, appt_i.IDNumber__c.length()))))
                    ) {
                        System.debug('inside Excluded SMS');
                        smsTemplate = sms_i.SmsTemplate__r.DeveloperName__c;
                        break;
                    }
                }
            }
            smsList.add(SMSUtils.prepareSMS(appt_i, smsTemplate != null ? smsTemplate : getGeneralTemplate(appt_i), true));    
        }
        
        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);

        for (Database.SaveResult result_i : Database.insert(smsList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }

        for (SMS__c sms_i : [SELECT Id, Appointment__c FROM SMS__c WHERE Id IN: smsIds]) {
            appts.add(
                new Appointment__c(
                    Id = sms_i.Appointment__c,
                    SMS_Reminder_Process__c = true,
                    sms_reminder_sent__c = true,
                    Remainder_type__c = 'SMS'
                )
            );
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Database.SaveResult result_i : Database.update(appts, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
        // run a batch with next reminders
        if (runNextJob) {
            Database.executeBatch(new CreateRemindersSchedulableBatch(true), 25);
        }
    }

    global void execute(SchedulableContext SC) {
        // skip if this job run in J_Holiday
       if (SMSUtils.checkBusinessDay(Date.today())) {            
           Database.executeBatch(new CreateSMSSchedulableBatch(), 25);
        }   
    }

    private static String getGeneralTemplate(Appointment__c app) {
        return app.RecordType.DeveloperName == 'Experts' ? 'General_Reminder_Experts' : 
                                                           'General_Reminder_Institutes';
    }
}