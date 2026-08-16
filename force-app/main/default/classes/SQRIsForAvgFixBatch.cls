/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Is For Avg Checkbox Filling Batch Apex class to check sqrs' Is For Avg checkbox
 *
 * Test                 SQRIsForAvgFixBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             19-01-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class SQRIsForAvgFixBatch implements Database.Batchable<sObject> {

    String query = 'SELECT IsForAvg__c'
                  + ' FROM SurveyQuestionResponse__c'
                 + ' WHERE Survey_Question__r.Survey__r.SurveyCode__c = \'DocAdvisor\''
                   + ' AND Survey_Question__r.IsForAvg__c = true'
                   + ' AND IsForAvg__c = false'
              + ' ORDER BY LastModifiedDate DESC';

    global SQRIsForAvgFixBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('SQRIsForAvgFixBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SurveyQuestionResponse__c> scope) {
        System.debug('SQRIsForAvgFixBatch ... execute');
        List<SurveyQuestionResponse__c> sqrsToUpdate = new List<SurveyQuestionResponse__c>();

        for (SurveyQuestionResponse__c sqr_i : scope) {
            sqr_i.IsForAvg__c = true;
            sqrsToUpdate.add(sqr_i);
        }
        System.debug('sqrsToUpdate: size: ' + sqrsToUpdate.size() + ' value: ' + sqrsToUpdate);

        if (!sqrsToUpdate.isEmpty()) {
            for (Database.SaveResult dr_i : Database.update(sqrsToUpdate, false)) {
                if (!dr_i.isSuccess()) {
                    System.debug('The following errors have occurred while trying to update Survey Question Response (' + dr_i.getId() + '):');
                    for (Database.Error err_i : dr_i.getErrors()) {
                        System.debug(' - ' + err_i.getStatusCode() + ': ' + err_i.getMessage());
                    }
                }
            }
            System.debug('SQRIsForAvgFixBatch ... executed');
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('SQRIsForAvgFixBatch ... finish');
    }
}