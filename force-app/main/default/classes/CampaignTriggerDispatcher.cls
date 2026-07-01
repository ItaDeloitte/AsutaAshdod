public class CampaignTriggerDispatcher {
    
	public static void fillFormtitanId(List<Campaign> newList){
        System.debug('CampaignTriggerDispatcher.fillFormtitanId...');
        for (Campaign campaign_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            campaign_i.FormtitanId__c = randomStr;
            System.debug('campaign_i.FormtitanId__c ' + campaign_i.FormtitanId__c);
        }
    }
}