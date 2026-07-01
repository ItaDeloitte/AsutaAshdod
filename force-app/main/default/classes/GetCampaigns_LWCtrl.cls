public with sharing class GetCampaigns_LWCtrl {

    @AuraEnabled(cacheable=false)
    public static String getCampaigns(String email) {
        ws_GetCampaigns_REST.GetCampaignReportByReceipientsRequest req = new ws_GetCampaigns_REST.GetCampaignReportByReceipientsRequest();
        req.Email = email;
        req.IsIncludeSenderInfo = true;
        ws_GetCampaigns_REST getC = new ws_GetCampaigns_REST(JSON.serialize(req));
        Map<String,Object> res = getC.getCampaigns();
        return JSON.serialize(res);
    }
}