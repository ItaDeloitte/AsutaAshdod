global class CoronaReminderSchedulableBatch implements Database.Batchable<sObject>, Schedulable  {
    Map<Id,String> formtitanAccMap = new Map<Id,String>();
    global List<String> idsList = new List<String>();
    Boolean runNextJob = false;
    Datetime currdatetime = Datetime.now();
    Datetime noon = Datetime.newInstance(currdatetime.year(), currdatetime.month(), currdatetime.day(), 12, 0, 0);
    Datetime tomorrowNoon =Datetime.newInstance(currdatetime.year(), currdatetime.month(), currdatetime.day(), 12, 0, 0).adddays(+1);
    String todayNoonStr =  noon.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String tomorrowNoonStr = tomorrowNoon.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String query = 'SELECT Id'
                      + ', IDNumber__c'
                      + ', Appointment_Status__c'
                      + ', Appointment_Date_Time__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', Site__c'
                      + ', Medical_Procedure__c'
                      + ', Domain__c'
                      + ', Site__r.Name'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__c'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Patient_Account__r.Corona_questionnaire__c'
                	  + ', Patient_Account__r.Sms_sent_time__c'
        			  + ', Patient_Account__r.formtitan_id_2__c'
                + ' FROM Appointment__c'
                + ' WHERE ((Appointment_Date_Time__c = TODAY'
        		+ ' AND Patient_Account__r.Sms_sent_time__c != YESTERDAY'
                + ' AND Appointment_Date_Time__c >'+todayNoonStr+')'
                + ' OR  (Appointment_Date_Time__c = TOMORROW'
                + ' AND Appointment_Date_Time__c <='+tomorrowNoonStr+'))'
                + ' AND (Appointment_Status__c =\'WaitingForAppointment\' OR Appointment_Status__c = \'וידוא הגעה לפגישה\')'
                + ' AND Patient_Account__c != null'
        		+ ' AND Patient_Account__r.Sms_sent_time__c != TODAY'
                + ' AND Medical_Procedure__r.Confidentiality__c!= true'
                + ' AND Site__r.SendCoronaSms__c = true'
                + ' AND Dont_send_reminder__c = false'
                + ' AND RecordType.DeveloperName = \'Institutes\''
                + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)'
				+ ' ORDER BY IDNumber__c DESC'; 
    
    global CoronaReminderSchedulableBatch() {}            

    global CoronaReminderSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global CoronaReminderSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {

        List<Account> accsToUpdate = new List<Account>();
        List<SMS__c> smsList = new List<SMS__c>();
        Set<String> errors = new Set<String>();
        Set<Id> smsIds = new Set<Id>();
        Set<Id> medProcsIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        set<Id> domainIds = new Set<Id>();
        List<Appointment__c> qualifiedAppts = new List<Appointment__c>();

        for (Appointment__c appt_i : scope) {
            siteIds.add(appt_i.Site__c);
            medProcsIds.add(appt_i.Medical_Procedure__c);
            domainIds.add(appt_i.Domain__c);
        }

        List<Medical_Procedure_in_Sites__c> mpisList = [SELECT Id,Site__c,Medical_Procedure__c FROM Medical_Procedure_in_Sites__c WHERE DontSendCoronaSms__c = false AND (Site__c IN:siteIds AND Medical_Procedure__c IN: medProcsIds)];
        List<Site_Domain__c> sdList = [SELECT Id,Domain__c,Site__c FROM Site_Domain__c WHERE DontSendCoronaSms__c = false AND (Site__c IN: siteIds AND Domain__c IN:domainIds)];
       
        for (Appointment__c appt_i : scope) {
            for(Medical_Procedure_in_Sites__c mpis : mpisList){
                for(Site_Domain__c sd : sdList){
                    if(mpis.Medical_Procedure__c==appt_i.Medical_Procedure__c && mpis.Site__c==appt_i.Site__c && sd.Site__c==appt_i.Site__c && sd.Domain__c==appt_i.Domain__c){
                        if((currdatetime.hour()>=19 && (appt_i.Appointment_Date_Time__c.day() == currdatetime.day()+1)) || Test.isRunningTest()){
                            if(!this.idsList.contains(appt_i.IDNumber__c)){
                                this.idsList.add(appt_i.IDNumber__c);
                                smsList= sendSMS(appt_i,smsList);
                            }
                        }
                        if((currdatetime.hour()>=8 && currdatetime.hour()<10 && appt_i.Appointment_Date_Time__c.day()== currdatetime.day()) || Test.isRunningTest()){
                            if(!this.idsList.contains(appt_i.IDNumber__c)){
                                this.idsList.add(appt_i.IDNumber__c);
                                smsList= sendSMS(appt_i,smsList);
                            }
                        }
                    }
                }
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

        for(Id accId : formtitanAccMap.keySet()){

            accsToUpdate.add(
                new Account(
                    Id = accId,
                    formtitan_id_2__c = formtitanAccMap.get(accId),
                    Sms_sent_time__c = Datetime.now()
                    )
                );  
        }
        if(!accsToUpdate.isEmpty()){
            update accsToUpdate;
        }
       
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
        if (runNextJob) {
            Database.executeBatch(this, 25);
        }
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CoronaReminderSchedulableBatch(runNextJob), 25);
    }

    private String getTemplate(Appointment__c appt, String smsName,Map<Id,String> formtitanAccMap) {
        String template = smsName + ',' + appt.Site__r.Name + ',' +appt.Formula_for_weekday_kit__c+ ',' + appt.Patient_Account__r.Corona_questionnaire__c;
        if(appt.Patient_Account__r.formtitan_id_2__c==null){
            template = template+formtitanAccMap.get(appt.Patient_Account__c); 
        }
        return template;
    }

    private String generateRandomId(){
        return CommonService.generateRandomKey(15);
    }

    private  List<SMS__c> sendSMS(Appointment__c appt_i,List<SMS__c> smsList){
        String smsPhoneNumber = appt_i.Case__c != null && appt_i.Case__r.SMS_Phone_Number__c != null ? appt_i.Case__r.SMS_Phone_Number__c : appt_i.Patient_Account__r.SMS_Phone_number__c;
		formtitanAccMap.put(appt_i.Patient_Account__c, appt_i.Patient_Account__r.formtitan_id_2__c==null ? generateRandomId() : appt_i.Patient_Account__r.formtitan_id_2__c);
        smsList.add(
            new SMS__c(
                status__c = '1',
                Type__c = 'Outgoing',
                Appointment__c = appt_i.Id,
                Template_Text__c = getTemplate(appt_i,'Corona_Reminder',formtitanAccMap),
                Phone_Number__c = smsPhoneNumber,
                Event_Name__c = 'Corona_Reminder'
                )
            );  
        return smsList;
    }

  
}