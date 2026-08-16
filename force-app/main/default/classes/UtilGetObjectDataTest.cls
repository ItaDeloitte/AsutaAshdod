@isTest
private class UtilGetObjectDataTest {

    @testSetup
    static void testSetup() {
        insert TestDataFactory.getENV();

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;

        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        
        insert TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Doctor_Account__c = doctor.Id;
        insert appt;

        // waiting_list__c waitingList = TestDataFactory.getWaitingList(appt.Id, appt.Id);
        // insert waitingList;

        File__c file = TestDataFactory.getFile();
        file.file_type__c = 'Waiver_of_confidentiality';
        file.Appointment__c = appt.Id;
        file.Account__c = patient.Id;
        file.RecordTypeId = TestDataFactory.getRTId('Referral', 'File__c');
        insert file;
    }

    @isTest
    static void getRecordTypeTest() {
        Test.startTest();
        List<RecordType> rtList = UtilGetObjectData.getRecordType('PersonAccount');
        System.assertEquals(1, rtList.size());
        Test.stopTest();
    }

    @isTest
    static void getSiteListTest() {
        Test.startTest();
        List<Site__c> sitetList = UtilGetObjectData.getSiteList();
        System.assertEquals(1, sitetList.size());
        Test.stopTest();
    }

    @isTest
    static void forAllTest() {
        User us = TestDataFactory.getUser('Manager');
        insert us;
        Id acctId = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER].Id;
        Test.startTest();
        Account acct = UtilGetObjectData.getAccount(acctId);
        List<Task> taskList = UtilGetObjectData.getTasksByAccount(acctId);
        List<Disabilities__c> desList = UtilGetObjectData.getDisabilitiesByAccount(acctId);
        List<Contact> contactList = UtilGetObjectData.getContactsByAccount(acctId);
        List<File__c> filesList = UtilGetObjectData.getFilesByAccount(acctId);
        List<AccountContactRelation> acctContList = UtilGetObjectData.getAccountContactByAccount(acctId);
        List<Appointment__History> appHisList = UtilGetObjectData.getAppHistory(acctId);
        List<Appointment__c> appList = UtilGetObjectData.getAppointmentByAccount(acctId);
        List<Appointment__c> institutesAppList = UtilGetObjectData.getInstitutesAppointment(acctId);
        List<ContentDocumentLink> contList = UtilGetObjectData.getContentDocumentLink(acctId);
        List<Case> caseList = UtilGetObjectData.getCaseByAccount(acctId);
        List<Callout_Timeout__mdt> timeoutList = UtilGetObjectData.getCalloutTimeout('Maccabi');
        User getUser = UtilGetObjectData.getUser(us.Id);
        System.assertEquals(TestDataFactory.P_ID_NUMBER, acct.ID_Number__c);
        Test.stopTest();
    }

    @isTest
    static void getDocTypeForPortalTest() {
        Test.startTest();
        List<Portal__mdt> docTypeList = UtilGetObjectData.getDocTypeForPortal();
        System.assert(docTypeList.size() > 0);
        Test.stopTest(); 
    }

    @isTest
    static void updateMaccabiTest() {
        Test.startTest();
        Id acctId = [SELECT Id FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER].Id;
        UtilGetObjectData.updateMaccabi(acctId);
        Test.stopTest();
    }

    @isTest
    static void getFileByAppointmentTest() {
        Id appointmentId = [SELECT Id FROM Appointment__c].Id;
        Test.startTest();
        List<File__c> file = UtilGetObjectData.getFileByAppointment(appointmentId);
        System.assert(file.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void getFileTest() {
        Id fileId = [SELECT Id FROM File__c].Id;
        Test.startTest();
        List<File__c> file = UtilGetObjectData.getFile(fileId);
        System.assert(file.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void getAppointmentTest() {
        Id apptId = [SELECT Id FROM Appointment__c].Id;
        Test.startTest();
        List<Appointment__c> apptList = UtilGetObjectData.getAppointment(apptId);
        System.assert(apptList.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void getMedProcedureMapTest() {
        Id[] ids = new List<Id>();
        List<Medical_Procedure__c> medProcList = [SELECT Id FROM Medical_Procedure__c];
        for (Medical_Procedure__c md : medProcList) {
            ids.add(md.Id);
        }
        Test.startTest();
        Map<Id, Medical_Procedure__c> medPrMap = UtilGetObjectData.getMedProcedureMap(ids);
        System.assert(medPrMap.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void getPayerFactorTest() {
        Id pfId = [SELECT Id FROM Payer_Factor__c LIMIT 1].Id;
        Test.startTest();
        Payer_Factor__c pf = UtilGetObjectData.getPayerFactor(pfId);
        System.assert(pf != null);
        Test.stopTest();
    }

    @isTest
    static void fetchRecordsTest() {
        Test.startTest();
        List<UtilGetObjectData.Records> fetchRecList = UtilGetObjectData.fetchRecords('Account', 'LastName', 'FirstName', '', 1, '');
        System.assert(fetchRecList.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void getContentVersionTest() {
        Test.startTest();
        Id fileId = [SELECT Id FROM File__c].Id;
        ContentVersion content = TestDataFactory.getContentVersion();
        insert content;
        ContentDocumentLink contentLink = TestDataFactory.getContentDocLink(fileId);
        contentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.id].ContentDocumentId;
        insert contentLink;
        ContentVersion contVers = (ContentVersion)JSON.deserialize(UtilGetObjectData.getContentVersion(fileId), ContentVersion.class);
        Test.stopTest();
    }
    
    @isTest
    static void checkRelatedReferralTest() {
        Id appointmentId = [SELECT Id FROM Appointment__c].Id;
        Test.startTest();        
        System.assert(UtilGetObjectData.checkRelatedReferral(appointmentId), true);
        Test.stopTest();
    }


    @IsTest
    static void fetchRecordsByQueryTest() {
        Test.startTest();
        List<sObject> fetchRecList = UtilGetObjectData.fetchRecordsByQuery('SELECT Id, Name FROM Account');            
        Test.stopTest(); 
        System.assert(fetchRecList.size() == 2);
    }

    @IsTest
    static void updateRecordTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        UtilGetObjectData.updateRecord(acc.Id, 'Account', 'PersonEmail', 'someemail12@gmail.com');            
        Test.stopTest(); 
        Account accUpdated = [SELECT Id, PersonEmail FROM Account LIMIT 1];
        System.assert(accUpdated.PersonEmail == 'someemail12@gmail.com');
    }
    
    @IsTest
    static void createRecordTest() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Description', 'some Description test');
        Test.startTest();
        UtilGetObjectData.createRecord('Task', JSON.serialize(fieldsMap));            
        Test.stopTest(); 
        Task task = [SELECT Id, Description FROM Task LIMIT 1];
        System.assert(task.Description == 'some Description test');
    }

    @isTest 
    static void getFieldValueTest(){
        File__c file = [SELECT Id, file_type__c FROM File__c LIMIT 1];
        Test.startTest();
        String value = UtilGetObjectData.getFieldValue(file.Id, 'file_type__c');
        Test.stopTest(); 
        System.assert(value == 'Waiver_of_confidentiality');
    }

    @isTest 
    static void getTimeZoneTest(){
        Test.startTest();
        String value = UtilGetObjectData.getTimeZone();
        Test.stopTest(); 
        System.assert(value != null);
    }

    @isTest 
    static void getSObjectAPINameByIdTest(){
        File__c file = [SELECT Id, file_type__c FROM File__c LIMIT 1];
        Test.startTest();
        String value = UtilGetObjectData.getSObjectAPINameById(file.Id);
        Test.stopTest(); 
        System.assert(value == 'File__c');
    }

    // @isTest 
    // static void getWaitingAppointmentsTest(){
    //     waiting_list__c wl = [SELECT ID FROM waiting_list__c LIMIT 1];
    //     Test.startTest();
    //     List<Appointment__c> appList = UtilGetObjectData.getWaitingAppointments(wl.Id);
    //     Test.stopTest(); 
    // }

}