/* eslint-disable no-console */
/* eslint-disable no-debugger */
import { LightningElement, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import GetWaitingAppointments from '@salesforce/apex/UtilGetObjectData.getWaitingAppointments';


export default class PotentialAppointment extends LightningElement {

    @track record;
    @track appsList = null;
    @track value = '';
    @track options = [];


    handleChange(event) {
        debugger
        this.updateWaitingList(event.detail.value);
    }

    connectedCallback() {
        let appID = this.template.baseURI.split("/")[6];
        debugger
        GetWaitingAppointments({waitingListId: appID})
            // eslint-disable-next-line no-unused-vars
            .then(res => {debugger
                this.appsList = res;
                for (let i = 0; i < this.appsList.length; i++) {
                    this.options = [...this.options,{label: `${this.appsList[i].Name} | ${this.appsList[i].AppointmentTime__c} | ${this.appsList[i].Site__r.Name}`, 
                                                    value: this.appsList[i].Id}];
                }
            })
            .catch(err => {debugger
                this.error = err;
            }); 
    }

    updateWaitingList(selectedApp) {
        let record = {
            fields: {
                Id: this.template.baseURI.split("/")[6],
                potential_appointment__c : selectedApp,
            },
        };
        updateRecord(record)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                console.log(`Waiting list record ${this.recordId} 'potential_appointment__c' field updated`);
            })
            .catch(error => {
                console.log(`Waiting list record ${this.recordId} 'potential_appointment__c' failed to update : ${error}`);
            });
    }

}