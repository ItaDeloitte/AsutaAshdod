global with sharing class CreateSurveyToAppSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {

        Id surveyId;
        if (Test.isRunningTest()) {
            surveyId = [SELECT Id FROM Survey__c LIMIT 1].Id;
        } else {
            surveyId = (Id) System.Label.SurveyId; 
        }
                	
        if (surveyId == null) {
            return;
        }

        Set<Id> siteIds = new Set<Id>();
        Set<Id> procedursIds = new Set<Id>();

        for (Medical_Procedure_in_Sites__c mps : [SELECT Id, Medical_Procedure__c, Site__c
                                                    FROM Medical_Procedure_in_Sites__c
                                                    WHERE Digital_Survey1__c = :surveyId
                                                    OR Digital_Survey_2__c = :surveyId
                                                    OR Digital_Survey_3__c = :surveyId
        ]) {            
            if (mps.Site__c != null && mps.Medical_Procedure__c != null) {
                Database.executeBatch(new CreateSurveyToAppScheduleBatch(mps.Site__c, mps.Medical_Procedure__c, surveyId), 10);
            }
        }         
    }
}