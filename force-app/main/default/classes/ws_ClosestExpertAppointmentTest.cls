/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * GetCalendars REST Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             24-06-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
private with sharing class ws_ClosestExpertAppointmentTest {

    @TestSetup
    static void makeData() {}

    @IsTest
    static void getCalendarsTest() {
        Test.setMock(HttpCalloutMock.class, new ws_ClosestExpertAppointment.ws_ClosestExpertAppointmentHttpMock());

        Test.startTest();
        ws_ClosestExpertAppointment.getCalendars('0', '0');
        Test.stopTest();
    }
}