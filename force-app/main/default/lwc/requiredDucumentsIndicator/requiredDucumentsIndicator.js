import { LightningElement, api } from 'lwc';
import getRequiredDocInfo from '@salesforce/apex/RequiredDucumentsIndicator_LWCtrl.getRequiredDocInfo';
import STATUS_FIELD from '@salesforce/schema/Appointment__c.Required_documents_status__c';
import INTEGRITY_FIELD from '@salesforce/schema/Appointment__c.Required_document_integrity__c';

export default class RequiredDucumentsIndicator extends LightningElement {

    @api recordId;
    loaded = false;
    docsData = []
    fields = [INTEGRITY_FIELD];
    fieldsRO = [STATUS_FIELD];

    connectedCallback() {
        getRequiredDocInfo({ appointmentId: this.recordId })
            .then(data => {
                if(data != 'There is no required documents for this appointment'){
                    this.docsData = JSON.parse(data);
                }
                console.log('this.docsData: '+this.docsData);
                this.loaded = true;
            })
            .catch(error => {
                console.error('-------error-------------' + error);
            });
    }

}