/* eslint-disable no-alert */
/* eslint-disable no-debugger */
import { LightningElement, api,track } from 'lwc';
//import IsReqLiabilityAuto from '@salesforce/apex/MaccabiIntegration.IsReqLiabilityAuto';


export default class HithaivuyotMaccabiManual extends LightningElement {

    @api isManual;
    @api memberId;
    @api appointmentId;
    @track DoctorID;
    @track ReferenceNumber;
    @track DateTreatment;
    @track Code1;
    @track Code2;
    @track Code3;
    @track Code4;
    @track codeConversionArr;
    @track dateTreat;
    @track message;    
    @track error;

    genericOnChange(event){
        this[event.target.name] = event.target.value;
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        alert('event : '+event.detail.files);
        //var uploadedFiles = event.detail.files;       

    }
    
    createReferralManual() {
        this.error = undefined;
        this.message = undefined;
        this.codeConversionArr = [];
        if(this.DoctorID === undefined) {
            this.error = `שדה 'ת.ז. רופא מפנה' הוא שדה חובה`;
        } else if(this.ReferenceNumber === undefined) {
            this.error = `שדה 'מספר הפניה' הוא שדה חובה`;
        } else if(this.Code1 === undefined && this.Code2 === undefined && this.Code3 === undefined && this.Code4 === undefined) {
            this.error = `שדה 'קוד טיפול' הוא שדה חובה`;
        } else if(this.DateTreatment === undefined) {
            this.error = `שדה 'תאריך טיפול' הוא שדה חובה`;
        } else {
            if (this.Code1 !== undefined) {
                this.codeConversionArr.push(this.Code1);
            }
            if (this.Code2 !== undefined) {
                this.codeConversionArr.push(this.Code2);
            }
            if (this.Code3 !== undefined) {
                this.codeConversionArr.push(this.Code3);
            }
            if (this.Code4 !== undefined) {
                this.codeConversionArr.push(this.Code4);
            }

            let newDate = this.DateTreatment.split('-');
            this.dateTreat = newDate[2]+newDate[1]+newDate[0];
        }


        IsReqLiabilityAuto({memberID: this.memberId, codeConversionArr: this.codeConversionArr, doctorId: this.DoctorID, referralNumber: this.ReferenceNumber, dateTreatment: this.dateTreat})
        // eslint-disable-next-line no-unused-vars
        .then(res => {debugger
            this.message = res;
        })
        .catch(error => {
            this.error = error; //this.label.statusOther
            this.message = undefined;
        });

    }



}