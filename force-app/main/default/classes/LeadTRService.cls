// Test: LeadTRTest
public with sharing class LeadTRService {

    public static void handleMailingApproval(Set<String> pCommChannelSet, Set<String> pLeadCommChannelSet, Map<String, Lead> pExactMatchLeadMap, Map<String, Lead> pPartialMatchLeadMap) {
        Map<String, List<Account>> commChannelToAccountsMap = new Map<String, List<Account>>();
        Map<String, List<Lead>> commChannelToLeadsMap = new Map<String, List<Lead>>();
        List<SObject> recordToUpdateList = new List<SObject>();

        List<Account> dbAccountList = pCommChannelSet.isEmpty()
            ? new List<Account>()
            : [SELECT SyncToMC__pc
                    , Mailing_approval__c
                    , OTP_EMAIL_HIDDEN__c
                    , SMS_Phone_Number__c
                 FROM Account
                WHERE (Status__c = null OR Status__c = 'פ')
                  AND RecordType.DeveloperName = 'PersonAccount'
                  AND (OTP_EMAIL_HIDDEN__c IN :pCommChannelSet OR SMS_Phone_Number__c IN :pCommChannelSet)
             ORDER BY CreatedDate DESC];
        System.debug('TR Lead dbAccountList [' + dbAccountList.size() + ']: ' + dbAccountList);

        List<Lead> dbLeadList = [
            SELECT SyncToMC__c
                 , CampaignOnly__c
                 , ApprovesMailing__c
                 , Email
                 , Phone
              FROM Lead
             WHERE IsConverted = false
               AND Campaign__r.Status != 'Inactive'
               AND Status NOT IN ('lost', 'false', 'win')
               AND (Email IN :pCommChannelSet OR Email IN :pLeadCommChannelSet OR Phone IN :pCommChannelSet OR Phone IN :pLeadCommChannelSet)
          ORDER BY CreatedDate DESC];
        System.debug('TR Lead dbLeadList [' + dbLeadList.size() + ']: ' + dbLeadList);

        for (Account account_i : dbAccountList) {
            Boolean isUpdated_i = false;
            String exactKey_i = account_i.OTP_EMAIL_HIDDEN__c + account_i.SMS_Phone_Number__c;

            if (pExactMatchLeadMap.containsKey(exactKey_i)) {
                if (!commChannelToAccountsMap.containsKey(exactKey_i)) {
                    commChannelToAccountsMap.put(exactKey_i, new List<Account>());
                }

                if (account_i.SyncToMC__pc != commChannelToAccountsMap.get(exactKey_i).isEmpty()) {
                    account_i.SyncToMC__pc = commChannelToAccountsMap.get(exactKey_i).isEmpty();
                    isUpdated_i = true;
                }

                commChannelToAccountsMap.get(exactKey_i).add(account_i);
            }

            if (pPartialMatchLeadMap.containsKey(account_i.OTP_EMAIL_HIDDEN__c) || pPartialMatchLeadMap.containsKey(account_i.SMS_Phone_Number__c)) {
                String partialKey_i = pPartialMatchLeadMap.containsKey(account_i.OTP_EMAIL_HIDDEN__c)
                    ? account_i.OTP_EMAIL_HIDDEN__c
                    : account_i.SMS_Phone_Number__c;

                if (account_i.Mailing_approval__c != pPartialMatchLeadMap.get(partialKey_i).ApprovesMailing__c) {
                    account_i.Mailing_approval__c = pPartialMatchLeadMap.get(partialKey_i).ApprovesMailing__c;
                    isUpdated_i = true;
                }
            }

            if (isUpdated_i) {
                recordToUpdateList.add(account_i);
            }
        }
        System.debug('TR Lead recordToUpdateList [' + recordToUpdateList.size() + ']: ' + recordToUpdateList);

        for (Lead lead_i : dbLeadList) {
            Boolean isUpdated_i = false;
            String exactKey_i = lead_i.Email + lead_i.Phone;

            if (pExactMatchLeadMap.containsKey(exactKey_i)) {
                if (!commChannelToLeadsMap.containsKey(exactKey_i)) {
                    commChannelToLeadsMap.put(exactKey_i, new List<Lead>());
                }

                if (lead_i.SyncToMC__c != commChannelToLeadsMap.get(exactKey_i).isEmpty()) {
                    lead_i.SyncToMC__c = commChannelToLeadsMap.get(exactKey_i).isEmpty();
                    isUpdated_i = true;
                }
                if (lead_i.campaignOnly__c != (commChannelToAccountsMap.containsKey(exactKey_i) || !commChannelToLeadsMap.get(exactKey_i).isEmpty())) {
                    lead_i.campaignOnly__c = (commChannelToAccountsMap.containsKey(exactKey_i) || !commChannelToLeadsMap.get(exactKey_i).isEmpty());
                    isUpdated_i = true;
                }

                commChannelToLeadsMap.get(exactKey_i).add(lead_i);
            }

            if (pPartialMatchLeadMap.containsKey(lead_i.Email) || pPartialMatchLeadMap.containsKey(lead_i.Phone)) {
                String partialKey_i = pPartialMatchLeadMap.containsKey(lead_i.Email)
                    ? lead_i.Email
                    : lead_i.Phone;

                if (lead_i.ApprovesMailing__c != pPartialMatchLeadMap.get(partialKey_i).ApprovesMailing__c) {
                    lead_i.ApprovesMailing__c = pPartialMatchLeadMap.get(partialKey_i).ApprovesMailing__c;
                    isUpdated_i = true;
                }
            }

            if (isUpdated_i) {
                recordToUpdateList.add(lead_i);
            }
        }
        System.debug('TR Lead recordToUpdateList [' + recordToUpdateList.size() + ']: ' + recordToUpdateList);

        if (!recordToUpdateList.isEmpty()) {
            recordToUpdateList.sort();
            update recordToUpdateList;
            System.debug('TR Lead handleMailingApproval ... executed');
        }
    }
}