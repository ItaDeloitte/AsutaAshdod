//Test: CreateColonoscopySMSSchedulableBatchTest
public class CreateColonoscopySMSSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                      + ', SMS1Day__c'
                      + ', SMS2Days__c'
                      + ', SMS3Days__c'
                      + ', SMS4Days__c'                      
                      + ', SendDate1DayBefore__c'
                      + ', SendDate2DaysBefore__c'
                      + ', SendDate3DaysBefore__c'
                      + ', SendDate4DaysBefore__c'
                      + ', Patient_Account__r.Phone' 
                      + ', Medical_Procedure__r.Colonoscopy_Single_SMS__c'
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
    
    public CreateColonoscopySMSSchedulableBatch() {}

    public CreateColonoscopySMSSchedulableBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CreateColonoscopySMSSchedulableBatch.start ...');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('CreateColonoscopySMSSchedulableBatch.execute ...');
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        Map<Id, Appointment__c> appointmentToUpdateMap = new Map<Id, Appointment__c>();         

        for (Appointment__c appointment_i : scope) {
            if((appointment_i.Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c != null &&
                appointment_i.Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c != null) ||
                appointment_i.Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c != null) {
                if(appointment_i.Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c != null &&
                    appointment_i.SendDate3DaysBefore__c <= System.today() &&
                    appointment_i.SMS3Days__c == false ) {
                    smsToInsertList.add(getSMS('SMSKidsColonoscopyFirstSMS', appointment_i)); 
                }
                if(appointment_i.Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c!= null &&
                    appointment_i.SendDate2DaysBefore__c <= System.today() &&
                    appointment_i.SMS2Days__c == false ) {
                    smsToInsertList.add(getSMS('SMSKidsColonoscopySecondSMS', appointment_i)); 
                }
                if(appointment_i.Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c != null &&
                    appointment_i.Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c == null &&
                    appointment_i.SendDate2DaysBefore__c <= System.today() &&
                    appointment_i.SMS2Days__c == false ) {
                    smsToInsertList.add(getSMS('SMSParentGastroFirstSMS', appointment_i)); 
                }
            } else {
                if(appointment_i.SendDate1DayBefore__c <= System.today() && appointment_i.SMS1Day__c == false) {
                    smsToInsertList.add(getSMS('OneDaySMSContentColonoscopy', appointment_i));                                                    
                }
                if(appointment_i.SendDate2DaysBefore__c <= System.today() && appointment_i.SMS2Days__c == false) {
                    smsToInsertList.add(getSMS('TwoDaysSMSContentColonoscopy', appointment_i));                                             
                }
                if(appointment_i.SendDate3DaysBefore__c <= System.today() && appointment_i.SMS3Days__c == false) {
                    smsToInsertList.add(getSMS('ThreeDaysSMSContentColonoscopy', appointment_i));                                       
                }
                if(appointment_i.SendDate4DaysBefore__c <= System.today() && appointment_i.SMS4Days__c == false) {
                    if(appointment_i.Medical_Procedure__r.Colonoscopy_Single_SMS__c) {
                        smsToInsertList.add(getSMS('NonColonoscopySMSContent', appointment_i)); 
                    } else {
                        smsToInsertList.add(getSMS('IntroductionSMSContentColonoscopy', appointment_i));                                       
                    }
                }            
            }           
        }
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);

        Set<Id> insertedSMSIdSet = AsyncUtil.doInsert(smsToInsertList);

        for (SMS__c sms_i : [SELECT Id
                                  , Appointment__c 
                                  , smsTemplate__c
                               FROM SMS__c 
                              WHERE Id 
                                 IN :insertedSMSIdSet]) {
            Appointment__c appointment;
            if (!appointmentToUpdateMap.containsKey(sms_i.Appointment__c)) {
                appointment = new Appointment__c(Id = sms_i.Appointment__c);                
            }else {
                appointment = appointmentToUpdateMap.get(sms_i.Appointment__c);
            }
            switch on sms_i.smsTemplate__c {
                when 'OneDaySMSContentColonoscopy' {
                    appointment.SMS1Day__c = true;
                }
                when 'TwoDaysSMSContentColonoscopy' {
                    appointment.SMS2Days__c = true;
                }
                when 'ThreeDaysSMSContentColonoscopy' {
                    appointment.SMS3Days__c = true;
                }
                when 'IntroductionSMSContentColonoscopy' {
                    appointment.SMS4Days__c = true;
                }  
                when 'NonColonoscopySMSContent' {
                    appointment.SMS4Days__c = true;
                } 
                when 'SMSKidsColonoscopyFirstSMS' {
                    appointment.SMS3Days__c = true;
                }
                when 'SMSKidsColonoscopySecondSMS' {
                    appointment.SMS2Days__c = true;
                }
                when 'SMSParentGastroFirstSMS' {
                    appointment.SMS2Days__c = true;
                }

            }
            appointmentToUpdateMap.put(appointment.Id, appointment);                       
        }
        System.debug('appointmentToUpdateMap: size: ' + appointmentToUpdateMap.size() + ' value: ' + appointmentToUpdateMap);

        AsyncUtil.doUpdate(appointmentToUpdateMap.values());
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CreateColonoscopySMSSchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateColonoscopySMSSchedulableBatch(), 25);
    }
    
    private static SMS__c getSMS(String smsTemplate, Appointment__c appointment) {    
        SMS__c sms_i = SMSUtils.prepareSMS(smsTemplate, appointment.Patient_Account__r.Phone, appointment.Id, false);
        sms_i.Automation_name__c = 'CreateColonoscopySMSSchedulableBatch';
        return sms_i;
    }
}