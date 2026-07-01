/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          23-05-2021
* @modified         DD-MM-YYYY
* @description      An interface for get Ambulatory Commitment from Maccabi
* @test             ws_getAmbulatoryCommitmentRESTTest    
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class ws_getAmbulatoryCommitmentREST {
    public ws_getAmbulatoryCommitmentREST() {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive number of comitment and create new file typeOf  התחייבות
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appId                record Id of appointment
    * @param    patientAccId         record Id of patient
    * @param    patientNum           patient Id number 
    * @param    procedureCode        Procedure Code of Appointment
    * @param    appointmentDate      Date of Appointment
    * @param    siteCode             SiteCode of Appointment
    * @return   result                                          
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future(callout=true) @AuraEnabled(cacheable=false)
    public static void getAmbulatoryCommitment (Id appId, Id patientAccId, String memberId, String memberIdCode, String procedureCode, Date appointmentDate, String siteCode) {
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/maccabicommitments/getcommitment');
       
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('PatientID', memberId);
            gen.writeStringField('ProcedureCode', procedureCode);
            gen.writeStringField('AppointmentDate', String.valueOf(appointmentDate));
            gen.writeStringField('ServiceProviderCode', siteCode != '33' ? '1701' : '1608');
            gen.writeEndObject();              
        String sendMsg = gen.getAsString();
        request.setBody(sendMsg);
        try{
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String commitmentId = String.valueOf(results.get('CommitmentID'));
                String commitmentErrCode = String.valueOf(results.get('Success')) == 'true'? '0' : 'E';                
                String commitmentErrDesc = String.valueOf(results.get('ErrorMessage'));
                String status = commitmentId != null && commitmentErrCode == '0' ? '0' : 
                                commitmentErrCode == 'E' && commitmentErrDesc == '2 = סטטוס התחייבות' ? '22' : 'E';
                if (status == '0') {
                    Map<String, String> comData = new Map<String, String>();
                    comData.put('refType', null);
                    comData.put('accountID', patientAccId);
                    comData.put('appId', appId);
                    comData.put('LiabilityID', commitmentId);
                    //comData.put('DateCreateLiability', String.valueOf(Date.today()));
                    comData.put('ErrorCode', commitmentErrCode);
                    comData.put('DescriptionRemark', commitmentErrDesc);
                    receiveDocumentFromMaccabi(patientAccId, memberId, memberIdCode, commitmentID, comData);
                }
                update new Appointment__c(Id = appId, Commitment_Status__c = status, Number_of_commitment__c = commitmentId);
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to getAmbulatoryCommitment: ' + e.getMessage());
        }  
    }  

    public static void receiveDocumentFromMaccabi (Id patientAccId, String memberId, String memberIdCode, String commitmentID, Map<String, String> comData) {        
        Boolean isRecivedCommitmentFile = false;
        String commitmentFileErrCode = '9b';
        Blob attachContentCom = Blob.valueOf('');
        try{/*Callout isReceiveDocumentFromArc - COMMITMENT*/
            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberId, memberIdCode, commitmentID, true); 
            Dom.Document docCom = new Dom.Document();
            docCom.load(resultIsReceiveDocFromArc);
            commitmentFileErrCode = docCom.getRootElement().getChildElement('ErrorCode', null).getText();
            attachContentCom = EncodingUtil.base64Decode(docCom.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
            isRecivedCommitmentFile = commitmentFileErrCode.Trim() == '0' ? true : false;
            comData.put('referralErrorCode', commitmentFileErrCode);
            System.debug('isRecivedCommitmentFile ErrorCode : '+ isRecivedCommitmentFile);
            Id fileId = MaccabiIntegration.insertFileCommitment(comData, new List<String>());
            if(fileId != null && isRecivedCommitmentFile) {
                MaccabiIntegration.insertAttachment(fileId, comData.get('LiabilityID')+' - התחייבות', attachContentCom, patientAccId);
            }
        } catch (Exception ex) {
            System.debug('ws_getAmbulatoryCommitmentREST.isReceiveDocumentFromArc fail: '+ex); 
        }       
    }           
}