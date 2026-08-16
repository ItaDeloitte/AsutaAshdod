import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { services } from 'c/assutaGlobalService';
import APPOINTMENT_OBJECT from '@salesforce/schema/Appointment__c';
import URGENTREASON_FIELD from '@salesforce/schema/Appointment__c.UrgentReason__c';
import RECORDTYPE_FIELD from "@salesforce/schema/Appointment__c.RecordType.DeveloperName";
import APPSTATUS_FIELD from "@salesforce/schema/Appointment__c.Appointment_Status__c";
import ISURGENT_FIELD from "@salesforce/schema/Appointment__c.Is_Urgent__c";
//import checkRelatedReferral from "@salesforce/apex/UtilGetObjectData.checkRelatedReferral";

import urgentAppointmentDet from "@salesforce/label/c.Urgent_Appointment_Title";
import isUrgent from "@salesforce/label/c.Is_Urgent";
import urgentReason from "@salesforce/label/c.Urgent_Reason";
import otherUrgentReason from "@salesforce/label/c.Other_Urgent_Reason";
import cancel from "@salesforce/label/c.Cancel";
import submit from "@salesforce/label/c.Submit";
import completeThisField from "@salesforce/label/c.Complete_this_field";
import close from "@salesforce/label/c.Close";
import updateRecordSuccess from "@salesforce/label/c.Urgent_Appointment_Update";
import urgentAppointment from "@salesforce/label/c.Urgent_Appointment";

const {toastService, errorsService } = services;
const fields = [RECORDTYPE_FIELD, APPSTATUS_FIELD, ISURGENT_FIELD];
const labels = {
  UrgentAppointmentTitle: urgentAppointmentDet,
  IsUrgent: isUrgent,
  UrgentReason: urgentReason,
  OtherUrgentReason: otherUrgentReason,
  CompleteThisField: completeThisField,
  UpdateRecordSuccess: updateRecordSuccess,
  UrgentAppointment: urgentAppointment,
  Cancel: cancel,
  Submit: submit,  
  Close: close
};

export default class UrgentAppointmentButton extends LightningElement {
  labels = labels;
  @api appointmentId;
  @track record;
  @track urgentReasonValue = null;  
  @track othUrgentReasonValue = null; 
  @track isLoading = false;
  @track isUrgentValue = true; 
  @track reqUrgentReasonField = true;
  @track reqOthUrgentReasonField = false;
  @track isExistsReff = false;

  isShownbtn = false;
  isShowModal = false;

  // GET OBJECT INFO
  @wire(getObjectInfo, { objectApiName: APPOINTMENT_OBJECT })
  objectInfo;

  // GET PICKLIST VALUES
  @wire (getPicklistValues,
          {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
            fieldApiName: URGENTREASON_FIELD
          }
        )
  UrgentReasonPicklist;

  @wire(getRecord, {
    recordId: "$appointmentId",
    fields
  })
  wiredAppointment({ error, data }) {
    if (data) {
      this.record = data;
      if (this.recTypeName == 'Institutes' && !this.isUrgent && (this.appStatus == 'WaitingForAppointment' || this.appStatus == 'וידוא הגעה לפגישה')) {
         //this.checkFiles();//Removed for new version 20.03.25 by yifa
         this.isShownbtn = true;
      }
    } else if (error) {
      console.log("error in wiredAppointment" + error);
    }
  }


  renderedCallback() {   
  }

  get recTypeName() {
    return this.record ? getFieldValue(this.record, RECORDTYPE_FIELD) : "";
  }

  get appStatus() {
    return this.record ? getFieldValue(this.record, APPSTATUS_FIELD) : "";
  }

  get isUrgent() {
    return this.record ? getFieldValue(this.record, ISURGENT_FIELD) : "";
  }  

  /*checkFiles(){   
    checkRelatedReferral({appId: this.appointmentId})
      .then((res) => {
        this.isExistsReff = res;
        if(this.isExistsReff){
          this.isShownbtn = true;
        }          
      }).catch(error => {
        this.error = error;
        console.log("checkFiles in UrgentAppointmentButton fail : " + error); 
      });
  }*/

  openModal() {
    this.isShowModal = true;    
  }

  closeModal() {
    this.isShowModal = false;
  }

  onIsUrgentChange(event){
    this.isUrgentValue = event.detail.checked;      
    this.reqUrgentReasonField = this.isUrgentValue ? true: false;
  }

  onUrgentReasonChange(event){
    this.urgentReasonValue = event.detail.value; 
    this.reqOthUrgentReasonField = this.urgentReasonValue == '10' ? true: false;
  }

  onOthUrgentReasonChange(event){
    this.othUrgentReasonValue = event.detail.value; 
  }

  submitModal() {
    if(this.isInputValid()) {
      this.isLoading = true;
      let record = {
          fields: {
              Id: this.appointmentId,
              Is_Urgent__c: this.isUrgentValue,
              UrgentReason__c : this.urgentReasonValue,
              other_app_reason__c: this.othUrgentReasonValue
          },
      };
      updateRecord(record)
      .then(() => {
        this.isShowModal = false;
        this.isLoading = false;
        this.othUrgentReasonValue = null;
        this.urgentReasonValue = null;
        toastService.success(this, { message: this.labels.UpdateRecordSuccess });             
      })
      .catch(err => {
        const errorText = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errorText });
      });
    }
  }


  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.validate');
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false;
        }
    });
    return isValid;
  }
}