/* eslint-disable no-console */
/* eslint-disable eqeqeq */
/* eslint-disable no-debugger */
import { LightningElement, track, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getIVRLines from "@salesforce/apex/ws_IVR_PlayInstructions.getIVRLines";
import makeTransferIVRInfo from "@salesforce/apex/ws_IVR_PlayInstructions.makeTransferIVRInfo";
import updateDateforInstuction from "@salesforce/apex/ws_IVR_PlayInstructions.updateDateInstuctionReadField";
import getAppointment from "@salesforce/apex/UtilGetObjectData.getInstitutesAppointment";
import getUser from "@salesforce/apex/UtilGetObjectData.getUser";
import getAccount from "@salesforce/apex/UtilGetObjectData.getAccount";
import RecordType from "@salesforce/schema/Case.RecordType.DeveloperName";
import AccountId from "@salesforce/schema/Case.AccountId";
import userId from "@salesforce/user/Id";
import CheckFreeLinesbtn from "@salesforce/label/c.CheckFreeLinesIVRBtnTitle";
import playInstructionsbtn from "@salesforce/label/c.PlayInstructionsBtn";
import errorMessage from "@salesforce/label/c.PayAttantionError";
import appointmentName from "@salesforce/label/c.AppName";
import site from "@salesforce/label/c.Site";
import dateTimeOfAppointment from "@salesforce/label/c.DateTimeOfAppointment";
import movePlayInstructionsMesg from "@salesforce/label/c.MovePlayInstructionsMesg";
import cancelePlayInstructions from "@salesforce/label/c.CancelePlayInstructions";
import manualInstructions from "@salesforce/label/c.IVRManualInstructions";
import noAppForPlayInstructions from "@salesforce/label/c.NoAppForPlayInstructions";
import recordExist from "@salesforce/label/c.RecordExist";


export default class CheckFreeLinesIvrButton extends LightningElement {
  @api caseId;
  @track record;
  @track isFreeLine;
  @track makeTransferRslt;
  @track memberId;
  @track agentId;
  @track extension;
  @track isShownbtn = false;
  @track isShowModal = false;
  @track _appointments;
  @track appointmentData = [];
  @track appointmentIds = [];
  @track appointmentNoRecIds = [];
  @track sortedBy;
  userId = userId;

  sortedDirection = "asc";

  label = {
    CheckFreeLinesbtn: CheckFreeLinesbtn,
    playInstructionsbtn,
    errorMessage,
    appointmentName,
    site,
    dateTimeOfAppointment,
    movePlayInstructionsMesg,
    cancelePlayInstructions,
    manualInstructions,
    noAppForPlayInstructions,
    recordExist
  };

  columns = [
    {
      label: this.label.appointmentName,
      fieldName: "appointmentName",
      type: "text",
      sortable: true
    },
    {
      label: this.label.site,
      fieldName: "site",
      type: "text",
      sortable: true
    },
    {
      label: this.label.dateTimeOfAppointment,
      fieldName: "dateTimeOfAppointment",
      type: "DateTime",
      sortable: true
    },
    {
      label: this.label.recordExist,
      fieldName: "guidScenarioManual",
      type: "text",
      sortable: true
    }
  ];

  renderedCallback() {
  }

  @wire(getRecord, { recordId: "$caseId", fields: [RecordType, AccountId] })
  wiredCase({ error, data }) {
    if (data) {
      this.record = data;
      if (this.RecordName == "Appointments") {
        //this.isShownbtn = true;
        // commented because of request of Oran from CRM on 25.10.21
      }
    } else if (error) {
      console.log("error" + error);
    }
  }

  get RecordName() {
    return this.record ? getFieldValue(this.record, RecordType) : "";
  }
  get AccountId() {
    return this.record ? getFieldValue(this.record, AccountId) : "";
  }

  checkIVRLines() {
    getIVRLines()
      .then(result => {
        this.isFreeLine = result;
        if (this.isFreeLine) {
          getAppointment({ accID: this.AccountId })
            .then(res => {
              this._appointments = res;
              if(this._appointments.length == 0){
                this.ShowToastMessage(
                  "Success",
                  this.label.noAppForPlayInstructions,
                  "success",
                  "dismissable "
                );
              }else{
                this.appointmentData = [];
                this.appointmentIds = [];
                this.appointmentNoRecIds = [];
                this._appointments.forEach(i => {
                  let date =
                    i.Appointment_Date_Time__c != undefined
                      ? this.toSFDate(new Date(i.Appointment_Date_Time__c))
                      : "";
                  this.appointmentData = [
                    ...this.appointmentData,
                    {
                      id: i.Id,
                      appointmentName: i.Name != undefined ? i.Name : "",
                      site: i.Site__r.Name != undefined ? i.Site__r.Name : "",
                      dateTimeOfAppointment: date,
                      guidScenarioManual:
                        (i.Guidance_Scenario__c != undefined && (i.Guidance_Scenario__r.Recording_Code_1__c != undefined || i.Guidance_Scenario__r.Recording_Code_2__c != undefined || 
                         i.Guidance_Scenario__r.Recording_Code_3__c != undefined || i.Guidance_Scenario__r.Recording_Code_4__c != undefined ||
                         i.Guidance_Scenario__r.Recording_Code_5__c != undefined || i.Guidance_Scenario__r.Recording_Code_6__c != undefined)) &&
                         i.Medical_Procedure__r.Domain__r.Recording_Code__c != undefined ? "" : this.label.manualInstructions
                    }
                  ];                
                  if((i.Guidance_Scenario__c != undefined && (i.Guidance_Scenario__r.Recording_Code_1__c != undefined || i.Guidance_Scenario__r.Recording_Code_2__c != undefined || 
                      i.Guidance_Scenario__r.Recording_Code_3__c != undefined || i.Guidance_Scenario__r.Recording_Code_4__c != undefined ||
                      i.Guidance_Scenario__r.Recording_Code_5__c != undefined || i.Guidance_Scenario__r.Recording_Code_6__c != undefined) 
                      && i.Medical_Procedure__r.Domain__r.Recording_Code__c != undefined)){
                      this.appointmentIds = [...this.appointmentIds, i.Id]; 
                  }else{
                    this.appointmentNoRecIds = [...this.appointmentNoRecIds, i.Id];
                  }
                });
                if( this.appointmentIds.length == 0 && this.appointmentNoRecIds.length > 0){
                  this.ShowToastMessage(
                    "Success",
                    this.label.manualInstructions,
                    "success",
                    "dismissable "
                  );
                } else{
                  this.isShowModal = true;
                } 
              } 
            })
            .catch(error => {
              console.log("GetAppointments fail : " + error);
            });
        } else {
          this.ShowToastMessage(
            "Error",
            this.label.errorMessage,
            "error",
            "pester"
          );
        }
      })
      .catch(error => {
        this.error = error;
        console.log("CheckFreeLinesIvrButton fail : " + error);
      });
  }

  ShowToastMessage(titlem, message, variant, mode) {
    const toastEvnt = new ShowToastEvent({
      title: titlem,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(toastEvnt);
  }

  getSelectedName(event) {
    debugger
    const selectedRows = event.detail.selectedRows;
    // Display that id of the selected rows
    this.appointmentIds = [];
    for (let i = 0; i < selectedRows.length; i++) {
      if(this.appointmentNoRecIds.indexOf(selectedRows[i].id)==-1){
        this.appointmentIds = [...this.appointmentIds, selectedRows[i].id];
      }      
    }
  }

  sortData(fieldName, sortDirection) {
    var data = JSON.parse(JSON.stringify(this.appointmentData));
    //function to return the value stored in the field
    var key = a => a[fieldName];
    var reverse = sortDirection === "asc" ? 1 : -1;
    data.sort((a, b) => {
      let valueA = key(a) ? key(a).toLowerCase() : "";
      let valueB = key(b) ? key(b).toLowerCase() : "";
      return reverse * ((valueA > valueB) - (valueB > valueA));
    });
    //set sorted data to appointmentData attribute
    this.appointmentData = data;
  }
  updateColumnSorting(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortedDirection);
  }

  closeModal() {
    this.isShowModal = false;
  }

  sendInfoToIVR() {
    getAccount({ recordId: this.AccountId })
      .then(res => {
        this.memberId = res.ID_Number__c;
      })
      .catch(error => {
        console.log("getAccount fail : " + error);
      });

    getUser({ OwnerId: this.userId })
      .then(res => {
        this.agentId = res.Agent_ID__c;
        this.extension = res.Extension;
      })
      .catch(error => {
        console.log("getUser fail : " + error);
      });
    getIVRLines()
      .then(result => {
        this.isFreeLine = result;
        if (this.isFreeLine) {
          updateDateforInstuction({ appIds: this.appointmentIds });

          makeTransferIVRInfo({
            patientId: this.memberId,
            agentId: this.agentId,
            extension: this.extension,
            aptSFID: this.appointmentIds
          })
            .then(res => {
              this.isShowModal = false;
              this.makeTransferRslt = res;
              if (
                this.makeTransferRslt == "ERROR" ||
                this.makeTransferRslt.length < 20
              ) {
                this.ShowToastMessage(
                  "Error",
                  this.label.errorMessage,
                  "error",
                  "pester"
                );
              } else {
                this.ShowToastMessage(
                  "Success",
                  this.label.MovePlayInstructionsMesg,
                  "success",
                  "dismissable "
                );
              }
            })
            .catch(error => {
              this.error = error;
            });
        } else {
          this.ShowToastMessage(
            "Error",
            this.label.errorMessage,
            "error",
            "pester"
          );
        }
      })
      .catch(error => {
        this.error = error;
        console.log("CheckFreeLinesIvrButton fail : " + error);
      });
  }

  toSFDate(dateObj) {
    // string format is YYYY-MM-DD
    var dateStr = `${this.pad2(dateObj.getHours())}:${this.pad2(
      dateObj.getMinutes()
    )} ${this.pad2(dateObj.getDate())}-${this.pad2(
      dateObj.getMonth() + 1
    )}-${dateObj.getFullYear()}`;
    return dateStr;
  }

  pad2(number) {
    return (number < 10 ? "0" : "") + number;
  }
}