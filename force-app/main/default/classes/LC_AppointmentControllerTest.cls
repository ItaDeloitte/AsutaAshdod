@isTest
private class LC_AppointmentControllerTest {
    
    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData().initCommonData();
        
        dBuilder.pFactor.PresentOnSchdeuleScreen__c = true;
        update dBuilder.pFactor;
        
        dBuilder.site.Relevant_for_appointment_screen__c = true;
        update dBuilder.site;
        
        dBuilder.clinic.Site__c = dBuilder.site.Id;
        update dBuilder.clinic;

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
        schParameters.Asthma__c  = 'כן';
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
        update new List<Appointment__c>{
            appt1,
            appt2
        };
    }

    @isTest
    static void cancelAppointmentTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());

        Test.startTest();
        LC_AppointmentController controller = new LC_AppointmentController();
        Response res = controller.executeAction(new Map<String, Object>{
            'canceledReason' => '2',
        	'reasonFreeText' => 'test',
            'actionName' => 'cancelAppointment',
        	'caseId' => [SELECT Id FROM Case LIMIT 1].Id,
        	'appointmentId' => [SELECT Id FROM Appointment__c LIMIT 1].Id
        });
        Test.stopTest();
    }
}