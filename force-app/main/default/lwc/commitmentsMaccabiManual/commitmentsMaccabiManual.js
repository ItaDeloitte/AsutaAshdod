/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
/* eslint-disable no-debugger */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import GetAppointment from '@salesforce/apex/UtilGetObjectData.getAppointment';
import GetRecTypeID from '@salesforce/apex/UtilGetObjectData.getRecordType';
import GetContentDocumentLink from '@salesforce/apex/UtilGetObjectData.getContentDocumentLink';
import GetMedProcedureMap from '@salesforce/apex/UtilGetObjectData.getMedProcedureMap';
import GetSiteList from '@salesforce/apex/UtilGetObjectData.getSiteList';
import InsertDocumentToArchive from '@salesforce/apex/MaccabiIntegration.insertDocumentToArchive';
import IsReqLiabilityAuto from '@salesforce/apex/MaccabiIntegration.isReqLiabilityAuto';
import IsLiabilitiesManagement from '@salesforce/apex/MaccabiIntegration.isLiabilityManagement';


import AccountID from '@salesforce/schema/File__c.Account__c';
import AccountNum from '@salesforce/schema/File__c.Account__r.ID_Number__c';
import IDType from '@salesforce/schema/File__c.Account__r.ID_Type__c';
import KupaId from '@salesforce/schema/File__c.Account__r.KupaId__c';
import DoctorNum from '@salesforce/schema/File__c.Doctor_ID__c';
import DoctorID from '@salesforce/schema/File__c.DoctorName__c';
import DoctorName from '@salesforce/schema/File__c.DoctorName__r.Name';
import ReferralNum from '@salesforce/schema/File__c.ReferralNumber__c';
import MedProcedure from '@salesforce/schema/File__c.Medical_Procedure__c';
import MedProcedure1 from '@salesforce/schema/File__c.Medical_Procedure2__c';
import MedProcedure2 from '@salesforce/schema/File__c.Medical_Procedure3__c';
import MedProcedure3 from '@salesforce/schema/File__c.Medical_Procedure4__c';
import AppointmenID from '@salesforce/schema/File__c.Appointment__c';
import CaseID from '@salesforce/schema/File__c.Case__c';
import AppointmenDate from '@salesforce/schema/File__c.Date_Time_of_the_appointment__c';
import PayerFactor from '@salesforce/schema/File__c.PayerFactor__c';
import SiteID from '@salesforce/schema/File__c.Site__c';
import RelatedProcess from '@salesforce/schema/File__c.Related_Process__c';
import MaccabiGuid from '@salesforce/schema/File__c.Appointment__r.GuidForMaccabi__c';
import Classification from '@salesforce/schema/File__c.Appointment__r.Classification__c';

import Appointment_OBJECT from '@salesforce/schema/Appointment__c';
import RecTypeId_App from '@salesforce/schema/Appointment__c.RecordTypeId';
import MedicalProc_App from '@salesforce/schema/Appointment__c.Medical_Procedure__c';
import MedicalProc2_App from '@salesforce/schema/Appointment__c.Medical_Procedure2__c';
import MedicalProc3_App from '@salesforce/schema/Appointment__c.Medical_Procedure3__c';
import MedicalProc4_App from '@salesforce/schema/Appointment__c.Medical_Procedure4__c';
import PatientAcc_App from '@salesforce/schema/Appointment__c.Patient_Account__c';
import ReferralStatusMaccabi_App from '@salesforce/schema/Appointment__c.Referral_Status_Maccabi__c';
import DoctorAcc_App from '@salesforce/schema/Appointment__c.Doctor_Account__c';
import PayerFactor_App from '@salesforce/schema/Appointment__c.PayerFactor__c';
import Name_App from '@salesforce/schema/Appointment__c.Name';
import CaseID_App from '@salesforce/schema/Appointment__c.Case__c';
import SourceSystem_App from '@salesforce/schema/Appointment__c.SourceSystem__c';
import Site_App from '@salesforce/schema/Appointment__c.Site__c';
import Junction_OBJECT from '@salesforce/schema/cases_and_appoitments__c';
import CaseID_Junc from '@salesforce/schema/cases_and_appoitments__c.Case__c';
import AppointmentID_Junc from '@salesforce/schema/cases_and_appoitments__c.Appointment__c';
import IsTheMain_Junc from '@salesforce/schema/cases_and_appoitments__c.Is_it_the_main_case_for_surgery__c';
import NoAttachments from '@salesforce/label/c.No_attachments';
import MaccabiRefManual1 from '@salesforce/label/c.MaccabiRefManual1';
import MaccabiRefManual2 from '@salesforce/label/c.MaccabiRefManual2';
import MaccabiRefManual3 from '@salesforce/label/c.MaccabiRefManual3';
import MaccabiRefManual4 from '@salesforce/label/c.MaccabiRefManual4';
import PayAttantion from '@salesforce/label/c.PayAttantion';
import SendReferralBtn from '@salesforce/label/c.MaccabiSendReferralBtn';
import CreateAppBtn from '@salesforce/label/c.MaccabiCreateAppBtn';
import CreateReflManualBtn from '@salesforce/label/c.MaccabiCreateReflManualBtn';


export default class CommitmentsMaccabiManual extends NavigationMixin(LightningElement) {

    @api recordId;
    @track error = undefined;
    @track memberId;
    @track appointmentId;
    @track isMaccabi = false;
    @track isFromAccount = false;
    @track loaded = true;
    @track comNumber = '0';
    @track codeConversionArr= [];
    @track servProviderID = '';
    @track siteList;
    @track message;
    @track ContentDocumentId;
    @track docType = '';

    label = {
        NoAttachments,
        MaccabiRefManual1,
        MaccabiRefManual2,
        MaccabiRefManual3,
        MaccabiRefManual4,
        PayAttantion,
        SendReferralBtn,
        CreateAppBtn,
        CreateReflManualBtn
    };

    @wire(getRecord, {recordId: '$recordId', fields: [AppointmenID, CaseID, AppointmenDate, AccountID, DoctorID, DoctorNum, DoctorName, 
                                                      ReferralNum, AccountNum, IDType, KupaId, MedProcedure, MedProcedure1, MedProcedure2, 
                                                      MedProcedure3, PayerFactor, SiteID, RelatedProcess, MaccabiGuid, Classification]})
    wiredFile({ error, data }) {
        if (data) {
            this.record = data;debugger
            this.newAppButtonIsShow();
            this.apexCallGetAppointment();        
        } else if (error) {
            this.error = `${this.error}
            ${error}`;
            this.record = undefined;
        }
    }

    @wire(GetSiteList)
    wiredSiteList({ error, data }) {
        if(data) {
            this.siteList = data;
        } else if(error) {
            this.error = error;
        }
    }

    newAppButtonIsShow(){
        this.isFromAccount = false;
        if(this.CaseID != null 
            && this.AppointmenID == null 
            && this.RelatedProcess == '0'
            && this.DoctorID != null 
            && this.PayerFactor != null 
            && this.SiteID != null) {
            this.isFromAccount = true;
        }
    }

    get AccountID() {
        return this.record? getFieldValue(this.record, AccountID) :'';
    }
    get IDType() {
        return this.record? getFieldValue(this.record, IDType) == '9' ? '9' : '0' : '';
    }
    get KupaId() {
        return this.record? getFieldValue(this.record, KupaId) :'';
    }
    get AccountNum() {
        return this.record? getFieldValue(this.record, AccountNum) :'';
    }
    get DoctorNum() {
        return this.record? getFieldValue(this.record, DoctorNum) :'';
    }
    get DoctorID() {
        return this.record? getFieldValue(this.record, DoctorID) :'';
    }
    get DoctorName() {
        return this.record? getFieldValue(this.record, DoctorName) :'';
    }
    get ReferralNum() {
        return this.record? getFieldValue(this.record, ReferralNum) :'';
    }
    get MedProcedure() {
        return this.record? getFieldValue(this.record, MedProcedure) :'';
    }
    get MedProcedure1() {
        return this.record? getFieldValue(this.record, MedProcedure1) :'';
    }
    get MedProcedure2() {
        return this.record? getFieldValue(this.record, MedProcedure2) :'';
    }
    get MedProcedure3() {
        return this.record? getFieldValue(this.record, MedProcedure3) :'';
    }
    get AppointmenDate() {
        return this.record? getFieldValue(this.record, AppointmenDate) :'';
    }
    get AppointmenID() {
        return this.record? getFieldValue(this.record, AppointmenID) :'';
    }
    get PayerFactor() {
        return this.record? getFieldValue(this.record, PayerFactor) :'';
    }
    get CaseID() {
        return this.record? getFieldValue(this.record, CaseID) :'';
    }
    get SiteID() {
        return this.record? getFieldValue(this.record, SiteID) :'';        
    }
    get RelatedProcess(){
        return this.record? getFieldValue(this.record, RelatedProcess) :'';
    }
    get MaccabiGuid(){
        return this.record? getFieldValue(this.record, MaccabiGuid) :'';
    }
    get Classification(){
        return this.record? getFieldValue(this.record, Classification) :'';
    }
    get IdNumber(){
        return this.IDType == '0' ? this.AccountNum : this.IDType == '9' && this.KupaId != null ? this.KupaId : this.AccountNum;
    }
    

    getCodeConversionArr() {
        let codeConvArr = [];
        if (this.MedProcedure !== undefined && this.MedProcedure !== null && !codeConvArr.includes(this.MedProcedure)) {
            codeConvArr.push(this.MedProcedure);
        }
        if (this.MedProcedure1 !== undefined && this.MedProcedure1 !== null && !codeConvArr.includes(this.MedProcedure1)) {
            codeConvArr.push(this.MedProcedure1);
        }
        if (this.MedProcedure2 !== undefined && this.MedProcedure2 !== null && !codeConvArr.includes(this.MedProcedure2)) {
            codeConvArr.push(this.MedProcedure2);
        }
        if (this.MedProcedure3 !== undefined && this.MedProcedure3 !== null && !codeConvArr.includes(this.MedProcedure3)) {
            codeConvArr.push(this.MedProcedure3);
        }
        if (codeConvArr.length > 0){
            this.apexCallGetMedProcedureMap(codeConvArr);
        }
    }

    getSite(){
        for (let i = 0; i < this.siteList.length; i++) {            
            if(this.siteList[i].Id === this.SiteID) {
                this.servProviderID = this.siteList[i].Maccabi_Code__c;
            }
        }  
    }

    apexCallGetMedProcedureMap(codeConvArr) {
        GetMedProcedureMap({ids: codeConvArr})
        .then(res => {
            for(let id of codeConvArr) {
                if(res[id]) {
                    this.codeConversionArr.push(res[id].Procedure_Code__c);
                }
            }
            this.codeConversionArr = [...new Set(this.codeConversionArr)];
        })
        .catch(err => {
            this.error = `${this.error}
            ${err}`;
        });
    }

    sendReferralToMaccabi() {
        this.getCodeConversionArr();
        console.log(`this.codeConversionArr : ${this.codeConversionArr}`);
        GetContentDocumentLink({entitytId: this.recordId})
        .then(res => {
            if(res.length > 0){
                this.ContentDocumentId = res[0].ContentDocumentId;
                if(this.Classification == 'אדום'){
                    this.apexCallIsLiabilitiesManagement();
                }
                else{
                    this.apexCallIsReqLiabilityAuto();
                }
            } else {
                this.ShowToastMessage('', this.label.NoAttachments, 'error', 'sticky');
            }
        })
        .catch(err => {
            this.ShowToastMessage(this.label.PayAttantion, err.statusText, 'error', 'sticky');
        });
    }

    apexCallIsReqLiabilityAuto(){
        this.getSite();
        IsReqLiabilityAuto({appId: this.AppointmenID,
                            fileID: this.recordId,
                            memberID: this.IdNumber,
                            memberIDCode: this.IDType,  
                            codeConversionArr: this.codeConversionArr, 
                            doctorId: this.DoctorNum, 
                            referralNumber: '0',
                            dateTreatment: this.getDate(),
                            servProviderID: this.servProviderID})//this.dateFormat(this.AppointmenDate)})
        .then(result => {
            this.message = result;
            debugger
            console.log(`IsReqLiabilityAuto result : ${this.message}`);
            GetAppointment({recordId: this.AppointmenID})
                .then(res => {
                    this.comNumber = res[0].Number_of_commitment__c;
                    this.docType = 'הפניה';
                    this.apexCallGetContentDocumentLink();
                })
                .catch(err => {
                    this.error = `${this.error}
                    ${err}`;
                }); 
        })
        .catch(error => {
            debugger
            this.error = `${this.error}
            ${error.statusText}`;
            console.log(`IsReqLiabilityAuto error result : ${this.error}`);
            this.ShowToastMessage(this.label.PayAttantion, this.error, 'error', 'sticky')
        });        
    }

    apexCallIsLiabilitiesManagement(){
        this.getSite();
        IsLiabilitiesManagement({appId: this.AppointmenID,
                                 fileID: this.recordId,
                                 memberID: this.IdNumber,
                                 memberIDCode: this.IDType,
                                 codeConversionArr: this.codeConversionArr, 
                                 doctorId: this.DoctorNum, 
                                 doctorName: this.DoctorName,
                                 servProviderID: this.servProviderID,
                                 guid: this.MaccabiGuid})
        .then(result => {
            this.message = result;
            debugger
            console.log(`IsLiabilitiesManagement result : ${this.message}`);
            GetAppointment({recordId: this.AppointmenID})
                .then(res => {
                    this.comNumber = res[0].Number_of_commitment__c;
                    this.apexCallGetContentDocumentLink();
                })
                .catch(err => {
                    this.error = `${this.error}
                    ${err}`;
                }); 
        })
        .catch(error => {
            debugger
            this.error = `${this.error}
            ${error.statusText}`;
            console.log(`IsReqLiabilityAuto error result : ${this.error}`);
            this.ShowToastMessage(this.label.PayAttantion, this.error, 'error', 'sticky')
        });        
    }

    apexCallGetContentDocumentLink() {        
        InsertDocumentToArchive({contentDocumentId: this.ContentDocumentId, 
                                memberID: this.IdNumber,
                                memberIDCode: this.IDType,
                                referralNumber: this.comNumber,
                                appId: this.AppointmenID, 
                                appDate: this.AppointmenDate,
                                fileID: this.recordId,
                                docType: this.docType})        
        .then(result => {
            this.setMessage(result);
            this.updateStatusRefManualInFile(this.recordId); //Update File__c with StatusRefManualToMaccabi__c ='הוגש למכבי'
        })
        .catch(err => {
            this.ShowToastMessage(this.label.PayAttantion, err.statusText, 'error', 'sticky');
        });
    }

    apexCallGetAppointment() {
        GetAppointment({recordId: this.AppointmenID})
        .then(res => {
            if(res[0].PayerFactor__r.Code_Parent_for_Interface__c === '3') {                
                this.isMaccabi = true;
            }
               
        })
        .catch(err => {
            this.error = `${this.error}
            ${err}`;
        });
    }

    createAppointment() {
        this.loaded=false;
        GetRecTypeID({developerName: 'Surgeries'})
            .then(referral => { // Create appointment
                    const fields = {};                    
                    fields[RecTypeId_App.fieldApiName] = referral[0].Id;
                    fields[MedicalProc_App.fieldApiName] = this.MedProcedure;
                    fields[MedicalProc2_App.fieldApiName] = this.MedProcedure1;
                    fields[MedicalProc3_App.fieldApiName] = this.MedProcedure2;
                    fields[MedicalProc4_App.fieldApiName] = this.MedProcedure3;
                    fields[PatientAcc_App.fieldApiName] = this.AccountID;
                    fields[DoctorAcc_App.fieldApiName] = this.DoctorID;
                    fields[PayerFactor_App.fieldApiName] = this.PayerFactor;
                    fields[ReferralStatusMaccabi_App.fieldApiName] = '0';// ?
                    fields[CaseID_App.fieldApiName]= this.CaseID;
                    fields[Site_App.fieldApiName]= this.SiteID;
                    fields[SourceSystem_App.fieldApiName]= 'Manual';
                    fields[Name_App.fieldApiName] = 'פגישה חדשה';
                    const recordInput = { apiName: Appointment_OBJECT.objectApiName, fields };
                    createRecord(recordInput)
                        .then(appointment => {
                            this.appointmentId = appointment.id;
                            //this.createJuction(this.CaseID, this.appointmentId);
                            this.updateFile(this.recordId, appointment.id); //Update File__c with Appointment_Id and navigate to Appointment layout                            
                        })
                        .catch(error => {
                            this.loaded= true;
                            this.ShowToastMessage('Error creating appointmnet', error.body.message, 'error', 'sticky');
                        });
            })
            .catch(error => {
                this.loaded= true;
                this.ShowToastMessage('Error creating appointmnet', error.body.message, 'error', 'sticky');
            });
    }

    createJuction(caseID, appID){
        const fields = {};
        fields[CaseID_Junc.fieldApiName] = caseID;
        fields[AppointmentID_Junc.fieldApiName] = appID;
        fields[IsTheMain_Junc.fieldApiName] = true;
        const recordInput = { apiName: Junction_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(junction => {                                    
            console.debug(`ases_and_appoitments__c object created: ${junction.Id}`);           
        })
        .catch(error => {
            this.loaded= true;
            this.ShowToastMessage('Error creating appointmnet', error.body.message, 'error', 'sticky');
        });

    }

    updateFile(id, appId) {
        let record = {
            fields: {
                Id: id,
                Appointment__c: appId,
                Request_Manually__c : true,
            },
        };
        updateRecord(record)
        // eslint-disable-next-line no-unused-vars
        .then(() => {
            this.navigateToAppointmentEdit(this.appointmentId);//Open Tab of appointment
            this.loaded=true;             
        })
        .catch(error => {
            this.ShowToastMessage('Error update file', error.message, 'error', 'sticky');
        });
    }

    updateStatusRefManualInFile(id) {
        let record = {
            fields: {
                Id: id,
                StatusRefManualToMaccabi__c:'הוגש למכבי'
            },
        };
        updateRecord(record)
        .then(() => {                                    
            console.log(`updateFile succsess id : ${record.Id}`);
            this.loaded= true;           
        })
        .catch(error => {
            this.loaded= true;
            console.log(`updateFile error : ${error}`);
        });
    }
    
    getDate() {
        var today = new Date();
        var day = new Date(today.getFullYear()-2,today.getMonth()+22,today.getDate()+66);
        return `${day.getDate()<10?'0':''}${day.getDate()}${day.getMonth()+1<10?'0':''}${day.getMonth()+1}${day.getFullYear()}`;
    }

    dateFormat(dateStr) {
        let newDate = dateStr.split('-');
        return newDate[2].substr(0,2)+newDate[1]+newDate[0];
    }

    setMessage(res) {
        if (res === '0') {
            this.ShowToastMessage('', this.label.MaccabiRefManual1, 'success', 'pester')
        } else if(res === '1') {
            this.ShowToastMessage(this.label.PayAttantion, this.label.MaccabiRefManual2, 'error', 'sticky')
        } else if(res === '2'){
            this.ShowToastMessage(this.label.PayAttantion, this.label.MaccabiRefManual3, 'error', 'sticky')
        } else {
          this.ShowToastMessage(this.label.PayAttantion, this.label.MaccabiRefManual4, 'error', 'sticky') 
        }        
    }

    ShowToastMessage(titlem, message, variant, mode) {
        const toastEvnt = new ShowToastEvent( {
              title: titlem,
              message: message ,
              variant: variant ,
              mode: mode,
        });
        this.dispatchEvent (toastEvnt);
    }

    navigateToAppointmentEdit(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Appointment__c',
                actionName: 'view'
            },
        });
    }
    

}