@isTest
public with sharing class ws_gateScannerApi_Test {

    @isTest
    static void testUploadFileFail() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiUpload_Mock());

        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Test.startTest();        
        System.enqueueJob(new ws_gateScannerApi_Upload_REST(cVersion.Id));
        Test.stopTest();
    }

    @isTest
    static void testUploadFileSuccsess() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiUpload_Mock1());

        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Test.startTest();        
        System.enqueueJob(new ws_gateScannerApi_Upload_REST(cVersion.Id));
        Test.stopTest();
    }

    @isTest
    static void testScanFileSuccsess() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiUpload_Mock1());
        
        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Map<String, String> inputForScan = new Map<String, String>{
            'medonEndpoint' => 'https://esbwebdev.asuta.co.il/csp/salesforceWS/callout:Ensemble_SF_DEV/Assuta.Maccabi.BS.RetrievingServiceReferrals.cls',
            'JobId' => '123-45-678-932-165-49-87',
            'contVersionId' => cVersion.Id,
            'fileId' => file.Id,
            'counter' => '0'
        };

        Test.startTest();        
        System.enqueueJob(new ws_gateScannerApi_Scan_REST(inputForScan));
        Test.stopTest();
    }

    @isTest 
    static void testDownloadFileSuccsess() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiDownload_Mock());

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Id cDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Case cas = new Case(AccountId = patient.Id, Status = 'New');
        insert cas;

        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(cas.Id);
        cDocLink.ContentDocumentId = cDocId;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;

        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        Map<String, String> inputForDowload = new Map<String, String>{
            'medonEndpoint' => 'https://esbwebdev.asuta.co.il/csp/salesforceWS/callout:Ensemble_SF_DEV/Assuta.Maccabi.BS.RetrievingServiceReferrals.cls',
            'JobId' => '123-45-678-932-165-49-87',
            'contVersionId' => cVersion.Id,
            'outFileName' => 'gatefg45',
            'portalNum' => '132456765',
            'contDocumentId' => cDocId,
            'fileSize' => '1234',
            'fileId' => file.Id
        };

        Test.startTest();
        System.enqueueJob(new ws_gateScannerApi_Download_REST(inputForDowload));
        Test.stopTest();
    }

    @isTest
    static void testDownloadFileSuccsess1() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiDownload_Mock());

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Id cDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(patient.Id);
        cDocLink.ContentDocumentId = cDocId;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;

        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        Map<String, String> inputForDowload = new Map<String, String>{
            'medonEndpoint' => 'https://esbwebdev.asuta.co.il/csp/salesforceWS/callout:Ensemble_SF_DEV/Assuta.Maccabi.BS.RetrievingServiceReferrals.cls',
            'JobId' => '123-45-678-932-165-49-87',
            'contVersionId' => cVersion.Id,
            'contDocumentId' => cDocId,
            'outFileName' => 'gatefg45',
            'portalNum' => '132456765',
            'fileSize' => '1234',
            'fileId' => file.Id
        };

        Test.startTest();
        System.enqueueJob(new ws_gateScannerApi_Download_REST(inputForDowload));
        Test.stopTest();
    }

    @isTest 
    static void ws_gateScannerApiRESTTest() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiDownload_Mock());
        
        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Test.startTest();
        System.enqueueJob(new ws_gateScannerApiREST(cVersion));
        Test.stopTest();
    }

    @isTest
    static void ws_gateScannerApiREST0Test() {
        Test.setMock(HttpCalloutMock.class, new ws_gateScannerApiUpload_Mock1());

        File__c file = TestDataFactory.getFile();
        file.RecordTypeId = TestDataFactory.getRTId('General', 'File__c');
        file.file_type__c = '14';
        insert file;

        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.TEST__c = true;
        insert cVersion;

        Test.startTest();
        ws_gateScannerApiREST inst = new ws_gateScannerApiREST(cVersion);
        System.enqueueJob(inst);
        Test.stopTest();
        try {
            inst.scanFile(1);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public class ws_gateScannerApiREST_Mock  implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"JobDescription":null,"JobError":null,"JobID":"6cf45364-9dc0-4df8-b28b-02ae35930b15","PlaceInQueue":-99,"ScanProgress":0,"ScanStageProgress":0,"Scan_Status_c":3,"ScansLogArr":[{"Result":2,"OutputFileName":"name","FileSizeBytes":"20"}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}