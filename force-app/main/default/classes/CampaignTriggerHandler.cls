// Test: CampaignTriggerDispatcherTest
// Created: Ortal kazum
// Created date: 01.02.2021
public class CampaignTriggerHandler {
	public static void handleTrigger(List<Campaign> newList, Map<Id, Campaign> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('CampaignTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                CampaignTriggerDispatcher.fillFormtitanId(newList);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
		}
   }
}