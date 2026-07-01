@isTest
public class FileTriggerTest {

    @TestSetup
    static void prepareData() {
        insert TestDataFactory.getENV();
        Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.SMS_Phone_Number__c = null;
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        procedure1.Reminder_required__c = true;
        procedure1.SMS_Reminder__c = '0';
        insert procedure1;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor('333');
        pFactorParent.Insurance_Company__c = true;
        insert pFactorParent;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = pFactorParent.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;
        Payer_Factor__c pFactorChild = TestDataFactory.getPFactor('333');
        pFactorChild.Name_of_parent__c = pFactor.Id;
        insert pFactorChild;
        Medical_Procedure__c procedure2 = new Medical_Procedure__c();
        procedure2.Marketing_Procedure_Name__c = '';
        procedure2.Procedure_Code__c = '70.5';
        procedure2.Name = '';
        insert procedure2;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Case cas = TestDataFactory.getCase('IVF_Freezing_Eggs', doctor.Id, patient.Id, con.Id, pFactorChild.Id);
        insert cas;

        Guidelines__c guideline = TestDataFactory.getGuidelines();        
        guideline.Guideline_Type__c = 'D';
        guideline.Required_documents__c = '14';
        insert guideline;
    
        Guidance_Scenario__c scenario = TestDataFactory.getGuidlineScenario(procedure1.Id, guideline.Id, site.Id);           
        insert scenario;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Doctor_Account__c = doctor.Id;
        appt.Site__c = site.Id;
        appt.Guidance_Scenario__c = scenario.Id;
        insert appt;
        
	    Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Doctor_Account__c = doctor.Id;
        appt2.Site__c = site.Id;   
        appt2.SourceSystem__c = 'RIS';
        insert appt2;
        
        insert TestDataFactory.getContentVersion();
        ContentVersion version = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        File__c file = TestDataFactory.getFile();
        file.Content_Version_Id__c = version.ContentDocumentId;
        file.ReferralNumber__c = '12345';
        file.Appointment__c = appt.Id;
        file.file_type__c = '13';
        insert file;
        
        File__c fileToCase = TestDataFactory.getFile();
        fileToCase.Content_Version_Id__c = version.ContentDocumentId;
        fileToCase.ReferralNumber__c = '123456';
        fileToCase.Case__c = cas.Id;
        fileToCase.file_type__c = '13';
        insert fileToCase;
        
        File__c docFile = TestDataFactory.getFile();
        docFile.DoctorName__c = doctor.Id;
        docFile.RecordTypeId = TestDataFactory.getRTId('Doctor_Photo','File__c');
        insert docFile;
        
        File__c fileReSendPortal = TestDataFactory.getFile();
        fileReSendPortal.RecordTypeId = TestDataFactory.getRTId('General','File__c');
        fileReSendPortal.Content_Version_Id__c = version.ContentDocumentId;        
        fileReSendPortal.file_type__c = '97';
        insert fileReSendPortal;
    }

    @isTest
    static void markFileForDeletionTest() {
        File__c file = [SELECT Id, GateScaner_FileScanStatus__c FROM File__c WHERE ReferralNumber__c = '12345'];
        file.GateScaner_FileScanStatus__c = '1';

        Test.startTest();
        update file;
        Test.stopTest();
    }

    @isTest
    static void updatePortalURLTest() {
        File__c file = [SELECT Id, URL__c FROM File__c WHERE ReferralNumber__c = '12345'];
        file.URL__c = 'https://test.com/';

        Test.startTest();
        update file;
        Test.stopTest();
    }
    
    @isTest
    static void testInitDoctorPhoto(){
        
        Account docAcc = [SELECT Id FROM Account WHERE Doctor_Code__c = '111' LIMIT 1];
        File__c file = [SELECT Id, Content_Version_Id__c FROM File__c WHERE DoctorName__c =:docAcc.Id AND Content_Version_Id__c=null LIMIT 1];
        ContentVersion version = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        file.Content_Version_Id__c = version.ContentDocumentId;
        Test.startTest();
        update file;
        Test.stopTest();
    }

    @isTest
    static void markForwardToRISTest() {
        File__c file = [SELECT Id, URL__c FROM File__c WHERE ReferralNumber__c = '12345'];
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE SourceSystem__c = 'RIS' LIMIT 1];
        file.Appointment__c = appt.Id;
        file.URL__c = 'https://test.com/';
        file.RecordTypeId = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName().get('Referral').getRecordTypeId();
        Test.startTest();
        update file;
        Test.stopTest();
    }
    
    @isTest
    static void preventDuplicateCreationTest() {
    	File__c file = [SELECT Id, URL__c FROM File__c WHERE ReferralNumber__c = '12345'];
		file.ReferralNumber__c = '123';
        Test.startTest();
        update file;
        Test.stopTest();
    } 
    
    @isTest
    static void insertDocumentToPortalTest() {
    	File__c file = [SELECT Id, URL__c FROM File__c WHERE file_type__c = '97'];
		file.file_type__c = '13';
        file.GateScaner_FileScanStatus__c = '2';
        Test.startTest();
        update file;
        Test.stopTest();
    } 
    
    @isTest
    static void updateStatusForReqDocumentTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c where Guidance_Scenario__c != null];
		File__c file = TestDataFactory.getFile();
        file.ReferralNumber__c = '12345';
        file.Appointment__c = appt.Id;
        file.file_type__c = '13';
        Test.startTest();
        insert file;
        Test.stopTest();
    } 
}