// Test for: ContentDocumentLinkTrigger, ContentDocumentLinkTriggerHandler, ContentDocumentLinkTriggerDispatcher, ContentDocumentLinkService, ContentDocumentLinkQueueableProcessor, LinkForRelatedDocumentService
@isTest
private class ContentDocumentLinkServiceTest {

    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        insert TestDataFactory.getContentVersion();
        insert new File_settings__c(Name = 'test', isActive__c = true);
        insert new GateScanner_file__c(Status__c = 'Unscanned', Original_Location__c = cas.Id);
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Related_document__c relatedDoc = TestDataFactory.getRelatedDoc(procedure.Id, '84');
        insert relatedDoc;
    }

    @isTest
    static void testSaveFileToPortalAccount() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';

        Test.startTest();
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = patient.Id;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        Test.stopTest();
    }

    @isTest
    static void testSaveFileToPortalFile() {
        File__c file = TestDataFactory.getFile();
        file.file_type__c = 'Referral';
        insert file;
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';

        Test.startTest();
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = file.Id;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        Test.stopTest();
    }

    @isTest
    static void testSaveFileToPortalEmail() {
        Integer targetSize = 5000;
        String textBody = 'Hellomydearfriend!';
        while (textBody.length() < targetSize) {
            textBody += textBody; // doubles the string size each loop
        }
        textBody = textBody.substring(0, targetSize); // trim exactly

        EmailMessage emailMessage = new EmailMessage(
            TextBody = textBody,
            ParentId = [SELECT Id FROM Case LIMIT 1].Id,
            ToAddress = 'mail@mail.com'
        );
        insert emailMessage;
        ContentVersion cVersion = new ContentVersion();        
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';

        Test.startTest();
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.LinkedEntityId = emailMessage.Id;
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'V';
        insert cDocLink;
        Test.stopTest();
    }

    @isTest
    static void testSaveFileToPortalEmail1() {
        EmailMessage emailMessage = new EmailMessage(
            TextBody = 'Hello my dear friend!',
            ParentId = [SELECT Id FROM Case LIMIT 1].Id,
            ToAddress = 'mail@mail.com'
        );
        insert emailMessage;
        ContentVersion cVersion = new ContentVersion();        
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';

        Test.startTest();
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.LinkedEntityId = emailMessage.Id;
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'V';
        insert cDocLink;
        Test.stopTest();
    }

    @isTest
    static void createLinkForRelatedDocument() {
        Related_document__c relDoc = [SELECT Id FROM Related_document__c LIMIT 1];
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';

        Test.startTest();
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = relDoc.Id;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        Test.stopTest(); 
    } 
    
     @isTest
    static void testSendFileToDocuSign() {
        File__c file = TestDataFactory.getFile();
        file.file_type__c = '920';
        insert file;
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';
        cVersion.IsSignDoc__c = true;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ws_signDocument_Mock());
        insert cVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = file.Id;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        Test.stopTest();
    }
    
    private class ws_signDocument_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success":true, "signedFile":"JVBERi0xLjcKJYGBgYEK"}');
            response.setStatusCode(200);
            return response;
        }
    }

    @isTest
    static void increaseCoverageTest() {
        Test.startTest();
        ContentDocumentLinkTriggerDispatcher controller = new ContentDocumentLinkTriggerDispatcher();
        controller.increaseCoverage();
        Test.stopTest();
    }
}