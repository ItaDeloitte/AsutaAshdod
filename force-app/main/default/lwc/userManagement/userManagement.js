import { LightningElement, track } from 'lwc';
import getUserPermissionsLiveAgent from '@salesforce/apex/UserManagementController.getUserPermissionsLiveAgent';
import getAgentName from '@salesforce/apex/UserManagementController.getAgentName';
import deleteUserPermissionsLiveAgent from '@salesforce/apex/UserManagementController.deleteUserPermissionsLiveAgent';
import insertUserPermissionsLiveAgent from '@salesforce/apex/UserManagementController.insertUserPermissionsLiveAgent';
import getMaxLicenses from '@salesforce/apex/UserManagementController.getMaxLicenses';
import { services } from 'c/assutaGlobalService';
import mustChooseAgent from '@salesforce/label/c.MustChooseAgent';
import EndLicenses from '@salesforce/label/c.EndLicenses';
import PermmisionSetRemove from '@salesforce/label/c.PermmisionSetRemove';
import PermmisionSetUpdate from '@salesforce/label/c.PermmisionSetUpdate';


const { toastService } = services;

const actions = [
    { label: 'מחק' , name: 'delete' },
];

const COLS = [
    { label: 'שם נציג', fieldName: 'Name', type: "text", editable: false },
    { label: 'הרשאה דיגיטלית', fieldName: 'UserPermissionsLiveAgentUser', type: "boolean", editable: false},
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];

export default class UserManagement extends LightningElement {
    @track error;
    @track columns = COLS;
    @track itemsUser = []; //this hold key, value pair for input
    @track listUser = []; //this hold columns for datatable
    @track userValue = "" ;
    @track visableBtn = false;
    @track noteLabel = "";
    
    initialized = false;
    insertedUserId;

    label = {
        mustChooseAgent,
        EndLicenses,
        PermmisionSetRemove,
        PermmisionSetUpdate
    };

    connectedCallback(){
        this.getUserPermissionsLiveAgent();
        this.getAgentName();
        this.getMaxLicenses();
    }

    renderedCallback() {
        if (this.initialized) {
            return;
        }
        this.initialized = true;
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", listId);
    }

    getAgentName(){
        getAgentName({})
        .then(data => {
            for(let i=0; i<data.length; i++)  {
                this.itemsUser = [...this.itemsUser ,{key: data[i].Id , value: data[i].Name} ];                                   
            } 
            console.log('ItemsUser => ', this.itemsUser, JSON.stringify(this.itemsUser));                      
            this.error = undefined;
        })
        .catch(error=>{
            this.error = error;
            console.log('error getAgentName: '+ error);
            this.itemsUser = undefined;
        })
    }

    getUserPermissionsLiveAgent(){
        getUserPermissionsLiveAgent({})
        .then(data => {
            for(let i=0; i<data.length; i++)  {
                this.listUser = [...this.listUser ,{Id: data[i].Id , Name: data[i].Name, UserPermissionsLiveAgentUser: true} ];                                   
            } 
            console.log('listUser => ', this.listUser, JSON.stringify(this.listUser)); 
            this.error = undefined;    
        })
        .catch(error=>{
            this.error = error;
            console.log('error getUserPermissionsLiveAgent: '+ error);
            this.listUser = undefined;
        })
    }

    getMaxLicenses(){
        getMaxLicenses({})
        .then(value =>{
            this.visableBtn = value;
            console.log('over max Licenses: ' + this.visableBtn);  
            if (this.visableBtn){
                this.noteLabel = this.label.EndLicenses;
            }
        })
        .catch(error=>{
            this.error = error;
            console.log('error getMaxLicenses: '+ error);
        })
    }

    handleChange(evt) {
        this.userValue = evt.target.value;
        console.log('Current value of the input value: ' + evt.target.value);  
    }

    addUser(){
        console.log('add User to data tabel');  
        if(this.userValue != ""){
            this.insertUserPermissions(this.userValue);
            this.itemsUser = this.itemsUser.filter(item => item.value != this.userValue);
            this.getMaxLicenses();
        }else{
            toastService.error(this, { message: this.label.mustChooseAgent });
        } 
    }

    handleRowAction(event) {
        this.listUser = this.listUser.filter(item => item.Id != event.detail.row.Id);
        const userId = event.detail.row.Id;
        this.deleteUserPermissions(userId);
        this.getMaxLicenses();
    }

    deleteUserPermissions(userId){
        deleteUserPermissionsLiveAgent({userId: userId})
            .then(() => {
                toastService.success(this, { message: this.label.PermmisionSetRemove});
            }).catch(error => {
                toastService.error(this, { message: error.body.message});
            });
    }

    insertUserPermissions(userName){
        insertUserPermissionsLiveAgent({userName: userName})
            .then(userId =>  {
                this.insertedUserId = userId;
                if(this.insertedUserId != undefined){
                    this.listUser = [...this.listUser ,{Id: this.insertedUserId , Name: this.userValue, UserPermissionsLiveAgentUser: true} ];
                    this.userValue = '';
                    toastService.success(this, { message: this.label.PermmisionSetUpdate });
                }
            }).catch(error => {
                toastService.error(this, { title: 'Error creating record', message: error.body.message });
            });
    }
}