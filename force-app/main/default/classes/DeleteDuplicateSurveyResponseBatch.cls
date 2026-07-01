global class DeleteDuplicateSurveyResponseBatch implements Database.Batchable<sObject>, Schedulable,Database.Stateful {
    
    List<String> questionTypes = new List<String>{'Courtesy','Availability','Professionalism','General_impression','IsAnonimous','Survey_comments'};
    List<Survey_Question__c> sqList = [SELECT Id,Name FROM Survey_Question__c WHERE Name IN : questionTypes];
    String query = 'SELECT Id'
                        + ', SurveyTaker__c'
        				+ ', Survey_Question__c'
                + ' FROM SurveyQuestionResponse__c'
                + ' WHERE SurveyTaker__r.RecordType.DeveloperName = \'Doc_Advisor\''
        		+ ' ORDER BY SurveyTaker__c';
    Map<Id,Set<Id>> surveyTakerRespMap = new Map<Id,Set<Id>>();
    List<SurveyQuestionResponse__c> sqrToDelete = new List<SurveyQuestionResponse__c>();

    global DeleteDuplicateSurveyResponseBatch() {}
    global DeleteDuplicateSurveyResponseBatch(String query){
        this.query=query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('SurveyQuestionResponse__c'));
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<SurveyQuestionResponse__c> surveyQuestionResponses){
        for (SurveyQuestionResponse__c sqr : surveyQuestionResponses) {
            if(surveyTakerRespMap.get(sqr.SurveyTaker__c)==null){
                surveyTakerRespMap.put(sqr.SurveyTaker__c,new Set<Id>());
            }
            if(surveyTakerRespMap.get(sqr.SurveyTaker__c).contains(sqr.Survey_Question__c)){
                sqrToDelete.add(sqr);
            }else{
                surveyTakerRespMap.get(sqr.SurveyTaker__c).add(sqr.Survey_Question__c);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('finish DeleteDuplicateSurveyResponseBatch');
        System.debug('trying to delete duplicates responses in a batch, total duplicate responses: '+sqrToDelete.size());
        Database.executeBatch(new ExecuteDeleteDMLSurveyResponseBatch(sqrToDelete),100);
    }
        
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DeleteDuplicateSurveyResponseBatch(), 25);
    }

    
}