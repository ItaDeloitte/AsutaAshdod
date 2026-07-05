/* eslint-disable no-debugger */
/* eslint-disable no-mixed-spaces-and-tabs */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import GetPricesForMD from  '@salesforce/apex/ws_getPrices.getPricesFromMedProcedure';
//import GetPayerFactor from  '@salesforce/apex/UtilGetObjectData.getPayerFactor';
import getFieldValue from '@salesforce/apex/UtilGetObjectData.getFieldValue';
import fetchRecords from '@salesforce/apex/UtilGetObjectData.fetchRecordsByQuery';

export default class GetPrices extends LightningElement {

    @api medProcCode;
    @api medProcType; //"ניתוחית" - Surgical
    @api medProcName;

    @track sASArray;
    @track priceData = []

    siteCode;
    payerFactorParent;
    payerFactorCode;
    doctorCode;
    isSurgery = false;
    isAmbulatory = false;
    isError = false;
    isRes = false;
    getPricesContainer = `height: 12rem;overflow-y: unset !important;`;
    isLoaded = true;
    disableGetPricesBtn = true

    agreeYesNo; //מספר הסכם / מחירון
    surgeryAgreeSales; //[]עבור פעולה אמבולטורית
    surgeryAgreeResources; //[]עבור פעולה ניתוחית   
    errorMsg;//הודעת שגיאה ממשק מחירונים והסכמים
    selectedPayerFactor
    selectedSite
    selectedDoctor
    filterPF = {};
    filterSite = {};
    filterDoc = {};
    displayInfoPF = {}
    matchingInfoPF = {}    
    displayInfoSite = {}
    matchingInfoSite = {}    
    displayInfoDoc = {}
    matchingInfoDoc = {}

    connectedCallback(){
        this.filterPF = {
            criteria: [
                {
                    fieldPath: 'PresentOnSchdeuleScreen__c',
                    operator: 'eq',
                    value: true,
                }
            ],
            filterLogic: '1',
        };

        this.filterSite = {
            criteria: [
                {
                    fieldPath: 'Relevant_for_appointment_screen__c',
                    operator: 'eq',
                    value: true,
                }
            ],
            filterLogic: '1',
        };
        this.filterDoc = {
            criteria: [
                {
                    fieldPath: 'RecordType.DeveloperName',
                    operator: 'eq',
                    value: 'Doctor_Account',
                },
                {
                    fieldPath: 'Status__c',
                    operator: 'eq',
                    value: 'פ',
                }
            ],
            filterLogic: '1 AND 2',
        };
        this.displayInfoPF = {
            primaryField: 'Name',
            additionalFields: ['InsuranceCode__c'],
        };
        this.matchingInfoPF = {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'InsuranceCode__c' }],
        };
        this.displayInfoSite = {
            primaryField: 'Name',
            additionalFields: ['Site_Code__c'],
        };
        this.matchingInfoSite = {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Site_Code__c' }],
        };
        this.displayInfoDoc = {
            primaryField: 'Name',
            additionalFields: ['Doctor_Code__c'],
        };
        this.matchingInfoDoc = {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Doctor_Code__c' }],
        };
    }

    handleRecordPickerChange(event){
        if(event.target.label.includes('גורם משלם')){
            this.selectedPayerFactor = event.detail.recordId;
            if(this.selectedPayerFactor != null){
                let query = `SELECT Id, Code_Parent_for_Interface__c, InsuranceCode__c FROM Payer_Factor__c 
                            WHERE Id = \'${this.selectedPayerFactor}\'`;
                fetchRecords({ queryStr: query })
                .then(result => {
                    console.log('-------SUCCSESS-------------'); 
                    let recList = result;
                    this.payerFactorParent = recList[0]?.Code_Parent_for_Interface__c;
                    this.payerFactorCode = recList[0]?.InsuranceCode__c;
                })
                .catch(error => {
                    console.error('-------error-------------' + error);
                });                
            }
        } else if(event.target.label.includes('אתר')){
            this.selectedSite = event.detail.recordId;
            if(this.selectedSite != null){
                getFieldValue({ recId: this.selectedSite, fieldName: 'Site_Code__c' })
                .then(result => {
                    console.log('-------SUCCSESS-------------');
                    this.siteCode = result;
                })
                .catch(error => {
                    console.error('-------error-------------' + error);
                })
            }
        } else if(event.target.label.includes('רופא')){
            this.selectedDoctor = event.detail.recordId;
            getFieldValue({ recId: this.selectedDoctor, fieldName: 'Doctor_Code__c' })
            .then(result => {
                console.log('-------SUCCSESS-------------');
                this.doctorCode = result;
            })
            .catch(error => {
                console.error('-------error-------------' + error);
            });
        }      
        this.disableGetPricesBtn = !this.selectedPayerFactor || !this.selectedSite || this.selectedPayerFactor == null || this.selectedSite == null  
    }

    getPrices(){
        this.isLoaded = false;
        this.errorMsg = undefined;
        this.isRes = false;
        this.isAmbulatory = false;
        this.isSurgery = false;

        let date = new Date();
        let formatedDate = this.toSFDate(date);

        this.doctorCode = (this.doctorCode === undefined || this.doctorCode == null) ? '777' : this.doctorCode;

        let obj = `{"siteCode" : "${this.siteCode}",
                    "payerFactorParent" : "${this.payerFactorParent}",
                    "payerFactorCode" : "${this.payerFactorCode}",
                    "doctorCode" : "${this.doctorCode}",
                    "activityDate" : "${formatedDate}",
                    "activityCode_1" : "${this.medProcCode}"}`;

        console.log(`JSON input ${JSON.parse(JSON.stringify(obj))}`);
        GetPricesForMD({jsonInput: JSON.parse(JSON.stringify(obj))})
        .then (res => {
            console.log(`res ${res}`);
            if(res.ErrCodes.length > 0){
                this.isLoaded = true;
                this.isError=true;
                this.errorMsg = res.ErrCodes[0].Message;
            } else {
                this.isLoaded = true;
                this.isAmbulatory = true;
                this.isRes = true;
                this.agreeYesNo = res.AgreeYesNo === 'Y' ? 'יש הסכם' : 'אין הסכם';          
                if(this.medProcType !== 'Surgical' && this.medProcType !== 'ניתוחית' && res.SurgeryAgreeSales.length > 0){
                    this.sASArray = res.SurgeryAgreeSales;
                    this.sASArray.forEach(sa => {
                        if(sa.ClientNo === '0'){
                            sa.ClientNo = 'פרטי';
                        } else if (sa.ClientNo === '1111'){
                            sa.ClientNo = 'פרטי תייר';
                        } else if (sa.ClientNo === '166'){
                            sa.ClientNo = 'פרטי פרסונל';
                        }
                        sa.NetPrice = Math.floor(sa.NetPrice)
                        sa.Coin = sa.Coin === 'NIS' ? 'ש"ח' : sa.Coin; //מטבע
                    });

                    if(this.sASArray.length === 1){
                        this.getPricesContainer = `height: 18rem;!important`;
                    } else if(this.sASArray.length === 2){
                        this.getPricesContainer = `height: 23rem;!important`;
                    } else if(this.sASArray.length === 3){
                        this.getPricesContainer = `height: 29rem;!important`;
                    } else if(this.sASArray.length === 4){
                        this.getPricesContainer = `height: 36rem;!important`;
                    }                    
                } else if ((this.medProcType === 'Surgical' || this.medProcType === 'ניתוחית') && res.SurgeryAgreeResources.length > 0){
                    this.isSurgery = true;
                    let sergRes= res.SurgeryAgreeResources[0]; //[]עבור פעולה ניתוחית
                    let isInclVat = this.payerFactorCode === '0' || this.payerFactorCode === '166' || this.payerFactorCode === '1111'
                    this.priceData = [
                        {label : 'עלות חדר ניתוח (רבע שעה) כולל מע"מ', includeVat: isInclVat ? sergRes.PriceIncludeVat1 : undefined, netPrice: sergRes.NetPrice1, coin: sergRes.Coin1 === 'NIS' ? 'ש"ח' : sergRes.Coin1},
                        {label : 'פתולוגיה חתך קפוא כולל מע"מ', includeVat: isInclVat ? sergRes.PriceIncludeVat2 : undefined, netPrice: sergRes.NetPrice2, coin: sergRes.Coin2 === 'NIS' ? 'ש"ח' : sergRes.Coin2},
                        {label : 'פתולוגיה היסטולוגיה כולל מע"מ', includeVat: isInclVat ? sergRes.PriceIncludeVat3 : undefined, netPrice: sergRes.NetPrice3, coin: sergRes.Coin3 === 'NIS' ? 'ש"ח' : sergRes.Coin3},
                        {label : 'עלות חדר ניתוח פלסטיקה (רבע שעה) כולל מע"מ', includeVat: isInclVat ? sergRes.PriceIncludeVat4 : undefined, netPrice: sergRes.NetPrice4, coin: sergRes.Coin4 === 'NIS' ? 'ש"ח' : sergRes.Coin4},
                        {label : 'מרדים פרטי', includeVat: isInclVat ? sergRes.PriceIncludeVat5 : undefined, netPrice: sergRes.NetPrice5, coin: sergRes.Coin5 === 'NIS' ? 'ש"ח' : sergRes.Coin5},
                        {label : 'חדר פרטי', includeVat: sergRes.PriceIncludeVat6, netPrice: sergRes.NetPrice6, coin: sergRes.Coin6 === 'NIS' ? 'ש"ח' : sergRes.Coin6}
                    ]
                    this.getPricesContainer = `height: 40rem;!important`;
                }                   
            }             
            
        })
        .catch(error => {
            this.isLoaded = true;
            this.isError=true;
            this.errorMsg = 'תקלה טכנית';
            console.log(`error ${error}`);
        });
    }

    toSFDate(dateObj) {
	    // string format is YYYY-MM-DD         
        var dateStr = `${dateObj.getFullYear()}-${this.pad2(dateObj.getMonth()+1)}-${this.pad2(dateObj.getDate())}`;
        return dateStr;
    }

    pad2(number) {
	    return (number < 10 ? '0' : '') + number;
    }


}