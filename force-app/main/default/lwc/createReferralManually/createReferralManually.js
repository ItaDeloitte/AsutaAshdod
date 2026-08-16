/* eslint-disable no-console */
/* eslint-disable no-debugger */
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, createRecord } from 'lightning/uiRecordApi';

import GetRecTypeID from '@salesforce/apex/UtilGetObjectData.getRecordType';

import RecType from '@salesforce/schema/Appointment__c.RecordType.DeveloperName';
import MedicalProc from '@salesforce/schema/Appointment__c.Medical_Procedure__c';
import MedicalProc2 from '@salesforce/schema/Appointment__c.Medical_Procedure2__c';
import MedicalProc3 from '@salesforce/schema/Appointment__c.Medical_Procedure3__c';
import MedicalProc4 from '@salesforce/schema/Appointment__c.Medical_Procedure4__c';
import PatientAcc from '@salesforce/schema/Appointment__c.Patient_Account__c';
import PatientAccNum from '@salesforce/schema/Appointment__c.Patient_Account__r.ID_Number__c';
import DoctorAcc from '@salesforce/schema/Appointment__c.Doctor_Account__c';
import DoctorAccNum from '@salesforce/schema/Appointment__c.Doctor_Account__r.DocIDNum__c';
import PayerFactor from '@salesforce/schema/Appointment__c.PayerFactor__c';
import CaseID from '@salesforce/schema/Appointment__c.Case__c';
import SiteID from '@salesforce/schema/Appointment__c.Site__c';
import RefStatusMaccabi from '@salesforce/schema/Appointment__c.Referral_Status_Maccabi__c';
import PayerFactorParent from '@salesforce/schema/Appointment__c.PayerFactor__r.Code_Parent_for_Interface__c';

import FILE_OBJ from '@salesforce/schema/File__c';
import RecTypeID_File from '@salesforce/schema/File__c.RecordTypeId';
import AccountID_File from '@salesforce/schema/File__c.Account__c';
import DoctorID_File from '@salesforce/schema/File__c.DoctorName__c';
import MedProcedure_File from '@salesforce/schema/File__c.Medical_Procedure__c';
import MedProcedure1_File from '@salesforce/schema/File__c.Medical_Procedure2__c';
import MedProcedure2_File from '@salesforce/schema/File__c.Medical_Procedure3__c';
import MedProcedure3_File from '@salesforce/schema/File__c.Medical_Procedure4__c';
import AppointmenID_File from '@salesforce/schema/File__c.Appointment__c';
import CaseID_File from '@salesforce/schema/File__c.Case__c';
import PayerFactor_File from '@salesforce/schema/File__c.PayerFactor__c';
import SiteID_File from '@salesforce/schema/File__c.Site__c';
import StatusRefManual_File from '@salesforce/schema/File__c.StatusRefManualToMaccabi__c';
import IsRequestManually_File from '@salesforce/schema/File__c.Request_Manually__c';



import CreateReflManualBtn from '@salesforce/label/c.MaccabiCreateReflManualBtn';

export default class CreateReferralManually extends NavigationMixin(LightningElement) {

    @api appointmentId;
    @track record;
    @track isRefManual = false;
    @track codeConversionArr= [];
    @track servProviderID = '';
    @track siteList;
    @track loaded = true;
    @track error;
    @track message;
    @track fileId;

    label = {
        CreateReflManualBtn
    };

    @wire(getRecord, {recordId: '$appointmentId', fields: [RecType, MedicalProc, MedicalProc2, MedicalProc3, MedicalProc4, PatientAcc, DoctorAcc, DoctorAccNum,
                                                    PayerFactor, CaseID, SiteID, RefStatusMaccabi, PatientAccNum, PayerFactorParent]})
    wiredAppointment({ error, data }) {
        if (data) {
            this.record = data; 
            if(this.RecType === 'Surgeries' && this.PayerFactorParent === '3'){
                this.isRefManual = true;
            }
        } else if (error) {
            this.error = `${this.error}
            ${error}`;
            this.record = undefined;
        }
    }

    get PatientAcc() {
        return this.record? getFieldValue(this.record, PatientAcc) :'';
    }
    get PatientAccNum() {
        return this.record? getFieldValue(this.record, PatientAccNum) :'';
    }
    get RecType() {
        return this.record? getFieldValue(this.record, RecType) :'';
    }
    get DoctorID() {
        return this.record? getFieldValue(this.record, DoctorAcc) :'';
    }
    get DoctorAccNum() {
        return this.record? getFieldValue(this.record, DoctorAccNum) :'';
    }
    get MedProcedure() {
        return this.record? getFieldValue(this.record, MedicalProc) :'';
    }
    get MedProcedure1() {
        return this.record? getFieldValue(this.record, MedicalProc2) :'';
    }
    get MedProcedure2() {
        return this.record? getFieldValue(this.record, MedicalProc3) :'';
    }
    get MedProcedure3() {
        return this.record? getFieldValue(this.record, MedicalProc4) :'';
    }
    get PayerFactor() {
        return this.record? getFieldValue(this.record, PayerFactor) :'';
    }
    get PayerFactorParent() {
        return this.record? getFieldValue(this.record, PayerFactorParent) :'';
    }
    get CaseID() {
        return this.record? getFieldValue(this.record, CaseID) :'';
    }
    get SiteID() {
        return this.record? getFieldValue(this.record, SiteID) :'';        
    }
    get RefStatusMaccabi() {
        return this.record? getFieldValue(this.record, RefStatusMaccabi) :'';        
    }

    createReferralManually(){               
        this.createFile();        
    }

    createFile() {
        this.loaded=false;
        GetRecTypeID({developerName: 'Referral'})
        .then(recType => { //Create appointment
                const fields = {};
                fields[RecTypeID_File.fieldApiName] = recType[0].Id;
                fields[MedProcedure_File.fieldApiName] = this.MedProcedure;
                fields[MedProcedure1_File.fieldApiName] = this.MedProcedure1;
                fields[MedProcedure2_File.fieldApiName] = this.MedProcedure2;
                fields[MedProcedure3_File.fieldApiName] = this.MedProcedure3;
                fields[AccountID_File.fieldApiName] = this.PatientAcc;
                fields[DoctorID_File.fieldApiName] = this.DoctorID;
                fields[PayerFactor_File.fieldApiName] = this.PayerFactor;
                fields[CaseID_File.fieldApiName]= this.CaseID;
                fields[SiteID_File.fieldApiName]= this.SiteID;
                fields[AppointmenID_File.fieldApiName] = this.appointmentId;
                fields[IsRequestManually_File.fieldApiName] = true;
                fields[StatusRefManual_File.fieldApiName] = 'ממתין לצירוף מסמך';
                const recordInput = { apiName: FILE_OBJ.objectApiName, fields };
                createRecord(recordInput)
                    .then(file => {
                        this.fileId = file.id;
                        console.log(`createFile succsess id : ${file.id}`);
                        this.loaded= true;
                        this.navigateToFile(this.fileId);
                        //this.apexCallIsReqLiabilityAuto();
                    })
                    .catch(error => {
                        this.loaded= true;
                        console.log(`createFile error : ${error}`);
                    });
        })
        .catch(error => {
            this.loaded= true;
            console.log(`createFile error : ${error}`);
        });
    }  

    navigateToFile(fileID) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: fileID,
                objectApiName: 'File__c',
                actionName: 'view'
            },
        });
    }
}