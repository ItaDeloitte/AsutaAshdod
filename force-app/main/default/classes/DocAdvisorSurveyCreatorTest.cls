@isTest
public class DocAdvisorSurveyCreatorTest {
    @TestSetup
    static void makeData(){
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;

        Case cas = new Case(
            RecordTypeId = TestDataFactory.getRTId('Surgery', 'Case'),
            Patient__c = patient.Id,
            AccountId = patient.Id
        );
        insert cas;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Payer_Factor__c pfactor = TestDataFactory.getPFactor('3');
        pfactor.Send_Home_Admission_Link__c = true;
        insert pfactor;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Send_Home_Admission_Link__c =true;
        site.Site_Code__c ='85';
        insert site;

        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        insert clinic;

        Expertise__c expertise1 = TestDataFactory.getExpertise();
        insert expertise1;
        Sub_Expertise__c subExpertise1 = TestDataFactory.getSubExpertise(expertise1.Id);
        insert subExpertise1;
        /*Expertise__c expertise2 = TestDataFactory.getExpertise();
        insert expertise2;
        Sub_Expertise__c subExpertise2 = TestDataFactory.getSubExpertise(expertise2.Id);
        insert subExpertise2;
        Expertise__c expertise3 = TestDataFactory.getExpertise();
        insert expertise3;
        Sub_Expertise__c subExpertise3 = TestDataFactory.getSubExpertise(expertise3.Id);
        insert subExpertise3;
        Expertise__c expertise4 = TestDataFactory.getExpertise();
        insert expertise4;
        Sub_Expertise__c subExpertise4 = TestDataFactory.getSubExpertise(expertise4.Id);
        insert subExpertise4;*/
        
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise1.Id, '13');
        procedure1.Dont_Send_Home_Admission_Link__c = false;
        insert procedure1;
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise1.Id, '13.0');
        procedure2.Dont_Send_Home_Admission_Link__c = false;
        insert procedure2;
        Medical_Procedure__c procedure3 = TestDataFactory.getProcedure(domain.Id, subExpertise1.Id, '13.1');
        procedure3.Dont_Send_Home_Admission_Link__c = false;
        insert procedure3;
        Medical_Procedure__c procedure4 = TestDataFactory.getProcedure(domain.Id, subExpertise1.Id, '13.2');
        procedure4.Dont_Send_Home_Admission_Link__c = false;
        insert procedure4;

        SpinCal__c spincal = new SpinCal__c();
        spincal.Name = '12345';
        insert spincal;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Medical_Procedure2__c = procedure2.Id;
        appt.Medical_Procedure3__c = procedure3.Id;
        appt.Medical_Procedure4__c = procedure4.Id;
        appt.Clinic__c = clinic.Id;
        appt.Appointment_Status__c = 'WaitingForAppointment';
        DateTime todayPlus4Days = date.today().adddays(4);
        appt.Appointment_Date_Time__c = todayPlus4Days;
        appt.Doctor_Account__c = doctor.Id;
        appt.Spincal__c = spincal.Id;
        appt.Commitment_Status__c = '0';
        appt.PayerFactor__c = pfactor.Id;
        appt.Number_of_commitment__c = '12345';
        appt.Date_of_referral__c = Date.today();
        appt.Number_of_referral__c = '12345';
        appt.Expiration_date_commitment__c = Date.today() + 15;
        appt.Date_of_commitment__c= Date.today() - 15;
        appt.Site__c = site.Id;
        appt.Release_Date__c = Date.today();
        insert appt;

        Survey__c survey = new Survey__c();
        survey.SurveyCode__c ='DocAdvisor';
        insert survey;
        Survey_Question__c sq = new Survey_Question__c();
        sq.OrderNumber__c=2;
        sq.Question__c ='Can you please stop answering this survey for god sake?';
        sq.Type__c = 'RadioButton';
        sq.Survey__c=survey.id;
        insert sq;

        DocAdvisorSetting__c docAdvDaysOffset =new DocAdvisorSetting__c();
        docAdvDaysOffset.Days_From_Release__c =4;
        insert docAdvDaysOffset;
        
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new DocAdvisorSurveyCreatorSchedulableBatch(
                'SELECT Id'
                + ', Case__c'
                + ', Clinic__c'
                + ', Doctor_Account__c'
                + ', Patient_Account__c'
                + ', Medical_Procedure__c'
                + ', Medical_Procedure2__c'
                + ', Medical_Procedure3__c'
                + ', Medical_Procedure4__c'
                + ', Site__c'
                + ', Release_Date__c'
            + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job SMS', '20 30 8 10 2 ?', new DocAdvisorSurveyCreatorSchedulableBatch());
        Test.stopTest();
    }
}