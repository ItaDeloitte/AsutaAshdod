/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Payment Status Checking Schedule Apex Test class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-02-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public without sharing class CheckPaymentStatusScheduleTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData().initCommonData();

        dBuilder
            .addCase('caseA', 'Appointments')
            .addProcedure('proc99400', '99400');

        Appointment__c appt2 = dBuilder.createAppoitment('appt2', TestDataFactory.APPT_E_RT_NAME, 'proc99400', 'caseA');

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @IsTest
    static void executeTest() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        Datetime now = System.now().addMinutes(25);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('Test Payment Status Checker #' + now.getTime(), CRONEXP, new CheckPaymentStatusSchedule(new Set<Id>{appt.Id}));
        Test.stopTest();
    }
}