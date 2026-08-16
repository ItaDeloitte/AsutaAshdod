/*
* @author         Avraham Dasa   <adasa@deloitte.co.il>
* @Class Name     ws_KmsGuidance
* @modifiedBy     
* @version        1.0
* @created        23-09-2019
* @modified       DD-MM-YYYY
* @description    inser in Kms Guidance to Appointment__c obj
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class ws_KmsGuidanceTest {
    
    @testSetup
    static void testSetup() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.DisableValidation__c = true;
        insert patient;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, null);
        appt.Accession_Number__c = 'R1234567';
        insert appt;
    }

    @isTest
    static void getKMSGuidance() {
        String accessionNumber = [SELECT Accession_Number__c FROM Appointment__c].Accession_Number__c;
        String jsonMsg = '{"AccessionNumber":"' + accessionNumber + '", "Guidance":"test 123"}';
        System.debug('jsonMsg ' + jsonMsg);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/KMS_Guidance';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response= res;
        ws_KmsGuidance.getKMSGuidance();
        Test.StopTest();
    }

    @isTest
    static void getKMSExceptionGuidance() {
        String jsonMsg = '{"","Guidance":"test 123"}'; // exception
        System.debug('jsonMsg ' + jsonMsg);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/KMS_Guidance';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        try {ws_KmsGuidance.getKMSGuidance();} catch (Exception e) {}
        Test.StopTest();
    }
}