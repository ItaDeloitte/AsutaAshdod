//Created by Ortal k.
@isTest
public with sharing class ws_OpenRecordAccountByQFTest {

    @testSetup
    static void testSetup() {
        insert new ENV__c(Env_value__c = 'QA');
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PROCEDURE_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c = DateTime.now();
        appt.Accession_Number__c = 'R121440';
        insert appt;
    }

    @isTest
    static void getDetailsForOpenAccountTest() {
        User user = TestDataFactory.getUser('System Administrator');
        user.UserName = 'qatest@assuta.co.il';
        insert user;
        Account patient = [SELECT Id, ID_Number__c, ID_Type__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Appointment__c appt = [SELECT Id, Accession_Number__c FROM Appointment__c LIMIT 1];
        
        String jsonMsg = '{"PatientId":"' + patient.ID_Number__c + '","PatientIdType":"' + patient.ID_Type__c + '","UserName":"qatest","AppointmentID":"' + appt.Id + '","AccsionNumber":"' + appt.Accession_Number__c + '"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/OpenRecordAccountByQF/';
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_OpenRecordAccountByQF ws_OpenAccount = new ws_OpenRecordAccountByQF();
        ws_OpenRecordAccountByQF.getDetailsForOpenAccount();
        Test.StopTest();
    }

    @isTest
    static void getDetailsForOpenAccountWithErrorTest() {
        User user = TestDataFactory.getUser('System Administrator');
        user.UserName = 'qatest@assuta.co.il';
        insert user;
        Account patient = [SELECT Id, ID_Number__c, ID_Type__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Appointment__c appt = [SELECT Id, Accession_Number__c FROM Appointment__c LIMIT 1];
        
        String jsonMsg = '{"PatientId":"315485697","PatientIdType":"' + patient.ID_Type__c + '","UserName":"qatest","AppointmentID":"a02250000054kBlA","AccsionNumber":"' + appt.Accession_Number__c + '"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/OpenRecordAccountByQF/';
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_OpenRecordAccountByQF ws_OpenAccount = new ws_OpenRecordAccountByQF();
        ws_OpenRecordAccountByQF.getDetailsForOpenAccount();
        Test.StopTest();
    }
}