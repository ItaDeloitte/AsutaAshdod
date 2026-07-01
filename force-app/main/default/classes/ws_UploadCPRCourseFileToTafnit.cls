/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * {PostFiles} REST Apex class to upload the CRP Course Files to Tafnit
 * 
 * Test                 ws_UploadCPRCourseFileToTafnitTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-11-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class ws_UploadCPRCourseFileToTafnit {

    private static final ENV__c ENV = ENV__c.getInstance();
    private static final String NAMED_CREDENTIAL = 'callout:Ensemble_Rest_' + ENV.Env_value__c;
    private static final String REST_RESOURCE = '/CprSF2Tafnit/ToTafnit';
    private static final String ENDPOINT = NAMED_CREDENTIAL + REST_RESOURCE;

    public static PostFilesResponse postFiles(String doctorCode, List<File__c> files) {
        System.debug('ws_UploadCPRCourseFileToTafnit.postFiles ...');

        String reqBody = JSON.serialize(new PostFilesRequest(generateGUID(), doctorCode, files));
        System.debug('ws_UploadCPRCourseFileToTafnit.postFiles Request: ' + reqBody);

        try {
            HttpResponse hRes = doPost(reqBody);
            System.debug('ws_UploadCPRCourseFileToTafnit.postFiles Status: ' + hRes.getStatus());
            System.debug('ws_UploadCPRCourseFileToTafnit.postFiles StatusCode: ' + hRes.getStatusCode());

            String resBody = hRes.getBody();
            System.debug('ws_UploadCPRCourseFileToTafnit.postFiles Response: ' + resBody);

            if (hRes.getStatusCode() == 200) {
                return (PostFilesResponse) JSON.deserialize(resBody, PostFilesResponse.class);
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to ' + REST_RESOURCE + ':' + e.getMessage());
        }

        return new PostFilesResponse();
    }

    private static HttpResponse doPost(String body) {
        Http http = new Http();
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Content-Type', 'application/json');
        hReq.setEndpoint(ENDPOINT);
        hReq.setMethod('POST');
        hReq.setTimeout(3000);
        hReq.setBody(body);
        return http.send(hReq);
    }

    private static String generateGUID() {
        String hex = EncodingUtil.convertToHex(Crypto.generateAesKey(128));

        return hex.SubString(0, 8)
            + '-' + hex.SubString(8, 12)
            + '-' + hex.SubString(12, 16)
            + '-' + hex.SubString(16, 20)
            + '-' + hex.substring(20);
    }

    /** WRAPPERS */
    public class PostFilesRequest {
        public String Guid;
        public String EmpNo;
        public String EmpType;
        public String PWinUser;
        public String RestName;
        public List<Subject> Subjects;

        public PostFilesRequest(String guid, String doctorCode, List<File__c> files) {
            this.Guid = guid;
            this.EmpNo = doctorCode;
            this.EmpType = '3';
            this.PWinUser = 'TAFSF01';
            this.RestName = 'PERSDOCINTAFNIT';

            this.Subjects = new List<Subject>();
            for (File__c file_i : files) {
                this.Subjects.add(new Subject(file_i));
            }
        }
    }

    public class Subject {
        public String EntityType;
        public String SubjectCode;
        public String SubSubjectCode;
        public String DocDateBegin;
        public String DocDateEnd;
        public String Remark;
        public String FileType;
        public String FileLink;
        public String KeyType;
        public String ScanDate;

        public Subject(File__c file) {
            this.EntityType = file.file_type__c;
            this.SubjectCode = file.Case__r.Approval_Topic__c;
            this.SubSubjectCode = file.Case__r.Approval_Sub_Topic__c;
            this.DocDateBegin = String.valueOf(file.DocDateBegin__c);
            this.DocDateEnd = String.valueOf(file.DocDateEnd__c);
            this.Remark = file.Remarks__c;
            this.FileType = file.FileExtension__c;
            if (!file.ContentDocumentLinks.isEmpty()) {
                this.FileLink = Url.getSalesforceBaseUrl().toExternalForm()
                    + '/sfc/servlet.shepherd/document/download/'
                    + file.ContentDocumentLinks.get(0).ContentDocumentId;
            }
            this.KeyType = file.file_type__c;
            this.ScanDate = String.valueOf(Date.today());
        }
    }

    public class PostFilesResponse {
        public String Guid;
        public String ResultStatus;
        public List<ErrCode> ErrCodes;
    }

    public class ErrCode {
        public String Tag;
        public String Message;
        public Long ErrorCode;
    }

    /** MOCK */
    global class ws_UploadCPRCourseFileToTafnitHttpMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            PostFilesResponse mock = new PostFilesResponse();
            mock.ResultStatus = '0';

            HttpResponse hRes = new HttpResponse();
            hRes.setHeader('Content-Type', 'application/json');
            hRes.setBody(JSON.serialize(mock));
            hRes.setStatusCode(200);
            return hRes;
        }
    }
}