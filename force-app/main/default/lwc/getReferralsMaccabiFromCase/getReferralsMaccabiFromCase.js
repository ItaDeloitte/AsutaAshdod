/* eslint-disable no-debugger */
/* eslint-disable no-eval */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, api, wire, track } from "lwc";
//import RetrievingServiceReferrals from "@salesforce/apex/MaccabiIntegration.retServiceReferralsFromCase";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import btnTitle from "@salesforce/label/c.MaccabiGetReferrals";
import AccountId from "@salesforce/schema/Case.AccountId";
import PayerFactorCode from "@salesforce/schema/Case.PayerFactor__r.Parent_Code__c";
import PayerFactor from "@salesforce/schema/Case.PayerFactor__c";
import PatientID from "@salesforce/schema/Case.Patient_ID__c";
import RecordType from "@salesforce/schema/Case.RecordType.DeveloperName";
import StatusAmbulatory from "@salesforce/schema/Case.Status_Ambulatory_Referrals__c";

export default class GetReferralsMaccabiFromCase extends LightningElement {
  @api recordId;
  @track loaded = false;
  @track isMaccabi = false;
  @track record;
  @track hasRendered = false;

  label = { btnTitle };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      AccountId,
      PayerFactor,
      PayerFactorCode,
      PatientID,
      RecordType,
      StatusAmbulatory
    ]
  })
  wiredCase({ data }) {
    if (data) {
      this.record = data;
      if (this.payerFactorCode === "333" && this.reqType === "Appointments") {
        //'בדיקה'
        this.isMaccabi = true;
      }
    }
  }

  get accId() {
    return this.record ? getFieldValue(this.record, AccountId) : "";
  }
  get payerFactor() {
    return this.record ? getFieldValue(this.record, PayerFactor) : "";
  }
  get patientNum() {
    return this.record ? getFieldValue(this.record, PatientID) : "";
  }
  get reqType() {
    return this.record ? getFieldValue(this.record, RecordType) : "";
  }
  get payerFactorCode() {
    return this.record ? getFieldValue(this.record, PayerFactorCode) : "";
  }
  get statusAmbulatory() {
    return this.record ? getFieldValue(this.record, StatusAmbulatory) : "";
  }

  getReferrals() {
    this.loaded = true;
    RetrievingServiceReferrals({
      memberID: this.patientNum,
      payerFactor: this.payerFactor,
      caseID: this.recordId,
      accountID: this.accId
    })
      // eslint-disable-next-line no-unused-vars
      .then(res => {
        console.log("Get Referrals from Maccabi service - succsess");
        setTimeout(() => {
          this.loaded = false;
          if (window.location.toString().includes("/Case")) {
            eval("$A.get('e.force:refreshView').fire();");
          }
        }, 15000);
      })
      .catch(err => {
        this.loaded = false;
        console.error(err);
      });
  }

  renderedCallback() {
    setTimeout(() => {
      if (
        window.location.toString().includes("/Case") &&
        this.StatusAmbulatory === undefined &&
        !this.hasRendered
      ) {
        eval("$A.get('e.force:refreshView').fire();");
      }
      this.hasRendered = true;
    }, 15000);
  }
}