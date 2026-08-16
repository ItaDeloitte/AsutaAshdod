/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           ws_insertDocumentToPortalRESTTest
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       15-06-2020
* @description    An interface for Insert document to Portal
* @Input          jsonInput       The patient details
* @Input          content         The Blob (file content)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/


public with sharing class ws_insertDocumentToPortalREST implements Queueable, Database.AllowsCallouts{

    private Map<String, String> jsonMap = new Map<String, String>();
    private Map<String, Portal__mdt> portalCodes = new Map<String, Portal__mdt>();
    private List<File__c> fileList = new List<File__c>();
    private Blob content = null;
    private Boolean reSend;
    private Boolean isSaveToPortal;   

    public ws_insertDocumentToPortalREST(Map<String, String> jsonInput, Blob content, Boolean reSend) {
        this.jsonMap = jsonInput;
        this.content = content;
        this.isSaveToPortal = false;
        this.reSend = reSend;
        for(Portal__mdt portal : [SELECT Id, Code__c, DeveloperName, Name__c FROM Portal__mdt WHERE saveToPortal__c = true]){
            this.portalCodes.put(portal.Code__c, portal);
        }
        if(this.jsonMap.containsKey('contVersionId')){
            System.debug('#####insertDocumentToPortal contDocumentId: '+this.jsonMap.get('contDocumentId'));
            this.fileList = [SELECT Id, Portal_Auto_Number__c, Account__r.ID_Number__c, Account__r.ID_Type__c, Account__r.LastName, Account__r.FirstName, file_type__c, Appointment__c, 
                                Appointment__r.Accession_Number__c,Appointment__r.Tafnit_Case_Number__c, DoctorName__c, DoctorName__r.DocIDNum__c, DoctorName__r.Name, DoctorName__r.Doctor_Code__c, Doctor_License__c, 
                                Doctor_ID__c, Number_of_commitment__c, 
                                Site__c, Site__r.Portal_Code__c, Medical_Procedure__r.Name, Medical_Procedure__r.Procedure_Code__c, Maccabi_Doctor_License__c, Maccabi_Doctor_Name__c,
                                Maccabi_Doctor_Code__c, IsSendAshdodPortal__c
                            FROM File__c 
                            WHERE Content_Version_Id__c =:this.jsonMap.get('contDocumentId') LIMIT 1]; //must be only one
            System.debug('#####insertDocumentToPortal fileType: '+this.fileList[0].file_type__c);
            this.jsonMap.put('fileId', this.fileList.size()>0 ? String.valueOf(this.fileList[0].Id) : '');
            this.jsonMap.put('target', '0'); //Not from Maccabi
            if(this.fileList.size()>0 && this.fileList[0].file_type__c != null && this.portalCodes.containsKey(this.fileList[0].file_type__c)){
                this.isSaveToPortal = true;
                this.jsonMap.put('patientId', this.fileList[0].Account__r.ID_Number__c != null ? this.fileList[0].Account__r.ID_Number__c : '');
                this.jsonMap.put('patientType', this.fileList[0].Account__r.ID_Type__c != null ? this.fileList[0].Account__r.ID_Type__c : '');
                this.jsonMap.put('patLastName', this.fileList[0].Account__r.LastName != null ? this.fileList[0].Account__r.LastName : '');
                this.jsonMap.put('patFirstName', this.fileList[0].Account__r.FirstName != null ? this.fileList[0].Account__r.FirstName : '');
                
                this.jsonMap.put('portalAutoNum', this.fileList[0].Portal_Auto_Number__c);
                jsonMap.put('executeDocId', this.fileList[0].Doctor_ID__c != null ? this.fileList[0].Doctor_ID__c : this.fileList[0].DoctorName__c != null && this.fileList[0].DoctorName__r.DocIDNum__c != null ? this.fileList[0].DoctorName__r.DocIDNum__c : this.fileList[0].Maccabi_Doctor_Code__c != null ? this.fileList[0].Maccabi_Doctor_Code__c : '');
                jsonMap.put('executeDocName', this.fileList[0].DoctorName__c != null && this.fileList[0].DoctorName__r.Name != null ? this.fileList[0].DoctorName__r.Name : this.fileList[0].Maccabi_Doctor_Name__c != null ? this.fileList[0].Maccabi_Doctor_Name__c : '');
                jsonMap.put('executeDocLic', this.fileList[0].Doctor_License__c != null ? this.fileList[0].Doctor_License__c : this.fileList[0].DoctorName__c != null && this.fileList[0].DoctorName__r.Doctor_Code__c != null ? this.fileList[0].DoctorName__r.Doctor_Code__c : this.fileList[0].Maccabi_Doctor_License__c != null ? this.fileList[0].Maccabi_Doctor_License__c : '');
            
                this.jsonMap.put('procdName', this.fileList[0].Medical_Procedure__r.Name != null ? this.fileList[0].Medical_Procedure__r.Name : '');
                this.jsonMap.put('procdCode', this.fileList[0].Medical_Procedure__r.Procedure_Code__c != null ? this.fileList[0].Medical_Procedure__r.Procedure_Code__c : '');
                this.jsonMap.put('commitmentNum', this.fileList[0].Number_of_commitment__c != null ? this.fileList[0].Number_of_commitment__c : '');

                this.jsonMap.put('servProviderCode', this.fileList[0].Site__c != null && this.fileList[0].Site__r.Portal_Code__c != null ? this.fileList[0].Site__r.Portal_Code__c : this.fileList[0].IsSendAshdodPortal__c ? '1608' : '');
                this.jsonMap.put('messageSubType', this.fileList[0].file_type__c == 'Referral' || this.fileList[0].file_type__c == '14' ? '14' : this.portalCodes.get(this.fileList[0].file_type__c).Code__c);
                this.jsonMap.put('examinationName', this.fileList[0].file_type__c == 'Referral' || this.fileList[0].file_type__c == '14' ? 'הפניה' : this.portalCodes.get(fileList[0].file_type__c).Name__c);
                this.jsonMap.put('accNum', this.fileList[0].Appointment__r.Accession_Number__c != null ? this.fileList[0].Appointment__r.Accession_Number__c : '');
                this.jsonMap.put('VisitCode', this.fileList[0].Appointment__r.Tafnit_Case_Number__c != null ? this.fileList[0].Appointment__r.Tafnit_Case_Number__c : '');
            }
        }
        System.debug('#####insertDocumentToPortal isSaveToPortal: '+this.isSaveToPortal);
    }

    public void execute(QueueableContext context){        
        if(this.isSaveToPortal){
            insertDocumentToPortal(this.jsonMap, this.content);
        } else {
            updateFile('', '', '', this.jsonMap);
        }
    }

    public void insertDocumentToPortal(Map<String, String> jsonMap, Blob content) {
        ENV__c env = ENV__c.getInstance();        
        String afterblob = EncodingUtil.base64Encode(content);

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(30000);
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/SalesForce/SalesForce2Portal/InsertDocument');
        JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject(); 
                        gen.writeStringField('MessageId', jsonMap.get('portalAutoNum'));
                        gen.writeStringField('Status', '1'); // 1-new; 3 update
                        gen.writeNumberField('UpdateNumber', 000); // 000-for new
                        gen.writeStringField('UpdateReason', '');
                        gen.writeNumberField('TargetCode', Integer.valueof(jsonMap.get('target'))); // מכבי = 2, כללית = 1 מאוחדת = 3 לאומית = 4, אחר= 0
                        gen.writeNumberField('ServiceProviderType', 1); // in Assuta always 1
                        gen.writeStringField('ServiceProviderCode', jsonMap.get('servProviderCode'));
                        gen.writeStringField('UnitType', '');
                        gen.writeStringField('UnitCode', '');
                        gen.writeStringField('ExecuteTime', String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));                        
                        gen.writeStringField('ExecuteDocID', jsonMap.get('executeDocId'));
                        gen.writeStringField('ExecuteDocName', jsonMap.get('executeDocName'));
                        gen.writeStringField('ExecuteDocLic', jsonMap.get('executeDocLic'));
                        gen.writeStringField('MessageSubType', jsonMap.get('messageSubType'));
                        gen.writeStringField('PatID', jsonMap.get('patientId'));
                        gen.writeStringField('IDPatCode', jsonMap.get('patientType') == '1' ? '0' : '9');  // 8 - other
                        gen.writeStringField('PatLastName', jsonMap.get('patLastName'));
                        gen.writeStringField('PatFirstName', jsonMap.get('patFirstName'));
                        gen.writeStringField('ExaminationName', jsonMap.get('examinationName'));
                        gen.writeFieldName('PDFFiles');
                        gen.writeStartObject();
                            gen.writeStringField('FileName', jsonMap.get('portalAutoNum')+'001.'+jsonMap.get('fileType')); //001 חדש 011 לאחר עדכון 1 021 לאחר עדכון שני וכו'
                            gen.writeStringField('FileContent', afterblob);
                        gen.writeEndObject();
                        gen.writeStringField('Pathological', '2'); // 2 - this is default, accsess with Stas
                        gen.writeBooleanField('Solved', true);
                        gen.writeStringField('AccNum', jsonMap.get('accNum'));
                        gen.writeFieldName('Procedures');
                        gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeStringField('ProcdName', jsonMap.get('procdName'));
                                gen.writeStringField('ProcdCode', jsonMap.get('procdCode'));
                                gen.writeStringField('ProcdDetail', '');
                            gen.writeEndObject();
                        gen.writeEndArray();
                        gen.writeNumberField('internet', 0); // המטופל מעוניו במידע באינטרנט 0 – לא מעוניין 1 – מעוניין
                        gen.writeStringField('VisitCode', jsonMap.get('VisitCode'));
                        gen.writeStringField('CompletePatID', jsonMap.get('patientId'));
                        gen.writeStringField('ExamCode', ''); 
                        gen.writeStringField('HitNum', jsonMap.get('commitmentNum'));
                    gen.writeEndObject();
        String sendMsg = gen.getAsString();
        System.debug('sendMsg: '+sendMsg);
        request.setBody(sendMsg);
        try{
            HttpResponse response = http.send(request);
            System.debug('response: '+response);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object res = results.get('AssutaResult');
                Dom.Document doc = new Dom.Document();
                doc.load(res+'');
                Dom.XmlNode rootNode = doc.getRootElement(),
                            pathNodeResults = rootNode.getChildElement('Results',null),
                            pathNodeStatus = rootNode.getChildElement('StatusCode',null),
                            pdfPath = pathNodeResults.getChildElement('PDFFileUrl',null);
                String pdfPathStr = pdfPath.getText();
                String statusCode = pathNodeStatus.getText();  
                String cvId = jsonMap.get('contVersionId');                              
                if(statusCode.trim() == '1'){
                    System.debug('#######deleteDocument: '+pdfPathStr);
                    updateFile(pdfPathStr, statusCode.trim(), '', jsonMap);
                    update new ContentVersion(Id= Id.valueOf(cvId), IsNeedToBeDeleted__c = true);
                } else {
                    System.debug('#######statusCode: '+statusCode.trim());                    
                    updateFile(pdfPathStr, statusCode.trim(), '', jsonMap);
                    update new ContentVersion(Id= Id.valueOf(cvId), Portal_Status__c = statusCode.trim());
                }
            }
        } catch (exception e) {
            updateFile('', '0', e.getMessage(), jsonMap);
            System.debug('Error: An exception has been encountered while calling out to InsertDocument:  ' + e.getMessage());
        }
    }

    @TestVisible
    private void updateFile(String pdfPathStr, String portalStatus, String errorDetails, Map<String, String> jsonMap){
        File__c file = new File__c();
        file.Id = jsonMap.get('fileId');
        file.URL__c = pdfPathStr;  
        file.OriginFileVisible__c = true;
        file.Portal_Status__c = portalStatus;     
        file.Portal_error_details__c = errorDetails;
        if(!reSend) {
            //file.Name = jsonMap.get('fileName');                     
            file.GateScanner_JobId__c = jsonMap.get('target') == '2' ? '' : jsonMap.get('JobId');
            file.GateScaner_Status__c = jsonMap.get('target') == '2' ? '' : jsonMap.get('scanStatus');
            file.GateScaner_FileScanStatus__c = jsonMap.get('target') == '2' ? '' : jsonMap.get('scanFileResult');
        }
                        
        Database.SaveResult updateResult  = Database.update(file, false);
        if(updateResult.isSuccess()){
            System.debug('#######updateFile: succsess: ' + updateResult);
        } else {
            for(Database.Error err : updateResult.getErrors()) {
                System.debug('#######updateFile: failed: ' + updateResult);
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('File__c fields that affected this error: ' + err.getFields());
            }
        }          
    }
}