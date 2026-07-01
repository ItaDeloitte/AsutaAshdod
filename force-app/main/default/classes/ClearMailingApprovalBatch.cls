// Test: ClearMailingApprovalBatchTest
global class ClearMailingApprovalBatch implements Database.Batchable<sObject> {

    String query = 'SELECT Id FROM AccountHistory WHERE Id = null';

    global ClearMailingApprovalBatch(Integer queryNumber) {
        if (queryNumber == 1) {         
            this.query = 'SELECT AccountId'                            
                            + ', MAX(CreatedDate) maxDate'                            
                        + ' FROM AccountHistory'
                        + ' WHERE Field = \'Mailing_approval__c\''
                          + ' AND Account.Status__c = \'פ\'' 
                          + ' AND Account.RecordType.DeveloperName = \'PersonAccount\''
                          + ' AND (Account.Mailing_approval__c = \'מאשר דיוור - שיווקי\''
                          + ' OR Account.Mailing_approval__c = \'מאשר דיוור - הכל\')'
                          + ' AND (CreatedBy.Profile.Name = \'Agent\''
                          + ' OR CreatedBy.Profile.Name = \'Manager\''
                          + ' OR CreatedBy.Profile.Name = \'Agent Ashdod\''
                          + ' OR CreatedBy.Profile.Name = \'Senior Agent\''
                          + ' OR CreatedBy.Profile.Name = \'Agent 360\''                                                    
                          + ' OR CreatedBy.Profile.Name = \'TelleAll Agent\')'                           
                          + ' GROUP BY AccountId';
        } else if (queryNumber == 2) {
            this.query = 'SELECT AccountId'                            
                            + ', MAX(CreatedDate) maxDate'                            
                        + ' FROM AccountHistory'
                        + ' WHERE Field = \'Mailing_approval__c\''
                        + ' AND Account.Status__c = \'פ\'' 
                        + ' AND Account.RecordType.DeveloperName = \'PersonAccount\''
                        + ' AND Account.Mailing_approval__c = \'מאשר דיוור - שירותי\''
                        + ' AND CreatedById = \'0058d0000023umVAAQ\''                                                                                                    
                        + ' GROUP BY AccountId';          
        }
    }

    global ClearMailingApprovalBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
}