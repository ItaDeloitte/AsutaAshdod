//Created by Ortal k.
// Test for All IVR Interface.
@IsTest
public with sharing class ws_IVR_Test {

    @TestSetup
    static void testSetup() {
        insert TestDataFactory.getENV();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = TestDataFactory.getUser('System Administrator');
        user.ProfileId = p.Id;
        user.Title = null;
        user.Agent_ID__c = '13902';
        user.Extension = '4453';
        //insert user;

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.X360_patient_checkbox__c = true;
        //patient.X360_Coordinator__c = user.Id;
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;

        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case');
        cas.AccountId = patient.Id;
        //cas.OwnerId = user.Id;
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        VDN__c vdn = new VDN__c(CodeVDN__c = '17632');
        insert vdn;

        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        domain.Appointment_Coordination_System__c = 'RIS';
        domain.Recording_Code__c = 'Mahon_memografia.wav';
        domain.VDN__c = vdn.Id; 
        insert domain;
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure1.Recording_Code__c = 'ct_beten.wav';        
        insert procedure1;

        Site__c site1 = TestDataFactory.getSite('20');
        site1.Recording_Code__c = '20.wav';
        insert site1;
        Site__c site2 = TestDataFactory.getSite(null);
        site2.Recording_Code__c = null;
        insert site2;

        Guidance_Scenario__c guidlineScenario = new Guidance_Scenario__c(
            Recording_Code_1__c = 'mri_rikmot_rakot_tzavar.wav',
            Recording_Code_2__c = 'mri_rikmot_rakot_tzavar.wav',
            Recording_Code_3__c = 'mri_rikmot_rakot_tzavar.wav',
            Recording_Code_4__c = 'mri_rikmot_rakot_tzavar.wav',
            Recording_Code_5__c = 'mri_rikmot_rakot_tzavar.wav',
            Recording_Code_6__c = 'mri_rikmot_rakot_tzavar.wav',
            Medical_Procedure__c = procedure1.Id
        );
        insert guidlineScenario;

        Appointment__c appt1 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure1.Id, patient.Id, calendar.Id, null);
        appt1.Appointment_Status__c = 'WaitingForAppointment';
        appt1.Guidance_Scenario__c = guidlineScenario.Id;
        appt1.Appointment_Date_Time__c = DateTime.now();
        appt1.Doctor_Account__c = doctor.Id;
        appt1.Site__c = site1.Id;
        insert appt1;

        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure1.Id, patient.Id, calendar.Id, null);
        appt2.Appointment_Status__c = 'WaitingForAppointment';
        appt2.Appointment_Date_Time__c = DateTime.now() + 1;
        appt2.Guidance_Scenario__c = guidlineScenario.Id;
        appt2.Doctor_Account__c = doctor.Id;
        appt2.Site__c = site2.Id;
        insert appt2;

        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure1.Id, patient.Id, calendar.Id, null);
        appt3.Appointment_Status__c = 'WaitingForAppointment';
        appt3.Appointment_Date_Time__c = DateTime.now() + 2;
        appt3.Guidance_Scenario__c = guidlineScenario.Id;
        appt3.Doctor_Account__c = doctor.Id;
        appt3.Site__c = site2.Id;
        insert appt3;
        
        insert TestDataFactory.getSmsTemplate();
    }

    // Test for ws_IVR_GetPatientData class
    @IsTest
    static void getPatientDataTest() {
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;
        List<Appointment__c> apps = [SELECT Id
                                          , Week_Day__c
                                          , Time_of_appointment__c
                                          , Date_of_appointment__c
                                          , Appointment_Date_Time__c
                                          , Site__r.Site_Code__c
                                          , Medical_Procedure__r.Confidentiality__c
                                          , Medical_Procedure__r.Domain__r.Recording_Code__c
                                          , Medical_Procedure__r.Domain__r.VDN__r.CodeVDN__c 
                                          , Domain__r.VDN__r.CodeVDN__c
                                          , Patient_Account__r.ID_Number__c
                                          , Guidance_Scenario__r.Recording_Code_1__c
                                          , Guidance_Scenario__r.Recording_Code_2__c
                                          , Guidance_Scenario__r.Recording_Code_3__c
                                          , Guidance_Scenario__r.Recording_Code_4__c
                                          , Guidance_Scenario__r.Recording_Code_5__c
                                          , Guidance_Scenario__r.Recording_Code_6__c
                                     FROM Appointment__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_getPatientData/';
        req.httpMethod = 'Get';
        req.addParameter('PatientId', patientId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_GetPatientData IVR_GetPatientData = new ws_IVR_GetPatientData();
        ws_IVR_GetPatientData.getPatientData();
        Test.StopTest();
    }

    // Test for ws_IVR_CallBack class
    @IsTest
    static void callbackWithExistPatientidTest() {
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;
        String JsonMsg = '{"UCID":"00001106701568187948","' + patientId + '":"311049191","PhoneNumber":"0546850060","PhoneForCallback":"0546850060","NumberOfAttempts":"4","CallCreatedOn":"2019-25-11 10:23:15","CallResult":"0","ActionCode":"2","VDN":"17085"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CallBack';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_IVR_CallBack IVR_CallBack = new ws_IVR_CallBack();
        ws_IVR_CallBack.getCallBackDetails();
        Test.StopTest();
    }

    @IsTest
    static void callbackWithDemographyPatientIdTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        String JsonMsg = '{"UCID":"00001106701568187948","PatientId":"311049136","PhoneNumber":"0546850060","PhoneForCallback":"0546850060","NumberOfAttempts":"4","CallCreatedOn":"2019-25-11 10:23:15","CallResult":"0","ActionCode":"2","VDN":"17085"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CallBack';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_IVR_CallBack.getCallBackDetails();
        Test.StopTest();
    }

    @IsTest
    static void callbackwithActionCode4Test() {
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;
        String JsonMsg = '{"UCID":"00001106701568187948","PatientId":"' + patientId + '","PhoneNumber":"0546850060","PhoneForCallback":"0546850060","NumberOfAttempts":"4","CallCreatedOn":"2019-25-11 10:23:15","CallResult":"0","ActionCode":"4","VDN":"17085"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CallBack';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_IVR_CallBack.getCallBackDetails();
        Test.StopTest();
    }

    @IsTest
    static void getCallBack360Test() {
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;
        String JsonMsg = '{"UCID":"12345678965865464","PatientId":"' + patientId + '","Caller":"0527632145"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CallBack';
        req.httpMethod = 'Put';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_IVR_CallBack.getCallBack360();
        Test.StopTest();
    }

    @IsTest
    static void getCallBack360WithErrorTest() {
        String JsonMsg = '{"UCID":"12345678965865464","PatientId":"311049136","Caller":"0527632145"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CallBack';
        req.httpMethod = 'Put';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_IVR_CallBack.getCallBack360();
        Test.StopTest();
    }

    // Test for ws_IVR_CancelAppointment class
    @IsTest
    static void createOTPTest() {
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CancelAppointment/';
        req.httpMethod = 'Get';
        req.addParameter('PatientId', patientId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_CancelAppointment IVR_CancelAppointment = new ws_IVR_CancelAppointment();
        ws_IVR_CancelAppointment.createOTP();
        Test.StopTest();
    }

    @IsTest
    static void createOTPWithPatientErrorTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CancelAppointment/';
        req.httpMethod = 'Get';
        req.addParameter('PatientId', '311049136');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_CancelAppointment.createOTP();
        Test.StopTest();
    }

    @IsTest
    static void canceleAppointmentAccount360Test() {
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CancelAppointment/';
        req.httpMethod = 'Get';
        req.addParameter('ApptId', apptId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_CancelAppointment.canceleAppointment();
        Test.StopTest();
    }

    @IsTest
    static void canceleAppointmentPersonAccountTest() {
        Account acct = [SELECT Id, ID_Number__c, X360_patient_checkbox__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        acct.X360_patient_checkbox__c = false;
        update acct;
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_CancelAppointment/';
        req.httpMethod = 'Get';
        req.addParameter('ApptId', apptId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_CancelAppointment.canceleAppointment();
        Test.StopTest();
    }

    // Test for ws_IVR_PlayInstructions class
    private class IVR_GetIVRLine_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"GetIVRLinesSalesForceResult": "true"}');
            response.setStatusCode(200);
            return response;
        }
    }

    @IsTest
    static void getIVRLines() {
        Test.setMock(HttpCalloutMock.class, new IVR_GetIVRLine_Mock());
        Test.startTest();
        ws_IVR_PlayInstructions.getIVRLines();
        Test.stopTest();
    }

    private class IVR_MakeTransfer_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"makeTransferIVRInfoSalesFrcRslt": true}');
            response.setStatusCode(200);
            return response;
        }
    }

    @IsTest
    static void makeTransferIVRInfoTest() {
        Test.setMock(HttpCalloutMock.class, new IVR_MakeTransfer_Mock());
        Account acct = [SELECT Id, ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME  LIMIT 1];
        List<String> apptIds = new List<String>();
        for (Appointment__c appt_i : [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName =: TestDataFactory.APPT_I_RT_NAME]) {
            apptIds.add(appt_i.Id);
        }

        Test.startTest();
        ws_IVR_PlayInstructions.makeTransferIVRInfo(acct.ID_Number__c, '13902', '4453', apptIds);
        ws_IVR_PlayInstructions.updateDateInstuctionReadField(apptIds);
        Test.stopTest();
    }

    @IsTest
    static void getIVRSummaryByRepresentativeTest() {
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_PlayInstructions/';
        req.httpMethod = 'Get';
        req.addParameter('ApptId', apptId);
        req.addParameter('IsApproved', 'True');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_PlayInstructions IVR_PlayInstructions = new ws_IVR_PlayInstructions();
        ws_IVR_PlayInstructions.getIVRSummaryByRepresentative();
        Test.StopTest();
    }

    // Test for ws_IVR_GetPreferredChannel class
    @IsTest
    static void sendSMSForChatTest() {
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());
        String patientId = [SELECT ID_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].ID_Number__c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_GetPreferredChannel/';
        req.httpMethod = 'Get';
        req.addParameter('PatientId', patientId);
        req.addParameter('MobilePhone', '0527965412');
        req.addParameter('SMSType', 'new_appointment');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_GetPreferredChannel IVR_GetPreferredChannel = new ws_IVR_GetPreferredChannel();
        ws_IVR_GetPreferredChannel.sendSMSForChat();
        Test.StopTest();
    }

    @IsTest
    static void SendDatainPreferredChannel() {
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_GetPreferredChannel/';
        req.httpMethod = 'Post';
        req.addParameter('ApptId', apptId);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_GetPreferredChannel.SendDatainPreferredChannel();
        Test.StopTest();
    }

    @IsTest
    static void SendDatainPreferredChannelwithError() {
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IVR_GetPreferredChannel/';
        req.httpMethod = 'Post';
        req.addParameter('ApptId', '123456');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_IVR_GetPreferredChannel.SendDatainPreferredChannel();
        Test.StopTest();
    }
}