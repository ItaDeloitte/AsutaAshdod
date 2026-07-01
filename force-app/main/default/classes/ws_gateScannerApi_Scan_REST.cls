/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       02-10-2019
* @description    An interface for scan file by Gate Scanner  
* @Input          Map<String, String> inputForScan
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_gateScannerApi_Scan_REST implements Queueable, Database.AllowsCallouts{

    private String JobId = '';

    private Id contVersionId = null;
    private Integer counter = null;
    private String medonEndpoint = '';
    private String fileType = '';
    private String portalNum = '';
    private String scanStatus = '';
    private String scanFileResult = '';
    private Map<String, String> inputForScan = new Map<String, String>();

    public ws_gateScannerApi_Scan_REST(Map<String, String> inputForScan){
        this.inputForScan = inputForScan;
        this.JobId = inputForScan.get('JobId');
        this.contVersionId = inputForScan.get('contVersionId');
        this.counter = Integer.valueOf(inputForScan.get('counter'));
        this.medonEndpoint = inputForScan.get('medonEndpoint');
        this.fileType = inputForScan.get('fileType');
        this.scanStatus = inputForScan.get('scanStatus');
        this.scanFileResult = inputForScan.get('scanFileResult');
    }

    public void execute(QueueableContext context){
        scanFile(this.medonEndpoint, this.JobId, this.contVersionId, this.counter, this.fileType, this.scanStatus, this.scanFileResult);
    }
    

    private void scanFile(String medonEndpoint, String JobId, Id contVersionId, Integer counter, String fileType, String scanStatus, String scanFileResult) {
        System.debug('#######scanFile SCAN execute: ');
        System.debug('scanFile counter:' + counter);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(medonEndpoint + '/v3/scan/'+counter+'/'+JobId);
        try{
            HttpResponse response = http.send(request);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> logs = (List<Object>) results.get('ScansLogArr');
            scanStatus = String.valueOf(results.get('Scan_Status_c'));
            System.debug('#######scanStatus 2 : '+scanStatus);
            if(scanStatus == '3' || scanStatus == '4'){ //3- Finished  4- Recived
                for (Object log: logs) {
                    Map<String,Object> data = (Map<String,Object>)log;
                    scanFileResult = String.valueOf(data.get('Result'));
                    String outFileName = String.valueOf(data.get('OutputFileName'));
                    String fileSize = String.valueOf(data.get('FileSizeBytes'));
                    inputForScan.put('outFileName', outFileName);
                    inputForScan.put('fileSize', fileSize);
                    inputForScan.put('contVersionId', contVersionId);
                    System.debug('#######scanFileResult 2 : '+scanFileResult);
                    if(scanFileResult == '0' || scanFileResult == '2'){ //0- Ok  2- Reconstructed
                        inputForScan.put('scanStatus', scanStatus);
                        inputForScan.put('scanFileResult', scanFileResult);
                        System.enqueueJob(new ws_gateScannerApi_Download_REST(inputForScan));
                    } else if (scanFileResult == '3' || scanFileResult == '1'){ // 3- Error in Appication  1- Drop
                        System.debug('#######update ContentVersion: ');
                        update new ContentVersion(Id = contVersionId, GateScaner_Status__c = scanStatus, GateScaner_FileScanStatus__c = scanFileResult);
                        if(counter < 30 && scanFileResult == '3'){//When it is 60 - time CPU exided, need to be less
                            scanFile(medonEndpoint, jobID, contVersionId, counter+1, fileType, scanStatus, scanFileResult);
                        }
                    }
                }
            } else if(counter < 30 && (scanStatus == '1' || scanStatus == '2' || scanStatus == '5')) { //if less than 2 minutes
                sleep(3000);                
                scanFile(medonEndpoint, jobID, contVersionId, counter+1, fileType, scanStatus, scanFileResult);
            } else if(scanStatus == '0'){
                System.debug('Scan Status :' + 'The server return unknown status for the job. ');
            }         
        } catch (exception e) {
            update new ContentVersion(Id = contVersionId, GateScaner_Error__c = e.getMessage());
            System.debug('Error: An exception has been encountered while calling out to scan file:  ' + e.getMessage());
        }
    }

    
    private void sleep(Long milliSeconds) {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }


}