/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       DD-MM-YYYY
* @description    An interface for update reminderStatus about appointments that set in RIS/QFlow 
                  and not modified by Dev Integration user.       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_gateScannerApiREST implements Queueable, Database.AllowsCallouts{

    public static Blob blobOfFile = null;
    public static String scanStatus = '';
    public static String scanFileResult = '';

    public String afterblob = '';
    public String fileType = '';
    public String fileName = '';
    public static String jobID = '';
    public Id fileId = null;
    public Id contentVersionId = null;

    public String gsKey = '';
    private String medonEndpoint = '';

    public ws_gateScannerApiREST(ContentVersion contVersion) {
        this.afterblob = EncodingUtil.base64Encode(contVersion.VersionData);
        this.fileType = contVersion.FileType;
        this.fileName = contVersion.Title;
        this.contentVersionId = contVersion.Id;
    }
    
    public void execute(QueueableContext context){

        List<Endpoints__mdt> edpList = [SELECT Id, Key__c, Test__c, Prod__c FROM Endpoints__mdt WHERE DeveloperName='ScannerApi'];        
        if(!edpList.isEmpty()){
            gsKey = edpList[0].Key__c;
            medonEndpoint = edpList[0].Prod__c;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(medonEndpoint+'upload/file');
        request.setHeader('FileName', fileName+'.'+fileType);
        request.setHeader('GS-Key', gsKey);
        request.setHeader('AppInfo', 'Assuta');
        request.setHeader('profileID', '1');
        request.setHeader('F-Size', String.valueOf(this.afterblob.length()));
        request.setHeader('Accept', 'application/json');

        request.setBody(this.afterblob);

        try{
            HttpResponse response = http.send(request);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Received results:' + results);
            jobID = String.ValueOf(results.get('JobID'));
            scanStatus = String.ValueOf(results.get('Scan_Status_c'));
            if(jobID != '' && (scanStatus == '1' || scanStatus == '2' || scanStatus == '5')){
                scanFile(1);
            }
        } catch(exception e){
                System.debug('Error: An exception has been encountered while calling out to gateScannerApiREST:  ' + e.getMessage());
        }

    }
    
    public void scanFile(Integer counter) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(medonEndpoint + 'scan/'+counter+'/'+JobId);
        HttpResponse response = http.send(request);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> logs = (List<Object>) results.get('ScansLogArr');
        scanStatus = String.valueOf(results.get('Scan_Status_c'));
        if(scanStatus == '3' || scanStatus == '4'){ //3- Finished  4- Recived
            for (Object log: logs) {
                Map<String,Object> data = (Map<String,Object>)log;
                scanFileResult = String.valueOf(data.get('Result'));
                String outFileName = String.valueOf(data.get('OutputFileName'));
                System.debug('outFileName '  + outFileName);
                String fileSize = String.valueOf(data.get('FileSizeBytes'));
                if(scanFileResult == '0' || scanFileResult == '2'){ //0- Ok  2- Reconstructed
                    downloadFile(outFileName, fileSize);
                } else if (scanFileResult == '3' || scanFileResult == '1'){ // 3- Error in Appication  1- Drop
                    if(counter < 60 && scanFileResult == '3'){
                        scanFile(counter+1);
                    }
                }
            }
        } else if(counter < 60 && (scanStatus == '1' || scanStatus == '2' || scanStatus == '5')) { //if less than 2 minutes
            sleep(2000);
            System.debug('scanFile counter:' + counter);
            scanFile(counter+1);
        } else if(scanStatus == '0'){
            System.debug('Scan Status :' + 'The server return unknown status for the job. ');
        }

    }

    public void downloadFile(String outFileName, String fileSize) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(medonEndpoint + 'download/file/'+JobId);
        request.setHeader('FileName', outFileName);
        request.setHeader('F-Size', fileSize);
        request.setHeader('Accept', 'application/octet-stream');

        HttpResponse response = http.send(request);
        System.debug('Received file stream:' + response.getBody());
        blobOfFile = EncodingUtil.base64Decode(response.getBody());
    }


    private void sleep(Long milliSeconds) {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }

}