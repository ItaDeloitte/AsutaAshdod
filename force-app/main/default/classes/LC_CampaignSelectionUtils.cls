//Test: LC_CampaignSelectionTest
public with sharing class LC_CampaignSelectionUtils {

    public static String ERR_LEAD_NOT_FOUND = 'Lead not found';
    public static String MSG_SUCCESS = 'Success';
    
    public static List<Campaign> obtainCampaigns(String keyword) {
        keyword = '%' + keyword + '%';

        return [SELECT Id, Name FROM Campaign WHERE Name LIKE :keyword AND Status = 'Active'];
    }

    public static Lead obtainLead(String recordId) {
        List<Lead> leads = [SELECT Id
                                , Campaign__r.Id
                                , Campaign__r.Name 
                            FROM Lead 
                            WHERE Id =: recordId LIMIT 1];

        return leads.isEmpty() ? null : leads.get(0);
    }
}