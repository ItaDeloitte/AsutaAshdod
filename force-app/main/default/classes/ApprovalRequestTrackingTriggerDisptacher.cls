/*
    * @author         Max Feldman   <maxf@assuta.co.il>
    * @Test           SendSMSHandlerTest
    * @modifiedBy     
    * @version        1.0
    * @created        01-11-2020
    * @modified       DD-MM-YYYY
    * @description    trigger for managing Approval request for Doctor Profile
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ApprovalRequestTrackingTriggerDisptacher {

     public static void updateRequiredTable(List<Approval_Request_Tracking__c> newList, Map<Id, Approval_Request_Tracking__c> oldMap) {
        Set<Id> approvalIds = new Set<Id>();
        for (Approval_Request_Tracking__c approval : newList) {
            if ((approval.Decision_Result__c != oldMap.get(approval.Id).Decision_Result__c) && (approval.Decision_Result__c == 'Approved')) {
                approvalIds.add(approval.Id);
            }
        }
        if(!approvalIds.isEmpty()){
            ApprovalRequestTrackingTriggerService.updateRequiredTable(approvalIds);
        }else{
            System.debug('list is empty, no approvals to update');
        }

    }
}