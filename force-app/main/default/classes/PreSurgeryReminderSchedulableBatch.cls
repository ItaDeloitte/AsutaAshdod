global class PreSurgeryReminderSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean runNextJob = false;
    String query = 'SELECT Id'
                      + ', IDNumber__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Medical_Procedure__r.Confidentiality__c'
                      + ', Medical_Procedure2__r.Confidentiality__c'
                      + ', Medical_Procedure3__r.Confidentiality__c'
                      + ', Medical_Procedure4__r.Confidentiality__c'
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c = TOMORROW'
                + ' AND RecordType.DeveloperName = \'Surgeries\''
                + ' AND Medical_Procedure__c != null'
                + ' AND Appointment_Status__c =\'WaitingForAppointment\''
                + ' AND Patient_Account__c != null'
                + ' AND Medical_Procedure__r.Confidentiality__c!= true'
                + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)';


                
    global PreSurgeryReminderSchedulableBatch() {

    }

    global PreSurgeryReminderSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global PreSurgeryReminderSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<Appointment__c> appts = new List<Appointment__c>();
        List<SMS__c> smsList = new List<SMS__c>();
        Set<String> errors = new Set<String>();
        Set<Id> smsIds = new Set<Id>();

        for (Appointment__c appt_i : scope) {
            String smsPhoneNumber = appt_i.Case__c != null && appt_i.Case__r.SMS_Phone_Number__c != null
                ? appt_i.Case__r.SMS_Phone_Number__c
                : appt_i.Patient_Account__r.SMS_Phone_number__c;
            
            if(!isConfidential(appt_i)){
                smsList.add(
                    new SMS__c(
                        status__c = '1',
                        Type__c = 'Outgoing',
                        Appointment__c = appt_i.Id,
                        question_type__c = '',
                        Template_Text__c = 'Pre_Surgery_Reminder,\'\'',
                        Phone_Number__c = smsPhoneNumber
                    )
                );               
            }  
        }
        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);

        for (Database.SaveResult result_i : Database.insert(smsList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
         
        if (runNextJob) {
            Database.executeBatch(new PreSurgeryReminderSchedulableBatch(true), 25);
        }
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new PreSurgeryReminderSchedulableBatch(runNextJob), 25);
    }

    private Boolean isConfidential(Appointment__c appt){
        if(appt.Medical_Procedure2__r.Confidentiality__c || 
            appt.Medical_Procedure2__r.Confidentiality__c ||
            appt.Medical_Procedure2__r.Confidentiality__c){
            return true;
        }
        return false;
    }

}