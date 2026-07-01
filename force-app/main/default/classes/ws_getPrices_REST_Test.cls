@isTest
public class ws_getPrices_REST_Test {

    @testSetup
    static void setup() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Experts_center__c = true;
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor('3');
        pFactorParent.Insurance_Company__c = true;
        insert pFactorParent;
        Payer_Factor__c pFactorChild = TestDataFactory.getPFactor('8');
        pFactorChild.Name_of_parent__c = pFactorParent.Id;
        pFactorChild.Insurance_Company__c = true;
        insert pFactorChild;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactorChild.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '741560');
		procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '3';
        procedure.SMS_Reminder__c = '1';
		procedure.Humen__c = '3';
        insert procedure;
    }

    @isTest
    static void getPricesTest1() {
        Test.setMock(HttpCalloutMock.class, new ws_getPrices_REST_Mock());
        Map<String, String> jsonInput = new Map<String, String>{
            'siteCode' => TestDataFactory.SITE_CODE,
            'activityDate' => '2019-10-10',
            'Guid' => 'ghadfj987qt538',
            'payerFactorParent' => '3',
            'payerFactorCode' => '8',
            'doctorCode' => '123456',
            'activityCode_1' => '13',
            'activityCode_2' => '13',
            'activityCode_3' => '13',
            'activityCode_4' => '13'
        };

        Test.startTest();
        System.enqueueJob(new ws_getPrices_REST(JSON.Serialize(jsonInput)));
        ws_getPrices.getPricesFromMedProcedure(JSON.Serialize(jsonInput));
        Test.stopTest();
    }

    @isTest
    static void getPricesTest2() {
        Test.setMock(HttpCalloutMock.class, new ws_getPrices_REST_Mock());
        Map<String, String> jsonInput = new Map<String, String>{
            'siteCode' => TestDataFactory.SITE_CODE,
            'activityDate' => '2019-10-10',
            'Guid' => 'ghadfj987qt538',
            'payerFactorParent' => '3',
            'payerFactorCode' => '8',
            'doctorCode' => '123456',
            'activityCode_1' => '13',
            'activityCode_2' => '13',
            'activityCode_3' => '13',
            'activityCode_4' => '13'
        };

        Test.startTest();
        System.enqueueJob(new ws_getPrices_REST(JSON.Serialize(jsonInput)));
        ws_getPrices_REST.getPricesFromAppointment(JSON.Serialize(jsonInput));
        Test.stopTest();
    }

    @isTest
    static void updateAppointmentTest1() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        String jsonInput = '';

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Remainder_time__c = appt.Appointment_Date_Time__c.date().addDays(1);
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Commitment_Status__c = '0';
        appt.Case_Hidden__c = cas.Id;
        insert appt;

        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
                gen.writeStringField('Guid', '6436434666363');
                gen.writeStringField('Site', TestDataFactory.SITE_CODE);
                gen.writeStringField('ClientNo', '3');
                gen.writeFieldName('SurgeryAgreeSales');
                gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('SurgeryAgreeResources');
                gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('ErrCodes');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('ErrorCode', '01266');
                        gen.writeStringField('Message', 'תאריך לא יכול ');
                    gen.writeEndObject();
                gen.writeEndArray();
            gen.writeEndObject();
        String sendMsg = gen.getAsString();

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(sendMsg);
        Test.startTest();
        ws_getPrices_REST gp = new ws_getPrices_REST(jsonInput);
        gp.updateAppointment(results, String.valueOf(appt.Id), '3', '8');
        Test.stopTest();
    }

    @isTest
    static void updateAppointmentTest2() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        String jsonInput = '';

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Remainder_time__c = appt.Appointment_Date_Time__c.date().addDays(1);
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Commitment_Status__c = '0';
        appt.Case_Hidden__c = cas.Id;
        insert appt;

        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
                gen.writeStringField('Guid', '6436434666363');
                gen.writeStringField('Site', TestDataFactory.SITE_CODE);
                gen.writeStringField('ClientNo', '3');
                gen.writeStringField('ActivityCode', '80.206');
                gen.writeStringField('ActivityDate','2019-11-04');
                gen.writeStringField('EmpNoType', '3');
                gen.writeStringField('EmpNo', '33456');
                gen.writeStringField('AgreeYesNo', 'Y');
                gen.writeStringField('BuyAgree', 'N');
                gen.writeStringField('EmpNo', '33456');
                gen.writeFieldName('SurgeryAgreeSales');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('Site', '0');
                        gen.writeStringField('EmpNoType', '3');
                        gen.writeStringField('EmpNo','777');
                        gen.writeNumberField('ClientNo', 0);
                        gen.writeStringField('ActivityCode', '71250');
                        gen.writeStringField('SalaryFlag', 'N');
                        gen.writeNumberField('AgreeNo', 1);
                        gen.writeNumberField('NetPrice', 162.82);
                        gen.writeNumberField('PriceIncludeVat', 1887);
                        gen.writeStringField('Coin', 'NIS');
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('SurgeryAgreeResources');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeNumberField('ClientNo', 0);
                        gen.writeNumberField('NetPrice1', 1111.97);
                        gen.writeNumberField('PriceIncludeVat1', 1301);
                        gen.writeStringField('Coin1', 'NIS');
                        gen.writeNumberField('NetPrice2', 1115.55);
                        gen.writeNumberField('PriceIncludeVat2', 1301);
                        gen.writeStringField('Coin2', 'NIS');
                        gen.writeNumberField('NetPrice3', 1111.97);
                        gen.writeNumberField('PriceIncludeVat3', 1301);
                        gen.writeStringField('Coin3', 'NIS');
                        gen.writeNumberField('NetPrice5', 1111.97);
                        gen.writeNumberField('PriceIncludeVat5', 1301);
                        gen.writeStringField('Coin5', 'NIS');
                        gen.writeNumberField('NetPrice6', 1111.97);
                        gen.writeNumberField('PriceIncludeVat6', 1301);
                        gen.writeStringField('Coin6', 'NIS');
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('ErrCodes');
                gen.writeStartArray();
                gen.writeEndArray();
            gen.writeEndObject();
        String sendMsg = gen.getAsString();

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(sendMsg);
        Test.startTest();
        ws_getPrices_REST gp = new ws_getPrices_REST(jsonInput);
        gp.updateAppointment(results, String.valueOf(appt.Id), '3', '8');
        Test.stopTest();
    }

    @isTest
    static void updateAppointmentTest3() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        String jsonInput = '';

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Remainder_time__c = appt.Appointment_Date_Time__c.date().addDays(1);
        appt.Doctor_Account__c = doctor.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Commitment_Status__c = '0';
        appt.Case_Hidden__c = cas.Id;
        insert appt;

        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
                gen.writeStringField('Guid', '6436434666363');
                gen.writeStringField('Site', TestDataFactory.SITE_CODE);
                gen.writeStringField('ClientNo', '3');
                gen.writeStringField('ActivityCode', '80.206');
                gen.writeStringField('ActivityDate','2019-11-04');
                gen.writeStringField('EmpNoType', '3');
                gen.writeStringField('EmpNo', '33456');
                gen.writeStringField('AgreeYesNo', 'Y');
                gen.writeStringField('BuyAgree', 'N');
                gen.writeStringField('EmpNo', '33456');
                gen.writeFieldName('SurgeryAgreeSales');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('Site', '0');
                        gen.writeStringField('EmpNoType', '3');
                        gen.writeStringField('EmpNo','777');
                        gen.writeNumberField('ClientNo', 0);
                        gen.writeStringField('ActivityCode', '71250');
                        gen.writeStringField('SalaryFlag', 'N');
                        gen.writeNumberField('AgreeNo', 1);
                        gen.writeNumberField('NetPrice', 162.82);
                        gen.writeNumberField('PriceIncludeVat', 1887);
                        gen.writeStringField('Coin', 'NIS');
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('SurgeryAgreeResources');
                gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeNumberField('ClientNo', 0);
                        gen.writeNumberField('NetPrice1', 1111.97);
                        gen.writeNumberField('PriceIncludeVat1', 1301);
                        gen.writeStringField('Coin1', 'NIS');
                        gen.writeNumberField('NetPrice2', 1115.55);
                        gen.writeNumberField('PriceIncludeVat2', 1301);
                        gen.writeStringField('Coin2', 'NIS');
                        gen.writeNumberField('NetPrice3', 1111.97);
                        gen.writeNumberField('PriceIncludeVat3', 1301);
                        gen.writeStringField('Coin3', 'NIS');
                        gen.writeNumberField('NetPrice5', 1111.97);
                        gen.writeNumberField('PriceIncludeVat5', 1301);
                        gen.writeStringField('Coin5', 'NIS');
                        gen.writeNumberField('NetPrice6', 1111.97);
                        gen.writeNumberField('PriceIncludeVat6', 1301);
                        gen.writeStringField('Coin6', 'NIS');
                    gen.writeEndObject();
                gen.writeEndArray();
                gen.writeFieldName('ErrCodes');
                gen.writeStartArray();
                gen.writeEndArray();
            gen.writeEndObject();
        String sendMsg = gen.getAsString();

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(sendMsg);
        Test.startTest();
        ws_getPrices_REST gp = new ws_getPrices_REST(jsonInput);
        gp.updateAppointment(results, String.valueOf(appt.Id), '0', '8');
        Test.stopTest();
    }
}