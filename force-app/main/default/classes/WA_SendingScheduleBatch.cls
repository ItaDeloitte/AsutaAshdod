global with sharing class WA_SendingScheduleBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    Datetime currentDateTime = System.now();
    String query = 'SELECT Id'
                      + ', Messaging_User__c'
                      + ', Automation_name__c'                                            
                      + ', Values4ScheduledWA__c'
                      + ', Messaging_Template__c'
                      + ', expected_sending_date_time__c'
                  + ' FROM WhatsApp__c'
                 + ' WHERE Messaging_User__c != null'
                   + ' AND Messaging_Template__c != null'
                   + ' AND Outbound_Success__c = false'
                   + ' AND expected_sending_date_time__c != null' +
                   + ' AND expected_sending_date_time__c <= :currentDateTime'
              + ' ORDER BY CreatedDate DESC';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('WA_SendingScheduleBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<WhatsApp__c> scope) {
        System.debug('WA_SendingScheduleBatch ... execute');
        System.debug('scope: [' + scope.size() + '] value: ' + scope);
        
        Map<String, Object> params = new Map<String, Object>();
        List<WA_SendingWrapper> sendingWrappers = new List<WA_SendingWrapper>();

        for (WhatsApp__c WA_i : scope) {
            sendingWrappers.add(new WA_SendingWrapper( WA_i.Id
                                                      , WA_i.Messaging_Template__c
                                                      , WA_i.Messaging_User__c
                                                      , WA_i.Values4ScheduledWA__c
                                                      , WA_i.Automation_name__c
                                                     )
                               );
        }
        System.debug('sendingWrappers: size: ' + sendingWrappers.size() + ' value: ' + sendingWrappers);
        params.put('MessageTime', 'job');
        params.put('Scheduled_WA', sendingWrappers);
        Flow.Interview.Outbound_WA_for_Surgery OutboundWAForSurgeryFlow = new Flow.Interview.Outbound_WA_for_Surgery(params);
        OutboundWAForSurgeryFlow.start(); 
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('WA_SendingScheduleBatch ... finish');
        Datetime now = System.now().addMinutes(5);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('WhatsApp Messages Sender #' + now.getTime(), CRONEXP, new WA_SendingScheduleBatch());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new WA_SendingScheduleBatch(), 25);
    }
}