@IsTest
public class PreventMessagingUtilsTest {

    @TestSetup
    static void setupData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
    
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_status__c = 'אין מענה';
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt.Appointment_Date_Time__c = date.today().adddays(+1); 
        insert appt;                

        insert TestDataFactory.getAppointmentManager(site.Id, calendar.Id, procedure.Id);
    }
  
    // isMessagingPrevented = TRUE
    @IsTest
    static void testIsMessagingPrevented_true() {
        Appointment__c appt = [SELECT Id, Site__c, Calendar__c, Medical_Procedure__c
                                FROM Appointment__c
                                LIMIT 1];

        Test.startTest();
        Map<Id, Boolean> results =
            PreventMessagingUtils.isMessagingPrevented(
                new List<Appointment__c>{ appt }
            );
        Test.stopTest();

        System.assertEquals(true, results.get(appt.Id),
            'Messaging should be prevented');
    }

    // isMessagingPrevented = FALSE
    @IsTest
    static void testIsMessagingPrevented_false() {

        site__c site = TestDataFactory.getSite('69');
        insert site;

        Appointment__c appt = [SELECT Id, Site__c, Calendar__c, Medical_Procedure__c
                                FROM Appointment__c
                                LIMIT 1];
        appt.site__c = site.Id;    
        update appt;

        Appointment_Manager__c appManager = [SELECT Id, RecordTypeId, Action_Type__c  FROM Appointment_Manager__c  LIMIT 1];
        System.debug('appManager  ' + appManager);

        Test.startTest();
        Map<Id, Boolean> results =
            PreventMessagingUtils.isMessagingPrevented(
                new List<Appointment__c>{ appt }
            );
        Test.stopTest();

        System.assertEquals(false, results.get(appt.Id),
            'Messaging should NOT be prevented');
    }

    // Flow / Invocable Method
    @IsTest
    static void testPreventMessageFlow() {

        Appointment__c appt = [SELECT Id, Site__c, Calendar__c, Medical_Procedure__c
                                FROM Appointment__c
                                LIMIT 1];

        PreventMessagingUtils.PreventMessage_Request req =
            new PreventMessagingUtils.PreventMessage_Request();
        req.appointment = appt;

        Test.startTest();
        List<PreventMessagingUtils.PreventMessage_Response> resp =
            PreventMessagingUtils.preventMessageFlow(
                new List<PreventMessagingUtils.PreventMessage_Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, resp.size());
        System.assert(resp[0].isSuccses);
        System.assertEquals(true, resp[0].isPrevented);
    }
}