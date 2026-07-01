//Test: WA_AshdodColonoscopySchedulableBatchTest
public class WA_AshdodColonoscopySchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                      + ', SMS1Day__c'
                      + ', SMS2Days__c'
                      + ', SMS3Days__c'
                      + ', SMS4Days__c'                      
                      + ', Site__r.Name' 
                      + ', day_date_hour__c'                       
                      + ', Medical_Procedure__r.Name'
                      + ', formtitan_arrival_link__c'                                                                                   
                      + ', SendDate1DayBefore__c' 
                      + ', SendDate2DaysBefore__c'
                      + ', SendDate3DaysBefore__c'
                      + ', SendDate4DaysBefore__c'                                      
                      + ', Days_Until_Appointment__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_Number__c' 
                      + ', Patient_Account__r.Number_not_Kosher__c'
                      + ', Patient_Account__r.AshdodPreferredChannel__c  '                                                                                                          
                      + ', Medical_Procedure__r.Colonoscopy_Single_SMS__c'
                      + ', Medical_Procedure__r.Colonoscopy1DayBeforeLink__c'
                      + ', Medical_Procedure__r.Colonoscopy2DaysBeforeLink__c'
                      + ', Medical_Procedure__r.Colonoscopy3DaysBeforeLink__c'
                      + ', Medical_Procedure__r.Colonoscopy4DaysBeforeLink__c' 
                      + ', Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c'
                      + ', Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c'
                      + ', Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c'
                      + ', Medical_Procedure__r.ColonoscopyParent3DaysBeforeLink__c'                                                         
                + ' FROM Appointment__c'             
                + ' WHERE RecordType.DeveloperName = \'Institutes\''
                + ' AND Appointment_Status__c != \'Canceled\''
                + ' AND Appointment_Date_Time__c >= TODAY'
                + ' AND Medical_Procedure__c != null' 
                + ' AND Site__r.Site_Code__c = \'33\''                              
                + ' AND ((SendDate1DayBefore__c <= TODAY AND SMS1Day__c = FALSE) OR'
                +        '(SendDate2DaysBefore__c <= TODAY AND SMS2Days__c = FALSE) OR' 
                +        '(SendDate3DaysBefore__c <= TODAY AND SMS3Days__c = FALSE) OR'
                +        '(SendDate4DaysBefore__c <= TODAY AND SMS4Days__c = FALSE))'                                   
                + ' ORDER BY CreatedDate DESC';
    
    public WA_AshdodColonoscopySchedulableBatch() {}

    public WA_AshdodColonoscopySchedulableBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('WA_AshdodColonoscopySchedulableBatch.execute ...');               
        Map<Id, String> appIdToPhone = new Map<Id, String> ();
        
         for (Appointment__c app : scope) {  
            if (app.Patient_Account__r.SMS_Phone_number__c != null) {
                appIdToPhone.put(app.Id, WhatAppUtils.getValidPhone(app.Patient_Account__r.SMS_Phone_number__c));
            }          
        }       
        System.debug('appIdToPhone: size: ' + appIdToPhone.size() + ' value: ' + appIdToPhone);

        //Get EndUsers         
        Map<String, Id> phoneToEndUser = !appIdToPhone.isEmpty()? 
                                        WhatAppUtils.getMessagingEndUser(appIdToPhone, WhatAppUtils.getMessagingChannel('Assuta_Ashdod_Enhanced_Bot').get(0).Id)
                                        : new Map<String, Id>();
        System.debug('phoneToEndUser: size: ' + phoneToEndUser.size() + ' value: ' + phoneToEndUser);

        // Build WhatsApp messages ---
        List<WA_AshdodWrapper> wrappers = new List<WA_AshdodWrapper>(); 
        List<Appointment__c> appointmentToUpdate = new List<Appointment__c>();              

        for (Appointment__c app : scope) {
            String phone = appIdToPhone.get(app.Id);
            String reminderType = getReminderType(app);
            String endUserId = phoneToEndUser.containsKey(appIdToPhone.get(app.Id)) ? 
                               phoneToEndUser.get(phone) : null;
            if (endUserId == null) {
                continue; 
            }
            wrappers.addAll(getWrappersForAppointment(app, endUserId, reminderType));
            
            Appointment__c appUpdate = new Appointment__c(Id = app.Id);
                if (app.SMS1Day__c) appUpdate.SMS1Day__c = true;
                if (app.SMS2Days__c) appUpdate.SMS2Days__c = true;
                if (app.SMS3Days__c) appUpdate.SMS3Days__c = true;
                if (app.SMS4Days__c) appUpdate.SMS4Days__c = true;
            appointmentToUpdate.add(appUpdate);
        }

        System.debug('wrappers: size: ' + wrappers.size() + ' value: ' + wrappers);
        if (!wrappers.isEmpty()) {
            //Call Flow
            Map<String, Object> params = new Map<String, Object>{
                'MessageTime' => 'Apex',
                'Appointments_Data' => wrappers
            };
            Flow.Interview.Outbound_Whatsapp_Ashdod_Centers flow = 
                new Flow.Interview.Outbound_Whatsapp_Ashdod_Centers(params);
            flow.start();  
        }         

        System.debug('appointmentToUpdate: size: ' + appointmentToUpdate.size() + ' value: ' + appointmentToUpdate);
        AsyncUtil.doUpdate(appointmentToUpdate);
    }           

    private static String getReminderType(Appointment__c app) {
        Boolean kosher = app.Patient_Account__r.Number_not_Kosher__c;
        String preferred = app.Patient_Account__r.AshdodPreferredChannel__c;
        return (kosher && (preferred == 'WA' || preferred == null)) ? 'WA' : 'SMS';
    }

    private static List<WA_AshdodWrapper> getWrappersForAppointment(Appointment__c app, String endUserId, String type) {
        List<WA_AshdodWrapper> result = new List<WA_AshdodWrapper>();

        Boolean hasKid = app.Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c != null ||
                         app.Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c != null;
        Boolean hasParent = app.Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c != null;

        if (hasKid || hasParent) {            
            if (app.SendDate3DaysBefore__c <= System.today() && !app.SMS3Days__c && app.Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c != null) {               
                app.SMS3Days__c = true;
                result.add(new WA_AshdodWrapper(app, 'SMSKidsColonoscopyFirstSMS', 'WA_AshdodColonoscopySchedulableBatch', endUserId, type));
            }
            if (app.SendDate2DaysBefore__c <= System.today() && !app.SMS2Days__c && app.Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c != null) {                
                app.SMS2Days__c = true;
                result.add(new WA_AshdodWrapper(app, 'SMSKidsColonoscopySecondSMS', 'WA_AshdodColonoscopySchedulableBatch', endUserId, type));
            }
            if (app.SendDate2DaysBefore__c <= System.today() && !app.SMS2Days__c && app.Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c != null) {               
                app.SMS2Days__c = true;
                result.add(new WA_AshdodWrapper(app, 'SMSParentGastroFirstSMS', 'WA_AshdodColonoscopySchedulableBatch', endUserId, type));
            }
        } else {            
            Map<Integer, String> templateByDay = getTemplateByDay(app.Medical_Procedure__r.Colonoscopy_Single_SMS__c);

            for (Integer day : templateByDay.keySet()) {                
                Date sendDate = (Date)app.get('SendDate' + day + (day == 1 ? 'DayBefore__c' : 'DaysBefore__c'));
                Boolean sent = (Boolean)app.get('SMS' + (day == 1 ? '1Day__c' : day + 'Days__c'));
                if (sendDate <= System.today() && !sent) {                   
                    app.put('SMS' + (day == 1 ? '1Day__c' : day + 'Days__c'), true);          
                    result.add(new WA_AshdodWrapper(app, templateByDay.get(day), 'WA_AshdodColonoscopySchedulableBatch', endUserId, type));
                }
            }
        }
        return result;
    }

    public static Map<Integer, String> getTemplateByDay(Boolean isSingleSMS) {
        return new Map<Integer, String>{
            1 => 'OneDaySMSContentColonoscopy',
            2 => 'TwoDaysSMSContentColonoscopy',
            3 => 'ThreeDaysSMSContentColonoscopy',
            4 => isSingleSMS
                ? 'NonColonoscopySMSContent'
                : 'IntroductionSMSContentColonoscopy'
        };       
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('WA_AshdodColonoscopySchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new WA_AshdodColonoscopySchedulableBatch(), 25);
    }
}