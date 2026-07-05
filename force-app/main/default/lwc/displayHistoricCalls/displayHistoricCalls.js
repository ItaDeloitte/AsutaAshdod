import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import checkHistoricCalls from '@salesforce/apex/displayHistoricCalls.checkHistoricCalls';
import AccountId from "@salesforce/schema/Case.AccountId";
import displayHistoryCall from "@salesforce/label/c.displayHistoryCall";
import closeHistoryModal from "@salesforce/label/c.closeHistoryModal";
import PatientId from "@salesforce/label/c.PatientId";
import CallComments from "@salesforce/label/c.CallComments";
import PatientPhone from "@salesforce/label/c.PatientPhone";
import CallDate from "@salesforce/label/c.CallDate";
import CallResults from "@salesforce/label/c.CallResults";
import CallOwner from "@salesforce/label/c.CallOwner";
import CallbackStatus from "@salesforce/label/c.CallbackStatus";
import CallDirection from "@salesforce/label/c.CallDirection";
import PhoneForCallback from "@salesforce/label/c.PhoneForCallback";
import NoHistory from "@salesforce/label/c.NoHistory";



export default class DisplayHistoricCalls extends NavigationMixin(LightningElement) {

    @api recordId;
    @track historicCalls;
    @track record;
    @track isModalOpen = false;
    @track error;
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
          AccountId
        ]
      })
      wiredCase({ data }) {
        if (data) {
          this.record = data;
        }
      }

    label = {
        displayHistoryCall,
        PatientId,
        CallComments,
        PatientPhone,
        CallDate,
        CallResults,
        CallOwner,
        CallbackStatus,
        CallDirection,
        PhoneForCallback,
        NoHistory,
        closeHistoryModal
    };

    @track columns = [{
        label: PatientId,
        type: 'text',
        fieldName: 'Patient_ID__c',
        sortable: true,
    },
    {
        label: CallComments,
        fieldName: 'Comments__c',
        type: 'text',
        sortable: true
    },
    {
        label: PatientPhone,
        fieldName: 'Patient_Phone_No__c',
        type: 'text',
        sortable: false
    },
    {
        label: CallDate,
        fieldName: 'Call_date__c',
        type: 'date',
        sortable: false
    },
    {
        label: CallOwner,
        fieldName: 'Owner__c',
        type: 'text',
        sortable: false
    },
    {
        label: CallbackStatus,
        fieldName: 'Callback_status__c',
        type: 'text',
        sortable: false
    },
    {
        label: PhoneForCallback,
        fieldName: 'Phone_for_callback__c',
        type: 'text',
        sortable: false
    },
    
    {
        label: CallDirection,
        fieldName: 'Direction__c',
        type: 'text',
        sortable: false
    },

    {
        label: CallResults,
        fieldName: 'Call_Results__c',
        type: 'text',
        sortable: true
    }
];

    get accId() {
        console.log('accId' + this.record);
        return this.record ? getFieldValue(this.record, AccountId) : this.recordId;
    }
    getHistoricCalls() {

        console.log('*** in getHistoricCalls accId-->' + this.accId);
        checkHistoricCalls({
            
            accountId: this.accId
        })
            .then(result => {
                if (result!=null && result.length > 0) {
                    this.historicCalls = result;
                    console.log('Result are'+ JSON.stringify(this.historicCalls));
                    
                }else {
                    this.error = this.label.NoHistory;
                    //console.log('err'+error);
                }
            })
            .catch(err => {
                console.error("Error! " + JSON.stringify(err));
            });
    }

    closeModal(){
        this.historicCalls = undefined;
    }
    
}