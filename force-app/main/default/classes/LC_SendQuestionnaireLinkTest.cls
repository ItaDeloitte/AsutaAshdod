/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment 'Send Questionnaire Link' button Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             13-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class LC_SendQuestionnaireLinkTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        Case cas = dBuilder.createCase('cas', 'DOC_expert');

        dBuilder
            .addAppoitment('appt', TestDataFactory.APPT_S_RT_NAME, 'proc', 'cas')
            .buildSurvey('survey').build()
            .addSurveyQuestion('survey')
            .buildDocToAction('survey').build()
            .buildSurveyTaker('survey', 'cas', 'patient').build();

        TestDataFactory.CommonData cData = dBuilder.insertCommonData();

        Appointment__c appt = cData.appointments.get('appt');

        SurveyTaker__c surveyTaker = [SELECT Appointment__c FROM SurveyTaker__c LIMIT 1];
        surveyTaker.Appointment__c = appt.Id;
        update surveyTaker;
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_SendQuestionnaireLinkController().executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void obtainSurveyTakersTest() {
        Appointment__c appointment = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        new LC_SendQuestionnaireLinkController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainSurveyTakers',
            'appointmentId' => appointment.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void submitTest() {
        Appointment__c appointment = [SELECT Id FROM Appointment__c LIMIT 1];
        SurveyTaker__c surveyTaker = [SELECT Id FROM SurveyTaker__c LIMIT 1];

        Test.startTest();
        new LC_SendQuestionnaireLinkController().executeAction(new Map<String, Object>{
            'actionName' => 'submit',
            'appointmentId' => appointment.Id,
            'surveyTakerId' => surveyTaker.Id
        });
        Test.stopTest();
    }
}