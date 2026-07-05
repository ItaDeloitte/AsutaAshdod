import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { errorsService } from 'c/errorsService';
import { toastService } from 'c/toastService';
import USER_ID from '@salesforce/user/Id';
import USER_AD from '@salesforce/schema/User.User_AD__c';
import portalMaccabiBtn from "@salesforce/label/c.PortalMaccabiBtn";

export default class PortalMaccabiButton extends NavigationMixin(LightningElement) {

  @api recordId;
  @track error;
  @track userAD;
  @track idNumber;

  label = {portalMaccabiBtn };

  @wire(getRecord, { recordId: '$recordId', fields: ['Case.Account.ID_Number__c'] })
  wiredCase({ error, data }) {
      if (data) {
        if (this.recordId.startsWith('500')) {
          this.idNumber = data.fields.Account.value.fields.ID_Number__c.value
        }
      }
  }

  @wire(getRecord, { recordId: '$recordId', fields: ['Account.ID_Number__c'] })
  wiredAccount({ error, data }) {
      if (data) {
        if (this.recordId.startsWith('001')) {
          this.idNumber = data.fields.ID_Number__c.value
        }
      }
  }

  @wire(getRecord, { recordId: USER_ID, fields: [USER_AD]})
  wireUser({error,data}) {
    if (error) {
      const errMessage = errorsService.buildServerErrorsString(error);
      toastService.error(this, { message: errMessage });
    } else if (data) {
        this.userAD = data.fields.User_AD__c.value;
    }
  }

  connectedCallback() {}

  disconnectedCallback() {}

  buttonClickHandler() {   
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
          "url": 'http://portalrof.mac.org.il/Doctors/CommonRoute.aspx?target=PatientMiniTik_Assuta&PatientID=' +this.idNumber +'&PatientIDCode=0&hadasa_user_id=AssutaSecretary&user_id=' +this.userAD +'&'
      }
    });
  }
}