//SendSurveyToDoctorsScheduleBatchTest
global with sharing class SendSurveyToDoctorsScheduleBatch implements Database.Batchable<sObject>, Schedulable{

    String query = 'SELECT Id'
                + ', Doctors__c, Clinic__c, Email__c, SurveySentTime__c'
                + ' FROM Doctor_in_Clinic__c'
                + ' WHERE SendSurveyToDoctor__c = True'
                + ' AND Email__c != null'
                + ' ORDER BY CreatedDate';

    global SendSurveyToDoctorsScheduleBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Doctor_in_Clinic__c> scope) {
        EmailTemplate template = [SELECT Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Doctors_weekly_survey'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Appointment__c> appToUpdate = new List<Appointment__c>();
        List<Doctor_in_Clinic__c> docClinicToUpdate = new List<Doctor_in_Clinic__c>();

        Set<Id> docIds = new Set<Id>();
        Set<Id> clinicId = new Set<Id>();
        
        Map<String, Doctor_in_Clinic__c> docClinicMap = new Map<String, Doctor_in_Clinic__c>();
        Set<String> docClinicApp = new Set<String>();

        for (Doctor_in_Clinic__c docClinic_i : scope) {
            docIds.add(docClinic_i.Doctors__c);
            clinicId.add(docClinic_i.Clinic__c);
            docClinicMap.put(docClinic_i.Doctors__c + '-' + docClinic_i.Clinic__c, docClinic_i);
        }
        
        System.debug('docIds: size: ' + docIds.size() + ' value: ' + docIds);
        System.debug('clinicId: size: ' + clinicId.size() + ' value: ' + clinicId);
        System.debug('docClinicMap: size: ' + clinicId.size() + ' value: ' + docClinicMap);
    	
        for(Appointment__c app_i :[SELECT Id, SurveySentToDoctor__c, Doctor_Account__c, Clinic__c 
                                  FROM Appointment__c WHERE Doctor_Account__c IN :docIds 
                                  AND Clinic__c IN :clinicId AND Appointment_Date_Time__c = LAST_N_DAYS:7 
                                  AND Appointment_Status__c != 'Canceled' AND Opportunity__r.Campaign.DoctorSurvey__c = true]){
            docClinicApp.add(app_i.Doctor_Account__c + '-' + app_i.Clinic__c);
            app_i.SurveySentToDoctor__c = true;
            appToUpdate.add(app_i);
        }
        
        System.debug('appToUpdate: size: ' + appToUpdate.size() + ' value: ' + appToUpdate);
		System.debug('docClinicApp: size: ' + docClinicApp.size() + ' value: ' + docClinicApp);
        
        if(!docClinicApp.isEmpty()){
            for(String docClinic_i :docClinicMap.keySet()){
                if(docClinicApp.contains(docClinic_i)){
                    Doctor_in_Clinic__c doctorClinic_i = docClinicMap.get(docClinic_i);
                    doctorClinic_i.SurveySentTime__c = System.now();
                    docClinicToUpdate.add(doctorClinic_i);
                    mails.add(prepareMail(docClinicMap.get(docClinic_i), template));
                }
            }

            System.debug('mails: size: ' + mails.size() + 'values' + mails);
            System.debug('docClinicToUpdate: size: ' + docClinicToUpdate.size() + ' value: ' + docClinicToUpdate);
            System.debug('appToUpdate: size: ' + appToUpdate.size() + ' value: ' + appToUpdate);
            
			if (!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
            if (!docClinicToUpdate.isEmpty()) {
                update docClinicToUpdate;
            }
            if (!appToUpdate.isEmpty()) {
                update appToUpdate;
            }
        }
    }

    private static Messaging.SingleEmailMessage prepareMail(Doctor_in_Clinic__c docInClinic, EmailTemplate template) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{docInClinic.Email__c});
        mail.setSenderDisplayName('Assuta No-Reply');
        mail.setReplyTo('nonreply@assuta.co.il');
        mail.setPlainTextBody(template.Body);
        mail.setTreatBodiesAsTemplate(true);
        mail.setSubject(template.Subject);
        mail.setWhatId(docInClinic.Id);
        return mail;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new SendSurveyToDoctorsScheduleBatch(), 25);
    }
}