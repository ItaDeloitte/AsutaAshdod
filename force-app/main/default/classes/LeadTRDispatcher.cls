// Test: LeadTRTest
public with sharing class LeadTRDispatcher {

    public static Map<String, RecordTypeInfo> LEAD_RT_MAP = SObjectType.Lead.getRecordTypeInfosByDeveloperName();

    /**
     * Copy mailing approval info to the Lead and Account with the same comm channel
     */
    public static void handleMailingApproval(List<Lead> pNewList, Map<Id, Lead> pOldMap) {
        System.debug('TR Lead handleMailingApproval ... start');
        Map<String, Lead> partialMatchLeadMap = new Map<String, Lead>();
        Map<String, Lead> exactMatchLeadMap = new Map<String, Lead>();
        Set<String> leadCommChannelSet = new Set<String>();
        Set<String> commChannelSet = new Set<String>();

        for (Lead lead_i : pNewList) {
            if (lead_i.ApprovesMailing__c != null
                    && (pOldMap == null || pOldMap.get(lead_i.Id).ApprovesMailing__c != lead_i.ApprovesMailing__c)) {
                if (lead_i.Email != null || lead_i.Phone != null) {
                    exactMatchLeadMap.put(lead_i.Email + lead_i.Phone, lead_i);
                    partialMatchLeadMap.put(lead_i.Email, lead_i);
                    partialMatchLeadMap.put(lead_i.Phone, lead_i);
                    if (lead_i.RecordTypeId == LEAD_RT_MAP.get('Medical_Tourism').getRecordTypeId()) {
                        leadCommChannelSet.add(lead_i.Email);
                        leadCommChannelSet.add(lead_i.Phone);
                    } else {
                        commChannelSet.add(lead_i.Email);
                        commChannelSet.add(lead_i.Phone);
                    }
                }
            }
        }
        commChannelSet.remove(null);
        leadCommChannelSet.remove(null);
        partialMatchLeadMap.remove(null);
        System.debug('TR Lead commChannelSet [' + commChannelSet.size() + ']: ' + commChannelSet);
        System.debug('TR Lead leadCommChannelSet [' + leadCommChannelSet.size() + ']: ' + leadCommChannelSet);
        System.debug('TR Lead partialMatchLeadMap [' + partialMatchLeadMap.size() + ']: ' + partialMatchLeadMap);
        System.debug('TR Lead exactMatchLeadMap [' + exactMatchLeadMap.size() + ']: ' + exactMatchLeadMap);

        if (!exactMatchLeadMap.isEmpty()) {
            LeadTRService.handleMailingApproval(commChannelSet, leadCommChannelSet, exactMatchLeadMap, partialMatchLeadMap);
        }
    }
}