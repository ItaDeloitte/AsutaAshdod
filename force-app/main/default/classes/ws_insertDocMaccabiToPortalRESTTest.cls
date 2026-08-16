@isTest
private class ws_insertDocMaccabiToPortalRESTTest {

    @TestSetup
    static void makeData() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar('Test');
        insert calendar;
        Appointment__c apt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        apt.Appointment_Date_Time__c = Date.today().addDays(3);
        insert apt;
        File__c file = TestDataFactory.getFile();
        file.File_Type__c = '14';
        file.IsMaccabi__c = true;
        file.Appointment__c = apt.Id;
        insert file;
        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.IsMaccabiFile__c = true;
        insert cVersion;
        Id cDocId = [SELECT ContentDocumentId FROM contentVersion WHERE Id =: cVersion.Id].contentDocumentId;
        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(file.Id);
        cDocLink.ContentDocumentId = cDocId;
        insert cDocLink;
        file.Content_Version_Id__c = cDocId;
        update file;
    }

    @isTest
    static void scheduleTest() {
        Test.setMock(HttpCalloutMock.class, new ws_insertDocMaccabiToPortal_Mock());
        Test.startTest();
        System.scheduleBatch(new ws_insertDocMaccabiToPortalREST(), 'InsertDoc batch test', 1);
        Test.stopTest();
    }

    @isTest
    static void scheduleTest_StatusCode_Test() {
        ws_insertDocMaccabiToPortal_Mock mock = new ws_insertDocMaccabiToPortal_Mock();
        mock.statusCode = '0';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.scheduleBatch(new ws_insertDocMaccabiToPortalREST(), 'InsertDoc batch test', 1);
        Test.stopTest();
    }
}