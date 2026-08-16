//Test: LC_CampaignSelectionTest
public with sharing class LC_CampaignSelectionService {

    public class LC_CampaignSelectionException extends Exception {}

    private static LC_CampaignSelectionService intance;
    private Lead currentLead;

    public static LC_CampaignSelectionService getInstance(String recordId) {
        if (intance == null) {
            intance = new LC_CampaignSelectionService(recordId);
        }
        return intance;
    }

    private LC_CampaignSelectionService(String recordId) {
        this.currentLead = LC_CampaignSelectionUtils.obtainLead(recordId);

        if (this.currentLead  == null) {
            throw new LC_CampaignSelectionException(LC_CampaignSelectionUtils.ERR_LEAD_NOT_FOUND);
        }
        System.debug('currentLead: ' + this.currentLead );
    }

    public InitWrp init() {
        InitWrp result = new InitWrp(this.currentLead);
        System.debug('result: ' + result);
        return result;
    }

    public CampaignSelectionWrp searchCampaign(String keyword) {
        CampaignSelectionWrp result = new CampaignSelectionWrp();

        List<Campaign> campaigns = LC_CampaignSelectionUtils.obtainCampaigns(keyword);
        System.debug('campaigns: size: ' + campaigns.size() + ' values: ' + campaigns);
        List<CampaignWrp> campaignWrps = this.mapCampaigns(campaigns);
        System.debug('campaignWrps: size: ' + campaignWrps.size() + ' values: ' + campaignWrps);
        result.campaigns = campaignWrps;

        System.debug('result: ' + result);
        return result;
    }

    public String assignCampaign(String campaignId) {
        Database.update(new Lead(
            Id = this.currentLead.Id,
            Campaign__c = campaignId
        ));
        return LC_CampaignSelectionUtils.MSG_SUCCESS;
    }

    private List<CampaignWrp> mapCampaigns(List<Campaign> camps) {
        List<CampaignWrp> result = new List<CampaignWrp>();

        for (Campaign camp_i : camps) {
            result.add(new CampaignWrp(camp_i));
        }
        return result;
    }

    public class InitWrp {
        @AuraEnabled
        public CampaignWrp campaign  {get;set;}

        public InitWrp(Lead lead1) {
            this.campaign = new CampaignWrp(lead1);
        }
    }

    public class CampaignSelectionWrp {
        @AuraEnabled 
        public List<CampaignWrp> campaigns {get;set;}
    }

    public class CampaignWrp {
        @AuraEnabled 
        public String id {get;set;}
        @AuraEnabled 
        public String name {get;set;}

        public CampaignWrp(Campaign camp) {
            this.id = camp.Id;
            this.name = camp.Name;
        }

        public CampaignWrp(Lead lead1) {
            this.id = lead1.Campaign__r.Id;
            this.name = lead1.Campaign__r.Name;
        }
    }
}