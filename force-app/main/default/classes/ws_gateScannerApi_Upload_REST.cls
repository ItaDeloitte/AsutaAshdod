/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       02-10-2019
* @description    An interface for upload file to Gate Scanner  
* @Input           Set<Id> conVersionIds
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_gateScannerApi_Upload_REST implements Queueable, Database.AllowsCallouts{

    private String gsKey = '';
    private String medonEndpoint = '';
    private String medonProfileId = '';
    private Map<Id, List<ContentDocumentLink>> contDocLinkMap = new Map<Id, List<ContentDocumentLink>>();
    private Map<String, String> inputForScan = new Map<String, String>();

    private String afterblob = '';
    private String fileType = '';
    private String fileName = '';
    private String jobID = '';
    private String scanStatus = '';
    private String scanFileResult = '';
    private ContentVersion contVersion = null;

    public Id conVersionId;

    public ws_gateScannerApi_Upload_REST(Id conVersionId) {
        this.conVersionId = conVersionId;
    }

    public void execute(QueueableContext context) {
        this.contVersion = [SELECT Id, FileExtension, VersionData, Title, GateScaner_Status__c, Portal_Status__c, ContentDocumentId FROM ContentVersion WHERE Id =: conVersionId];
        List<Endpoints__mdt> edpList = [SELECT Id, Key__c, Test__c, Profile_Id__c, Prod__c FROM Endpoints__mdt WHERE DeveloperName = 'ScannerApi'];
        if (!edpList.isEmpty()) {
            this.gsKey = edpList[0].Key__c;
            this.medonEndpoint = edpList[0].Prod__c;
            this.medonProfileId = edpList[0].Profile_Id__c;
        }
        uploadFile();
    }

    public void uploadFile() {
        afterblob = EncodingUtil.base64Encode(contVersion.VersionData);
        fileType = contVersion.FileExtension;
        fileName = date.today().format().replaceAll('[^a-zA-Z0-9\\s+]', '');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(this.medonEndpoint+'/v3/upload/file/base64');
        request.setHeader('FileName', fileName+'.'+fileType);
        request.setHeader('GS-Key', this.gsKey);
        request.setHeader('AppInfo', 'Assuta');
        request.setHeader('profileID', this.medonProfileId);
        request.setHeader('F-Size', String.valueOf(afterblob.length()));
        request.setHeader('Accept', 'application/json');
        request.setTimeout(60000);
        request.setBody(afterblob);

        try {
            HttpResponse response = http.send(request);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> logs = (List<Object>) results.get('ScansLogArr');
            System.debug('Received results:' + results);
            jobID = String.ValueOf(results.get('JobID'));
            scanStatus = String.valueOf(results.get('Scan_Status_c'));
            inputForScan.put('JobId', jobID);
            inputForScan.put('counter', '0');
            inputForScan.put('fileName', fileName+'.'+fileType);
            inputForScan.put('fileType', fileType);
            inputForScan.put('medonEndpoint', this.medonEndpoint);
            inputForScan.put('contVersionId', contVersion.Id);
            inputForScan.put('contDocumentId', contVersion.ContentDocumentId);
            System.debug('#######scanStatus: '+scanStatus);
            if (scanStatus == '3' || scanStatus == '4') { //3- Finished 4- Recived
                for (Object log: logs) {
                    Map<String,Object> data = (Map<String,Object>)log;
                    scanFileResult = String.valueOf(data.get('Result'));
                    String outFileName = String.valueOf(data.get('OutputFileName'));
                    String fileSize = String.valueOf(data.get('FileSizeBytes'));
                    System.debug('#######scanFileResult: '+scanFileResult);
                    if (scanFileResult == '0' || scanFileResult == '2') { //0- Ok 2- Reconstructed
                        inputForScan.put('scanStatus', scanStatus);
                        inputForScan.put('scanFileResult', scanFileResult);
                        System.enqueueJob(new ws_gateScannerApi_Download_REST(inputForScan));
                    } else if (scanFileResult == '3' || scanFileResult == '1') { // 3- Error in Appication 1- Drop
                        if (scanFileResult == '3') {
                            System.enqueueJob(new ws_gateScannerApi_Scan_REST(inputForScan));
                        }
                        update new ContentVersion(Id = contVersion.Id, GateScaner_Status__c = scanStatus, GateScaner_FileScanStatus__c = scanFileResult);
                        System.debug('#######update ContentVersion: '+contVersion.Id);
                    }
                }
            } else if (scanStatus == '1' || scanStatus == '2' || scanStatus == '5') { //if less than 2 minutes 1- InQueue 2- InScan 5- PreScan
                System.enqueueJob(new ws_gateScannerApi_Scan_REST(inputForScan));
            } else if (scanStatus == '0') { // 0- Unknown
                update new ContentVersion(Id = contVersion.Id, GateScaner_Status__c = scanStatus);
                System.debug('#######update ContentVersion: '+contVersion.Id);
                System.debug('Scan Status :' + 'The server return unknown status for the job. ');
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to uploadFile: ' + e.getMessage());
        }
    }
}