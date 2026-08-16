// Test: LC_PreSaleTest
public with sharing class LC_PreSaleUtil {

    public class LC_PreSaleException extends Exception {}

    public static final Map<String, Schema.RecordTypeInfo> CASE_RT_MAP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    public static Opportunity obtainOpportunityDetails(String opptId) {
        Opportunity oppt;

        List<Opportunity> opptList = [
            SELECT Id
                 , Name
                 , Case__c
                 , Channel__c
                 , Agreement__c
                 , PayerFactor__c
                 , Recommended_doc__c
                 , Doctor_Arrangement__c
                 , CampaignId
                 , Campaign.FormtitanId__c
                 , AccountId
                 , Account.payer_factor_ID__c
              FROM Opportunity
             WHERE Id =: opptId
             LIMIT 1];

        if (!opptList.isEmpty()) {
            oppt = opptList.get(0);
        }

        return oppt;
    }

    public static Case obtainCaseDetails(String casId) {
        Case cas;

        List<Case> casList = [
            SELECT Id
                 , AccountId
                 , Channel__c
                 , Agreement__c
                 , PayerFactor__c
                 , Opportunity__c
                 , Recommended_doc__c
                 , Doctor_Arrangement__c
                 , CampaignFormtitanId__c
              FROM Case
             WHERE Id =: casId
             LIMIT 1];

        if (!casList.isEmpty()) {
            cas = casList.get(0);
        }

        return cas;
    }
}