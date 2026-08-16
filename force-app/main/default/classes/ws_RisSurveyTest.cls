/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * GetIsAnswerdQuestionsList REST Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-08-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
private with sharing class ws_RisSurveyTest {

    @TestSetup
    static void makeData() {}

    @IsTest
    static void getCalendarsTest() {
        Test.setMock(HttpCalloutMock.class, new ws_RisSurvey_REST.ws_RisSurvey_RESTHttpMock());

        Test.startTest();
        ws_RisSurvey_REST.getSurveyFromRis('0', '0');
        Test.stopTest();
    }
}