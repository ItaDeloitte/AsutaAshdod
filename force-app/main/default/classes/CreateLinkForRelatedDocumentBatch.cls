/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Batch job to create public link in contentVersion for Related document object
 * 
 * Test                 CreateLinkForRelatedDocumentBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             10-04-2022             <ortalk@assuta.co.il>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class CreateLinkForRelatedDocumentBatch implements Database.Batchable<sObject>  {
    
    private String query = 'SELECT Id FROM Related_document__c';    
                                
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Related_document__c> scope) {
        Set<Id> relateDocIds = new Set<Id>();
        Set<Id> contentDocIds = new Set<Id>();                                
        
        for (Related_document__c rd_i : scope) {
            relateDocIds.add(rd_i.Id);
        }
        System.debug('relateDocIds: size: ' + relateDocIds.size() + ' value: ' + relateDocIds);        

        for (ContentDocumentLink conDocLink_i : [SELECT LinkedEntityId, ContentDocumentId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN: relateDocIds]) {
            contentDocIds.add(conDocLink_i.ContentDocumentId);            
        }
        System.debug('contentDocIds: size: ' + contentDocIds.size() + ' value: ' + contentDocIds);
        if(!contentDocIds.isEmpty()) {
            LinkForRelatedDocumentService.createLink(contentDocIds);
        }         
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    } 
       
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateLinkForRelatedDocumentBatch(), 25);
    }
}