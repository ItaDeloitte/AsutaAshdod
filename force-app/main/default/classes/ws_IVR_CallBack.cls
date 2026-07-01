/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          01-09-2019
* @modified         DD-MM-YYYY
* @description      An interface for IVR - CallBack 
                    URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_CallBack      
* @test             ws_IVR_CallBackTest
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/IVR_CallBack/*')
global class ws_IVR_CallBack {
    
    public ws_IVR_CallBack() {}
    public static Map<String, Object> callbackMap;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Post Json From Ensemble In the IVR Callback interface.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Json            
    * @return   Success       True/False
                ErrorMessage  Exception/Success
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPost
    global static void getCallBackDetails() {

        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();
        Id accountId = null;
        
        try{
            callbackMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            System.debug(' ***callbackMap*** ' + callbackMap);

            String actionCode = String.valueOf(callbackMap.get('ActionCode'));
            String direction = (actionCode == '0' || actionCode == '4' || actionCode == '5') ? 'Inbound':'Outbound';
            String patientId = String.valueOf(callbackMap.get('PatientId'));
            
            if(patientId != null && patientId != ''){       
                List<Account> accounts = [SELECT Id FROM Account WHERE  ID_Number__c = :patientId AND ID_Type__c = '1' AND RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
                System.debug(' ***accounts*** ' + accounts);
                if(!accounts.isEmpty()){
                    accountId = accounts[0].Id;
                }
                else{
                    Account patient = new Account(
                        ID_Number__c = patientId,
                        ID_Type__c = '1',
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
                    );
                    DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(patient, patient.ID_Number__c, patient.ID_Type__c);
                    if (accountWithDemography.IsDemographyExist) {
                        insert accountWithDemography.acct;
                        accountId = accountWithDemography.acct.Id;
                    } 
                    else{
                        Account generalPatient = new Account(
                        ID_Number__c = patientId,
                        ID_Type__c = '1',
                        LastName = patientId,
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
                        );
                        insert generalPatient;
                        accountId = generalPatient.Id;
                    }      
                }
            }

            
            if(actionCode == '2'){
                VDN__c VDNInfo = getVDNCodeToVDN(String.valueOf(callbackMap.get('VDN')));
                String callCenter = (VDNInfo != null && VDNInfo.CallCenter__c != null) ? VDNInfo.CallCenter__c : null;
                String smsTemplate = (callCenter == 'אסותא אשדוד') ? 'IVR_CallBack_Ashdod' : 'IVR_CallBack'; 
                SMS__c CBSMS = prepareSMS(smsTemplate, String.valueOf(callbackMap.get('PhoneNumber')), accountId);
                insert CBSMS;
            }

            createTask(accountId, direction);
            CommonService.createJsonResponse('1', 'Success'); 

        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', e.getMessage()); 
        } 
    }

    public static SMS__c prepareSMS (String smsTemplate, String phoneNumber, Id accountId) {
        return new SMS__c (
            Type__c = 'Outgoing',                       
            Phone_Number__c = phoneNumber,            
            smsTemplate__c = smsTemplate,
            Account__c = accountId,
            Received_Sent_Date_Time__c = datetime.now(),
            status__c = '1',
            Automation_name__c = 'ws_IVR_CallBack'
        );
    }


    public static VDN__c getVDNCodeToVDN (String vdn) {        
         List<VDN__c> VDNList = [SELECT CodeVDN__c, CallCenter__c FROM VDN__c WHERE CodeVDN__c = :vdn];
         if(!VDNList.isEmpty())
         {
             return VDNList.get(0);
         }
         return null;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * create new Task 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    accountId      sfId of account
    * @param    direction      Direction of conversation: Inbound/Outbound
    * @return   -----
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void createTask(ID accountId, String direction) {
        Task callBackTask = new Task(); 
            callBackTask.TaskSubtype = 'Call';
            callBackTask.Type = 'Call';
            callBackTask.Subject = 'Call';
            callBackTask.Call_ID__c = String.valueOf(callbackMap.get('UCID')); //מזהה שיחה
            callBackTask.related_account__c = accountId; //Related To Account
            callBackTask.PhoneForCallback__c = String.valueOf(callbackMap.get('PhoneForCallback')); // מס טלפון לחיוג חוזר
            callBackTask.NumberOfAttempts__c = String.valueOf(callbackMap.get('NumberOfAttempts'));//נסיונות חיוג
            callBackTask.CallStartTime__c = DateTime.valueOf(String.valueOf(callbackMap.get('CallCreatedOn')));//ת.יצירה
            callBackTask.CallDisposition = String.valueOf(callbackMap.get('CallResult'));//תוצאת נסיון חיוג
            callBackTask.CallResult__c = String.valueOf(callbackMap.get('CallResult'));//תוצאת נסיון חיוג
            callBackTask.CALLBACK_status__c = String.valueOf(callbackMap.get('ActionCode')); //סטאטוס השיחה
            callBackTask.CALLBACK__c = True; //מייצג משימה מסוג CallBack
            callBackTask.CallType = direction;
            callBackTask.Call_Type__c = (direction == 'Inbound') ? 'Incoming call (OutSide)' : 'Outcoming call (Outside)';
            callBackTask.Status = 'Completed';                     

            if(direction == 'Inbound'){
                callBackTask.Caller__c = String.valueOf(callbackMap.get('PhoneNumber')); //מס טלפון שממנו התקשר המטופל/הנציג
                callBackTask.Called__c = String.valueOf(callbackMap.get('VDN'));
            }else{
                callBackTask.Caller__c = String.valueOf(callbackMap.get('VDN'));
                callBackTask.Called__c = String.valueOf(callbackMap.get('PhoneForCallback')); //מס טלפון שממנו התקשר המטופל/הנציג
            }
    
        insert callBackTask;
        system.debug('callBackTask.ID ' + callBackTask.ID);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Put Json From Ensemble In the IVR Callback interface for Disease management 360.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Json          PatientId, UCID, Caller
    * @return   Success       True/False
                ErrorMessage  Exception/Success  
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPut
    global static void getCallBack360() {
        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();

        try{
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            System.debug('***jsonMap***' + jsonMap);

            Account account = [SELECT Id, Case_360__c , X360_patient_checkbox__c FROM Account WHERE  ID_Number__c = : String.valueOf(jsonMap.get('PatientId')) And RecordType.DeveloperName = 'PersonAccount'];
            
            Task callBack360Task = new Task(); 
            callBack360Task.TaskSubtype = 'Call';
            callBack360Task.Type = 'Call';
            callBack360Task.Subject = 'Call';
            callBack360Task.related_account__c = account.Id;//Related To Account
            callBack360Task.OriginalCallObjectId__c = String.valueOf(jsonMap.get('UCID')); //מזהה שיחה
            callBack360Task.Caller__c = String.valueOf(jsonMap.get('Caller'));
            callBack360Task.CallType = 'Inbound';
            callBack360Task.Status = 'Completed';

            if(account != null && account.Case_360__c != null && account.X360_patient_checkbox__c){
                callBack360Task.WhatId = account.Case_360__c;//Related To Case
                callBack360Task.Hidden_Case__c = account.Case_360__c; 
            }
            insert callBack360Task;
            CommonService.createJsonResponse('1', 'Success'); 
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', e.getMessage()); 
        } 
    }
}