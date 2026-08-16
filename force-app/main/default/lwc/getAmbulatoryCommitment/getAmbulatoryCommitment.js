import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAmbulatoryCommitment from '@salesforce/apex/ws_getAmbulatoryCommitmentREST.getAmbulatoryCommitment';

import RecordType from '@salesforce/schema/Appointment__c.RecordType.Name';
import IdType from '@salesforce/schema/Appointment__c.Patient_Account__r.ID_Type__c';
import IdNumber from '@salesforce/schema/Appointment__c.IdNumberForMaccabi__c';
import PatientAccount from '@salesforce/schema/Appointment__c.Patient_Account__c';
import CommitStatus from '@salesforce/schema/Appointment__c.Commitment_Status__c';
import CommitNumber from '@salesforce/schema/Appointment__c.Number_of_commitment__c';
import AppointmentDate from '@salesforce/schema/Appointment__c.Appointment_Date__c';
import PayerFactorCode from '@salesforce/schema/Appointment__c.PayerFactor__r.Code_Parent_for_Interface__c';
import ProcedureCode from '@salesforce/schema/Appointment__c.Medical_Procedure__r.Procedure_Code__c';
import MabarCode from '@salesforce/schema/Appointment__c.Medical_Procedure__r.Mabar_Code__c';
import SiteCode from '@salesforce/schema/Appointment__c.Site__r.Site_Code__c';

import btnCommitmentTitle from '@salesforce/label/c.MaccabiBtnTitle';
import payAttantionWarning from '@salesforce/label/c.PayAttantionWarning';
import CommitmentSuccess from '@salesforce/label/c.MaccabiGetAmbulatoryCommitmentS';
import CommitmentFailed from '@salesforce/label/c.MaccabiGetAmbulatoryCommitmentFailed';

export default class GetAmbulatoryCommitment extends LightningElement {

    @api appointmentId;
    @track record;
    @track error;
    @track res;
    @track message;
    @track isMaccabiAmbuComm = false;
    @track loaded = true;

    label = {
        btnCommitmentTitle,
        payAttantionWarning,
        CommitmentSuccess,
        CommitmentFailed
    };
   
    @wire(getRecord, {
        recordId: '$appointmentId', fields: [RecordType, IdNumber, IdType, PatientAccount, CommitStatus, 
                CommitNumber, PayerFactorCode, ProcedureCode, MabarCode, AppointmentDate, SiteCode]
    })

    wiredAppointment({ error, data }) {
        if (data) {
            this.record = data;
            if (this.PayerFactorCode === '3' && this.reqType === 'בדיקה' && (this.CommitStatus === 'E' || this.CommitStatus === '22' || this.CommitStatus === null)) {
                this.isMaccabiAmbuComm = true;
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    get reqType() {
        return this.record ? getFieldValue(this.record, RecordType) : '';
    }
    get IdNumber() {
        return this.record ? getFieldValue(this.record, IdNumber) : '';
    }
    get isTZ() {
        if (this.record)
            return getFieldValue(this.record, IdType) === '1' ? true : false;
        return false
    }
    get PatientId() {
        return this.record ? getFieldValue(this.record, PatientId) : '';
    }
    get IdType() {
        return this.record ? getFieldValue(this.record, IdType) === '9' ? '9' : '0' : '';
    }
    get CommitStatus() {
        return this.record ? getFieldValue(this.record, CommitStatus) : '';
    }
    get CommitNumber() {
        return this.record ? getFieldValue(this.record, CommitNumber) : '';
    }
    get AppointmentDate() {
        return this.record ? getFieldValue(this.record, AppointmentDate) : '';
    }
    get PayerFactorCode() {
        return this.record ? getFieldValue(this.record, PayerFactorCode) : '';
    }
    get ProcedureCode() {
        if (this.record)
            return getFieldValue(this.record, MabarCode) ? getFieldValue(this.record, MabarCode) : getFieldValue(this.record, ProcedureCode);
        return '';
    }
    get SiteCode() {
        return this.record ? getFieldValue(this.record, SiteCode) : '';
    }
   
    async getCommitment() {
        this.loaded = false;
        await getAmbulatoryCommitment({
            appId: this.appointmentId,
            patientAccId: this.PatientAccount,
            memberId: this.IdNumber,
            memberIdCode: this.IdType,
            procedureCode: this.ProcedureCode,
            appointmentDate: this.AppointmentDate,
            siteCode:this.SiteCode
        })
        .then(res => {
            this.loaded = true;
            getRecordNotifyChange([{recordId: this.appointmentId}]);
            if(this.CommitNumber != null && this.CommitStatus == '0'){
                this.ShowToastMessage('', this.label.CommitmentSuccess, 'success', 'pester');
            }else{
                this.ShowToastMessage(this.label.payAttantionWarning, this.label.CommitmentFailed, 'warning', 'sticky');
            }
        })
        .catch(error => {
            this.error = error;
            this.message = undefined;
            this.loaded = true;
        });
    }

    ShowToastMessage(titlem, message, variant, mode) {
        const toastEvnt = new ShowToastEvent({
            title: titlem,
            message: message,
            variant: variant,
            mode: mode,
        });
        this.dispatchEvent(toastEvnt);
    }
}