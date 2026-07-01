//Test: LC_CampaignSelectionTest
public with sharing class LC_CampaignSelectionController implements ILCController {

    public class LC_CampaignSelectionException extends Exception{}
    
    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'init' {
                return this.init(
                    (String) params.get('recordId')
                );
            }
            when 'searchCampaign' {
                return this.searchCampaign(
                    (String) params.get('recordId'),
                    (String) params.get('keyword')
                );
            }
            when 'assignCampaign' {
                return this.assignCampaign(
                    (String) params.get('recordId'),
                    (String) params.get('campaignId')
                );
            }
            when else {
                throw new LC_CampaignSelectionException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response init(String recordId) {
        System.debug('LC_CampaignSelectionController.init...');
        return new Response(LC_CampaignSelectionService.getInstance(recordId).init());
    }

    private Response searchCampaign(String recordId, String keyword) {
        System.debug('LC_CampaignSelectionController.searchCampaign...');
        return new Response(LC_CampaignSelectionService.getInstance(recordId).searchCampaign(keyword));
    }

    private Response assignCampaign(String recordId, String campaignId) {
        System.debug('LC_CampaignSelectionController.assignCampaign...');
        return new Response(LC_CampaignSelectionService.getInstance(recordId).assignCampaign(campaignId));
    }
}