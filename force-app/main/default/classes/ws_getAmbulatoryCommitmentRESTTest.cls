@isTest
public class ws_getAmbulatoryCommitmentRESTTest {
	
    @testSetup
    static void setup() {
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.ID_Number__c = '852986371';
        insert new List<Account>{doctor1, patient1};
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Maccabi_Code__c = '101701';
        insert site;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor1.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor1.Id, patient1.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Calendar__c calendar = TestDataFactory.getCalendar('test');
        insert calendar;
    }    

    @IsTest
    static void checkWs() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Test.setMock(HttpCalloutMock.class, new getAmbulatoryCommitment_Mock());
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c != '760904' LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c WHERE DomainCode__c =: Decimal.valueOf(TestDataFactory.DOMAIN_CODE) LIMIT 1];
        domain.MaccabiRefferal__c = '1234';
        update domain;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.PayerFactor__c = [SELECT Id FROM Payer_Factor__c LIMIT 1].Id;
        appt.Domain__c = domain.Id;
        insert appt;

        Test.startTest();
        ws_getAmbulatoryCommitmentREST.getAmbulatoryCommitment(appt.Id, patient.Id, '355585745', '1', '12345', Date.today(), '33');
        Test.stopTest();
    }
}