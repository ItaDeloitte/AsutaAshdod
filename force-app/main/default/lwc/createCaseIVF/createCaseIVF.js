import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchRecords from '@salesforce/apex/UtilGetObjectData.fetchRecordsByQuery';
import Id from '@salesforce/user/Id';
import IVFSITE_FIELD from '@salesforce/schema/User.Site_ivf__c';
import CASE_OBJECT from "@salesforce/schema/Case";
import ACCOUNT_FIELD from "@salesforce/schema/Case.AccountId";
import PARTNER_FIELD from "@salesforce/schema/Case.Partner_Name__c";
import PARTNERD_FIELD from "@salesforce/schema/Case.Partner_details__c";

import SEMEN_FIELD from "@salesforce/schema/Case.Semen_Source__c";
import DATE_FIELD from "@salesforce/schema/Case.Freezing_Date__c";
import DATETXT_FIELD from "@salesforce/schema/Case.Freezing_Date_Text__c";
import EGGS_AMOUNT_FIELD from "@salesforce/schema/Case.Eggs_Amount__c";
import SEMEND_FIELD from "@salesforce/schema/Case.Semen_Source_details__c";

export default class CreateCaseIVF extends LightningElement {

    @api title = '';
    @api icon = '';
    successMsg;
    errorMsg;
    ownerId;
    recType;
    isLoading = false;
    caseObject = CASE_OBJECT;
    fields = [ACCOUNT_FIELD, SEMEN_FIELD, PARTNER_FIELD, PARTNERD_FIELD, DATETXT_FIELD, EGGS_AMOUNT_FIELD, SEMEND_FIELD];

    userId = Id;
    @wire(getRecord, { recordId: '$userId', fields: [IVFSITE_FIELD] })
    user;
    get siteIVFfieldValue() {
        return getFieldValue(this.user.data, IVFSITE_FIELD);
    }

    connectedCallback() {
        let queryQueue = `SELECT Id FROM Group WHERE DeveloperName = 'ivf_ramat'`
        console.log('-------query-------------' + queryQueue);
        fetchRecords({ queryStr: queryQueue })
            .then(result => {
                console.log('-------SUCCSESS-------------' + result);
                this.ownerId = result ? result[0].Id : null;
            })
            .catch(error => {
                console.error('-------error-------------' + error);
            });

        let queryRT = `SELECT Id FROM RecordType WHERE DeveloperName = 'IVF_Freezing_Eggs'`
        console.log('-------queryRT-------------' + queryRT);
        fetchRecords({ queryStr: queryRT })
            .then(result => {
                console.log('-------SUCCSESS-------------' + result);
                this.recType = result ? result[0].Id : null;
            })
            .catch(error => {
                console.error('-------error-------------' + error);
            });
    }


    handleSubmit(event){
        this.isLoading = true;
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        fields.Owner_Queue_wf__c = this.ownerId;
        fields.RecordTypeId = this.recType;
        if(this.siteIVFfieldValue){
            fields.Case_site__c = this.siteIVFfieldValue == 'רמת החייל' ? 'Ramat_Hahayal' : 'Rishon_Letzion';
        }
        fields.Freezing_Date__c = fields.Freezing_Date_Text__c;
        this.template.querySelector("lightning-record-form").submit(fields);
    }

    handleSuccess(event){
        this.isLoading = false;
        this.errorMsg = undefined;
        this.successMsg = 'פניה נוצרה בהצלחה';
    }

    handleError(event){
        this.successMsg = undefined;
        this.errorMsg = event.detail.output?.fieldErrors ? event.detail.output.fieldErrors : event.detail.message;
        this.isLoading = false;
    }

    handleRefreshView(){
        this.successMsg = undefined;
        this.errorMsg = undefined;
        const editForm = this.template.querySelector('lightning-record-form');
        editForm.recordId = null;
    }
}