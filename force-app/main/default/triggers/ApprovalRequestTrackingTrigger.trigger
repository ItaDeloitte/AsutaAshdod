trigger ApprovalRequestTrackingTrigger on Approval_Request_Tracking__c (after update) {
    
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('ApprovalRequestTrackingTrigger')){
        ApprovalRequestTrackingTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }

}