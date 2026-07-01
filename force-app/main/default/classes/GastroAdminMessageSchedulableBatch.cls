// Test: GastroSMSReminderSchedulableBatchTest
public class GastroAdminMessageSchedulableBatch implements Database.Batchable<sObject>, Schedulable {    
    
    String query;
  
    public GastroAdminMessageSchedulableBatch() {}

    public GastroAdminMessageSchedulableBatch(String query) {
        this.query = query;    
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('GastroAdminMessageSchedulableBatch.start ...');        
        return Database.getQueryLocator([SELECT Id
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
                                        AND CreatedDate = YESTERDAY 
                                        AND Help_Parent_Code_in__c != '3']                                                                                                       
        );
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('GastroAdminMessageSchedulableBatch.execute ...');
        List<SMS__c> smsToInsertList = new List<SMS__c>();              

        for (Appointment__c appointment_i : scope) {
            SMS__c sms_i = SMSUtils.prepareSMS('Administrative_Message_Gastro', appointment_i.Patient_Account__r.Phone, appointment_i.Id, false);
            sms_i.Automation_name__c = 'GastroAdminMessageSchedulableBatch';
            smsToInsertList.add(sms_i);
        }
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);

        AsyncUtil.doInsert(smsToInsertList);        
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('GastroAdminMessageSchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new GastroAdminMessageSchedulableBatch(), 25);
    }
}