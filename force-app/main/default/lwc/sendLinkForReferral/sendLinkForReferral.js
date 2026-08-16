/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import btnTitle from '@salesforce/label/c.SendLinkBtnTitle';

export default class SendLinkForReferral extends LightningElement {

    @api caseId;

    label = {btnTitle};

    sendLink(){
        this.updateCase();
    }

    updateCase() {
        let record = {
            fields: {
                Id: this.caseId,
                send_link_for_referral__c: true,
            },
        };
        updateRecord(record)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                console.log(`Case ${this.recordId} 'send_link_for_referral__c' field updated`);
            })
            .catch(error => {
                console.log(`Case ${this.recordId} 'send_link_for_referral__c' failed to update : ${error}`);
            });
    }

}