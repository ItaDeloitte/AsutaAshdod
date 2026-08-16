/*
* @author         Avraham Dasa   <adasa@deloitte.co.il>
* @Class Name     WS_RisStatuses
* @modifiedBy     
* @version        1.0
* @created        09-09-2019
* @modified       05-01-2020
* @description    Ris Status interface test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class ws_RisStatusesTest {

    @testSetup
    static void setup() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;

        Expertise__c expertise = TestDataFactory.getExpertise() ;
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Accession_Number__c = 'R1234567';
        insert appt;

        RecommendationsTypeAfterExam__c raeType = TestDataFactory.getRecommendationsType();
        raeType.RecommendationType__c = '10';
        insert raeType;
    }

    @isTest
    static void postTest() {
        Appointment__c appt = [SELECT Id, Accession_Number__c FROM Appointment__c LIMIT 1];
        insert TestDataFactory.getRecommendations(appt.Id);
        String accessionNumber = appt.Accession_Number__c;
        String recommendationType = [SELECT Id, RecommendationType__c FROM RecommendationsTypeAfterExam__c].RecommendationType__c;
        String jsonMsg = '{"AccessionNumber":"' + accessionNumber + '","RecommendationCode":"' + recommendationType + '","Technician":"Tech test","AnswerStatus":"6","SignatureDateTime":"2019-09-18 12:30:00","ReferringDoctorNumber":"0018E0000185m8iQAA","StatusChangeDateTime":"2019-09-20 14:45:00", "SignedDoctorNumber":"0012661","TypistName":"test2","Birad":"2","RecommendationDescription":"TEST123","RecommendationNotes":"TEST1234","HasFinding":"1","OrderNotes":"TEST 1","AppointmentNotes":"TEST 21","TechnicianNotes":"TEST 31","TypistNotes":"TEST 41","RadiologistNotes":"TEST 5","Dust":"","Asthma":"","IodineSensitivity":"","TypistDateTime":"2020-01-20 14:45:00","TechnicianDateTime":"2020-01-20 14:45:00"}';
        System.debug('jsonMsg test: ' + jsonMsg);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RIS_Statuses';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        ws_RisStatuses.getRisStatues();
        Test.StopTest();
    }
    
    @isTest
    static void postEmptyListTest() {
        String accessionNumber = [SELECT Id, Accession_Number__c FROM Appointment__c].Accession_Number__c;
        String recommendationType = [SELECT Id, RecommendationType__c FROM RecommendationsTypeAfterExam__c].RecommendationType__c;
        String jsonMsg = '{"AccessionNumber":"' + accessionNumber + '","RecommendationCode":"' + recommendationType + '","Technician":"Tech test","AnswerStatus":"6","SignatureDateTime":"2019-09-18 12:30:00","ReferringDoctorNumber":"0018E0000185m8iQAA","StatusChangeDateTime":"2019-09-20 14:45:00", "SignedDoctorNumber":"0012661","TypistName":"test2","Birad":"2","RecommendationDescription":"TEST123","RecommendationNotes":"TEST1234","HasFinding":"1","OrderNotes":"TEST 1","AppointmentNotes":"TEST 21","TechnicianNotes":"TEST 31","TypistNotes":"TEST 41","RadiologistNotes":"TEST 5","Dust":"","Asthma":"","IodineSensitivity":"","TypistDateTime":"2020-01-20 14:45:00","TechnicianDateTime":"2020-01-20 14:45:00"}';
        System.debug('jsonMsg test: ' + jsonMsg);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RIS_Statuses';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        ws_RisStatuses.getRisStatues();
        Test.StopTest();
    }
}