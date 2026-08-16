@isTest
private class ws_getPrices_RESTTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor.Experts_center__c = true;
        doctor.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor.Doctor_Code__c = '0012661';
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
		procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '5';
        procedure.SMS_Reminder__c = '0';
		procedure.Humen__c = '0';
        insert procedure;
        Doctor_Medical_Procedure__c docProcedure = TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        docProcedure.House_doctor__c = true;
        insert docProcedure;
        
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
		insert TestDataFactory.getCalendars1_days(15, 32);
        insert TestDataFactory.getProcedurePlan();

        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor('333');
        pFactorParent.Insurance_Company__c = true;
        insert pFactorParent;
        Payer_Factor__c pFactorChild = TestDataFactory.getPFactor('8');
        pFactorChild.Name_of_parent__c = pFactorParent.Id;
        pFactorChild.Insurance_Company__c = true;
        insert pFactorChild;
        Agreement__c agreement = TestDataFactory.getAgreement(doctor.Id, pFactorChild.Id);
        insert agreement;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.PayerFactor__c = pFactorChild.Id;
        appt.Doctor_Account__c = doctor.Id;
        appt.Commitment_Status__c = '0';
        appt.Case_Hidden__c = cas.Id;
        appt.Payer_factor__c = '3';
        appt.Site__c = site.Id;
        insert appt;
    }

    @IsTest
    static void queuTest() {
        Test.setMock(HttpCalloutMock.class, new HttpGoodMock());
        Medical_Procedure__c procedure = [SELECT Id, Category_for_anesthetist__c, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id, InsuranceCode__c FROM Payer_Factor__c WHERE InsuranceCode__c = '8' LIMIT 1];
        Appointment__c appt = [SELECT Id, Doctor_Account__c FROM Appointment__c LIMIT 1];
        Site__c site = [SELECT ID, Site_Code__c FROM Site__c LIMIT 1];
        
        Test.startTest();
        String jsonString = '{"Guid":"'+appt.Id+'","siteCode":"'+site.Site_Code__c+'","payerFactorCode":"'+pFactor.InsuranceCode__c+'","anesthetist":"'+procedure.Category_for_anesthetist__c+'",'
                           + ' "activityDate":"2019-11-04","doctorCode":"'+appt.Doctor_Account__c+'","activityCode_1":"'+procedure.Procedure_Code__c+'","activityCode_2":"'+procedure.Procedure_Code__c+'",'
                           + ' "activityCode_3":"'+procedure.Procedure_Code__c+'","activityCode_4":"'+procedure.Procedure_Code__c+'","payerFactorParent":"333"}';
        ws_getPrices_REST inst = new ws_getPrices_REST(jsonString);
        System.enqueueJob(inst);
        Test.stopTest();
    }

    private class HttpGoodMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"ErrCodes":[],"AgreeYesNo":"Yes","BuyAgree":"Y","AgreeNo":"12345","SurgeryAgreeSales":[],"SurgeryAgreeResources":[]}');
            response.setStatusCode(200);
            return response;
        }
    }
}