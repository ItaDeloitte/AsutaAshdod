global with sharing class BatchFileScan implements database.batchable<sobject>{

    private List<ContentVersion> contVersionList;

    public BatchFileScan(List<ContentVersion> contVList) {
        contVersionList = contVList;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        return DataBase.getQueryLocator([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:contVersionList]);
    }

    global void execute(Database.BatchableContext BC, List<ContentVersion> scope) {
        system.debug('==========BatchFileScan START');
        for (ContentVersion cv : scope){
            System.enqueueJob(new ws_gateScannerApi_Upload_REST(cv.Id));
        } 
    }   

    global void finish(Database.BatchableContext BC) {
    }
}