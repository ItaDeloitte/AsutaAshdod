// Test: UpdateLeadInQueueBatchTest
global class UpdateLeadInQueueBatch implements Database.Batchable<sObject> , Schedulable {
    
    Id queueId = [SELECT Id, QueueId, SobjectType FROM QueueSobject WHERE SobjectType = 'Lead' AND Queue.DeveloperName = 'sales_agents'].QueueId;
    String query = 'SELECT Id'
                + ', OwnerId'
                + ', createdDate'
                + ', RecordType.DeveloperName'
                + ' FROM Lead'
                + ' WHERE (Status = \'working\' OR Status = \'waiting\')'
                + ' AND RecordType.DeveloperName != \'Medical_Tourism\''
                + ' AND createdDate >= LAST_N_MONTHS:3'
        		+ ' AND OwnerId != : queueId';
               

    global UpdateLeadInQueueBatch() {}

    global UpdateLeadInQueueBatch(String query, Id queueId) {
        this.query = query;
        this.queueId = queueId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<String> errors = new List<String>();                

        for (Lead lead_i : scope) {
             lead_i.OwnerId = this.queueId; 
        }                       
       
        List<Database.SaveResult> results = Database.update(scope, false);
        
        for (Database.SaveResult result_i : results) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
        
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateLeadInQueueBatch(), 75);
    }
}