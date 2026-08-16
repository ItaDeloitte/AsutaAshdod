/* eslint-disable no-eval */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-debugger */
/* eslint-disable eqeqeq */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import RetrievingServiceReferrals from '@salesforce/apex/MaccabiIntegration.retrievingReferralsFromAccount';
import GetTimeout from  '@salesforce/apex/UtilGetObjectData.getCalloutTimeout';
import UpdateMaccabi from  '@salesforce/apex/UtilGetObjectData.updateMaccabi';
import InsurerFactor from '@salesforce/schema/Account.Insurer_factor__c';
import IDNumber from '@salesforce/schema/Account.ID_Number__c';
import IDType from '@salesforce/schema/Account.ID_Type__c';
import KupaId from '@salesforce/schema/Account.KupaId__c';
import LastUpdateMaccabi from '@salesforce/schema/Account.Last_update_maccabi__c'; 


export default class GetRefferalsMaccabi extends LightningElement {

    @api recordId;
    @track isCallDone = false;
    @track timeout;
    @track localTime;

    @wire(getRecord, { recordId: '$recordId', fields: [InsurerFactor, IDNumber, IDType, KupaId, LastUpdateMaccabi] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            GetTimeout({devName: 'Portal'})
            .then (res => {
                this.timeout = res[0].Timeout__c
                let date = new Date();
                date = this.toSFDate(date);
                let endDate = Date.parse(date);
                let startDate = Date.parse(this.LastUpdateMaccabi);
                if ((this.LastUpdateMaccabi == null || (endDate-startDate)/1000 > this.timeout) && this.InsurerFactor == '2'){
                    this.getRefferal();
                } 
            })
            .catch(error1 => {
                this.timeout = '0'
                console.log(`GetTimeout failed ${error1}`);
            });
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }    
    }

    get InsurerFactor() {
        return this.record? getFieldValue(this.record, InsurerFactor) :'';
    }
    get IDNumber() {
        return this.record? getFieldValue(this.record, IDNumber) :'';
    }
    get IDType() {
        return this.record? getFieldValue(this.record, IDType) :'';
    }
    get KupaId() {
        return this.record? getFieldValue(this.record, KupaId) :'';
    }
    get LastUpdateMaccabi() {
        return this.record? getFieldValue(this.record, LastUpdateMaccabi) :'';        
    }

    getRefferal(){
        if(!this.isCallDone) {
            let memberIDCode = this.IDType == '9' ? '9' : '0';
            let memberID = memberIDCode == '0' ? this.IDNumber : memberIDCode == '9' &&  this.KupaId != null ? this.KupaId : this.IDNumber ;           
            RetrievingServiceReferrals({memberID: memberID, memberIDCode: memberIDCode, accId: this.recordId, domainCode: null})
            .then(result => {                        
                this.isCallDone = true;
                this.updateAccount();
            })
            .catch(err => {
                this.err = err;
                this.message = undefined;
                this.updateAccount(); // מבקשת יאנה נעדכן בכל מקרה את התאריך 16.04.20
            });
        }
    }

    updateAccount() {
        UpdateMaccabi({accID: this.recordId})
        .then(_ => {                        
            console.log(`Account ${this.recordId} 'Last_update_maccabi__c' field updated`);
        })
        .catch(err => {
            console.log(`Account ${this.recordId} 'Last_update_maccabi__c' failed to update ${err.body}`);
        });
    }

    toSFDate(dateObj) {
	    // string format is YYYY-MM-DDThh:mm:ssZ           
        var dateStr = `${dateObj.getFullYear()}-${this.pad2(dateObj.getMonth()+1)}-${this.pad2(dateObj.getDate())}T${this.pad2(dateObj.getHours()-2)}:${this.pad2(dateObj.getMinutes())}:${this.pad2(dateObj.getSeconds())}Z`;
        return dateStr;
    }

    pad2(number) {
	    return (number < 10 ? '0' : '') + number;
    }

}