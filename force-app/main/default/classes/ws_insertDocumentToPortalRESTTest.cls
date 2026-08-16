@isTest
private class ws_insertDocumentToPortalRESTTest {

    @testSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new HTTP_Mock());
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Payer_Factor__c pfChild = TestDataFactory.getPFactor('333');
        pfChild.Name_of_parent__c = pFactor.Id;
        insert pfChild;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        cas.AccountId = patient.Id;
        insert cas;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        insert TestDataFactory.getContentVersion();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pfChild.Id;
        appt.Site__c = site.Id;
        insert appt;
        File__c file = TestDataFactory.getFile();
        file.Appointment__c = appt.Id;
        file.file_type__c = '13';
        file.Case__c = cas.Id;
        insert file;
    }

    @isTest
    static void queu1Test() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        File__c file = [SELECT Id FROM File__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        ContentVersion content = TestDataFactory.getContentVersion();
        insert content;

        ContentDocumentLink contentLink = TestDataFactory.getContentDocLink(file.Id);
        contentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.id].ContentDocumentId;
        insert contentLink;

        Test.startTest();
        Map<String, String> jsonInput = new Map<String, String>{
            'patientId_Maccabi' => acct.Id,
            'patientId' => acct.Id,
            'patientType' => '0',
            'patLastName' => 'patLastName',
            'patFirstName' => 'patFirstName',
            'fileType' => 'PDF',
            'fileId' => file.Id,
            'contVersionId' => content.Id,
            'contDocumentId' => contentLink.ContentDocumentId,
            'attachmentId' => contentLink.ContentDocumentId
        };

        ws_insertDocumentToPortalREST instance = new ws_insertDocumentToPortalREST(jsonInput, Blob.valueOf('test'), false);
        System.enqueueJob(instance);
        instance.updateFile('https//www.file', '0', '',jsonInput);
        Test.stopTest();
    }

    private class HTTP_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"AssutaResult":{"AutoNumber":"00454819"}}');
            response.setStatusCode(200);
            return response;
        }
    }
}