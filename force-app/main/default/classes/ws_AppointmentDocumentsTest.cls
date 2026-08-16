@IsTest
private class ws_AppointmentDocumentsTest {

    @TestSetup
    static void setupData() {     
        insert TestDataFactory.getENV();

        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);        
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);       
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);       
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.ReminderId__c = '12345';
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);       
        insert site;
        Guidelines__c guideline = TestDataFactory.getGuidelines();        
        guideline.Guideline_Type__c = 'D';
        guideline.Required_documents__c = '14';
        insert guideline;
    
        Guidance_Scenario__c scenario = TestDataFactory.getGuidlineScenario(procedure.Id, guideline.Id, site.Id);           
        insert scenario;

        Related_document__c relatedDoc = TestDataFactory.getRelatedDoc(procedure.Id, '84');                        
        insert relatedDoc;  

        ContentVersion version = TestDataFactory.getContentVersion();                    
        version.CommercialName__c = 'Doc Label';
        version.RelatedDocumentUrl__c = 'https://example.com/test'; 
        insert version;
        
        ContentDocumentLink link = TestDataFactory.getContentDocLink(relatedDoc.Id);
        link.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id LIMIT 1].ContentDocumentId;      
        link.Visibility = 'AllUsers';      
        insert link;
               
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Date.today();
        appt.Guidance_Scenario__c = scenario.Id;
        appt.Related_document__c = relatedDoc.Id;       
        insert appt;    
        
        File__c file = new File__c(
            Name = 'Test File',
            Appointment__c = appt.Id,
            File_Type__c = '14'
        );
        insert file;
    }

     @IsTest
    static void testGetDocumentForApp() {        
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
       
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/AppointmentDocuments/';
        req.addParameter('appointmentId', appt.Id);
        RestContext.request = req;
        RestContext.response = new RestResponse();
       
        AppointmentDocumentsResponse response = ws_AppointmentDocuments.getDocumentForApp();

        System.assertNotEquals(null, response, 'AppointmentDocumentsResponse should not be null');
        System.assertNotEquals(0, response.requiredDocuments.size(), 'Should have required documents');
        System.assertNotEquals(0, response.relatedDocument.size(), 'Should have related documents');
    }

    @IsTest
    static void testGetDocumentForApp_NoAppointment() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/AppointmentDocuments/';
        req.addParameter('appointmentId', null);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        AppointmentDocumentsResponse response = ws_AppointmentDocuments.getDocumentForApp();
        System.assertEquals(0, response.requiredDocuments.size(), 'Expected empty required docs');
        System.assertEquals(0, response.relatedDocument.size(), 'Expected empty related docs');
    }

    @IsTest
    static void testGetDocumentForApp_InvalidId() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/AppointmentDocuments/';
        req.addParameter('appointmentId', 'a00XXXXXXXXXXXXXXX'); // Id לא קיים
        RestContext.request = req;
        RestContext.response = new RestResponse();

        AppointmentDocumentsResponse response = ws_AppointmentDocuments.getDocumentForApp();
        System.assertEquals(0, response.requiredDocuments.size(), 'Expected empty for invalid ID');
    }
}