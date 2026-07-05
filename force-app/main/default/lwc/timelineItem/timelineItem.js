/* eslint-disable no-useless-constructor */
/* eslint-disable eqeqeq */
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TimelineItem extends NavigationMixin(LightningElement){
    
    @api type;
    @api title;
    @api subTitle;
    @api dateTime;
    @api id;
    @api body; //{body: {fieldName : '', value: ''}, {fieldName : '', value: ''}}

    @api
    expandCollaps(){
        this.isOpened = this.isOpened ? false : true;
        this.template.querySelectorAll('.slds-timeline__item_all').forEach(element => {
            if(this.isOpened){
                this.template.querySelector('lightning-button-icon').iconName = 'utility:chevrondown';
                element.classList.add('slds-is-open', 'slds-timeline_item_expanded');
            } else {
                this.template.querySelector('lightning-button-icon').iconName = 'utility:chevronleft';
                element.classList.remove('slds-is-open', 'slds-timeline_item_expanded');  
            }
        });        
    }

    @track isOpened = false;
    @track isCaseType = false;
    @track isAppointmentType = false;
    @track isFileType = false;
    @track isDisabilitiesType = false;
    @track isTaskType = false;
    @track isEmailType = false;
    @track isCallType = false;
    @track isContact = false;
    @track isApphistory = false;
    @track _title;
    @track _subTitle;
    @track _id;
    @track _body;


    constructor(){
        super();
        this.type = 'case';
        this.title = '';
        this._id = '';
        this._body = [];
    }

    renderedCallback() {
        this.isCaseType = this.type == 'case' ? true : false;
        this.isAppointmentType = this.type == 'appointment' ? true : false;
        this.isFileType = this.type == 'files' ? true : false;
        this.isDisabilitiesType = this.type == 'disabilities' ? true : false;
        this.isTaskType = this.type == 'task' ? true : false;
        this.isEmailType = this.type == 'email' ? true : false;
        this.isCallType = this.type == 'call' ? true : false;
        this.isContact = this.type == 'contact' ? true : false;
        this.isApphistory = this.type == 'apphistory' ? true : false;
        
        this._title = this.title;
        this._subTitle = this.subTitle;
        this._id = this.id;
        this._body = this.body;
    }

    openCloseContainer(event){
        this.isOpened = this.isOpened ? false : true;
        if(this.isOpened){
            event.target.iconName = 'utility:chevrondown';
            event.target.parentNode.parentNode.parentNode.classList.add('slds-is-open', 'slds-timeline_item_expanded');
        } else {
            event.target.iconName = 'utility:chevronleft';
            event.target.parentNode.parentNode.parentNode.classList.remove('slds-is-open', 'slds-timeline_item_expanded');  
        }
       
    }

    navigateToObject() {
        let objType = 'Case';
        if(this.type == 'appointment'){
            objType = 'Appointment__c';
        } else if(this.type == 'files'){
            objType = 'File__c';
        } else if(this.type == 'disabilities'){
            objType = 'Disabilities__c';
        } else if(this.type == 'contact'){
            objType = 'Contact';
        } else if(this.type == 'email' || this.type == 'call' || this.type == 'task'){
            objType = 'Task';
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.id.split('-')[0],
                objectApiName: objType,
                actionName: 'view'
            },
        });
    }

}