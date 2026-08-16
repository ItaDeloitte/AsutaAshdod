// Test: LeadTRTest
public with sharing class LeadTRHandler {

    public static void handleTrigger(List<Lead> newList, Map<Id, Lead> oldMap) {
        System.debug('TR Lead ...');

        switch on Trigger.operationType {
            when AFTER_INSERT {
                System.debug('TR Lead AFTER_INSERT');
                LeadTRDispatcher.handleMailingApproval(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('TR Lead AFTER_UPDATE');
                LeadTRDispatcher.handleMailingApproval(newList, oldMap);
            }
        }
    }
}