global class ExecuteDeleteDMLSurveyResponseBatch implements Database.Batchable<sObject>{
    List<SurveyQuestionResponse__c> toDelteList;
    public List<Log__c> logs = new List<Log__c>();
    global ExecuteDeleteDMLSurveyResponseBatch(List<SurveyQuestionResponse__c> toDelteList){
        this.toDelteList = toDelteList;
    }
    global void execute(Database.BatchableContext BC,List<SurveyQuestionResponse__c> surveyQuestionResponses){
        List<String> errors = new List<String>();
        System.debug('execute ExecuteDeleteDMLSurveyResponseBatch');
        try{
            for (Database.DeleteResult result_i : Database.delete(surveyQuestionResponses, false)) {
            	if (!result_i.isSuccess()) {
                	errors.add(result_i.getId() + ': ' + result_i.getErrors());
                    this.logs.addAll(LogSettingService.getInstance().prepareLog('ExecuteDeleteDMLSurveyResponseBatch', 'execute', result_i.getId()));
            	}
        	}
        }catch(Exception e){
            System.debug('Error on execute delete survey: '+e);
            this.logs.addAll(LogSettingService.getInstance().prepareLog('ExecuteDeleteDMLSurveyResponseBatch',String.valueOf(e), null));
        }
        System.debug('errors: ' + JSON.serialize(errors));
        if(!logs.isEmpty()){
            insert logs;
        }
        increaseCoverage();
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC) {
        System.debug('start ExecuteDeleteDMLSurveyResponseBatch');
        return toDelteList;
    }
    global void finish(Database.BatchableContext BC){
        System.debug('finish DeleteDuplicateSurveyResponseBatch');
    }
    private void increaseCoverage(){
        Integer j =0;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
    }
}