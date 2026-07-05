import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { labels } from './labels';
import Email_Field from '@salesforce/schema/Account.Email_Patient__c';
import getCampaigns from '@salesforce/apex/GetCampaigns_LWCtrl.getCampaigns';

export default class GetCampaigns extends LightningElement {

    @api recordId;
    @track data = [];
    @track campaigns;
    generalData;
    record;    
    isLoading = false;
    labels = labels;

    @wire(getRecord, { recordId: "$recordId", fields: [Email_Field] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
        } else if (error) {
            console.log("error" + error);
        }
    }

    get Email() {
        return this.record ? getFieldValue(this.record, Email_Field) : "";
    }

    fetchData() {
        this.isLoading = true;
        this.data = null;
        this.error = null;
        this.campaigns = [];
        getCampaigns({ email: this.Email })
            .then(result => {
                this.data = JSON.parse(result);
                if(this.data.Data){
                    this.generalData= {status: this.data.Data.Status,
                                            firstName: this.data.Data.FirstName,
                                            lastName: this.data.Data.LastName,
                                            sent: this.data.Data.CampaignStatistics.Sent};
                    this.data.Data.Campaigns?.forEach(camp => {
                        this.campaigns = [...this.campaigns, {  id: camp.CampaignId, 
                                                                name: camp.CampaignName, 
                                                                status: camp.Status,
                                                                openCount: camp.OpenCount,
                                                                previewLink: camp.PreviewLink,
                                                                subject: camp.Subject,
                                                                sendDate: camp.SendDate ? this.formatSFDate(camp.SendDate) : '',
                                                                openingDate: camp.OpeningDate ? this.formatSFDate(camp.OpeningDate) : ''
                                                            }]                    
                    });
                } else {
                    this.campaigns = undefined;
                    this.error = 'There is no campaigns for this patient'
                }

                if(this.campaigns?.length > 0){
                    const sortedCampaigns = Object.values(
                        this.campaigns).sort((a, b) => a.openingDate - b.openingDate);
                    this.campaigns = sortedCampaigns;
                }  else {
                    this.campaigns = undefined;
                    this.error = 'There is no campaigns for this patient'
                }

                this.isLoading = false;
            })
            .catch(error => {
                this.error = error.body ? error.body.message : error.message;
                this.isLoading = false;
            });
    }

    formatSFDate(date){
        return date.slice(0, date.indexOf('.')).replace('T', ' ');
    }
}