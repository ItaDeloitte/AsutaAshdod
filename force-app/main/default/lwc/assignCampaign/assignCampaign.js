/**
	* Created by daniilvinnik on 11.09.2024.
	*/

import {LightningElement, api, track} from 'lwc';
import {errorsService} from "c/errorsService";
import {toastService} from "c/toastService";
import {service} from "./service";
import {labels} from "./labels";

export default class AssignCampaign extends LightningElement {
		@api recordId
		@track errors = [];
		@track editData = {
				campaign: undefined
		}
		isLoading = false;
		isAssigned = false;


		get labels(){
				return labels
		}

		get isAssignButtonDisabled() {
				return !this.isAssigned || !this.editData.campaign?.id;
		}

		connectedCallback() {
				service.init(this.recordId).then(res => {
				     this.editData.campaign = Object.keys(res.campaign)?.length ? Object.assign({}, res.campaign ,{title: res.campaign.name, icon: 'standard:campaign'}) : undefined
				}).catch(err => {
				     toastService.error(this, {message: errorsService.buildServerErrorsString(err)})
				}).finally(()=>{
				     this.isLoading = false;
				})
		}

		closeErrorsHandler() {
				this.resetErrors();
		}

		resetErrors() {
				this.errors = [];
		}

		searchCampaignHandler(event) {
				const { detail, target } = event;
				const { searchTerm } = detail;
				service.searchCampaign(this.recordId, searchTerm)
						.then(options => {
								target.setSearchResults(options.campaigns?.map(option => {
										return Object.assign({}, option, {title: option.name, icon: 'standard:campaign'})
								}));
						})
						.catch(err => {
								target.setSearchResults([]);
								const errorText = errorsService.buildServerErrorsString(err);
								toastService.error(this, { message: errorText });
						});
		}

		changeCampaignHandler(event) {
				if (!this.isAssigned) {
						this.isAssigned = true;
				}
				const { target } = event;
				const selection = target.getSelection();
				const newEditData = Object.assign({}, this.editData);
				newEditData.campaign = selection;
				this.editData = newEditData;
		}

		handleAssignCampaign() {
				this.isLoading = true;
				service.assignCampaign(this.recordId, this.editData.campaign.id).then(res => {
				     toastService.success(this, {message: ''})
				}).catch(err => {
				     toastService.error(this, {message: errorsService.buildServerErrorsString(err)})
				}).finally(()=>{
				     this.isLoading = false;
				})
		}
}