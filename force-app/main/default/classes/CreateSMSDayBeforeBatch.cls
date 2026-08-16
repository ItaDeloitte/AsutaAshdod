// Test: CreateSMSDayBeforeBatchTest
global class CreateSMSDayBeforeBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', Remainder_type__c'
                      + ', AppointmentTime__c'
                      + ', Appointment_Date_Time__c'
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
                      + ', Site__r.Site_Code__c'
                      + ', Clinic__r.Name'                       
                      + ', Calendar__c'                      
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.ID_Number__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Medical_Procedure__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'
                      + ', Medical_Procedure__r.Domain__c'
                      + ', Medical_Procedure__r.Domain__r.DomainCode__c'
                      + ', Medical_Procedure__r.Telemedicine_Action__c'
                      + ', Domain__c'
                      + ', Domain__r.DomainCode__c'
                  + ' FROM Appointment__c'
                 + ' WHERE Appointment_Date_Time__c = NEXT_N_DAYS:3'
                   + ' AND Appointment_Status__c = \'וידוא הגעה לפגישה\''
                   + ' AND (Remainder_status__c = \'אין מענה\' OR Remainder_status__c = null)'
                   + ' AND sms_reminder_sent__c = true'
                   + ' AND Date_for_tizkorit_reminder__c = null'
                   + ' AND Date_for_human_reminder__c = null'
                   + ' AND Medical_Procedure__r.Telemedicine_Action__c = false'
        		   + ' AND sendingByWhatsApp__c = false'
                   // next conditions are covered by sms_reminder_sent__c = true
                   /*
                       + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)'
                       + ' AND (Site__c != null OR Clinic__c != null)'
                       + ' AND Patient_Account__c != null'
                       + ' AND Medical_Procedure__c != null'
                       + ' AND Medical_Procedure__r.Confidentiality__c = false'
                       + ' AND Medical_Procedure__r.Reminder_required__c = true'
                       + ' AND Dont_send_reminder__c = false'
                   */
              + ' ORDER BY Appointment_Date_Time__c';

    global CreateSMSDayBeforeBatch() {}

    global CreateSMSDayBeforeBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore(' WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<SMS__c> newSMSList = new List<SMS__c>();
        Set<Database.Error> errors = new Set<Database.Error>();
        Set<String> smsIds = new Set<String>();
        
        Map<Date, Integer> businessDaysMap = SMSUtils.getBusinessDaysMap(Date.today().addDays(5));
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);

        for (Appointment__c appt_i : scope) {            
             //check if messaging is prevented if so, skip and do NOT send message 
            if (preventMap.get(appt_i.Id)) {
                System.debug('Messaging prevented for appointment ' + appt_i.Id);
                continue; 
            }
            Date date_i = appt_i.Appointment_Date_Time__c.date();

            if (businessDaysMap.containsKey(date_i) && businessDaysMap.get(date_i) == 1) {
                newSMSList.add(SMSUtils.prepareSMS(appt_i, getSMSReminderTemplate(appt_i), true));
            }
        }
        System.debug('newSMSList: size: ' + newSMSList.size() + ' value: ' + newSMSList);

        for (Database.SaveResult result_i : Database.insert(newSMSList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.addAll(result_i.getErrors());
            }
        }
        System.debug('smsIds: size: ' + smsIds.size() + ' value: ' + smsIds);
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        // skip if this job run in J_Holiday
        if (SMSUtils.checkBusinessDay(Date.today())) {            
           Database.executeBatch(new CreateSMSDayBeforeBatch(), 25);
        }        
    }

    private static String getSMSReminderTemplate(Appointment__c app) {
        return app.Site__r.Site_Code__c == '33' ? 'Reminder_for_SMS_reminder_Ashdod': 
               app.RecordType.DeveloperName == 'Experts' ? 'Reminder_for_SMS_reminder_Experts' : 
                                                           'Reminder_for_SMS_reminder_Institutes';
    }
}