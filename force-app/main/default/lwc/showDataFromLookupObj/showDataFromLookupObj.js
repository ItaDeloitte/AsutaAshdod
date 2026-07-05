import { LightningElement, track, api } from 'lwc';
import getSObjectAPINameById from '@salesforce/apex/UtilGetObjectData.getSObjectAPINameById';
import fetchRecords from '@salesforce/apex/UtilGetObjectData.fetchRecordsByQuery';

export default class ShowDataFromLookupObj extends LightningElement {

    @api recordId;
    @api apilookupFiled
    @api fieldsToShow
    @api title
    @api icon


    objectApiName
    searchedRecordId

    @track fieldPaths = [];


    connectedCallback() {
        this.fieldPaths = this.fieldsToShow.split(',');
        getSObjectAPINameById({ id: this.recordId })
            .then(sObjName => {
                let query = `SELECT ${this.apilookupFiled}`
                this.recordObjApiName = sObjName
                query = `${query} FROM ${this.recordObjApiName} WHERE Id = '${this.recordId}'`
                console.log('-------query-------------' + query);
                fetchRecords({ queryStr: query })
                    .then(result => {
                        console.log('-------SUCCSESS-------------' + result);
                        this.searchedRecordId = result ? result[0][this.apilookupFiled] : undefined;
                        if (this.searchedRecordId != '' && this.searchedRecordId != undefined) {
                            getSObjectAPINameById({ id: this.searchedRecordId })
                                .then(sObjName1 => {
                                    this.objectApiName = sObjName1
                                })
                                .catch(error => {
                                    console.error('-------error-------------' + error);
                                });
                        }
                    })
                    .catch(error => {
                        console.error('-------error-------------' + error);
                    });

            })
            .catch(error => {
                console.error('-------error-------------' + error);
            });
    }
}