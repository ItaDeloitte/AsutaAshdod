/**
	* Created by daniilvinnik on 09.09.2024.
	*/
import { services } from 'c/globalService';
const { executeService } = services;

class Service {

		refreshDashboard(dashboardId, refreshDelay) {
				const params = {
						actionName: 'refreshDashboard',
						dashboardId: dashboardId,
						refreshTime: refreshDelay
				};
				return this.request(params);
		}

		isUserCanRefreshDashboard() {
				const params = {
						actionName: 'isUserCanRefreshDashboard'
				}
				return this.request(params);
		}

		/**
			*
			* @param {*} params
			*/
		request(params) {
				return executeService.execute('LC_UtilityBarController', params);
		}
}

export const service = new Service();