// Test: LC_PreSaleTest
public with sharing class LC_PreSaleService {

    public class LC_PreSaleException extends Exception {}

    private static LC_PreSaleService instance;

    private Opportunity oppt;

    public static LC_PreSaleService getInstance() {
        return getInstance(null);
    }

    public static LC_PreSaleService getInstance(String opptId) {
        if (instance == null) {
            instance = new LC_PreSaleService(opptId);
        }
        return instance;
    }

    private LC_PreSaleService(String opptId) {
        this.oppt = LC_PreSaleUtil.obtainOpportunityDetails(opptId);
    }

    public Id createCase() {
        Boolean isOpptChanged = this.prepareOpptFields();
        Case cas;

        if (this.oppt.Case__c == null) {
            Id caseAfterSaleRTId = LC_PreSaleUtil.CASE_RT_MAP.get('CaseAfterSale').getRecordTypeId();
            cas = new Case(RecordTypeId = caseAfterSaleRTId, Status = 'preSale');
        } else {
            cas = LC_PreSaleUtil.obtainCaseDetails(this.oppt.Case__c);
        }

        this.cloneOpptFields(cas);

        if (this.oppt.Case__c != cas.Id) {
            this.oppt.Case__c = cas.Id;
            isOpptChanged = true;
        }

        if (isOpptChanged) {
            update this.oppt;
        }

        return cas.Id;
    }

    private Boolean prepareOpptFields() {
        Boolean isOpptChanged = false;

        if (this.oppt.PayerFactor__c == null && this.oppt.Account.payer_factor_ID__c != null) {
            this.oppt.PayerFactor__c = this.oppt.Account.payer_factor_ID__c;
            isOpptChanged = true;
        } /*else if (this.oppt.PayerFactor__c != this.oppt.Account.payer_factor_ID__c) {
            this.oppt.PayerFactor__c = this.oppt.Account.payer_factor_ID__c;
            isOpptChanged = true;
        }*/

        return isOpptChanged;
    }

    private void cloneOpptFields(Case cas) {
        if (cas.AccountId != this.oppt.AccountId ||
                cas.Channel__c != this.oppt.Channel__c ||
                cas.Agreement__c != this.oppt.Agreement__c ||
                cas.PayerFactor__c != this.oppt.PayerFactor__c ||
                cas.Recommended_doc__c != this.oppt.Recommended_doc__c ||
                cas.Doctor_Arrangement__c != this.oppt.Doctor_Arrangement__c ||
                cas.CampaignFormtitanId__c != this.oppt.Campaign.FormtitanId__c) {
            cas.Opportunity__c = this.oppt.Id;
            cas.AccountId = this.oppt.AccountId;
            cas.Channel__c = this.oppt.Channel__c;
            cas.Agreement__c = this.oppt.Agreement__c;
            cas.PayerFactor__c = this.oppt.PayerFactor__c;
            cas.Recommended_doc__c = this.oppt.Recommended_doc__c;
            cas.Doctor_Arrangement__c = this.oppt.Doctor_Arrangement__c;
            cas.CampaignFormtitanId__c = this.oppt.Campaign.FormtitanId__c;
            upsert cas;
        }
    }
}