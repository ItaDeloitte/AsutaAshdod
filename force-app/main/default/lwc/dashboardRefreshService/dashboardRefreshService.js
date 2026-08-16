import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {service} from "./service";
import {toastService} from "c/toastService";
import {errorsService} from "c/errorsService";
import {getAllTabInfo, refreshTab} from 'lightning/platformWorkspaceApi';

export default class DashboardRefreshService extends LightningElement {
		@api dashboardId;
		@api refreshDelay;
		@wire(CurrentPageReference) currentPageReference;
		styleId = `DashboardRefreshService${new Date().getSeconds()}`;
		intervalId;

		connectedCallback() {
				this.appendGlobalStyles();
				service.isUserCanRefreshDashboard().then(res => {
						console.log('+++ DV res >>> ', res)
      if (res) {
        this.fireRequestForUpdate()
        this.refreshHandler();
      }
				}).catch(err => {
						toastService.error(this, {message: errorsService.buildServerErrorsString(err)})
				}).finally(() => {
						this.isLoading = false;
				})
		}

		refreshHandler() {
				this.intervalId = setInterval(() => {
						this.fireRequestForUpdate()
				}, this.refreshDelay * 1000);
		}

		fireRequestForUpdate() {
    service.refreshDashboard(this.dashboardId, this.refreshDelay).then(async res => {
						const allTabs = await getAllTabInfo();
						const tabId = allTabs.find(tab => tab.recordId === this.dashboardId)?.tabId
						if (tabId) {
								console.log('+++ DV refresh >>> ',)
								refreshTab(tabId, {
										includeAllSubtabs: true
								});
						}
    }).catch(err => {
      toastService.error(this, {message: errorsService.buildServerErrorsString(err)})
    }).finally(() => {
      this.isLoading = false;
    })
  }

  disconnectedCallback() {
    clearInterval(this.intervalId)
				this.removeGlobalStyles();
  }

		appendGlobalStyles() {
				if (document.body.querySelector(`#${this.styleId}`)) {
						return;
				}

				const styleEl = document.createElement('style');
				styleEl.id = this.styleId;
				styleEl.innerText = `
						[data-component-id="dashboardRefreshService"] {
								display: none!important;
						}
				`
				document.body.appendChild(styleEl);
		}

		removeGlobalStyles() {
				const styleEl = document.body.querySelector(`#${this.styleId}`);
				if (!styleEl) {
						return;
				}
				styleEl.parentElement.removeChild(styleEl);
		}
}