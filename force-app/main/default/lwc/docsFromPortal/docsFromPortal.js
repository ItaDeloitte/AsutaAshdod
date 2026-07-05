/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable no-debugger */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import { getRecord, getFieldValue, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import GetDocumentsFromPortal from '@salesforce/apex/ws_DocumentsSyncPortalREST.portalGetPages';
import GetRecordType from  '@salesforce/apex/UtilGetObjectData.getRecordType';
import GetTimeout from  '@salesforce/apex/UtilGetObjectData.getCalloutTimeout';
import UpdatePortal from  '@salesforce/apex/UtilGetObjectData.updatePortal';
import GetDateTime from  '@salesforce/apex/UtilGetObjectData.getTimeZone';

import FILE_OBJECT from '@salesforce/schema/File__c';
import FILE_NUMBER_FROM_PORTAL from '@salesforce/schema/File__c.File_number_from_Portal__c';
import FILE_TYPE from '@salesforce/schema/File__c.file_type__c';
import FILE_URL from '@salesforce/schema/File__c.URL__c';
import FILE_ACCOUNT from '@salesforce/schema/File__c.Account__c';
import FILE_RECORD_TYPE from '@salesforce/schema/File__c.RecordTypeId';
import FILE_NAME from '@salesforce/schema/File__c.Name';
import FILE_DATE_RECIVED from '@salesforce/schema/File__c.Date_Received__c';

import IDNumber from '@salesforce/schema/Account.ID_Number__c';
import IDType from '@salesforce/schema/Account.ID_Type__c';
import LastUpdatePortal from '@salesforce/schema/Account.Last_update_portal__c';
import AccountStatus from '@salesforce/schema/Account.AccountStatus__c';



export default class DocsFromPortal extends LightningElement {

    @api recordId;
    @track file;
    @track record;
    @track fileRecordType;
    @track isCallDone = false;
    @track timeout;
    @track error;


    // GET OBJECT INFO
    @wire(getObjectInfo, { objectApiName: FILE_OBJECT })
    objectInfo;

    // GET PICKLIST VALUES
    @wire (getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FILE_TYPE})
    picklistValues;


    @wire(getRecord, { recordId: '$recordId', fields: [IDNumber, IDType, LastUpdatePortal, AccountStatus] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            GetRecordType({developerName: 'General'})
            .then (res => {
                this.fileRecordType = res[0].Id
                console.log(`this.fileRecordType : ${this.fileRecordType}`);
            })
            .catch(error1 => {this.fileRecordType = null});

            GetTimeout({devName: 'Portal'})
            .then (res => {debugger
                console.log(`GetTimeout res: ${res}`);
                this.timeout = res[0].Timeout__c;
                let date = new Date();
                date = this.toSFDate(date);
                let endDate = Date.parse(date);
                let startDate = Date.parse(this.LastUpdatePortal);

                console.log(`GetTimeout startDate: ${startDate}`);
                console.log(`GetTimeout endDate: ${endDate}`);
                if ((((endDate-startDate)/1000 > this.timeout) || (isNaN(startDate))) && this.AccountStatus != 'לקוח רזה'){
                    this.getDocuments();
                }
            })
            .catch(error1 => {
                this.timeout = '0'
                console.log(`GetTimeout :ERROR ${error1.body.output.errors[0].errorCode}`);
            });

        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }


    get IDNumber() {
        return this.record? getFieldValue(this.record, IDNumber) :'';
    }
    get IDType() {
        return this.record? getFieldValue(this.record, IDType) :'';
    }
    get LastUpdatePortal() {
        return this.record? getFieldValue(this.record, LastUpdatePortal) :'';
    }
    get AccountStatus() {
        return this.record? getFieldValue(this.record, AccountStatus) :'';
    }

    getDocuments() {
        if(!this.isCallDone) {
            GetDocumentsFromPortal({patientId: this.IDNumber,
                                    idType: this.IDType,
                                    accountId: this.recordId})
            // eslint-disable-next-line no-unused-vars
            .then(res => {debugger
                let itemsArray = res === '' ? [] : JSON.parse(res);
                Object.keys(itemsArray).forEach(key => {
                    Object.keys(itemsArray[key]).forEach(key1 => {
                        let name = '';
                        this.picklistValues.data.values.forEach(option => {
                            if(option.value == itemsArray[key][key1].type){
                                name = option.label;
                            }
                        })
                        this.createFile(itemsArray[key][key1].name, itemsArray[key][key1].type, name, itemsArray[key][key1].path, itemsArray[key][key1].date);
                    })
                })
                this.isCallDone = true;
                this.updateAccount();
            })
            .catch(error => {debugger
                this.error = error;
            });
        }
    }

    createFile(name, type, fileName, url, date) {
        const fields = {};
        fields[FILE_NUMBER_FROM_PORTAL.fieldApiName] = name.substr(0, name.length - 3);
        fields[FILE_TYPE.fieldApiName] = type;
        fields[FILE_URL.fieldApiName] = url;
        fields[FILE_ACCOUNT.fieldApiName] = this.recordId;
        fields[FILE_RECORD_TYPE.fieldApiName] = this.fileRecordType;
        fields[FILE_NAME.fieldApiName] = fileName;
        fields[FILE_DATE_RECIVED.fieldApiName] = date;
        const recordInput = { apiName: FILE_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(file => {
                this.file = file.id;
                console.log(`Record ${name} created`);
            })
            .catch(error => {
                console.log(`Record ${name} faild to create : ${error}`);
           });
    }

    updateAccount() {
        UpdatePortal({accID: this.recordId})
        .then(_ => {                        
            console.log(`Account ${this.recordId} 'Last_update_portal__c' field updated`);
        })
        .catch(err => {
            console.log(`Account ${this.recordId} 'Last_update_portal__c' failed to update ${err.body}`);
        });
    }

    /*updateAccount() {

        const dateTimeFormat = new Intl.DateTimeFormat(LANG);
        const localTime = new Date(Date.now());
        let record = {
            fields: {
                Id: this.recordId,
                Last_update_portal__c: localTime,
            },
        };
        updateRecord(record)
        // eslint-disable-next-line no-unused-vars
        .then(() => {
            console.log(`Account ${this.recordId} 'Last_update_portal__c' field updated - ${localTime}`);
        })
        .catch(error => {
            console.log(`Account ${this.recordId} 'Last_update_portal__c' failed to update ${error.body}`);
        });

    }*/

    toSFDate(dateObj) {
	    // string format is YYYY-MM-DDThh:mm:ssZ
        var dateStr = `${dateObj.getFullYear()}-${this.pad2(dateObj.getMonth()+1)}-${this.pad2(dateObj.getDate())}T${this.pad2(dateObj.getHours()-2)}:${this.pad2(dateObj.getMinutes())}:${this.pad2(dateObj.getSeconds())}Z`;
        return dateStr;
    }

    pad2(number) {
	    return (number < 10 ? '0' : '') + number;
    }
}