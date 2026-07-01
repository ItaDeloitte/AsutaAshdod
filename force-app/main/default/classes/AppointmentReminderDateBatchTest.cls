@IsTest
public with sharing class AppointmentReminderDateBatchTest {

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

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @IsTest
    private static void executeBatch1Test() {
        Test.startTest();
        Database.executeBatch(new AppointmentReminderDateBatch());
        Test.stopTest();
    }

    @IsTest
    private static void executeBatch2Test() {
        Test.startTest();
        Database.executeBatch(new AppointmentReminderDateBatch(
            'SELECT Medical_Procedure__c, Appointment_Date_Time__c, sendingByWhatsApp__c, Site_Code__c, Remainder_type__c, Remainder_time__c'
                + ', Date_for_human_reminder__c, Date_for_tizkorit_reminder__c, dateRemainder1WA__c, dateRemainder2WA__c FROM Appointment__c'));
        Test.stopTest();
    }
}