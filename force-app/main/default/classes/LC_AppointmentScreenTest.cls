/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment Scheduling Screen Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             28-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public without sharing class LC_AppointmentScreenTest {

    @TestSetup
    static void makeData() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData().initCommonData();

        dBuilder.pFactor.PresentOnSchdeuleScreen__c = true;
        update dBuilder.pFactor;

        dBuilder.site.Relevant_for_appointment_screen__c = true;
        update dBuilder.site;

        dBuilder.clinic.Site__c = dBuilder.site.Id;
        update dBuilder.clinic;

        dBuilder.calendar.BranchName__c = dBuilder.site.Id;
        dBuilder.calendar.technician1__c = dBuilder.doctor.Id;
        dBuilder.calendar.technician2__c = dBuilder.doctor.Id;
        dBuilder.calendar.technician3__c = dBuilder.doctor.Id;
        update dBuilder.calendar;

        dBuilder
            .addCase('caseA', 'Appointments')
            .addProcedure('proc760902', '760902')
            .addProcedure('proc760904', '760904')
            .addProcedure('proc99400', '99400')
            .addDoctorMedicalProcedure('proc760902')
            .addProcedureSite('proc760904')
            .addCalendarProcedure('proc760902')
            .addCalendarProcedure('proc99400')
            .addSequence('proc760902', 'proc760904')
            .addCalendar1(15, 32);

        Medical_Procedure_in_Sites__c procedureInSite = dBuilder.createProcedureSite('proc760902');
        procedureInSite.Queue__c = '00G8E0000036GH0UAM';

        Appointment__c appt1 = dBuilder.createAppoitment('appt1', TestDataFactory.APPT_S_RT_NAME, 'proc760902', 'caseA');
        appt1.Appointment_Status__c = 'WaitingForAppointment';
        appt1.Accession_Number__c = 'R118616';
        appt1.Doctor_Account__c = dBuilder.doctor.Id;
        appt1.PayerFactor__c = dBuilder.pFactor.id;
        appt1.Commitment_Status__c = '0';
        appt1.Protocol__c = 'p1';
        appt1.Site__c = dBuilder.site.Id;

        Appointment__c appt2 = dBuilder.createAppoitment('appt2', TestDataFactory.APPT_E_RT_NAME, 'proc99400', 'caseA');
        appt2.Appointment_Status__c = 'WaitingForAppointment';
        appt2.Is_Hidden_Appointment__c = true;
        appt2.Protocol__c = 'p2';
        appt2.Accession_Number__c = 'Q38632431';
        appt2.Site__c = dBuilder.site.Id;

        Scheduler_parameters__c schParameters = dBuilder.createSchedulerParameters('proc760904');
        schParameters.Site__c = '62;84;68;60;45;20';
        schParameters.Preview_Text__c = 'יש לבקש לשלוח את ההפניה באמצעות ממשק  מסמכים דיגיטליים ולתאם ציפיות חזרה עד 48 שעות';
        schParameters.Metals_In_Body__c = 'רסיסים';
        schParameters.Iodine_Sensitivity__c = 'כן';
        schParameters.Gender__c = 'נ';
        schParameters.From_Date__c = 4;
        schParameters.Dust__c = 'כן';
        schParameters.Diabetes__c = 'כן';
        schParameters.Blood_Thinning_Pills__c = 'לא';
        schParameters.Asthma__c = 'כן';
        schParameters.Action_Type__c = 'מתאריך';
        schParameters.Gender__c = 'נ';
        schParameters.Weight__c = 'בין 140 ל-200';

        Scheduler_parameters__c schParameters1 = dBuilder.createSchedulerParameters('proc99400');
        schParameters1.Site__c = '62;84;68;60;45;20';
        schParameters1.Preview_Text__c = 'יש לבקש לשלוח את ההפניה באמצעות ממשק  מסמכים דיגיטליים ולתאם ציפיות חזרה עד 48 שעות';
        schParameters1.From_Date__c = 4;
        schParameters1.Action_Type__c = 'מתאריך';

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();

        appt1 = cData.appointments.get('appt1');
        appt2 = cData.appointments.get('appt2');
        appt1.after_appointment__c = appt2.Id;
        appt1.Is_Hidden_Appointment__c = true;
        appt2.after_appointment__c = appt1.Id;
        appt2.Case_Hidden__c = cData.cases.get('caseA').Id;
        update new List<Appointment__c>{appt1, appt2};

        insert new MP_combinations_for_technicians__c(
            Calendar__c = cData.calendar.Id,
            leading_MP__c = cData.procedures.get('proc760902').Id,
            included_MP__c = cData.procedures.get('proc760902').Id);
    }

    @IsTest
    static void getAppointmentTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'getAppointment',
            'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void getSequenceOfAppointmentsTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'getSequenceOfAppointments',
            'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void isAvailableTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'isAvailable',
            'recordId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void getPreferredChannelsTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'getPreferredChannels',
            'recordId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void updatePreferredChannelTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'updatePreferredChannel',
            'recordId' => cas.Id,
            'preferredChannel' => 'Whatsapp'
        });
        Test.stopTest();
    }

    @IsTest
    static void initCasTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Clinic__c clinic = [SELECT Id FROM Clinic__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'init',
            'recordId' => cas.Id,
            'clinicId' => clinic.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void initApptTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        Clinic__c clinic = [SELECT Id FROM Clinic__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'init',
            'recordId' => appt.Id,
            'clinicId' => clinic.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void searchDomainsTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchDomains',
            'screenMode' => 'limitedProcedures'
        });
        Test.stopTest();
    }

    @IsTest
    static void searchProceduresTest() {
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchProcedures',
            'domainId' => domain.Id,
            'screenMode' => 'limitedProcedures',
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE})
        });
        Test.stopTest();
    }

    @IsTest
    static void searchSitesTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchSites',
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.BREAST_ULTRASOUND_MAMMOGRAPHY_PROCEDURE_CODE})
        });
        Test.stopTest();
    }

    @IsTest
    static void searchTechniciansTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchTechnicians',
            'procedureCode' => TestDataFactory.PROCEDURE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void searchTechnicianProceduresTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchTechnicianProcedures',
            'accountId' => doctor.Id,
            'siteCode' => TestDataFactory.SITE_CODE,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void searchExpertClinicsTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchExpertClinics'
        });
        Test.stopTest();
    }

    @IsTest
    static void searchExpertCalendarsTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchExpertCalendars',
            'siteCode' => TestDataFactory.SITE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void searchExpertProceduresTest() {
        Calendar__c calendar = [SELECT ServiceId__c FROM Calendar__c LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchExpertProcedures',
            'calendarCode' => calendar.ServiceId__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE})
        });
        Test.stopTest();
    }

    @IsTest
    static void searchSitesForcedTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchSitesForced',
            'procedureCode' => '760902'
        });
        Test.stopTest();
    }

    @IsTest
    static void searchCalendarsForcedTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchCalendarsForced',
            'procedureCode' => TestDataFactory.PROCEDURE_CODE,
            'siteCode' => TestDataFactory.SITE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void searchQFlowCalendarsTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchQFlowCalendars',
            'siteCode' => TestDataFactory.SITE_CODE,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void checkProcedureTest() {
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'checkProcedure',
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE})
        });
        Test.stopTest();
    }

    @isTest
    static void retrieveReferralsTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];


        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'retrieveReferrals',
            'recordId' => cas.Id,
            'domainCode' => domain.Id,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE

        });
        Test.stopTest();
    }

    @IsTest
    static void obtainDraftFileTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainDraftFile',
            'caseId' => cas.Id,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void isFileMandatoryTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        Referral_Domain_mapping__mdt mdt = [SELECT DomainId__c FROM Referral_Domain_mapping__mdt LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'isFileMandatory',
            'recordId' => appt.Id,
            'domainId' => mdt.DomainId__c,
            'insurerFactor' => TestDataFactory.PFACTOR_CODE
        });
        Test.stopTest();
    }

    @IsTest
    static void searchFilesTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        Referral_Domain_mapping__mdt mdt = [SELECT DomainId__c FROM Referral_Domain_mapping__mdt LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'searchFiles',
            'recordId' => appt.Id,
            'domainId' => mdt.DomainId__c
        });
        Test.stopTest();
    }

    private class SearchSlotsMock implements WebServiceMock {
        private List<ws_AppointmentNew.Error> errors {get;set;}

        private SearchSlotsMock(Boolean isError, String errorCode) {
            this.errors = new List<ws_AppointmentNew.Error>();
            if (isError) {
                ws_AppointmentNew.Error error = new ws_AppointmentNew.Error();
                error.ErrorCode = errorCode;
                this.errors.add(error);
            }
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = Date.today();
            result.ErrorCode = '0';
            result.ErrorDescription = 'ErrorDescription';

            ws_AppointmentNew.PricesInfo pricesInfo = new ws_AppointmentNew.PricesInfo();
            pricesInfo.ClientNo = '0';
            pricesInfo.Price = 1234;

            ws_AppointmentNew.ArrayOfPricesInfoPricesInfo pricesInfos = new ws_AppointmentNew.ArrayOfPricesInfoPricesInfo();
            pricesInfos.PricesInfo = new List<ws_AppointmentNew.PricesInfo>{pricesInfo};

            ws_AppointmentNew.CalenderSlot slot = new ws_AppointmentNew.CalenderSlot();
            slot.SlotId = 1;
            slot.StartTime = Datetime.now().addDays(1);
            slot.EndTime = Datetime.now().addDays(1);
            slot.Duration = 2;
            slot.ModalityCode = 1;
            slot.AppointmentTypeId = '1';
            slot.UnitCode = 20;
            slot.CalendarId = 1;

            ws_AppointmentNew.ArrayOfCalenderSlotCalenderSlot slots = new ws_AppointmentNew.ArrayOfCalenderSlotCalenderSlot();
            slots.CalenderSlot = new List<ws_AppointmentNew.CalenderSlot>{slot};

            ws_AppointmentNew.ArrayOfErrorError errors = new ws_AppointmentNew.ArrayOfErrorError();
            errors.Error = this.errors;

            ws_AppointmentNew.Agreement agreement = new ws_AppointmentNew.Agreement();
            agreement.IsAgreementExists = false;
            agreement.PricesInfoList = pricesInfos;
            agreement.Errors = errors;

            ws_AppointmentNew.AppointmentSearchResponse resp = new ws_AppointmentNew.AppointmentSearchResponse();
            resp.AppointmentSearchResult = result;
            resp.CalenderSlots = slots;
            resp.Agreements = agreement;

            ws_AppointmentNew.AppointmentSearchResponse_element response_x = new ws_AppointmentNew.AppointmentSearchResponse_element();
            response_x.AppointmentSearchResult = resp;
            response.put('response_x', response_x);
        }
    }

    @IsTest
    static void obtainSlotsTest() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(false, null));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErr1Test() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, '1'));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];
        
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErr2Test() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, '2'));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErr3Test() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, '3'));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErr4Test() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, '4'));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErr5Test() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, '5'));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsErrNullTest() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(true, null));
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlots',
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'siteCode' => TestDataFactory.SITE_CODE,
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'domainId' => domain.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainSlotsForcedTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlotsForced',
            'siteCode' => TestDataFactory.SITE_CODE,
            'calendarCode' => TestDataFactory.CALENDAR_CODE,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE,
            'startDate' => String.valueOf(Date.today()),
            'restrictionsOnly' => true
        });
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSlotsForced',
            'siteCode' => TestDataFactory.SITE_CODE,
            'calendarCode' => TestDataFactory.CALENDAR_CODE,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE,
            'startDate' => String.valueOf(Date.today()),
            'restrictionsOnly' => true,
            'doctorId' => doctor.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void obtainExpertSlotsTest() {
        Test.setMock(WebServiceMock.class, new SearchSlotsMock(false, null));
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainExpertSlots',
            'recordId' => cas.Id,
            'siteCode' => TestDataFactory.SITE_CODE,
            'calendarCode' => TestDataFactory.CALENDAR_CODE,
            'procedureCode' => TestDataFactory.NEW_DOCTOR_PROCEDURE_CODE,
            'doctorId' => doctor.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void lockSlotsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'lockSlots',
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'slotLockIds' => JSON.serialize(new List<String>{'1'})
        });
        Test.stopTest();
    }

    @IsTest
    static void unlockSlotsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'unlockSlots',
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'slotLockIds' => JSON.serialize(new List<String>{'1'})
        });
        Test.stopTest();
    }

    @IsTest
    static void relockSlotsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock()); 
        
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'relockSlots',
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'slotLockIds' => JSON.serialize(new List<String>{'1'})
        });
        Test.stopTest();
    }

    @IsTest
    static void unlockRelockSlotsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        
        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'unlockRelockSlots',
            'jsonedSlotsForUnlock' => TestDataFactory.JSONED_SLOTS,
            'slotLockIdsForUnlock' => JSON.serialize(new List<String>{'1'}),
            'jsonedSlotsForRefresh' => TestDataFactory.JSONED_SLOTS,
            'slotLockIdsForRefresh' => JSON.serialize(new List<String>{'1'})
        });
        Test.stopTest();
    }

    @IsTest
    static void createAppointmentsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Doctor_in_Clinic__c docInClinic = [SELECT Id FROM Doctor_in_Clinic__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];
        LC_AppointmentScreenService.TechnicianWrp tech = new LC_AppointmentScreenService.TechnicianWrp('all');

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'createAppointments',
            'recordId' => cas.Id,
            'clinicId' => docInClinic.Id,
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'assists' => JSON.serialize(new List<String>{'50'}),
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'urgentReason' => 'urgentReason',
            'insurenceCode' => TestDataFactory.PFACTOR_CODE,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'technician' => JSON.serialize(tech),
            'technicianProcedureCode' => '760902'
        });
        Test.stopTest();
    }

    @isTest 
    static void createAppointmentsFailTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Doctor_in_Clinic__c docInClinic = [SELECT Id FROM Doctor_in_Clinic__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];
        LC_AppointmentScreenService.TechnicianWrp tech = new LC_AppointmentScreenService.TechnicianWrp('all');

        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_D_RT_NAME];

        Test.startTest();
        try {
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'createAppointments',
            'recordId' => cas.Id,
            'clinicId' => docInClinic.Id,
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'assists' => JSON.serialize(new List<String>{'50'}),
            'protocols' => JSON.serialize(new List<String>{'p1'}),
            'urgentReason' => 'urgentReason',
            'insurenceCode' => TestDataFactory.PFACTOR_CODE,
            'procedureCodes' => JSON.serialize(new List<String>{TestDataFactory.PROCEDURE_CODE}),
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'technician' => JSON.serialize(tech),
            'technicianProcedureCode' => '760902',
            'doctorId' => doctor.Id
        });
        } catch (Exception e) {

        }
        Test.stopTest();
    }

    @isTest
    static void wrapperTest() {
        Medical_Procedure__c procedure = [SELECT id, Procedure_Code__c, Marketing_Procedure_Name__c FROM Medical_Procedure__c LIMIT 1];
        Sequence__c sequence = new Sequence__c(
            same_day__c = true,
            calendar__c = true,
            sec_1_to_2__c = 1,
            max_sec_1_to_2__c = 2,
            sec_2_to_3__c = 3,
            max_sec_2_to_3__c = 4
        );
        Test.startTest();
        LC_AppointmentScreenService.PriceWrp priceWrp = new LC_AppointmentScreenService.PriceWrp(new ws_Appointmentnew.PricesInfo(), 'test');
        LC_AppointmentScreenService.SequenceWrp sequenceWrp = new LC_AppointmentScreenService.SequenceWrp(procedure, sequence, '1_to_2');
        LC_AppointmentScreenService.SequenceWrp sequenceWrp2 = new LC_AppointmentScreenService.SequenceWrp(procedure, sequence, '2_to_3');
        Test.stopTest();
    }

    @IsTest
    static void setAppointmentsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Medical_Procedure_Plan_All__mdt mdt = [SELECT Id, ProcedureCode1__c FROM Medical_Procedure_Plan_All__mdt LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];
        Appointment__c appt = [SELECT Patient_Account__c FROM Appointment__c LIMIT 1];

        File__c file = TestDataFactory.getFile();
        file.Account__c = appt.Patient_Account__c;
        file.file_type__c = 'Waiver_of_confidentiality';
        insert file;

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'setAppointments',
            'jsonedSlots' => TestDataFactory.JSONED_SLOTS,
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'recordIds' => JSON.serialize(new List<String>{appt.Id}),
            'fileIds' => JSON.serialize(new List<String>{file.Id})
        });
        Test.stopTest();
    }

    @IsTest
    static void setAppointmentsMassTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Medical_Procedure_Plan_All__mdt mdt = [SELECT Id, ProcedureCode1__c FROM Medical_Procedure_Plan_All__mdt LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME];
        Appointment__c appt = [SELECT Patient_Account__c FROM Appointment__c LIMIT 1];
        Appointment__c appt2 = [SELECT Patient_Account__c FROM Appointment__c WHERE Id != :appt.Id LIMIT 1];

        File__c file = TestDataFactory.getFile();
        file.Account__c = appt.Patient_Account__c;
        file.file_type__c = 'Waiver_of_confidentiality';
        insert file;

        List<ws_AppointmentNew.CalenderSlot> slots = (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(TestDataFactory.JSONED_SLOTS, List<ws_AppointmentNew.CalenderSlot>.class);
        slots.add(slots.get(0));

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'setAppointments',
            'jsonedSlots' => JSON.serialize(slots),
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'recordIds' => JSON.serialize(new List<String>{appt.Id, appt2.Id}),
            'fileIds' => JSON.serialize(new List<String>{file.Id})
        });
        Test.stopTest();
    }

    @IsTest
    static void validateAppointmentsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        try {
            new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
                'actionName' => 'validateAppointments',
                'recordIds' => JSON.serialize(new List<String>{appt.Id})
            });
        } catch (Exception e) {
            System.assertEquals(LC_AppointmentScreenUtil.ERR_ENSEMBLE, e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void rescheduleAppointmentsTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = :TestDataFactory.ACCT_P_RT_NAME LIMIT 1];

        Test.startTest();
        new LC_AppointmentScreenController().executeAction(new Map<String, Object>{
            'actionName' => 'rescheduleAppointments',
            'recordId' => cas.Id,
            'patientId' => patient.ID_Number__c,
            'idType' => patient.ID_Type__c,
            'insurenceCode' => TestDataFactory.PFACTOR_CODE,
            'appointmentIds' => JSON.serialize(new List<String>{appt.Id}),
            'jsonedSlots' => TestDataFactory.getJSONSlots('99400')
        });
        Test.stopTest();
    }
    
    @isTest
    static void transferToDepartmentTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        try {
            Response res = controller.executeAction(new Map<String, Object>{
                'actionName' => 'transferToDepartment',
                'procedureCode' => TestDataFactory.PROCEDURE_CODE,
                'insurenceCode' => TestDataFactory.PFACTOR_CODE,
                'siteCode' => TestDataFactory.SITE_CODE,
                'caseId' => [SELECT Id FROM Case LIMIT 1].Id,
                'domainId' => [SELECT Id FROM Domain__c LIMIT 1].Id
            });
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void getCalendarProcedureTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getCalendarProcedure', 'calendarCode' => [SELECT ServiceId__c FROM Calendar__c LIMIT 1].ServiceId__c});
        Test.stopTest();
    }

    @isTest
    static void getCancelFormDataTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getCancelFormData', 'recordId' => [SELECT Id FROM Appointment__c LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void getUpdateFormDataTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getUpdateFormData', 'caseId' => [SELECT Id FROM Case LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void checkWorkingDaysTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'checkWorkingDays', 'scheduleDate' => String.valueOf(Date.today().addYears(1))});
        Test.stopTest();
    }

    @isTest
    static void checkAppointmentWorkingDaysOnCreateTest() {
        Test.startTest();
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        appt.more_than_14_days__c = true;
        update appt;
        
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'checkAppointmentWorkingDaysOnCreate', 'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @isTest
    static void approveAppointmentForMoreThan14DaysTest() {
        Test.startTest();
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        appt.more_than_14_days__c = true;
        update appt;
        
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'approveAppointmentForMoreThan14Days', 'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @isTest
    static void cancelAppointmentForMoreThan14DaysTest() {
        Test.startTest();
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        appt.more_than_14_days__c = true;
        update appt;
        
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'cancelAppointmentForMoreThan14Days', 'appointmentId' => appt.Id
        });
        Test.stopTest();
    }

    @isTest
    static void updateScreenTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'updateScreen', 'appointmentId' => [SELECT Id FROM Appointment__c LIMIT 1].Id});
        Test.stopTest();
    }

    @isTest
    static void checkSchedulerParametersTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'startDate' => '2020-05-05',
            'actionName' => 'checkSchedulerParameters',
            'idType' => TestDataFactory.ID_TYPE,
            'siteCode' => TestDataFactory.SITE_CODE,
            'domainId' => [SELECT Id FROM Domain__c LIMIT 1].Id,
            'patientId' => [SELECT ID_Number__c FROM Account WHERE ID_Number__c =: TestDataFactory.P_ID_NUMBER LIMIT 1].ID_Number__c,
            'procedureCode' => '760904',
            'protocol' => 'p1',
            'insurenceCode'=> '4'
        });
        Test.stopTest();
    }

    @isTest
    static void isRelatedDocExistsTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'isRelatedDocExists',
            'siteCode' => TestDataFactory.SITE_CODE,
            'procedureCodes' => JSON.serialize(new List<String>{'760902'})
        });
        Test.stopTest();
    }

    @isTest
    static void getUrgentAppointmentFormDataTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'actionName' => 'getUrgentAppointmentFormData',
            'recordId' => appt.Id
        });
        Test.stopTest();
    }

    @isTest
    static void appointmentSearchTest() {
        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(
            new Map<String, Object>{'actionName' => 'appointmentSearch', 'caseId' => [SELECT Id FROM Case LIMIT 1].Id, 'keyWord' => TestDataFactory.KEYWORD}
        );
        Test.stopTest();
    }

    @isTest
    static void cancelAppointmentTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());

        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{
            'canceledReason' => '2',
            'reasonFreeText' => 'test',
            'actionName' => 'cancelAppointment',
            'caseId' => [SELECT Id FROM Case LIMIT 1].Id,
            'appointmentId' => [SELECT Id FROM Appointment__c LIMIT 1].Id
        });
        Test.stopTest();
    }

    @isTest
    static void isSaveSlotTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        LC_AppointmentScreenController controller = new LC_AppointmentScreenController();
        Response res = controller.executeAction(new Map<String, Object>{            
            'actionName' => 'isSaveSlot',
            'recordId' => appt.Id,
            'calendarCode' => TestDataFactory.CALENDAR_CODE,
            'procedureCode' => TestDataFactory.PROCEDURE_CODE
        });
        Test.stopTest();
    }
    
     @isTest
    static void increaseCoverageTest() {
        Test.startTest();
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        LC_AppointmentScreenService.getInstance(appt.Id).increaseCoverage();
        Test.stopTest();
    }
}