/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable eqeqeq */
/* eslint-disable no-console */
/* eslint-disable handle-callback-err */
/* eslint-disable no-unused-vars */
/* eslint-disable no-useless-constructor */
/* eslint-disable no-debugger */
import { LightningElement, api, track, wire } from 'lwc';
import getCase from "@salesforce/apex/UtilGetObjectData.getCaseByAccount";
import getAppointment from "@salesforce/apex/UtilGetObjectData.getAppointmentByAccount";
import getFile from "@salesforce/apex/UtilGetObjectData.getFilesByAccount";
import getDisability from "@salesforce/apex/UtilGetObjectData.getDisabilitiesByAccount";
import getTask from "@salesforce/apex/UtilGetObjectData.getTasksByAccount";
import getContact from "@salesforce/apex/UtilGetObjectData.getContactsByAccount";
import getAccountContact from "@salesforce/apex/UtilGetObjectData.getAccountContactByAccount";
import getAppHistory from "@salesforce/apex/UtilGetObjectData.getAppHistory";
import { refreshApex } from '@salesforce/apex';


export default class Timeline extends LightningElement {
    
    @api recordId;
    @track _cases;
    @track _appointments;
    @track _apphistory;
    @track _files;
    @track _disabilities;
    @track _tasks;
    @track _contacts;
    @track accContact;
    @track openmodel = false;
    @track timelineTypeFilter = ['case', 'appointment', 'files', 'disabilities', 'email', 'call', 'task', 'contact', 'apphistory'];
    @track fromDate = `2015-${this.currentMonth}-${this.currentDay}T00:00:00Z`;
    @track toDate = `${this.currentYear}-${this.currentMonth}-${this.currentDay}T15:00:00Z`;
    @track timelineTypes;
    @track isCollapsed = true;
    @track loaded = true;
    @track isMoreData = true;

    @track timelineDataFull = [];
    @track timelineDataFiltered = [];
    @track timelineDataFilteredFirst = [];

    @track overflow = 'overflow-y: hidden;';

    get colExpIcon(){
        return this.isCollapsed ? 'utility:expand_all' : 'utility:collapse_all';
    }
    get timelineTypesOptions() {
        return [
            { label: 'פניות', value: 'case' },
            { label: 'תורים', value: 'appointment' },
            { label: 'מסמכים', value: 'files' },
            { label: 'מוגבלויות', value: 'disabilities' },
            { label: 'מיילים', value: 'email' },
            { label: 'שיחות', value: 'call' },
            { label: 'משימות', value: 'task' },
            { label: 'אנשי קשר', value: 'contact' },
            { label: 'היסטוריית תורים', value: 'apphistory' },
        ];
    }
    get currentYear(){
        var a = new Date();
        return a.getFullYear();
    }
    get currentMonth(){
        var a = new Date();
        return (a.getMonth()+1).toString().length == 1 ? `0${a.getMonth()+1}` : a.getMonth()+1;
    }
    get currentDay(){
        var a = new Date();
        return a.getDate().toString().length == 1 ? `0${a.getDate()}` : a.getDate();
    }
  
    renderedCallback(){
        if(!this.isRefreshed){
            this.isRefreshed = true;            
        }
    }

    connectedCallback(){
        this.getData();
    }

    getData(){
        Promise.all([
            getCase ({ accID: this.recordId })
            .then(res => {
                if(this._cases == undefined){
                    this._cases = res;
                    res.forEach((i) => {
                        this.timelineDataFull = [...this.timelineDataFull ,{type: 'case', title: `פניה חדשה ${i.CaseNumber}`, 
                                                                            subTitle: `${i.RecordType.Name} - ${i.sub_case_subject__c}`, 
                                                                            id: i.Id,
                                                                            dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)}, 
                                                                            body: [{fieldName : 'נושא', value: i.Case_subject__c}], 
                                                                            key: i.Id}];
                    })
                }                                  
            })
            .catch(err => {
                console.log('timeline - GetCases fail : '+err);
            }),

            getAppointment({ accID: this.recordId }) 
            .then(res => {
                if(this._appointments == undefined){
                    this._appointments = res;                        
                    res.forEach((i) => {
                        this.timelineDataFull = [...this.timelineDataFull ,{type: 'appointment', 
                                                                            title: 'תור חדש', 
                                                                            subTitle: i.Name,
                                                                            id: i.Id,
                                                                            dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                            body: [{fieldName : 'אתר', value: i.Site__c!= null ? i.Site__r.Name : ''}, {fieldName : 'סטאטוס', value: i.Appointment_Status__c!= null ? i.Appointment_Status__c : ''}],
                                                                            key: i.Id}];
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getAppointments fail : '+err);
            }),

            getAppHistory({ accID: this.recordId }) 
            .then(res => {
                if(this._apphistory == undefined){
                    res = res.filter(item => item.OldValue != 'NewAppointment');
                    this._apphistory = res;             
                    res.forEach((i) => {
                        this.timelineDataFull = [...this.timelineDataFull ,{type: 'apphistory', 
                                                                            title: 'סטאטוס תור השתנה', 
                                                                            subTitle: i.Parent.Name,
                                                                            id: i.ParentId,
                                                                            dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                            body: [{fieldName : 'שונה על ידי', value: i.CreatedBy.Name}, {fieldName : 'סטאטוס חדש', value: i.newVal}, {fieldName : 'סטאטוס ישן', value: i.oldVal}],
                                                                            key: i.Id}];
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getAppointments fail : '+err);
            }),

            getAccountContact({ accID: this.recordId }) 
            .then(accContact => {
                if(this.accContact == undefined){
                    accContact.forEach((accCon) => {
                        this.accContact = accCon;
                        getContact({ accID: this.accContact.ContactId }) 
                        .then(res => {
                            if(this._contacts== undefined){
                                this._contacts = res;                        
                                res.forEach((i) => {
                                    this.timelineDataFull = [...this.timelineDataFull ,{type: 'contact', 
                                                                                        title: 'הוספת איש קשר', 
                                                                                        subTitle: i.Name,
                                                                                        id: i.Id,
                                                                                        dateTime: {datetime: this.accContact.CreatedDate, date: this.getformattedDate(this.accContact.CreatedDate), time: this.getTime(this.accContact.CreatedDate)},
                                                                                        body: [{fieldName : 'סוג איק קשר', value: this.accContact.Roles}],
                                                                                        key: i.Id}];
                                })
                            }
                        })
                        .catch(err => {
                            console.log('timeline - getContacts fail : '+err);
                        })
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getAccountContacts fail : '+err);
            }),
            
            getFile({ accID: this.recordId }) 
            .then(res => {
                if(this._files == undefined){
                    this._files = res;                        
                    res.forEach((i) => {
                        this.timelineDataFull = [...this.timelineDataFull ,{type: 'files', 
                                                                            title: 'מסמך חדש', 
                                                                            subTitle: i.RecordType.Name,
                                                                            id: i.Id,
                                                                            dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                            body: [{fieldName : 'שם', value: i.Name}],
                                                                            key: i.Id}];
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getFile fail : '+err);
            }),

            getDisability({ accID: this.recordId }) 
            .then(res => {
                if(this._disabilities == undefined){
                    this._disabilities = res;                        
                    res.forEach((i) => {
                        this.timelineDataFull = [...this.timelineDataFull ,{type: 'disabilities', 
                                                                            title: 'מוגבלות חדשה', 
                                                                            subTitle: i.type,
                                                                            id: i.Id,
                                                                            dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                            body: [{fieldName : 'סוג', value: i.assType}, {fieldName : 'סטאטוס', value: i.Status_Disability__c}],
                                                                            key: i.Id}];
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getDisability fail : '+err);
            }),

            getTask({ accID: this.recordId }) 
            .then(res => {
                if(this._tasks == undefined){
                    this._tasks = res;                        
                    res.forEach((i) => {
                        if(i.Subject.includes('Email')){
                            this.timelineDataFull = [...this.timelineDataFull ,{type: 'email', 
                                                                                title: 'מייל חדש', 
                                                                                subTitle: i.Subject,
                                                                                id: i.Id,
                                                                                dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                                body: [{fieldName : 'שם', value: ''}, {fieldName : 'סטאטוס', value: ''}],
                                                                                key: i.Id}];
                        } else if(i.Subject.includes('Call')){
                            this.timelineDataFull = [...this.timelineDataFull ,{type: 'call', 
                                                                                title: 'שיחה חדשה', 
                                                                                subTitle: i.Subject,
                                                                                id: i.Id,
                                                                                dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                                body: [{fieldName : 'שם', value: ''}, {fieldName : 'סטאטוס', value: ''}],
                                                                                key: i.Id}];
                        } else {
                            this.timelineDataFull = [...this.timelineDataFull ,{type: 'task', 
                                                                                title: 'משימה חדשה', 
                                                                                subTitle: i.Subject,
                                                                                id: i.Id,
                                                                                dateTime: {datetime: i.CreatedDate, date: this.getformattedDate(i.CreatedDate), time: this.getTime(i.CreatedDate)},
                                                                                body: [{fieldName : 'שם', value: ''}, {fieldName : 'סטאטוס', value: ''}],
                                                                                key: i.Id}];                        
                        }
                    })
                }
            })
            .catch(err => {
                console.log('timeline - getTasks fail : '+err);
            })
        ]).then(()=> {
            this.timelineDataFull.sort((a, b) => {
                var dateA = new Date(a.dateTime.datetime).getTime();
                var dateB = new Date(b.dateTime.datetime).getTime();
                return dateA > dateB ? -1 : 1;  
            });
            debugger
            this.timelineDataFiltered = this.timelineDataFull;
            this.timelineDataFilteredFirst = this.timelineDataFiltered.slice(0, 5);
            console.log('timelineDataFull 1 : '+this.timelineDataFull.length);
            this.loaded = true;
        });
    }

    seeAllData(){
        this.timelineDataFilteredFirst = this.timelineDataFiltered;
        this.setScroll();
        this.isMoreData = false;
    }

    refresh(){
        this.loaded = false;
        this._cases = undefined;
        this._appointments = undefined;
        this._apphistory = undefined;
        this.accContact = undefined;
        this._files = undefined;
        this._disabilities = undefined;
        this._tasks = undefined;
        this.timelineDataFull = [];
        this.timelineDataFilteredFirst = [];
        this.getData();
    }

    openFilter(){
        this.openmodel = this.openmodel == true ? false : true;
    }

    closeFilter(){
        this.openmodel = false;
        this.timelineDataFiltered = this.timelineDataFull;
        this.timelineDataFiltered = this.timelineDataFiltered.filter(item => this.timelineTypeFilter.toString().indexOf(item.type) >= 0);
        if(this.fromDate){
            this.timelineDataFiltered = this.timelineDataFiltered.filter(item => item.dateTime.datetime>= this.fromDate);
        }
        if(this.toDate){
            this.timelineDataFiltered = this.timelineDataFiltered.filter(item => item.dateTime.datetime<= this.toDate);
        }
        this.setScroll();
    }

    setTimelineType(e) {
        this.timelineTypeFilter = e.detail.value;
    }
    
    genericOnChange(event){
        this[event.target.name] = event.target.value;
    }

    colupsExpandAction(){
         this.template.querySelectorAll('c-timeline-item').forEach(element => {
            element.expandCollaps();
        });
        this.isCollapsed = this.isCollapsed ? false : true;
    }

    checkAll() {
        for(let i=0; i<this.timelineTypesOptions.length; i++){
            this.timelineTypeFilter = [...this.timelineTypeFilter , this.timelineTypesOptions[i].value];
        }
    }

    uncheckAll() {
        this.timelineTypeFilter = [];
    }

    getformattedDate(date){
        return `${date.substr(0, 10).split("-")[2]}-${date.substr(0, 10).split("-")[1]}-${date.substr(0, 10).split("-")[0]}`
    }

    getTime(dateTime){
        let time = new Date(dateTime);
        let newTime = new Date(time);
        return newTime.toString().split(" ")[4].slice(0, 5);
    }

    setScroll(){
        if(this.timelineDataFiltered.length < 5){
            this.overflow = 'overflow-y: hidden;'
        } else {
            this.overflow = 'overflow-y: scroll;'
        }
    }


}