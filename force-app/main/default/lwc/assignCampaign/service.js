/**
	* Created by daniilvinnik on 11.09.2024.
	*/

import { services } from 'c/globalService';
const { executeService } = services;

class Service {
		init(recordId) {
				const params = {
						actionName: 'init',
						recordId: recordId
				};
				return this.request(params);
		}

		searchCampaign(recordId, keyword) {
				const params = {
						actionName: 'searchCampaign',
						keyword: keyword,
						recordId: recordId
				};
				return this.request(params);
		}

		assignCampaign(recordId, campaignId) {
				const params = {
						actionName: 'assignCampaign',
						campaignId: campaignId,
						recordId: recordId
				};
				return this.request(params);
		}


		/**
			*
			* @param {*} params
			*/
		request(params) {
				return executeService.execute('LC_CampaignSelectionController', params);
		}
}

export const service = new Service();