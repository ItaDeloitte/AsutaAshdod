// Test for: LC_SurgeryCancel
@isTest
public class LC_SurgeryCancelTest {
    
    @testSetup
    static void setup() {
        insert new ENV__c(Env_value__c = 'QA');
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '760904');
        insert new List<Medical_Procedure__c>{procedure1, procedure2};
        insert TestDataFactory.getDocProcedure(doctor.Id, procedure1.Id);
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE); // Modality_Code_per_Site_Medical_plan__mdt 760904_20
        insert site;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        insert TestDataFactory.getCalendars1(16);
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        clinic.Site__c = site.Id;
        insert clinic;   
        insert TestDataFactory.getDocClinic(doctor.Id, clinic.Id);
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Appointment__c appt = TestDataFactory.getAppointment('Surgeries', procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Accession_Number__c = 'R118616';
        insert appt;
    }

    @isTest
    static void getAppointmentsTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        LC_SurgeryCancel controller = new LC_SurgeryCancel();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getAppointments', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void cancelAppointmentTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE Appointment_Status__c != 'Canceled' LIMIT 1];
        Map<String, Object> params = new Map<String, Object>{'actionName' => 'cancelAppointment', 'recordId' => appt.Id};

        Test.startTest();
        LC_SurgeryCancel controller = new LC_SurgeryCancel();
        Response res1 = controller.executeAction(params);
        appt.Accession_Number__c = null;
        update appt;
        Response res2 = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void executeActionExceptionTest() {
        Test.startTest();
        LC_SurgeryCancel controller = new LC_SurgeryCancel();
        try {
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong', e.getMessage());
        }
        Test.stopTest();
    }
}