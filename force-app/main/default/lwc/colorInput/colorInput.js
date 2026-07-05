import { LightningElement, api } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import updateRecord from '@salesforce/apex/UtilGetObjectData.updateRecord';

export default class ColorInput extends LightningElement {

    @api recordId
    @api title
    @api objectAPI
    @api fieldAPI
    selectedColor

    handleChange(event) {
        this.selectedColor = event.target.value;
        this.updateColorField();
    }

    updateColorField(){
        updateRecord({ recId: this.recordId, sObjectAPIName: this.objectAPI, fieldName: this.fieldAPI, fieldValue: this.selectedColor })
        .then(result => {
            console.log('Color updated succsessfully');
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(error => {
            console.error('-------update user manager error-------------' + error);
        })
    }

}