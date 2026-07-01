// Test: GastroSMSReminderSchedulableBatchTest
public class GastroColonoscopySchedulableBatch implements Database.Batchable<sObject>, Schedulable {    
    String query;
    Date twoDays = Date.today().addDays(2);
    Date fourDays = Date.today().addDays(4);    
   
    public GastroColonoscopySchedulableBatch() {}

    public GastroColonoscopySchedulableBatch(String query) {
        this.query = query;    
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('GastroColonoscopySchedulableBatch.start ...');        
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
                                        AND ((Date_of_appointment__c =  :fourDays AND Medical_Procedure__r.Operation_of_Colonoscopy_Assuta_Doc__c = true) 
                                         OR (Date_of_appointment__c  =  :twoDays AND Medical_Procedure__r.Operation_of_Colonoscopy_Assuta_Doc__c = false))]                                                                                                       
        );
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('GastroColonoscopySchedulableBatch.execute ...');
        List<SMS__c> smsToInsertList = new List<SMS__c>();              
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);

        for (Appointment__c appointment_i : scope) {
            //check if messaging is prevented if so, skip and do NOT send message 
            if (preventMap.get(appointment_i.Id)) {
                System.debug('Messaging prevented for appointment ' + appointment_i.Id);
                continue; 
            }
            
            SMS__c sms_i = SMSUtils.prepareSMS('Gastro_Reminder', appointment_i.Patient_Account__r.Phone, appointment_i.Id, false);
            sms_i.Automation_name__c = 'GastroColonoscopySchedulableBatch';
            smsToInsertList.add(sms_i);
        }

        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);
        if (!smsToInsertList.isEmpty()) {
           AsyncUtil.doInsert(smsToInsertList);        
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('GastroColonoscopySchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new GastroColonoscopySchedulableBatch(), 25);
    }
}