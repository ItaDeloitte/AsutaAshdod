/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
/* eslint-disable no-eval */
/* eslint-disable no-debugger */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import GetPricesFromApp from  '@salesforce/apex/ws_getPrices_REST.getPricesFromAppointment';
import RecordType from '@salesforce/schema/Appointment__c.RecordType.Name';
import DateOfApp from '@salesforce/schema/Appointment__c.Date_of_appointment__c';
import PayerFactorParent from '@salesforce/schema/Appointment__c.PayerFactor__r.Code_Parent_for_Interface__c';
import PayerFactorCode from '@salesforce/schema/Appointment__c.PayerFactor__r.InsuranceCode__c';
import DoctorCode from '@salesforce/schema/Appointment__c.Doctor_Account__r.Doctor_Code__c';
import MedicalProcedure from '@salesforce/schema/Appointment__c.Medical_Procedure__r.Procedure_Code__c';
import MedicalProcedure1 from '@salesforce/schema/Appointment__c.Medical_Procedure2__r.Procedure_Code__c';
import MedicalProcedure2 from '@salesforce/schema/Appointment__c.Medical_Procedure3__r.Procedure_Code__c';
import MedicalProcedure3 from '@salesforce/schema/Appointment__c.Medical_Procedure4__r.Procedure_Code__c';
import Anesthetist from '@salesforce/schema/Appointment__c.Medical_Procedure4__r.Category_for_anesthetist__c';
import Site from '@salesforce/schema/Appointment__c.Site__r.Site_Code__c';
import getPricesBtn from '@salesforce/label/c.GetPricesBtn';


export default class GetPricesFromAppointment extends LightningElement {

    @api appointmentId;
    @track loaded = true;    
    @track record;
    @track isSurgeryApp = false;

    label = {
        getPricesBtn
    };

    @wire(getRecord, {
        recordId: '$appointmentId', fields: [RecordType, DateOfApp, PayerFactorParent, DoctorCode, PayerFactorCode, MedicalProcedure, Site, MedicalProcedure1, MedicalProcedure2, 
                                            MedicalProcedure3, Anesthetist]
    })
    wiredAppointment({ error, data }) {
        if (data) {
            this.record = data;
            if (this.reqType === 'ניתוח') {
                this.isSurgeryApp = true;
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    get reqType() {
        return this.record ? getFieldValue(this.record, RecordType) : '';
    }
    get dateOfApp() {
        return this.record ? getFieldValue(this.record, DateOfApp) : '';
    }
    get payerFactorParent() {
        return this.record ? getFieldValue(this.record, PayerFactorParent) : '';
    }
    get doctorCode() {
        return this.record ? getFieldValue(this.record, DoctorCode) : '';
    }
    get payerFactorCode() {
        return this.record ? getFieldValue(this.record, PayerFactorCode) : '';
    }
    get medProcCode() {
        return this.record ? getFieldValue(this.record, MedicalProcedure) : '';
    }
    get medProcCode1() {
        return this.record ? getFieldValue(this.record, MedicalProcedure1) : '';
    }
    get medProcCode2() {
        return this.record ? getFieldValue(this.record, MedicalProcedure2) : '';
    }
    get medProcCode3() {
        return this.record ? getFieldValue(this.record, MedicalProcedure3) : '';
    }
    get site() {
        return this.record ? getFieldValue(this.record, Site) : '';
    }
    get anesthetist() {
        return this.record ? getFieldValue(this.record, Anesthetist) : '';
    }

    getPrices(){
        this.loaded = false;
        let medProc1JSON = this.medProcCode1 != null ? `,"activityCode_2": "${this.medProcCode1}"` : '';
        let medProc2JSON = this.medProcCode2 != null ? `,"activityCode_3": "${this.medProcCode2}"` : '';
        let medProc3JSON = this.medProcCode3 != null ? `,"activityCode_4": "${this.medProcCode3}"` : '';
        let anesthetist = this.anesthetist != null ? `,"anesthetist": "${this.anesthetist}"` : '';
        let date = new Date();
        let formatedDate = this.toSFDate(date);
        let dateApp = this.dateOfApp != null ? this.dateOfApp : formatedDate;
        let jsonStr = `{"Guid": "${this.appointmentId}",
                "siteCode" : "${this.site}",
                "payerFactorParent" : "${this.payerFactorParent}",
                "payerFactorCode" : "${this.payerFactorCode}",
                "doctorCode" : "${this.doctorCode}",
                "activityDate" : "${dateApp}",                
                "activityCode_1" : "${this.medProcCode}"
                ${anesthetist}${medProc1JSON}${medProc2JSON}${medProc3JSON}}`;

        console.log(`JSON input ${JSON.parse(JSON.stringify(jsonStr))}`);
        GetPricesFromApp({jsonInput: JSON.parse(JSON.stringify(jsonStr))})
        .then (res => {
            console.log(`res ${res}`)            
            setTimeout(() => {
                eval("$A.get('e.force:refreshView').fire();");
                this.loaded = true;
            }, 5000);
        })
        .catch (error => {
            console.log(`error ${error}`)
            this.loaded = true;
        })
    }

    toSFDate(dateObj) {// string format is YYYY-MM-DD         
        var dateStr = `${dateObj.getFullYear()}-${this.pad2(dateObj.getMonth()+1)}-${this.pad2(dateObj.getDate())}`;
        return dateStr;
    }

    pad2(number) {
	    return (number < 10 ? '0' : '') + number;
    }

}