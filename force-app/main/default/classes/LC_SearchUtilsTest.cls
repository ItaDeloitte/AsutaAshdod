@isTest
private class LC_SearchUtilsTest {

    @TestSetup
    static void setup() {
        TestDataFactory.DataBuilder dBuilder =  TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        Case cas = dBuilder.createCase('cas', 'Appointments');

        Medical_Procedure__c procedure1 = dBuilder.createProcedure('procI1', '70551');
        Medical_Procedure__c procedure2 = dBuilder.createProcedure('procI2', '70604');
        Medical_Procedure__c procedureH = dBuilder.createProcedure('procIH', '760904');

        Appointment__c appt1 = dBuilder.createAppoitment(TestDataFactory.APPT_I_RT_NAME, 'procI1', 'cas');
        Appointment__c appt2 = dBuilder.createAppoitment(TestDataFactory.APPT_I_RT_NAME, 'procI2', 'cas');
        appt2.Appointment_Date_Time__c = appt1.Appointment_Date_Time__c.addMinutes(30);
        appt2.after_appointment__c = appt1.Id;
        Appointment__c apptH = dBuilder.createAppoitment(TestDataFactory.APPT_I_RT_NAME, 'procIH', 'cas');
        apptH.after_appointment__c = appt1.Id;
        apptH.Is_Hidden_Appointment__c = true;

        dBuilder.insertCommonData();
    }

    @IsTest
    static void getConnectedAppointmentsToCaseTest() {
        Test.startTest();
        LC_SearchUtils.getConnectedAppointmentsToCase([SELECT AccountId, RecordType.DeveloperName FROM Case LIMIT 1], '', true, true);
        Test.stopTest();
    }

    // PROCEDURES SEARCH
    @isTest
    static void procedureSearchForDocExpertTest() {
        Test.startTest();
        LC_SearchUtils.procedureSearchForDocExpert([SELECT Id FROM Sub_Expertise__c LIMIT 1].Id, '');
        Test.stopTest();
    }

    // EXPERTISES SEARCH
    @isTest
    static void expertiseSearchTest() {
        Test.startTest();
        LC_SearchUtils.expertiseSearch('');
        Test.stopTest();
    }

    @isTest
    static void subExpertiseSearchTest() {
        Test.startTest();
        LC_SearchUtils.subExpertiseSearch([SELECT Id FROM Expertise__c LIMIT 1].Id, '');
        Test.stopTest();
    }

    // DOCTOR SEARCH
    @isTest
    static void doctorSearchTest() {
        Test.startTest();
        LC_SearchUtils.doctorSearch('');
        Test.stopTest();
    }
}