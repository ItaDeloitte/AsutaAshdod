/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * SMS Sender Schedule Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             22-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class DoctorAbandonmentScheduleBatchTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        Case cas = dBuilder.createCase('cas', 'Surgery');
        Medical_Procedure__c proc =  dBuilder.createProcedure('proc', '12345');

        Appointment__c appt1LastHY = dBuilder.createAppoitment('appt1', TestDataFactory.APPT_S_RT_NAME, 'proc', 'cas');
        appt1LastHY.Appointment_Date_Time__c = Datetime.now().addMonths(-8);
        appt1LastHY.Appointment_Status__c = 'WaitingForAppointment';
        appt1LastHY.Doctor_Account__c = dBuilder.doctor.Id;
        Appointment__c appt2LastHY = dBuilder.createAppoitment('appt1', TestDataFactory.APPT_S_RT_NAME, 'proc', 'cas');
        appt2LastHY.Appointment_Date_Time__c = Datetime.now().addMonths(-7);
        appt2LastHY.Appointment_Status__c = 'WaitingForAppointment';
        appt2LastHY.Doctor_Account__c = dBuilder.doctor.Id;
        Appointment__c apptThisHY = dBuilder.createAppoitment('appt1', TestDataFactory.APPT_S_RT_NAME, 'proc', 'cas');
        apptThisHY.Appointment_Date_Time__c = Datetime.now().addMonths(-1);
        apptThisHY.Appointment_Status__c = 'WaitingForAppointment';
        apptThisHY.Doctor_Account__c = dBuilder.doctor.Id;

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @IsTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new DoctorAbandonmentScheduleBatch());
        Test.stopTest();
    }
}