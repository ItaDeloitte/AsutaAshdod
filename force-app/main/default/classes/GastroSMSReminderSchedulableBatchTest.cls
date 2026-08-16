@isTest
public class GastroSMSReminderSchedulableBatchTest {

    @testSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.ID_Number__c = '999088396';
        patient.FirstName = 'test2';
        insert patient2;
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor1.Doctor_Code__c = '0012661';
        doctor1.Experts_center__c = true;
        Account doctor2 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor2.ID_Number__c = '999657950';
        doctor2.Doctor_Code__c = '0012662';
        doctor2.Experts_center__c = true;
        insert new List<Account>{doctor1, doctor2};

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__C domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);		    
        insert procedure;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('4');
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor1.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor1.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Case cas2 = TestDataFactory.getCase(doctor1.Id, patient2.Id, con.Id, pFactor.Id);
        cas2.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas2;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        insert new Site_Domain__c(Site__c = site.Id, Domain__c = domain.Id, accurate_site__c = site.Id);
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.status__c ='פעיל';
        calendar.CalendarForGastro__c = true;
        insert calendar;        

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c = System.today().addDays(7);
        appt.Appointment_Status__c = 'NewAppointment';                
        appt.Domain__c = domain.Id;
        appt.Site__c = site.Id;
        insert appt;

        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient2.Id, calendar.Id, cas2.Id);       
        appt2.Appointment_Date_Time__c = System.today().addDays(5);
        appt2.Appointment_Status__c = 'NewAppointment';          
        appt2.Number_of_referral__c = null;
        appt2.Domain__c = domain.Id;
        appt2.Site__c = site.Id;
        insert appt2;  
              
        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient2.Id, calendar.Id, cas2.Id);       
        appt3.Appointment_Date_Time__c = System.today().addDays(4);
        appt3.Appointment_Status__c = 'NewAppointment';              
        appt3.Domain__c = domain.Id;
        appt3.Site__c = site.Id;
        insert appt3;  
        
        Appointment__c appt4 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient2.Id, calendar.Id, cas2.Id);       
        appt4.Appointment_Date_Time__c = System.today().addDays(2);
        appt4.Appointment_Status__c = 'NewAppointment';        
        appt4.Domain__c = domain.Id;
        appt4.Site__c = site.Id;        
        insert appt4;
        Test.setCreatedDate(appt4.Id, Date.today().addDays(-1));
        
    }

    @isTest
    static void batchTest() {        
        List<Appointment__c> appts = [SELECT Id FROM Appointment__c];        
        Test.startTest();
        Database.executeBatch(new GastroSMSReminderSchedulableBatch());
        Database.executeBatch(new GastroColonoscopySchedulableBatch());
        Database.executeBatch(new GastroAdminMessageSchedulableBatch());
        Test.stopTest();
    }   
}