import { LightningElement, api, wire, track } from "lwc";
import AccountId from "@salesforce/schema/Case.AccountId";
import FemaleEmail from "@salesforce/schema/Case.email_from_patient__c";
import PartnerEmail from "@salesforce/schema/Case.Partner_Email__c";
import FemalePhone from "@salesforce/schema/Case.SMS_Phone_Number__c";
import FemalePhone2 from "@salesforce/schema/Case.phone__c";
import PartnerPhone from "@salesforce/schema/Case.Primary_Phone_Partner__c";
import sendIVFLink from '@salesforce/apex/LC_CaseAppointmentButtons.sendIVFLink';
import maleLabel from '@salesforce/label/c.IVFPartner';
import femaleLabel from '@salesforce/label/c.IVFPatientFemale';
import bothLabel from '@salesforce/label/c.IVFBoth';
import emailLabel from '@salesforce/label/c.IVFEmail';
import recipientBannerLabel from '@salesforce/label/c.IVFRecipientBanner';
import smsLabel from '@salesforce/label/c.IVFSMS';
import sendOptionChannelLabel from '@salesforce/label/c.IVFSendOptionBanner';
import modalTitle from '@salesforce/label/c.IVFModalTitle';
import modalSubmitBtn from '@salesforce/label/c.IVFModalSubmit';
import modalIVFRequiredDataError from '@salesforce/label/c.IVFRequiredDataError';

//import CaseId from '@salesforce/schema/Case.Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class IvfCaseModal extends LightningElement {
    @api showModal = false
    @api recordId;
    @track record;
    @track value = 'female';
    @track sendValue = 'email';


    label = {
        maleLabel,
        femaleLabel,
        modalTitle,
        modalSubmitBtn,
        recipientBannerLabel,
        sendOptionChannelLabel,
        modalIVFRequiredDataError
    };

    

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
          AccountId,FemaleEmail,FemalePhone,FemalePhone2,PartnerEmail,PartnerPhone
        ]
    })
    wiredCase({ error, data }) {
    if (data) {
        this.record = data;
    } else if (error) {
        this.error = `${this.error}
        ${error}`;
        this.record = undefined;
        }
    }

    get AccountId() {
        return this.record? getFieldValue(this.record, AccountId) :'';
    }
    get FemaleEmail() {
        return this.record? getFieldValue(this.record, FemaleEmail) :'';
    }
    get FemalePhone() {
        return this.record? getFieldValue(this.record, FemalePhone) :'';
    }
    get FemalePhone2() {
        return this.record? getFieldValue(this.record, FemalePhone2) :'';
    }
    get PartnerEmail() {
        return this.record? getFieldValue(this.record, PartnerEmail) :'';
    }
    get PartnerPhone() {
        return this.record? getFieldValue(this.record, PartnerPhone) :'';
    }
    
    get options() {
        return [
            { label: femaleLabel, value: 'female' },
            { label: maleLabel, value: 'partner' },
            { label: bothLabel, value: 'both' }
        ];
    }

    get sendOptions() {
        return [
            { label: emailLabel, value: 'email' },
            { label: smsLabel, value: 'sms' },
            { label: bothLabel, value: 'both' }
        ];
    }

    @api
    openModal() {
        this.showModal = true;
    }

    @api
    closeModal() {
        this.showModal = false;
    }

    submitModal() {
        if(this.value=='both'){
            if((this.isRequiredDataValid('female',this.sendValue)) && (this.isRequiredDataValid('partner',this.sendValue))){
                sendIVFLink({recipient: 'female',caseId: this.recordId ,sendOption: this.sendValue})
                sendIVFLink({recipient: 'partner',caseId: this.recordId ,sendOption: this.sendValue})
            }
        }else{
            if(this.isRequiredDataValid(this.value,this.sendValue)){
                sendIVFLink({recipient: this.value,caseId: this.recordId ,sendOption: this.sendValue})
            }
            
        }
        this.showModal = false;
    }

     isRequiredDataValid(recipient,sendValue){
        
        if(recipient=='partner'){
            if(sendValue=='sms'){
                if(this.PartnerPhone==null){
                    this.showNotification()
                    return false
                }
            }else if(sendValue=='email'){
                if(this.PartnerEmail==null){
                    this.showNotification()
                    return false
                }
            }else if(sendValue=='both'){
                if(this.PartnerPhone == null || this.PartnerEmail==null){
                    this.showNotification()
                    return false
                }
            }
        }else if(recipient=='female'){
            if(sendValue=='sms'){
                if(this.FemalePhone==null && this.FemalePhone2==null){
                    this.showNotification()
                    return false
                }
            }else if(sendValue=='email'){
                if(this.FemaleEmail==null){
                    this.showNotification()
                    return false
                }

            }else if(sendValue=='both'){
                if((this.FemaleEmail==null) || (this.FemalePhone==null && this.FemalePhone2==null)){
                    this.showNotification()
                    return false
                }
            }
        }

        return true
    }

    @api
    handleChange(event){
        this.value = event.target.value
    }

    @api
    handleChangeSendOption(event){
        this.sendValue = event.target.value
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: modalIVFRequiredDataError,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}