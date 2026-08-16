/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────┐
 * Get ambulatory commitment for appointment that RellevantJobCommitment__c = true
 * ─────────────────────────────────────────────────────────────────────────────────────────────
 * @created         07-02-2022           <ortalk@assuta.co.il>
 * Test:GetAmbulatoryCommitmentBatchTest
 * ─────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class GetAmbulatoryCommitmentBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    List<String> insuranceCodes = new List<String>{'3','43','44','89'};
    
    String query = 'SELECT Id'
                    + ', Patient_Account__c'                    
                    + ', Patient_Account__r.ID_Type__c'
                    + ', IdNumberForMaccabi__c'                    
                    + ', Medical_Procedure__r.Procedure_Code__c'
                    + ', Medical_Procedure__r.Mabar_Code__c'
                    + ', Appointment_Date__c'
                    + ', Date_of_appointment__c'
                    + ', Site__c'
                    + ', Site__r.Site_Code__c'
                    + ', PayerFactor__r.InsuranceCode__c'
                    + ', RecordType.DeveloperName'                    
                    + ' FROM Appointment__c'
                    + ' WHERE (RecordType.DeveloperName = \'Institutes\''
                    + ' OR  RecordType.DeveloperName = \'Closedins\')'
                    + ' AND (Appointment_Date_Time__c = NEXT_N_DAYS:3 OR Appointment_Date_Time__c = TODAY)'                                    
                    + ' AND PayerFactor__r.InsuranceCode__c IN :insuranceCodes'
                    + ' AND Appointment_Status__c != \'Canceled\''
                    + ' AND Number_of_commitment__c = null'
                    + ' AND Domain__r.RellevantJobCommitment__c = true'                    
                    + ' ORDER BY Appointment_Date_Time__c'; 

    global GetAmbulatoryCommitmentBatch() {}

    global GetAmbulatoryCommitmentBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore(' WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('inside execute');
        Map<Id, Map<String, String>> appToComMap = new Map<Id, Map<String, String>>();          
        Map<Id, ContentVersion> appToConVMap = new Map<Id, ContentVersion>();
        Map<Id, File__c> appTofileMap = new Map<Id, File__c>();
        Map<Id, Id> conVeToConDocMap = new Map<Id, Id>();
        Set<Id> cvIds = new Set<Id>();
        List<ContentDocumentLink> cDocLinkToInsert = new List<ContentDocumentLink>();                                
        List<Appointment__c> appToUpdate = new List<Appointment__c>();
        
        
        for (Appointment__c app_i : scope) { 
            Map<String, String> appDetails;
            Blob attachment;            
            appDetails = getCommitment(app_i); 
            String Status = appDetails.containsKey('commId') && appDetails.get('commId') != null && appDetails.containsKey('commErrCode') && appDetails.get('commErrCode') == '0' ? '0' :
                            appDetails.get('commErrCode') == 'E' && appDetails.get('commErrDesc') == '2 = סטטוס התחייבות' ? '22'  : 'E'; 
            appDetails.put('status', Status); 
            appToComMap.put(app_i.Id, appDetails); 
            if (Status == '0') {                               
                attachment =  getDocument(appDetails.get('idNumber'), appDetails.get('idType'), appDetails.get('commId'));                               
                appTofileMap.put(app_i.Id, createFile(appDetails)); 
                if(attachment!= null && attachment != Blob.valueOf('')){
                    appToConVMap.put(app_i.Id, createContentVersion(appDetails.get('commId')+' - התחייבות', attachment));                                        
                }
                                                         
            }                                           
        }

        System.debug('appTofileMap.size ' + appTofileMap.size());
        if(!appTofileMap.isEmpty()){
            Database.insert(appTofileMap.values(), false);                        
        }

        System.debug('appToConVMap.size ' + appToConVMap.size());
        if(!appToConVMap.isEmpty()){
            List<Database.SaveResult> cvList = Database.insert(appToConVMap.values(), false);            
            for (Database.SaveResult cv : cvList) {
                if (cv.isSuccess()) {
                    cvIds.add(cv.getId());
                }
            }   
        }
        
        if(!cvIds.isEmpty()){
            for (ContentVersion conV_i :[SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds]){
                conVeToConDocMap.put(conV_i.Id, conV_i.ContentDocumentId);
            }
        }

        for (Appointment__c app_i : scope) {
                if (appToComMap.containsKey(app_i.Id)) {
                    appToUpdate.add(new Appointment__c(Id = app_i.Id, 
                                                       Commitment_Status__c = appToComMap.get(app_i.Id).get('status'), 
                                                       Number_of_commitment__c = appToComMap.get(app_i.Id).get('commId')));
                }
                if (appTofileMap.containsKey(app_i.Id) && 
                    appToConVMap.containsKey(app_i.Id) && 
                    conVeToConDocMap.containsKey(appToConVMap.get(app_i.Id).Id)
                ) {
                cDocLinkToInsert.add(createContentDocumentLink(
                                    appTofileMap.get(app_i.Id).Id, 
                                    conVeToConDocMap.get(appToConVMap.get(app_i.Id).Id))
                                    );                
            }
        } 

        if(!cDocLinkToInsert.isEmpty()){
            Database.insert(cDocLinkToInsert, false);     
        }

        System.debug('appToUpdate.size ' + appToUpdate.size());
        if(!appToUpdate.isEmpty()){
            Database.update(appToUpdate, false);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new GetAmbulatoryCommitmentBatch(), 25);
    }

    public static Map<String, String> getCommitment (Appointment__c app) {
        Map<String, String> appDetails = new Map<String, String>(); 
        appDetails.put('appId', app.Id);            
        if (app.Patient_Account__c != null) {
            appDetails.put('accountId', app.Patient_Account__c);                
        }
        if (app.IdNumberForMaccabi__c != null) {
            appDetails.put('idNumber', app.IdNumberForMaccabi__c);                
        }
        if (app.Patient_Account__r.ID_Type__c != null) {
            appDetails.put('idType', app.Patient_Account__r.ID_Type__c  == 'דרכון' ? '9' : '0');                
        }        
        if (app.Medical_Procedure__c != null) {
            String procedureCode = app.Medical_Procedure__r.Mabar_Code__c == null
                ? app.Medical_Procedure__r.Procedure_Code__c
                : app.Medical_Procedure__r.Mabar_Code__c;
            appDetails.put('procedureCode', procedureCode);
        }
        if (app.Date_of_appointment__c != null) {
            appDetails.put('appDate', String.valueOf(app.Date_of_appointment__c));
        }
        if (app.Site__c != null) {
            appDetails.put('siteCode', app.Site__r.Site_Code__c);
        }                    
        ws_getAmbulatoryCommitment getCommit_request = new ws_getAmbulatoryCommitment();
        Map<String, Object> results = getCommit_request.getCommitment(JSON.serialize(appDetails));
        if (results != null) {
            System.debug('results: ' + results);
            appDetails.put('commId', String.valueOf(results.get('CommitmentID')));
            appDetails.put('commErrCode', String.valueOf(results.get('Success')) == 'true'? '0' : 'E');
            appDetails.put('commErrDesc', String.valueOf(results.get('ErrorMessage')));            
        }
        return appDetails;
    }        

    public static Blob getDocument (String idNumber, String idType, String commitmentID) {        
        Boolean isRecivedCommitmentFile = false;
        String commitmentFileErrCode = '9b';
        Blob attachContentCom = Blob.valueOf('');
        try{/*Callout isReceiveDocumentFromArc - COMMITMENT*/
            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (idNumber, idType, commitmentID, true); 
            Dom.Document docCom = new Dom.Document();
            docCom.load(resultIsReceiveDocFromArc);
            commitmentFileErrCode = docCom.getRootElement().getChildElement('ErrorCode', null).getText();
            attachContentCom = EncodingUtil.base64Decode(docCom.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
            isRecivedCommitmentFile = commitmentFileErrCode.Trim() == '0' ? true : false;
            //comData.put('referralErrorCode', commitmentFileErrCode);
            System.debug('isRecivedCommitmentFile ErrorCode : '+ isRecivedCommitmentFile);
            return attachContentCom;
        } catch (Exception ex) {
            System.debug('ws_getAmbulatoryCommitmentREST.isReceiveDocumentFromArc fail: '+ex); 
            return null;
        }       
    }    
    
    public static File__c createFile (Map<String, String> appDetails) {         
        File__c newFile = new File__c();
        Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();                    
        newFile.file_type__c = '5';//Commmitment                
        newFile.Number_of_commitment__c = appDetails.get('commId');
        newFile.Appointment__c = Id.valueOf(appDetails.get('appId'));                             
        newFile.CommitmentStatus__c = appDetails.get('commErrCode');
        newFile.Commitment_Reason__c = appDetails.get('commErrDesc');                
        newFile.Name = appDetails.get('commId');                
        newFile.Account__c = Id.valueOf(appDetails.get('accountId'));               
        newFile.RecordTypeId = fileRTMap.get('Commitment').getRecordTypeId();                           
        return newFile;
    }

    public static ContentVersion createContentVersion (String fileName, Blob attachBody) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = attachBody;
        cv.PathOnClient = fileName+'.pdf';
        cv.Title = fileName;
        cv.IsMaccabiFile__c = true;  
        return cv;
    } 

    public static ContentDocumentLink createContentDocumentLink (Id fileId, Id conDocumentId) {
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId;
        cDocLink.LinkedEntityId = fileId;                
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        return cDocLink;
    }
}