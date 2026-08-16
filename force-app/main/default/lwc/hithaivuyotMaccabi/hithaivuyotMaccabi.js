/* eslint-disable no-console */
/* eslint-disable no-eval */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-debugger */

import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import RetrievingServiceReferrals from '@salesforce/apex/MaccabiIntegration.retrievingServiceReferrals';
import RetrievingCommitmentRED from '@salesforce/apex/MaccabiIntegration.retrieveServiceRefRED';
import RetrievingCommitmentGREEN from '@salesforce/apex/MaccabiIntegration.getCommitmentGreenWay';
import GetMedProcedureMap from '@salesforce/apex/UtilGetObjectData.getMedProcedureMap';

import RecordType from '@salesforce/schema/Appointment__c.RecordType.Name';
import IDNumber from '@salesforce/schema/Appointment__c.IdNumberForMaccabi__c';
import IDType from '@salesforce/schema/Appointment__c.ID_Type__c';
import RefStatus from '@salesforce/schema/Appointment__c.Referral_Status_Maccabi__c';
import ReferralNumber from '@salesforce/schema/Appointment__c.Number_of_referral__c';
import PayerFactorId from '@salesforce/schema/Appointment__c.PayerFactor__c';
import CommitStatus from '@salesforce/schema/Appointment__c.Commitment_Status__c';
import PayerFactor from '@salesforce/schema/Appointment__c.PayerFactor__r.Code_Parent_for_Interface__c';
import PayerFactorCode from '@salesforce/schema/Appointment__c.PayerFactor__r.InsuranceCode__c';
import Classification from '@salesforce/schema/Appointment__c.Classification__c';
import CreatedDate from '@salesforce/schema/Appointment__c.CreatedDate';
import PatientAccount from '@salesforce/schema/Appointment__c.Patient_Account__c';
import PatientAccNum from '@salesforce/schema/Appointment__c.Patient_Account__r.ID_Number__c';
import DoctorAccName from '@salesforce/schema/Appointment__c.Doctor_Account__r.Name';
import DoctorAccNum from '@salesforce/schema/Appointment__c.Doctor_Account__r.DocIDNum__c';
import DoctorCode from '@salesforce/schema/Appointment__c.Doctor_Account__r.Doctor_Code_Seven__c';
import MedicalProcedure from '@salesforce/schema/Appointment__c.Medical_Procedure__c';
import MedicalProcedure1 from '@salesforce/schema/Appointment__c.Medical_Procedure2__c';
import MedicalProcedure2 from '@salesforce/schema/Appointment__c.Medical_Procedure3__c';
import MedicalProcedure3 from '@salesforce/schema/Appointment__c.Medical_Procedure4__c';
import DomainCode from '@salesforce/schema/Appointment__c.Medical_Procedure__r.Domain__r.DomainCode__c';
import Site from '@salesforce/schema/Appointment__c.Site__r.Maccabi_Code__c';
import MaccabiGuid from '@salesforce/schema/Appointment__c.GuidForMaccabi__c';

import gtCommitment from '@salesforce/label/c.MaccabiGetCommitment';
import getRefferal from '@salesforce/label/c.MaccabiGetRefferal';
import btnTitle from '@salesforce/label/c.MaccabiBtnTitle';
import status1 from '@salesforce/label/c.MaccabiRefStatus_1';
import status2 from '@salesforce/label/c.MaccabiRefStatus_2';
import status3 from '@salesforce/label/c.MaccabiRefStatus_3';
import status4 from '@salesforce/label/c.MaccabiRefStatus_4';
import status5 from '@salesforce/label/c.MaccabiRefStatus_5';
import status6 from '@salesforce/label/c.MaccabiRefStatus_6';
import status7 from '@salesforce/label/c.MaccabiRefStatus_7';
import status9 from '@salesforce/label/c.MaccabiRefStatus_9';
import status0 from '@salesforce/label/c.MaccabiRefStatus_0';
import statusOther from '@salesforce/label/c.MaccabiRefStatus_error';
import statusNoTz from '@salesforce/label/c.MaccabiRefStatus_notTZ';
import payAttantion from '@salesforce/label/c.PayAttantion';
import payAttantionWarning from '@salesforce/label/c.PayAttantionWarning';
import referralsRecieved from '@salesforce/label/c.MaccabiRefRecieved';



export default class HithaivuyotMaccabi extends LightningElement {
    @api appointmentId;
    @track record;
    @track error;
    @track res;
    @track message;
    @track isMaccabiRef = false;
    @track isMaccabiComm = false;
    @track loaded = true;
    codeConversionArr = [];
    isThisIteration = false;
    isButtonClicked = false;

    label = {
        btnTitle,
        status1,
        status2,
        status3,
        status4,
        status5,
        status6,
        status7,
        status9,
        status0,
        statusOther,
        statusNoTz,
        gtCommitment,
        payAttantion,
        payAttantionWarning,
        getRefferal,
        referralsRecieved
    };

    @wire(getRecord, {
        recordId: '$appointmentId', fields: [RecordType, IDNumber, IDType, RefStatus, PayerFactorId, PayerFactorCode, CommitStatus, PayerFactor, Classification,
            CreatedDate, PatientAccount, PatientAccNum, DoctorAccName, DoctorAccNum, DoctorCode, MedicalProcedure, Site,
            MedicalProcedure1, MedicalProcedure2, MedicalProcedure3, ReferralNumber, DomainCode, MaccabiGuid]
    })
    wiredAppointment({ error, data }) {
        if (data && !this.isThisIteration) {
            this.isThisIteration = true;
            this.record = data; debugger
            if (this.PayerFactor === '3' && this.reqType === 'ניתוח') {
                this.getCalloutStatus();
                this.getCodeConversionArr();
            }
        } else if (error && !this.isThisIteration) {
            this.isThisIteration = true;
            this.error = error;
            this.record = undefined;
        }
    }


    get reqType() {
        return this.record ? getFieldValue(this.record, RecordType) : '';
    }
    get IDNumber() {
        return this.record ? getFieldValue(this.record, IDNumber) : '';
    }
    get PayerFactor() {
        return this.record ? getFieldValue(this.record, PayerFactor) : '';
    }
    get PayerFactorCode() {
        return this.record ? getFieldValue(this.record, PayerFactorCode) : '';
    }
    get RefStatus() {
        return this.record ? getFieldValue(this.record, RefStatus) : '';
    }
    get CommitStatus() {
        return this.record ? getFieldValue(this.record, CommitStatus) : '';
    }
    get IDType() {
        return this.record ? getFieldValue(this.record, IDType) == 'דרכון' ? '9' : '0' : '';
    }
    get isTZ() {
        if (this.record)
            return getFieldValue(this.record, IDType) === 'תעודת זהות' ? true : false;
        return false
    }
    get Classification() {
        return this.record ? getFieldValue(this.record, Classification) : '';
    }
    get CreatedDate() {
        return this.record ? getFieldValue(this.record, CreatedDate) : '';
    }
    get PayerFactorId() {
        return this.record ? getFieldValue(this.record, PayerFactorId) : '';
    }
    get PatientAccount() {
        return this.record ? getFieldValue(this.record, PatientAccount) : '';
    }
    get PatientAccNum() {
        return this.record ? getFieldValue(this.record, PatientAccNum) : '';
    }
    get DoctorAccName() {
        return this.record ? getFieldValue(this.record, DoctorAccName) : '';
    }
    get DoctorAccNum() {
        return this.record ? getFieldValue(this.record, DoctorAccNum) : '';
    }
    get DoctorCode() {
        return this.record ? getFieldValue(this.record, DoctorCode) : '';
    }
    get MedicalProcedure() {
        return this.record ? getFieldValue(this.record, MedicalProcedure) : '';
    }
    get MedicalProcedure1() {
        return this.record ? getFieldValue(this.record, MedicalProcedure1) : '';
    }
    get MedicalProcedure2() {
        return this.record ? getFieldValue(this.record, MedicalProcedure2) : '';
    }
    get MedicalProcedure3() {
        return this.record ? getFieldValue(this.record, MedicalProcedure3) : '';
    }
    get Site() {
        return this.record ? getFieldValue(this.record, Site) : '';
    }
    get ReferralNumber() {
        return this.record ? getFieldValue(this.record, ReferralNumber) : '';
    }
    get DomainCode() {
        return this.record ? getFieldValue(this.record, DomainCode) : '';
    }
    get MaccabiGuid() {
        return this.record ? getFieldValue(this.record, MaccabiGuid) : '';
    }



    getCodeConversionArr() {
        let codeConvArr = [];
        if (this.MedicalProcedure !== undefined && this.MedicalProcedure !== null && !codeConvArr.includes(this.MedicalProcedure)) {
            codeConvArr.push(this.MedicalProcedure);
        }
        if (this.MedicalProcedure1 !== undefined && this.MedicalProcedure1 !== null && !codeConvArr.includes(this.MedicalProcedure1)) {
            codeConvArr.push(this.MedicalProcedure1);
        }
        if (this.MedicalProcedure2 !== undefined && this.MedicalProcedure2 !== null && !codeConvArr.includes(this.MedicalProcedure2)) {
            codeConvArr.push(this.MedicalProcedure2);
        }
        if (this.MedicalProcedure3 !== undefined && this.MedicalProcedure3 !== null && !codeConvArr.includes(this.MedicalProcedure3)) {
            codeConvArr.push(this.MedicalProcedure3);
        }
        if (codeConvArr.length > 0) {
            this.apexCallGetMedProcedureMap(codeConvArr);
        }

    }

    apexCallGetMedProcedureMap(codeConvArr) {
        GetMedProcedureMap({ ids: codeConvArr })
        .then(res => {
            for(let id of codeConvArr) {
                if (res[id]) {
                    this.codeConversionArr.push(res[id].Procedure_Code__c);
                }
            }
        })
        .catch(err => {
            this.error = `${this.error}
        ${err}`;
        });
    }

    getReferralsHithaivuyot() {
        this.loaded = false;
        this.isButtonClicked = true
        RetrievingServiceReferrals({
            appId: this.appointmentId,
            memberID: this.IDNumber,
            memberIDCode: this.IDType,
            payerFactor: this.PayerFactorId,
            patientAcc: this.PatientAccount,
            servProviderID: this.Site,
            doctorLicense: this.DoctorCode,
            medicalProcedure: this.DomainCode
        }) // Only patients that is residence of Israel can get maccabi automated services
            // eslint-disable-next-line no-unused-vars
            .then(res => {
                this.getCalloutStatus();
                this.loaded = true;
            })
            .catch(error => {
                this.error = error;
                this.message = undefined;
                this.loaded = true;
            });
    }

    getHithaivuyot() {
        this.loaded = false;
        if (this.Classification === 'אדום') {
            console.log('The RED way');
            RetrievingCommitmentRED({
                appId: this.appointmentId,
                memberID: this.IDNumber,
                memberIDCode: this.IDType,
                doctorId: this.DoctorAccNum,
                doctorName: this.DoctorAccName,
                medProId: this.MedicalProcedure,
                patAccount: this.PatientAccount,
                servProviderID: this.Site,
                guid: this.MaccabiGuid
            })
                // eslint-disable-next-line no-unused-vars
                .then(res => {
                    this.checkStatus();
                    this.loaded = true;
                })
                .catch(err => {
                    this.error = err;
                    this.message = undefined;
                    this.loaded = true;
                });
        } else if (this.Classification === 'ירוק' || this.Classification === 'כתום') {
            console.log('The GREEN way');
            this.codeConversionArr = [...new Set(this.codeConversionArr)];
            RetrievingCommitmentGREEN({
                patientAccID: this.PatientAccount,
                refType: this.Classification === 'ירוק' ? 'ביצוע פעולה' : 'חיוב ישיר',
                memberID: this.IDNumber,
                memberIDCode: this.IDType,
                appID: this.appointmentId,
                payerFactor: this.PayerFactorCode,
                codeConversionArr: this.codeConversionArr,
                doctorIdNum: this.DoctorAccNum,
                doctorName: this.DoctorAccName,
                referralNumber: this.ReferralNumber,
                dateTreatmen: this.getDate(),
                servProviderID: this.Site
            })
            .then(result => {
                this.checkStatus();                
                this.loaded = true;
                console.log(`result:${result}`);
            })
            .catch(error => {
                this.error = error;
                this.message = undefined;
                this.loaded = true;
            });
        }

    }

    setError(errName, status) {
        if (status && status !== '0') {
            this.res = status.trim();
            if (this.res === '1') {
                this.error = `${errName} ${this.label.status1}`;
            } else if (this.res === '2') {
                this.error = `${errName} ${this.label.status2}`;
            } else if (this.res === '3') {
                this.error = `${errName} ${this.label.status3}`;
            } else if (this.res === '4') {
                this.error = `${errName} ${this.label.status4}`;
            } else if (this.res === '5') {
                this.error = `${errName} ${this.label.status5}`;
            } else if (this.res === '6') {
                this.error = `${errName} ${this.label.status6}`;
            } else if (this.res === '7') {
                this.error = `${errName} ${this.label.status7}`;
            } else if (this.res === '9') {
                this.error = `${errName} ${this.label.status9}`;
            } else {
                this.error = `${errName} ${this.label.status0}`;
            }
        } else if (status != null && status !== '') {
            this.res = status.trim();
        }
    }

    //connectedCallback
    getCalloutStatus() {
        this.error = undefined;
        this.message = undefined;
       
        if (this.isNeedToReload()) {
            setTimeout(() => {
                if (window.location.toString().includes('/Appointment__c') && this.RefStatus === null) {
                    eval("$A.get('e.force:refreshView').fire();");
                }
                setTimeout(() => {
                    this.checkStatus();
                }, 1000);
            }, 6000);
        } else if (this.RefStatus !== '0') {
            this.isMaccabiRef = true;
            
        } 

        if ((this.RefStatus !== '3' && this.CommitStatus !== '6' && this.CommitStatus !== '1b' && this.CommitStatus !== null) || (this.RefStatus !== '3' && this.Classification=='אדום' && this.CommitStatus==null)) {//recived referrals but not commitment
                    this.isMaccabiComm = true; //the option to get commitment ons again     
        }                
    }

    checkStatus(){
        if (this.RefStatus === '0' && this.CommitStatus === '0') { //recived referrals and commitment
            this.message = `${this.label.getRefferal}: ${this.label.referralsRecieved}
            ${this.label.gtCommitment}: תקין`;
            this.ShowToastMessage('', this.message, 'success', 'pester');
        }
        if (this.RefStatus !== null && this.RefStatus !== '0') { //there is no referrals
            this.setError(`${this.label.getRefferal}: `, this.RefStatus);
            this.isMaccabiRef = true;
            this.ShowToastMessage(this.label.PayAttantion, this.error, 'error', 'sticky')
        }
        if (this.RefStatus !== '3' && this.CommitStatus !== '6' && this.CommitStatus !== '1b' && this.CommitStatus !== null) {//recived referrals but not commitment
            this.isMaccabiComm = true; //the option to get commitment ons again
            this.message = `${this.label.getRefferal}: ${this.label.referralsRecieved}`;
            this.setError(`${this.label.gtCommitment}: `, this.CommitStatus);
            this.ShowToastMessage(this.label.payAttantionWarning, `${this.error}
                                                ${this.message}`, 'warning', 'sticky')
        }
        if (this.RefStatus === '0' && this.CommitStatus !== '0' && this.CommitStatus !== null && this.Classification === 'כתום') {//recived referrals but not commitment
            this.setError(`${this.label.gtCommitment}: `, this.CommitStatus);
            this.ShowToastMessage(this.label.payAttantionWarning, `${this.message}`, 'warning', 'sticky')
        }
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

    isNeedToReload() {
        var dd = new Date(this.CreatedDate);
        var d = new Date();
        if ((d.getTime() - dd.getTime()) / 60000 > 1) { // if more than 1 minutes - return false
            return false
        }
        return true
    }

    getDate() {
        var today = new Date();
        var day = new Date(today.getFullYear() - 2, today.getMonth() + 22, today.getDate() + 66);
        return `${day.getDate() < 10 ? '0' : ''}${day.getDate()}${day.getMonth() + 1 < 10 ? '0' : ''}${day.getMonth() + 1}${day.getFullYear()}`;
    }

}