// CreateSurveyToAppScheduleBatchTest
global with sharing class CreateSurveyToAppScheduleBatch implements Database.Batchable<sObject>{
    private Id surveyId;
    private String siteId;
    private String procedursId;
    
    global CreateSurveyToAppScheduleBatch(String siteId, String procedursId, Id surveyId) {
        this.surveyId = surveyId;
        this.procedursId = procedursId;
        this.siteId = siteId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Medical_Procedure__c, Site__c, Case__c, Appointment_Date_Time__c, Patient_Account__c, Domain__c  
                                    FROM Appointment__c
                                    WHERE Site__c = :this.siteId
                                    AND Medical_Procedure__c = :this.procedursId
                                    AND Appointment_Date_Time__c >= :DateTime.now()
                                    AND Appointment_Status__c NOT IN ('Canceled', '2', '5', 'CanceledFailed', 'not_arrived', '4', '3')]
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Appointment__c> scope) {
        if (scope.isEmpty()) {
            return;
        }
        Map<Id, Appointment__c> appointmentMap = new  Map<Id, Appointment__c>();

        for (Appointment__c appt : scope) {
            
            appointmentMap.put(appt.Id, appt);
        }
        for (SurveyTaker__c survey : [SELECT Id, Survey__c, Appointment__c FROM SurveyTaker__c WHERE Appointment__c IN: appointmentMap.keySet() AND Survey__c = :surveyId]) {            
            appointmentMap.remove(survey.Appointment__c);    
        }
                 
        try {
            if (!appointmentMap.isEmpty()) {
                AppointmentTriggerService.createConsentFormTaken(appointmentMap.values(), true, this.surveyId);
            }
        } catch (Exception e) {
            System.debug('Batch error: ' + e.getMessage());
        }        
    }
   
    global void finish(Database.BatchableContext bc) {       
    }
   
}