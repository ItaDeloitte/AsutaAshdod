/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       02-10-2019
* @description    An interface for dowload scanned file from Gate Scanner  and save it in Portal
* @Input          Map<String, String> inputForDowload
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_gateScannerApi_Download_REST  implements Queueable, Database.AllowsCallouts{

    private String JobId = '';    
    private String outFileName = '';
    private String fileSize = '';
    private String medonEndpoint = '';
    private String portalNum = '';
    private String contDocumentId = '';
    private Map<String, String> jsonInput = new Map<String, String>();

    public ws_gateScannerApi_Download_REST(Map<String, String> inputForDowload) {
        this.jsonInput = inputForDowload;
        this.JobId = inputForDowload.get('JobId');
        this.outFileName = inputForDowload.get('outFileName');
        this.fileSize = inputForDowload.get('fileSize');
        this.medonEndpoint = inputForDowload.get('medonEndpoint');
        this.portalNum = inputForDowload.get('portalNum');
        this.contDocumentId = inputForDowload.get('contDocumentId');
    }

    public void execute(QueueableContext context){
        downloadFile();
    }


    public void downloadFile() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(medonEndpoint + '/v3/download/file/base64/'+JobId);
        request.setHeader('FileName', outFileName);
        request.setHeader('F-Size', fileSize);
        request.setHeader('Accept', 'application/octet-stream');

        try{
            HttpResponse response = http.send(request);
            System.debug('Received file stream:' + response.getBody());
            Blob blobOfFile = EncodingUtil.base64Decode(response.getBody());
            saveToPortal(blobOfFile, contDocumentId);            
        } catch(exception e){
            System.debug('Error: An exception has been encountered while calling out to download file:  ' + e.getMessage());
        }

    }


    public void saveToPortal(Blob blobOfFile, Id contDocumentId){
        ContentVersion oldVersion = [SELECT Id, PathOnClient, Title FROM ContentVersion WHERE ContentDocumentId =:contDocumentId];
        ContentVersion newVersion = new ContentVersion();
        newVersion.ContentDocumentId = contDocumentId;
        newVersion.VersionData = blobOfFile;
        newVersion.PathOnClient = oldVersion.PathOnClient; // חובה
        newVersion.Title = oldVersion.Title;
        insert newVersion;

        System.debug('#######START saveToPortal: ');
        System.enqueueJob(new ws_insertDocumentToPortalREST(jsonInput, blobOfFile, false));
        System.debug('######END saveToPortal: ');
    }

}