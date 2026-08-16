@isTest
public class GetAmbulatoryCommitmentBatchTest {
    @testSetup
    static void setup() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.ID_Number__c = '852986371';
        insert new List<Account>{doctor, patient};
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        domain.RellevantJobCommitment__c = true;
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Maccabi_Code__c = '101701';
        insert site;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Calendar__c calendar = TestDataFactory.getCalendar('test');
        insert calendar;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.PayerFactor__c = pFactor.Id;
        appt.Domain__c = domain.Id;
        appt.Appointment_Status__c = 'NewAppointment';
        appt.Appointment_Date_Time__c =  Date.today().addDays(3);
        insert appt;
    }

    @IsTest
    static void batchTest() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Test.setMock(HttpCalloutMock.class, new getAmbulatoryCommitment_Mock());        

        Test.startTest();
        Database.executeBatch(new GetAmbulatoryCommitmentBatch());
        Test.stopTest();
    }    
}