import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { labels } from './labels';

import getIframeData from '@salesforce/apex/PaymentIntegration.getIframeData';
import inquireTransaction from '@salesforce/apex/PaymentIntegration.inquireTransaction';
import getPaymentsAmount from '@salesforce/apex/PaymentIntegration.getAllowedPayments';
import sendGenericPayment from "@salesforce/apex/PaymentIntegration.sendGenericPayment";
import getClubMember from "@salesforce/apex/PaymentIntegration.getClubMember";

//import fields from record
import IDNumber from "@salesforce/schema/Appointment__c.IDNumber__c";
import Deductibles from "@salesforce/schema/Appointment__c.Deductibles__c";
import AccountId from '@salesforce/schema/Appointment__c.Patient_Account__c';
import Email from '@salesforce/schema/Appointment__c.Patient_Account__r.PersonEmail';
import PersonMailingStreet from '@salesforce/schema/Appointment__c.Patient_Account__r.PersonMailingStreet';
import PersonMailingCountry from '@salesforce/schema/Appointment__c.Patient_Account__r.PersonMailingCountry';
import PersonMailingCity  from '@salesforce/schema/Appointment__c.Patient_Account__r.PersonMailingCity';
import IsRoomReserv  from '@salesforce/schema/Appointment__c.Site__r.Room_reservation_fee_applicable__c';
import SelfPaymentAgreement  from '@salesforce/schema/Appointment__c.Agreement__r.self_payment__c';
import SelfPaymentArrangement  from '@salesforce/schema/Appointment__c.Doctor_arrangement__r.self_payment__c';
import PatientAgreement  from '@salesforce/schema/Appointment__c.Agreement__c';
import PatientArrangement  from '@salesforce/schema/Appointment__c.Doctor_arrangement__c';
import ActionDetails from '@salesforce/schema/Appointment__c.Medical_Procedure__r.details_of_Collection_action__c';
import MedicalProcedurePrice from '@salesforce/schema/Appointment__c.Medical_Procedure__r.MedicalProcedurePrice__c';
import AppointmentType from '@salesforce/schema/Appointment__c.RecordType.DeveloperName';
import CostOfPrivateRoom from '@salesforce/schema/Appointment__c.Cost_of_private_room__c';


export default class PaymentValidationModal extends LightningElement {
    @api showModal = false;
    @api appointmentId;
    @track iFrameUrl = '';
    @track country;
    @track city;
    @track street;
    @track email;
    @track record;
    @track remark;
    @track payAmount;
    @track numOfPayments= '1';
    @track cardExpDate;
    @track paymentOptionsMap=[];
    @track finalPaymentsMap = [];
    @track priceAfterDiscount;
    @track noteForDiscount;

    token = null;
    creditCompany = null;
    showIframe = false;
    showPrePayment = true;
    isPrePaymentValid = false
    showSpinner = false;
    spinnerOn = false;
    paymentsAmountLocked = false;
    payAmountLocked = true;
    cardId = null;
    error = null;
    paymentType = 'charge';
    isDone = false;
    isDiscount = false;
    isSurgeries = false

    label = labels

    get fullUrl() {
        return `${this.iFrameUrl}`
    }

    get options() {
        if(this.AppointmentType == 'Surgeries' && this.IsRoomReserv){
            return [
                { label: this.label.modalPaymentCharge, value: 'charge' },
                { label: this.label.modalPaymentDeposit, value: 'deposit' },
                { label: this.label.modalPaymentPrivateRoom, value: 'reservationFee' }
            ];  
        } else {
            return [
                { label: this.label.modalPaymentCharge, value: 'charge' },
                { label: this.label.modalPaymentDeposit, value: 'deposit' }
            ];
        }
    }

    get paymentOptions() {
        return this.finalPaymentsMap;
    }

    @wire(getRecord, {
        recordId: '$appointmentId', fields: [
            IDNumber,
            Deductibles,
            Email,
            PersonMailingStreet,
            PersonMailingCountry,
            PersonMailingCity,
            AccountId,
            SelfPaymentAgreement,
            IsRoomReserv,
            SelfPaymentArrangement,
            PatientAgreement,
            PatientArrangement,
            ActionDetails,
            AppointmentType,
            MedicalProcedurePrice,
            CostOfPrivateRoom
        ]
    })
    wiredAppointment({ error, data }) {
        if (data) {
            this.record = data;
            //this.payAmountLocked = this.AppointmentType !== 'Surgeries';
            this.isSurgeries = this.AppointmentType == 'Surgeries';
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    get IDNumber() {
        return this.record ? getFieldValue(this.record, IDNumber) : '';
    }
    get Deductibles() {
        if (this.paymentType == 'charge' || this.paymentType == 'reservationFee') {
            if (this.record) {
                switch (this.AppointmentType) {
                    case 'Experts':
                        if((getFieldValue(this.record, PatientAgreement)!=null && getFieldValue(this.record, PatientArrangement)!=null) || (getFieldValue(this.record, PatientAgreement)!=null && getFieldValue(this.record, PatientArrangement)==null)){
                            this.payAmount = this.SelfPaymentAgreement;
                            return this.SelfPaymentAgreement;
                        }else if(getFieldValue(this.record, PatientAgreement)==null && getFieldValue(this.record, PatientArrangement)!=null){
                            this.payAmount = this.SelfPaymentArrangement;
                            return this.SelfPaymentArrangement;
                        }
                        break;
                    case 'Institutes':                    
                    case 'Closedins':
                        this.payAmount = this.MedicalProcedurePrice;
                        return this.MedicalProcedurePrice
                    case 'Surgeries':
                        if(this.paymentType == 'reservationFee'){
                            return this.payAmount;
                        } else {
                            this.payAmount = this.CostOfPrivateRoom;
                            return this.CostOfPrivateRoom                            
                        }
                    default:
                        break;
                }
                
            }
        } else {
            return 0.01;
        }
    }

    get PatientEmail() {
        return this.record ? getFieldValue(this.record, Email) : '';
    }
    get PersonMailingStreet() {
        return this.record ? getFieldValue(this.record, PersonMailingStreet) : '';
    }
    get PersonMailingCountry() {
        return this.record ? getFieldValue(this.record, PersonMailingCountry) : '';
    }
    get PersonMailingCity() {
        return this.record ? getFieldValue(this.record, PersonMailingCity) : '';
    }
    get AccountId() {
        return this.record ? getFieldValue(this.record, AccountId) : '';
    }
    get SelfPaymentAgreement() {
        return this.record ? getFieldValue(this.record, SelfPaymentAgreement) : '';
    }
    get SelfPaymentArrangement() {
        return this.record ? getFieldValue(this.record, SelfPaymentArrangement) : '';
    }
    get ActionDetails() {
        return this.record ? getFieldValue(this.record, ActionDetails) : '';
    }
    get AppointmentType(){
        return this.record ? getFieldValue(this.record, AppointmentType) : '';
    }
    get IsRoomReserv(){
        return this.record ? getFieldValue(this.record, IsRoomReserv) : '';
    }
    get MedicalProcedurePrice(){
        return this.record ? getFieldValue(this.record, MedicalProcedurePrice) : '';
    }
    get CostOfPrivateRoom(){
        return this.record ? getFieldValue(this.record, CostOfPrivateRoom) : '';
    }

    get isSubmitButtonDisabled(){
        return this.spinnerOn || this.isDone;
    }
    
    @api
    openModal() {
        this.showModal = true;
        this.initPaymentsOptions()
    }

    @api
    closeModal() {
        this.showModal = false;
        this.iFrameUrl ='';
        this.showIframe = false;
        this.showPrePayment = true;
        this.isPrePaymentValid = false
        this.removeDataFromForm()
    }

    removeDataFromForm(){
        this.country = null;
        this.city = null;
        this.street = null;
        this.email = null;
        this.remark = null;
        this.payAmount = null;
        this.numOfPayments='1';
    }

    submitModal() {
        if(this.isDone){
            return;
        }
        if(this.showPrePayment){
            this.savePrePaymentDetails()
            if(this.isPrePaymentValid){
                this.getIframe();
                this.showIframe = true;
                this.showPrePayment = false
            }else{
                this.showNotification('Error', 'Submit required fields', 'error');
            }
        } else if(this.showIframe) {
            if(this.token != null) {
                this.inquireTransactionData();
            }
            //this.showSpinner=true;
        }
    }

    inquireTransactionData(){
        this.spinnerOn = true;
        inquireTransaction({
            token:this.token}).then(res =>{
            if (res) {
                if(res['done']){
                    this.cardId = res['cardId']
                    this.cardExpDate = res['cardExpiration']
                    this.creditCompany = res['creditCompany']
                    this.triggerSendGenericPayment()
                    //alert(res['message'])
                }else{
                    if(res['result']=='686'){
                        this.showNotification('Error',this.label.modalPaymentFillDataError,'error');
                    }else{
                        this.showNotification('Error',res['message'],'error');
                    }
                    this.spinnerOn = false;
                }
            }else{
                this.showNotification('Error','Unexpected Error','error');
            }
            })
            .catch(error => {
                this.showNotification('Error',error,'error');
        });
    }

    triggerSendGenericPayment(){
        sendGenericPayment({
            SFId: this.appointmentId,
            token: this.cardId,
            creditCardTypeCode: this.creditCompany,
            amountOfPayments: this.numOfPayments,
            address: this.street,
            remark: this.ActionDetails,
            email: this.email,
            payAmount: this.payAmount,
            cardExpDate: this.cardExpDate,
            accId: this.AccountId,
            city: this.city,
            payType: this.paymentType,
            appointmentType: this.AppointmentType
        })
        .then(res =>{
            if (res) {
                if(res['ResultStatus']==='1'){
                    this.showNotification('Error',this.label.modalPaymentError,'error');
                    this.spinnerOn = false;
                    
                }else{
                    this.showNotification('Success',this.label.modalPaymentSuccess,'success');
                    this.spinnerOn = false;
                    this.isDone=true;
                    
                }
            }else{
                this.showNotification('Error',this.label.modalPaymentError,'error');
                this.spinnerOn = false;
            }
            setTimeout(() => {
                this.closeModal() 
                }, 3000)
        })
        .catch(error => {
            this.spinnerOn = false;
            this.showNotification('Error',error,'error');            
        });
    }

    getIframe() {
        getIframeData()
        .then(res => {
            if (res) {
                this.iFrameUrl = res['iframe']
                this.token = res['token']
            }else{
              
            }
            
            this.iFrameUrl = res.get('iframe')
        })
        .catch(error => {
            this.error = error;
            this.message = undefined;
            this.loaded = true;
            
        });
    }

    @api
    handleChange(event){
        //this.value
        //this.value = event.target.value
    }

    onCountryChange(event){
        this.country = event.detail.value;
    }

    onCityChange(event){
        this.city = event.detail.value;
    }

    onStreetChange(event){
        this.street = event.detail.value;
    }

    onEmailChange(event){
        this.email = event.detail.value;
    }

    onAmountChange(event){
        this.payAmount = event.detail.value;
        if(this.payAmount != null){
            this.paymentsAmountLocked = false
            this.calculatePaymentsAmount()
        }
    }

    onNumOfPaymentsChange(event){
        this.numOfPayments = event.detail.value;
    }

    onPaymentTypeChanged(event) {
        this.paymentType = event.detail.value
        if (event.detail.value=='deposit') {
            //this.payAmountLocked = true
            this.paymentsAmountLocked = true
            this.numOfPayments = 1
            this.payAmount = 0.01
            this.isDiscount = false
        } else if(event.detail.value=='charge') {
            //this.payAmountLocked = false
            this.paymentsAmountLocked = false
            this.isDiscount = true
        } else if(event.detail.value=='reservationFee'){
            this.paymentsAmountLocked = true
            this.numOfPayments = 1
            this.payAmount = 200
            this.isDiscount = false
        }
    }

    onEmailAutoFill(event) {
        if(event.detail.checked) {
            this.email = this.PatientEmail
        } else {
            this.email =null
        }
    }

    onAddressAutoFill(event) {
       if (event.detail.checked) {
          this.country = this.PersonMailingCountry
          this.city = this.PersonMailingCity 
          this.street = this.PersonMailingStreet
        } else {
            this.country = null
            this.city = null
            this.street = null
        }
    }
    onRemarkChange(event){
        //this.remark = event.detail.value; // commented because of CRM Request
    }

    initPaymentsOptions() {
        this.spinnerOn = true;
        if (this.AppointmentType == 'Institutes' || this.AppointmentType == 'Closedins') {
            getClubMember({appId: this.appointmentId })
            .then(res => {
                if (res) {
                    this.isDiscount = res.isDiscount;
                    this.noteForDiscount = res.NoteForDiscount;
                    this.priceAfterDiscount = res.PriceAfterDiscount; 
                    this.payAmount = res.PriceAfterDiscount;               
                }
            })
            .catch(error => {
                this.showNotification('Error','Error on attempt to retrive Club Member fields', error);
            });  
        }       
        
        getPaymentsAmount().then(res => {
            if (res) {
                this.paymentOptionsMap = res
                this.calculatePaymentsAmount();
                this.spinnerOn = false;
            }
        })
        .catch(error => {
            this.showNotification('Error','Error on attempt to retrive payments amount', error);
        });  

    }

    savePrePaymentDetails() {
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isInputsCorrect) {
            this.isPrePaymentValid = true
            if (this.isDiscount) {
                this.payAmount = this.priceAfterDiscount;
            }
            /*var input = this.template.querySelectorAll(".preLoaded");
            input.forEach(function(element) {
                //if (this.AppointmentType == 'Institutes' || this.AppointmentType == 'Closedins')
                if (element.name=='amount') {
                    this.payAmount = element.value;
                }
                else if (element.name=='numOfPayments') {
                    this.numOfPayments = element.value;
                }
            }, this);*/
        }
    }

    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    calculatePaymentsAmount() {
        var myMap = this.paymentOptionsMap;
        var paymentOptionsFinalMap = []
        var numOfPayments = 3
        var max = 0
        for (var key in myMap) {
            if ((parseInt(this.payAmount) >= parseInt(key)) && (parseInt(key)>max)) {
                numOfPayments = myMap[key]
                max = parseInt(key)
            }

        }
        for (let i = 1; i < numOfPayments + 1; i++) {
            paymentOptionsFinalMap.push({label:i.toString(), value:i.toString()});
        }
        this.finalPaymentsMap = paymentOptionsFinalMap
    }

}