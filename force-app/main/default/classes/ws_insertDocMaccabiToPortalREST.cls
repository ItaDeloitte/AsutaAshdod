// Test: ws_insertDocMaccabiToPortalRESTTest
global with sharing class ws_insertDocMaccabiToPortalREST implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {

    private String query = 'SELECT Id'
                              + ', URL__c'
                              + ', File_Type__c'
                              + ', Doctor_ID__c'
                              + ', Portal_Status__c'
                              + ', Doctor_License__c'
                              + ', OriginFileVisible__c'
                              + ', Content_Version_Id__c'
                              + ', Portal_Auto_Number__c'
                              + ', Number_of_commitment__c'
                              + ', Account__c'
                              + ', Account__r.LastName'
                              + ', Account__r.FirstName'
                              + ', Account__r.ID_Type__c'
                              + ', Account__r.ID_Number__c'
                              + ', DoctorName__c'
                              + ', DoctorName__r.Name'
                              + ', DoctorName__r.DocIDNum__c'
                              + ', DoctorName__r.Doctor_Code__c'
                              + ', Appointment__c'
                              + ', Appointment__r.Accession_Number__c'
                              + ', Appointment__r.Site__r.Portal_Code__c'
                              + ', Appointment__r.Tafnit_Case_Number__c'
                              + ', Medical_Procedure__c'
                              + ', Medical_Procedure__r.Name'
                              + ', Medical_Procedure__r.Procedure_Code__c'
                           + ' FROM File__c'
                           + ' WHERE URL__c = null'
                           + ' AND SendPortal__c = false'                         
                           + ' AND IsMaccabi__c = true'
                           + ' AND File_Type__c != null'
                           + ' AND Appointment__c != null'
                           + ' AND Content_Version_Id__c != null'
                           + ' AND CreatedDate > 2025-01-01T20:32:24.602+02:00' // Added by Yulia 08.11, to not run over files of 2019-2024
                        //    + ' AND Appointment__r.Appointment_Date_Time__c = NEXT_N_DAYS:7' // Added by Yulia 16.11, to give priority
                        //    + ' AND Appointment__r.Appointment_Date_Time__c = THIS_MONTH' //Added by Yulia 18.11
                           + ' ORDER BY Appointment__r.Appointment_Date_Time__c DESC'
                           + ' LIMIT 200';

    global ws_insertDocMaccabiToPortalREST() {}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<File__c> scope) {
        Map<Id, ContentVersion> fileIdToVersionMap = new Map<Id, ContentVersion>();
        Map<String, Portal__mdt> portalMap = new Map<String, Portal__mdt>();
        List<ContentVersion> versionsToUpdate = new List<ContentVersion>();
        List<File__c> filesToUpdate = new List<File__c>();
        Map<Id, Id> docIdToFileIdMap = new Map<Id, Id>();

        Map<Id, File__c> filesMap = new Map<Id, File__c>(scope);
        System.debug('filesMap: size: ' + filesMap.size() + ' value: ' + filesMap);

        for (File__c file_i : scope) {
            docIdToFileIdMap.put(file_i.Content_Version_Id__c, file_i.Id);
        }
        System.debug('docIdToFileIdMap: size: ' + docIdToFileIdMap.size() + ' value: ' + docIdToFileIdMap);

        for (ContentVersion version_i : [SELECT Id, ContentDocumentId, FileExtension, VersionData, IsNeedToBeDeleted__c, Portal_Status__c 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId IN: docIdToFileIdMap.keySet() AND IsMaccabiFile__c = true]) {
            fileIdToVersionMap.put(docIdToFileIdMap.get(version_i.ContentDocumentId), version_i);
        }
        System.debug('fileIdToVersionMap: size: ' + fileIdToVersionMap.size() + ' value: ' + fileIdToVersionMap);

        for (Portal__mdt portal : [SELECT Id, Code__c, DeveloperName, Name__c 
                                   FROM Portal__mdt 
                                   WHERE saveToPortal__c = true]) {
            portalMap.put(portal.Code__c, portal);
        }
        System.debug('portalMap: size: ' + portalMap.size() + ' value: ' + portalMap);

        for (File__c file_i : filesMap.values()) {
            if ((portalMap.containsKey(file_i.file_type__c) || file_i.file_type__c == 'Referral' || file_i.file_type__c == '14') && fileIdToVersionMap.containsKey(file_i.Id)) {
                ContentVersion version_i = fileIdToVersionMap.get(file_i.Id);
                insertDocumentToPortal(this.mapFile(file_i, version_i, portalMap));
                file_i.SendPortal__c = true;
                filesToUpdate.add(file_i);
                //InsertResult result_i = this.insertDocumentToPortal(this.mapFile(file_i, version_i, portalMap));

                // if (result_i != null) {
                //     file_i.Portal_Status__c = result_i.statusCode;
                //     file_i.URL__c = result_i.pdfPathStr;
                //     file_i.OriginFileVisible__c = true;

                //     if (result_i.statusCode == '1') {
                //         version_i.IsNeedToBeDeleted__c = true;
                //     } else {
                //         version_i.Portal_Status__c = result_i.statusCode;
                //     }
                //     filesToUpdate.add(file_i);
                //     versionsToUpdate.add(version_i);
                // }
            }
        }
        System.debug('filesToUpdate: size: ' + filesToUpdate.size() + ' value: ' + filesToUpdate);
        //System.debug('versionsToUpdate: size: ' + versionsToUpdate.size() + ' value: ' + versionsToUpdate);

        if (!filesToUpdate.isEmpty()) {
            Database.update(filesToUpdate, false);
        }
        /*if (!versionsToUpdate.isEmpty()) {
            Database.update(versionsToUpdate, false);
        }*/
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('ws_insertDocMaccabiToPortalREST ... finish');
        Datetime now = System.now().addMinutes(1);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('File to Portal Uploader #' + now.getTime(), CRONEXP, new ws_insertDocMaccabiToPortalREST());
    }
    
    private static void insertDocumentToPortal(String document) {
        InsertResult result = null;
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_' + env.Env_value__c + '/SalesForce/SalesForce2Portal/InsertDocument');
        request.setTimeout(25000);
        request.setBody(document);

        try {
            HttpResponse response = http.send(request);
            // if (response.getStatusCode() == 200) {
            //     Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //     Object res = results.get('AssutaResult');
            //     Dom.Document doc = new Dom.Document();
            //     doc.load(res + '');
            //     Dom.XmlNode rootNode = doc.getRootElement(),
            //         pathNodeResults = rootNode.getChildElement('Results', null),
            //         pathNodeStatus = rootNode.getChildElement('StatusCode', null),
            //         pdfPath = pathNodeResults.getChildElement('PDFFileUrl', null);

            //     return new InsertResult(pathNodeStatus.getText().trim(), pdfPath.getText());
            // }
            //return new InsertResult('0', ''); //added by Yuliya 06/11/2025
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to InsertDocument: ' + e.getMessage());
        }
        //return result;
    }

    public class InsertResult {
        String statusCode {set; get;}
        String pdfPathStr {set; get;}

        public InsertResult(String statusCode, String pdfPathStr) {
            this.statusCode = statusCode;
            this.pdfPathStr = pdfPathStr;
        }
    }

    private String mapFile(File__c file, ContentVersion version, Map<String, Portal__mdt> portalMap) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
            gen.writeStringField('MessageId', file.Portal_Auto_Number__c);
            gen.writeStringField('Status', '1'); // 1-new; 3 update
            gen.writeNumberField('UpdateNumber', 000); // 000-for new
            gen.writeStringField('UpdateReason', '');
            gen.writeNumberField('TargetCode', 2); // מכבי = 2 כללית = 1 מאוחדת = 3 לאומית = 4 אחר = 0
            gen.writeNumberField('ServiceProviderType', 1); // in Assuta always 1
            gen.writeStringField('ServiceProviderCode', file.Appointment__r.Site__r.Portal_Code__c != null ? file.Appointment__r.Site__r.Portal_Code__c : '');
            gen.writeStringField('UnitType', '');
            gen.writeStringField('UnitCode', '');
            gen.writeStringField('ExecuteTime', String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
            gen.writeStringField('ExecuteDocID', file.Doctor_ID__c != null ? file.Doctor_ID__c : file.DoctorName__r.DocIDNum__c != null ? file.DoctorName__r.DocIDNum__c : '');
            gen.writeStringField('ExecuteDocName', file.DoctorName__r.Name != null ? file.DoctorName__r.Name : '');
            gen.writeStringField('ExecuteDocLic', file.Doctor_License__c != null ? file.Doctor_License__c : file.DoctorName__r.Doctor_Code__c != null ? file.DoctorName__r.Doctor_Code__c : '');
            gen.writeStringField('MessageSubType', file.file_type__c == 'Referral' || file.file_type__c == '14' ? '14' : portalMap.get(file.file_type__c).Code__c);
            gen.writeStringField('PatID', file.Account__r.ID_Number__c != null ? file.Account__r.ID_Number__c : '');
            gen.writeStringField('IDPatCode', (file.Account__r.ID_Type__c != null ? file.Account__r.ID_Type__c : '') == '1' ? '0' : '9'); // 8 - other
            gen.writeStringField('PatLastName', file.Account__r.LastName != null ? file.Account__r.LastName : '');
            gen.writeStringField('PatFirstName', file.Account__r.FirstName != null ? file.Account__r.FirstName : '');
            gen.writeStringField('ExaminationName', file.file_type__c == 'Referral' || file.file_type__c == '14' ? 'הפניה' : portalMap.get(file.file_type__c).Name__c);
            gen.writeFieldName('PDFFiles');
                gen.writeStartObject();
                    gen.writeStringField('FileName', file.Portal_Auto_Number__c + '001.' + version.FileExtension); //001 חדש 011 לאחר עדכון 1 021 לאחר עדכון שני וכו'
                    gen.writeStringField('FileContent', EncodingUtil.base64Encode(version.VersionData));
                gen.writeEndObject();
            gen.writeStringField('Pathological', '2'); // 2 - this is default, accsess with Stas
            gen.writeBooleanField('Solved', true);
            gen.writeStringField('AccNum', file.Appointment__r.Accession_Number__c != null ? file.Appointment__r.Accession_Number__c : '');
            gen.writeFieldName('Procedures');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('ProcdName', file.Medical_Procedure__r.Name != null ? file.Medical_Procedure__r.Name : '');
                        gen.writeStringField('ProcdCode', file.Medical_Procedure__r.Procedure_Code__c != null ? file.Medical_Procedure__r.Procedure_Code__c : '');
                        gen.writeStringField('ProcdDetail', '');
                    gen.writeEndObject();
                gen.writeEndArray();
            gen.writeNumberField('internet', 0); // המטופל מעוניו במידע באינטרנט 0 – לא מעוניין 1 – מעוניין
            gen.writeStringField('VisitCode', file.Appointment__r.Tafnit_Case_Number__c != null ? file.Appointment__r.Tafnit_Case_Number__c : '');
            gen.writeStringField('CompletePatID', file.Account__r.ID_Number__c != null ? file.Account__r.ID_Number__c : '');
            gen.writeStringField('ExamCode', '');
            gen.writeStringField('HitNum', file.Number_of_commitment__c != null ? file.Number_of_commitment__c : '');
        gen.writeEndObject();

        return gen.getAsString();
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new ws_insertDocMaccabiToPortalREST(), 10);
    }
}