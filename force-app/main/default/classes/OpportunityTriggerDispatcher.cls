public class OpportunityTriggerDispatcher {
	
	public static void fillFormtitanId(List<Opportunity> newList){
        System.debug('CampaignTriggerDispatcher.fillFormtitanId...');
        for (Opportunity Opp_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            Opp_i.FormtitanId__c = randomStr;
            System.debug('Opp_i.FormtitanId__c ' + Opp_i.FormtitanId__c);
        }
    }
}