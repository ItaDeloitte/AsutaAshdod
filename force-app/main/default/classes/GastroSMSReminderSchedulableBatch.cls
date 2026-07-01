// Test: GastroSMSReminderSchedulableBatchTest
public class GastroSMSReminderSchedulableBatch implements Database.Batchable<sObject>, Schedulable {    
    
    String query;
    Date fiveDays = Date.today().addDays(5);
    Date sixDays = Date.today().addDays(6);
    Date sevenDays = Date.today().addDays(7);
   
    public GastroSMSReminderSchedulableBatch() {}

    public GastroSMSReminderSchedulableBatch(String query) {
        this.query = query;    
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('GastroSMSReminderSchedulableBatch.start ...');        
        return Database.getQueryLocator([SELECT Id
                                            , Site__c
                                            , Calendar__c
                                            , CreatedDate
                                            , Help_Parent_Code_in__c
                                            , Date_of_appointment__c
                                            , Patient_Account__r.Phone                                                                                         
                                            , Medical_Procedure__c
                                            , Medical_Procedure__r.Operation_of_Colonoscopy_Assuta_Doc__c                                                                                                                                              
                                        FROM Appointment__c             
                                       WHERE Patient_Account__r.Phone != null
                                        AND Site__r.Site_Code__c != '33'  
                                        AND Calendar__r.status__c ='פעיל'
                                        AND Calendar__r.CalendarForGastro__c = true
                                        AND RecordType.DeveloperName = 'Institutes'                   
                                        AND Appointment_Status__c NOT IN ('2', 'Canceled', 'CanceledFailed', '3')
                                        AND (Date_of_appointment__c =  :sevenDays 
                                        OR  ((Date_of_appointment__c =  :fiveDays OR Date_of_appointment__c =  :sixDays) AND Remainder_status__c != 'השיב להודעה בחיוב'))]                                                                                                       
        );
    }
    

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('GastroSMSReminderSchedulableBatch.execute ...');
        Set<Id> appointmentIds = new Set<Id>();
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        List<Appointment__c> appointmentToUpdate = new List<Appointment__c>();         
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);

        for (Appointment__c appointment_i : scope) {            
             //check if messaging is prevented if so, skip and do NOT send message 
            if (preventMap.get(appointment_i.Id)) {
                System.debug('Messaging prevented for appointment ' + appointment_i.Id);
                continue; 
            }

            if (appointment_i.Date_of_appointment__c == this.sevenDays) {
                smsToInsertList.add(getSMS('First_Gastro_Reminder', appointment_i));                                       
            }
            else if (appointment_i.Date_of_appointment__c == this.fiveDays || appointment_i.Date_of_appointment__c == this.sixDays) {
                smsToInsertList.add(getSMS('Second_Gastro_Reminder', appointment_i));                                             
            }           
        }
        
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);
        if(!smsToInsertList.isEmpty()) {
            Set<Id> insertedSMSIdSet = AsyncUtil.doInsert(smsToInsertList);

            for (SMS__c sms_i : [SELECT Id
                                        , Appointment__c 
                                        , smsTemplate__c
                                    FROM SMS__c 
                                    WHERE Id IN :insertedSMSIdSet]) {
                appointmentIds.add(sms_i.Appointment__c);                                                   
            }
            
            for(Appointment__c app_i : [SELECT Id
                                        , sms_reminder_sent__c 
                                        , Remainder_status__c
                                    FROM Appointment__c 
                                    WHERE Id IN :appointmentIds]) {
                if(!app_i.sms_reminder_sent__c) {
                    appointmentToUpdate.add(new Appointment__c(Id = app_i.Id, sms_reminder_sent__c = true, Remainder_status__c = 'אין מענה'));
                }
            }
            
            System.debug('appointmentToUpdate: size: ' + appointmentToUpdate.size() + ' value: ' + appointmentToUpdate);

            AsyncUtil.doUpdate(appointmentToUpdate);
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('GastroSMSReminderSchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new GastroSMSReminderSchedulableBatch(), 25);
    }
    
    private static SMS__c getSMS(String smsTemplate, Appointment__c appointment) {    
        SMS__c sms_i = SMSUtils.prepareSMS(smsTemplate, appointment.Patient_Account__r.Phone, appointment.Id, false);
        sms_i.Automation_name__c = 'GastroSMSReminderSchedulableBatch';
        return sms_i;
    }
}