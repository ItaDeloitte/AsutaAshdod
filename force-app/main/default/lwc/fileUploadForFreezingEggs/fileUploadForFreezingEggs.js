import { LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import importCSVFile from "@salesforce/apex/fileUploadForFreezingEggsController.importCSVFile";


export default class FileUploadForFreezingEggs extends LightningElement {

    @api recordId;
    @api options = [];
    @track cVersionId;
    @track siteValue;
    @track isDisabled = true;
    
    get acceptedFormats() {
        return ['.csv'];
    }

    get options() {
        return [
            { label: 'רמת החייל', value: 'Ramat_Hahayal' },
            { label: 'ראשון לציון', value: 'Rishon_Letzion' },
        ];
    }

    handleChange(event){
        this.siteValue = event.target.value;
        this.isDisabled = false;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("uploadedFiles[0].contentVersionId:", uploadedFiles[0].contentVersionId);
        this.cVersionId = uploadedFiles[0].contentVersionId;

        importCSVFile({ cVersionId: this.cVersionId,
                        siteName : this.siteValue })
        .then(res => {
        console.log("importFile success : " + res);
        })
        .catch(error => {
        console.log("importFile fail : " + error);
        });
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFiles[0].name,
                variant: 'success',
            }),
        );
    }
}