global class HomeAdmissionSMSSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean runNextJob = false;
    DateTime todayPlus1Days = date.today().adddays(+1);
    DateTime todayPlus2Days = date.today().adddays(+2);
    DateTime todayPlus3Days = date.today().adddays(+3);
    DateTime todayPlus4Days = date.today().adddays(+4);
    String todayPlus3Str = todayPlus3Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String todayPlus4Str = todayPlus4Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String query = 'SELECT Id'
                      + ', IDNumber__c'
                      + ', Appointment_Status__c'
                      + ', Spincal__c'
                      + ', Didkitsent__c'
                      + ', Process_Status_From_Site__c'
                      + ', Edited__c'
                      + ', TAF_Future_Case__c' 
                      + ', Appointment_Date_Time__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_number__c'
        			  + ', Process_Finished__c'
                + ' FROM Appointment__c'
                + ' WHERE Appointment_Date_Time__c >= TODAY'
                + ' AND ((Appointment_Date_Time__c >='+todayPlus3Str
                + ' AND Appointment_Date_Time__c <='+todayPlus4Str
                + ' ) OR Appointment_Date_Time__c = TOMORROW)'
                + ' AND Medical_Procedure__c != null'
                + ' AND Didkitsent__c = true'
                + ' AND Spincal__c!= null'
                + ' AND Appointment_Status__c =\'WaitingForAppointment\''
                + ' AND TAF_Future_Case__c!=null'
                + ' AND Patient_Account__c != null'
                + ' AND Dont_send_reminder__c = false'
                + ' AND RecordType.DeveloperName = \'Surgeries\''
                + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)';

    global HomeAdmissionSMSSchedulableBatch() {

    }

    global HomeAdmissionSMSSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global HomeAdmissionSMSSchedulableBatch(String query) {
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
            String msgType = determineMessageType(appt_i);
            if(msgType!=null){
                smsList.add(
                    new SMS__c(
                        status__c = '1',
                        Type__c = 'Outgoing',
                        Appointment__c = appt_i.Id,
                        question_type__c = '',
                        Template_Text__c = getTemplate(appt_i,msgType),
                        Phone_Number__c = smsPhoneNumber,
                        Event_Name__c = msgType
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
            Database.executeBatch(new HomeAdmissionSMSSchedulableBatch(true), 25);
        }
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new HomeAdmissionSMSSchedulableBatch(runNextJob), 25);
    }

    private String getTemplate(Appointment__c appt, String smsName) {
        String template = smsName + ',' + appt.Patient_Account__r.FirstName;
        return template;
    }

    private String determineMessageType(Appointment__c appointment){
        if(appointment.Process_Status_From_Site__c=='0' && 
           appointment.Appointment_Date_Time__c >=todayPlus3Days &&
           appointment.Appointment_Date_Time__c <=todayPlus4Days){
            System.debug('inside HomeAdmission not started');
            return 'Check_In_From_Home_Not_Started';
        }
        else if(appointment.Process_Status_From_Site__c!=null &&
                appointment.Process_Status_From_Site__c!='5' &&
                appointment.Process_Status_From_Site__c!='0' &&
                appointment.Appointment_Date_Time__c >=todayPlus3Days &&
                appointment.Appointment_Date_Time__c <=todayPlus4Days){
                System.debug('inside HomeAdmission quit form');
                return 'Check_In_From_Home_Middle';
        }
        else if(appointment.Process_Finished__c==true &&
                appointment.Appointment_Date_Time__c >= todayPlus1Days &&
                appointment.Appointment_Date_Time__c <= todayPlus2Days){
                System.debug('inside HomeAdmission Message welcome');
                return 'Check_In_From_Home_Welcome';   
        }       
        else{
            System.debug('none of the conditions');
            return null;
        }  
    }  
}