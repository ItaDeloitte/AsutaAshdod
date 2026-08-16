// Test for: DocInClinicTrigger, DocInClinicTriggerHandler, DocInClinicTriggerDispatcher, DocInClinicServices
// Created: Evgeniy Kravchuk
// Date: 30.01.2020
@isTest
private class DocInClinicServicesTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        clinic.Area__c = 'area';
        insert clinic;
    }

    @isTest
    static void updateDocFieldsTest() {
        Account doctor = [SELECT Id FROM Account LIMIT 1];
        Clinic__c clinic = [SELECT Id FROM Clinic__c LIMIT 1];
        Doctor_in_Clinic__c junction = TestDataFactory.getDocClinic(doctor.Id, clinic.Id);
        junction.Schedule_System__c = 'QFlow';
        Test.startTest();
        insert junction;
        update junction;
        delete junction;
        Test.stopTest();
    }
}