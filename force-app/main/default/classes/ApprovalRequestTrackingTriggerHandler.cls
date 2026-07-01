public  class ApprovalRequestTrackingTriggerHandler {
    public static void handleTrigger(List<Approval_Request_Tracking__c> newList,Map<Id, Approval_Request_Tracking__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ApprovalRequestTrackingTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                ApprovalRequestTrackingTriggerDisptacher.updateRequiredTable(newList,oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}