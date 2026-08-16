public class CommitmentReminderScheduleBatch  implements Database.Batchable<sObject>, Schedulable {
    
    String query = 'SELECT Id'
                      + ', Patient_Account__r.Phone'                     
                      + ', SendDate4DaysBefore__c'                      
                      + ', SMS4Days__c' 
                      + ',link_to_upload_hitchayvut__c'                                            
                + ' FROM Appointment__c'             
                + ' WHERE RecordType.DeveloperName = \'Surgeries\''
                + ' AND (Appointment_Status__c = \'ממתין להתחייבות\''
                + ' OR Appointment_Status__c = \'בטיפול אדמיניסטרטיבי\')'
                + ' AND Appointment_Date_Time__c >= TODAY'
                + ' AND hitchayvut_was_recieved__c = False'                                                          
                + ' AND SendDate4DaysBefore__c <= TODAY AND SMS4Days__c = FALSE'                                  
                + ' ORDER BY CreatedDate DESC';

    public CommitmentReminderScheduleBatch() {}

    public CommitmentReminderScheduleBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CommitmentReminderScheduleBatch.start ...');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('CommitmentReminderScheduleBatch.execute ...');
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        List<Appointment__c> appointmentToUpdate = new List<Appointment__c>();         

        for (Appointment__c appointment_i : scope) {
            SMS__c sms_i = SMSUtils.prepareSMS('Message_for_Commitment_Upload_DL_False', appointment_i.Patient_Account__r.Phone, appointment_i.Id, false);
            sms_i.Automation_name__c = 'CommitmentReminderScheduleBatch';
            smsToInsertList.add(sms_i);
        }
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);

        Set<Id> insertedSMSIdSet = AsyncUtil.doInsert(smsToInsertList);

        for (SMS__c sms_i : [SELECT Id
                                  , Appointment__c 
                                  , smsTemplate__c
                               FROM SMS__c 
                              WHERE Id 
                              IN :insertedSMSIdSet]) {
            appointmentToUpdate.add(new Appointment__c(Id = sms_i.Appointment__c, SMS4Days__c = true));                                  
        }
        System.debug('appointmentToUpdate: size: ' + appointmentToUpdate.size() + ' value: ' + appointmentToUpdate);

        AsyncUtil.doUpdate(appointmentToUpdate);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CommitmentReminderScheduleBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CommitmentReminderScheduleBatch(), 25);
    }  
}