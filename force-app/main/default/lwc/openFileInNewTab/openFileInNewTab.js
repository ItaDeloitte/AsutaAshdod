import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContentVersion from '@salesforce/apex/UtilGetObjectData.getContentVersion';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Url from "@salesforce/schema/File__c.URL__c";
import openFileInNewTab from "@salesforce/label/c.OpenFileInNewTab";

export default class OpenFileInNewTab extends NavigationMixin(LightningElement) {
  @api recordId;
  record;
  isShownLink = false;
  urlFile;
  conVersionId;
  extention
  error = 'no file to display';
  pngFormat = ['png', 'jpeg', 'jpg'];
  label = {openFileInNewTab };

  @wire(getRecord, { recordId: "$recordId", fields: [Url] })
  wiredCase({ error, data }) {
    if (data) {
      this.record = data;
      if (this.Url != null) {
        this.urlFile = this.Url;
        this.isShownLink = true;
      }else {
        this.getContentVersionId();
      }
    } else if (error) {
      console.log("error" + error);
    }
  } 

  get Url() {
    return this.record ? getFieldValue(this.record, Url) : "";
  }

  getContentVersionId(){
    getContentVersion({entitytId: this.recordId})
      .then(res => {
        let contVers = JSON.parse(res);
        this.conVersionId = contVers.Id;
        this.extention = contVers.FileExtension;
        if(this.conVersionId != null){
          this.isShownLink = true;
        }
      })
    .catch(error => {
      this.error = error;
      console.log("getContentVersion fail : " + error);
    });
  }

  navigateToFile() {        
    if(this.urlFile != null){
      this.navigateToWebPage();
    } else if(this.conVersionId != null){
      this.navigateToViewContentVersionPage();
    }else{
      this.ShowToastMessage(
        "Error",
        "No File",
        "error",
        "pester"
      );
    }
  }

  // Navigate to View ContentVersion Page
  navigateToViewContentVersionPage() {
    // this[NavigationMixin.Navigate]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: this.conVersionId,
    //         objectApiName: 'ContentVersion',
    //         actionName: 'view'
    //     },
    // });

    const a = document.createElement('a');
    let prefURL = `/sfc/servlet.shepherd/version/`;
    let sufffURL = this.pngFormat.includes(this.extention) ? `renditionDownload?rendition=ORIGINAL_Png&versionId=` : `download/`;
    a.href = `${prefURL}${sufffURL}${this.conVersionId}`;
    a.target = '_blank';
    a.rel = 'noopener';
    a.click();

  }

  // Navigation to web page 
  navigateToWebPage() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": this.urlFile
        }
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
}