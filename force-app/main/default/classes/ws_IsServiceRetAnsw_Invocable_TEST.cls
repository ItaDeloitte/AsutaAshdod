@isTest
public with sharing class ws_IsServiceRetAnsw_Invocable_TEST {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
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
		procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '3';
        procedure.SMS_Reminder__c = '1';
		procedure.Humen__c = '3';
        insert procedure;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Contact con = TestDataFactory.getContact(doctor1.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor1.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        insert new Site_Domain__c(Site__c = site.Id, Domain__c = domain.Id, accurate_site__c = site.Id);
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        List<Calendar1__c> calendars = TestDataFactory.getCalendars1_days(20, 60);
        insert calendars;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Date_for_tizkorit_reminder__c = System.today().addDays(1);
        appt.Appointment_Status__c = 'NewAppointment';
        appt.Number_of_commitment__c = '12345';
        appt.First_Update_Caught__c = false;
        appt.more_than_14_days__c = false;
        appt.PayerFactor__c = pFactor.Id;
        appt.Remainder_time__c = null;
        appt.Domain__c = domain.Id;
        appt.Site__c = site.Id;
        insert appt;
    }

    @isTest
    static void test1() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsServiceRetAns_Mock());
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        appt.Commitment_Status__c = '6';
        update appt;

        Test.startTest();
        ws_IsServiceRetAnsw_Invocable.isServiceRetAns(new List<Id>{appt.Id});
        Test.stopTest();
    }

    @isTest
    static void test2() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsServiceRetAns_Mock());
        Appointment__c appt = [SELECT Id, Number_of_commitment__c FROM Appointment__c LIMIT 1];
        appt.Commitment_Status__c = '6';
        update appt;

        Test.startTest();
        System.schedule('Test Sched', '0 0 0 1 1 ? 2055', new ws_IsServiceRetAnsw_Schedule(new List<Appointment__c>{appt}));
        Test.stopTest();
    }

    @isTest
    static void test3() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsServiceRetAns_Mock1());
        Appointment__c appt = [SELECT Id, Number_of_commitment__c FROM Appointment__c LIMIT 1];
        appt.Commitment_Status__c = '6';
        update appt;

        Test.startTest();
        System.schedule('Test Sched', '0 0 0 1 1 ? 2055', new ws_IsServiceRetAnsw_Schedule(new List<Appointment__c>{appt}));
        Test.stopTest();
    }

    @isTest
    static void test4() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Test.startTest();
        ws_IsServiceRetAnsw_Batchable.getDocument('1234567', '0', '12345');
        test.stopTest();
    }

    @isTest
    static void test5() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsServiceRetAns_Mock1());
        Appointment__c appt = [SELECT Id, Number_of_commitment__c FROM Appointment__c LIMIT 1];
        appt.Commitment_Status__c = '6';
        update appt;

        Test.startTest();
        Database.executeBatch( new ws_IsServiceRetAnsw_Batchable(new List<Appointment__c>{appt}));
        Test.stopTest();
    }

    private class ws_maccabiIsServiceRetAns_Mock1 implements WebServiceMock {
    	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput RetOutput = new ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput();
            ws_maccabiIsServiceRetAnswer.ResultMessage resMsg = new ws_maccabiIsServiceRetAnswer.ResultMessage();
            resMsg.Message = '';
            resMsg.Description = '';
            resMsg.Code = 1;

            ws_maccabiIsServiceRetAnsOut.ArrayOfCommentReplyString CommentReplys = new ws_maccabiIsServiceRetAnsOut.ArrayOfCommentReplyString();
            CommentReplys.CommentReply = new List<String>{'tewst', 'test 2'};
            ws_maccabiIsServiceRetAnsOut.ArrayOfCodeConversionString CodesConversions = new ws_maccabiIsServiceRetAnsOut.ArrayOfCodeConversionString();
            CodesConversions.CodeConversion = new List<String>{'28.6', '28.2'};
            ws_maccabiIsServiceRetAnsOut.ArrayOfDescriptionCodeAnalysisString Descriptions = new ws_maccabiIsServiceRetAnsOut.ArrayOfDescriptionCodeAnalysisString();
            Descriptions.DescriptionCodeAnalysis = CommentReplys.CommentReply;

            RetOutput.CommentReplys = CommentReplys;
            RetOutput.CodesConversions = CodesConversions;
            RetOutput.Descriptions = Descriptions;
            RetOutput.DeductibleHospital = '20';
            RetOutput.AmountAnesthesiologist = '500';
            RetOutput.DoctorID = 123456789;
            RetOutput.DateAnalysis = 10102019;
            RetOutput.Remark = 'gsgh';
            RetOutput.LiabilityID = '2143556';
            RetOutput.Deductible = 1510;
            RetOutput.AmountDoctor = 300;
            RetOutput.AmountImplants = '10';
            RetOutput.DateCreateLiability = '10102019';
            RetOutput.DateSofLiability = '10102019';
            RetOutput.ErrorCode = '0';

            ws_maccabiIsServiceRetAnsSOAP.isServiceReturnsAnswersResponse_element response_x = new ws_maccabiIsServiceRetAnsSOAP.isServiceReturnsAnswersResponse_element();
            response_x.isServiceReturnsAnswersResult = RetOutput;
            response.put('response_x', response_x);
        }
    }
}