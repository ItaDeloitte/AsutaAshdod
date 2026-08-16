@IsTest
public with sharing class ws_FutureCase_Test {

    @TestSetup
    static void testSetup() {
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

        Expertise__c expertise1 = TestDataFactory.getExpertise();
        insert expertise1;
        Sub_Expertise__c subExpertise1 = TestDataFactory.getSubExpertise(expertise1.Id);
        insert subExpertise1;
        Expertise__c expertise2 = TestDataFactory.getExpertise();
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
        insert subExpertise4;
        
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise1.Id, '13');
        procedure1.Dont_Send_Home_Admission_Link__c = false;
        insert procedure1;
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise2.Id, '13.0');
        procedure2.Dont_Send_Home_Admission_Link__c = false;
        insert procedure2;
        Medical_Procedure__c procedure3 = TestDataFactory.getProcedure(domain.Id, subExpertise3.Id, '13.1');
        procedure3.Dont_Send_Home_Admission_Link__c = false;
        insert procedure3;
        Medical_Procedure__c procedure4 = TestDataFactory.getProcedure(domain.Id, subExpertise3.Id, '13.2');
        procedure4.Dont_Send_Home_Admission_Link__c = false;
        insert procedure4;

        SpinCal__c spincal = new SpinCal__c();
        spincal.Name = '12345';
        insert spincal;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        appt.Medical_Procedure2__c = procedure2.Id;
        appt.Medical_Procedure3__c = procedure3.Id;
        appt.Medical_Procedure4__c = procedure4.Id;
        appt.Appointment_Status__c = 'WaitingForAppointment';
        DateTime todayPlus4Days = date.today().adddays(4);
        appt.Appointment_Date_Time__c = todayPlus4Days;
        appt.Doctor_Account__c = doctor.Id;
        appt.Spincal__c = spincal.Id;
        appt.Commitment_Status__c = '0';
        appt.PayerFactor__c = pfactor.Id;
        appt.Number_of_commitment__c = '12345';
        appt.Miss_match_medical_pro_1__c = false;
        appt.Miss_match_medical_pro_2__c = false;
        appt.Miss_match_medical_pro_3__c = false;
        appt.Miss_match_medical_pro_4__c = false;
        appt.Date_of_referral__c = Date.today();
        appt.Number_of_referral__c = '12345';
        appt.Expiration_date_commitment__c = Date.today() + 15;
        appt.Date_of_commitment__c= Date.today() - 15;
        appt.Site__c = site.Id;
        insert appt;
    }

    @IsTest
    static void ws_FutureCase_Test() {
        Test.setMock(HttpCalloutMock.class, new FutureCase_Mock());
        Appointment__c appt = [SELECT Id, Didkitsent__c,Appointment_Date_Time__c, Medical_Procedure__r.Dont_Send_Home_Admission_Link__c, Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c, Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c, Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c FROM Appointment__c LIMIT 1];

        Test.startTest();
        System.debug('****apppp ****' + appt);
        appt.Didkitsent__c = true;
        update appt;

        /*appt = [SELECT Id,Didkitsent__c, Medical_Procedure__c,Medical_Procedure2__c,Medical_Procedure3__c,Medical_Procedure4__c,Medical_Procedure__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c FROM Appointment__c LIMIT 1];
        appt.Didkitsent__c = false;
        update appt;
        Medical_Procedure__c md = [SELECT Id, Dont_Send_Home_Admission_Link__c FROM Medical_Procedure__c limit 1];
        md.Dont_Send_Home_Admission_Link__c = true;
        update md;

        appt = [SELECT Id,Didkitsent__c,Medical_Procedure__c,Medical_Procedure2__c,Medical_Procedure3__c,Medical_Procedure4__c,Medical_Procedure__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c,Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c FROM Appointment__c LIMIT 1];
        System.debug('updating fields');
        appt.Medical_Procedure__c = md.Id;
        appt.Medical_Procedure2__c=md.Id;
        appt.Medical_Procedure3__c=md.Id;
        appt.Medical_Procedure4__c =md.Id;
        appt.Didkitsent__c = true;
        update appt;
        System.debug('appointment was updated');*/
        Test.StopTest();
    }

    private class FutureCase_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{'+
                             '"Guid": "EFF52CD8-2C8A-4D12-B323-7C690A008EBE",'+
                             '"ResultStatus": "0",'+
                             '"IdType": "1",'+
                             '"IdNo": "311049191",'+
                             '"PFirstName": "testFirstName",'+
                             '"PLastName": "testFirstName",'+
                             '"ClientNo": "20001",'+
                             '"FileNo": 6636071,'+
                             '"ErrCodes": ['+
                             '{'+
                             '"Tag": "",'+
                             '"ErrorCode": "",'+
                             '"Message": ""'+
                             '}'+
                             ']'+
                             '}'
            );
            response.setStatusCode(200);
            return response;
        }
    }
}