@isTest
public class ws_DiariesTest {
	
    @testSetup
    static void setup() {
        Site__c site = TestDataFactory.getSite('85');
		insert site;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.AppointmentSys__c = 'RIS';
        calendar.BranchName__c = site.Id;
        insert calendar;
    }
    
    @isTest
    public static void checkWs() {
        Test.setMock(HttpCalloutMock.class, new GetDiaries_Mock());
        Test.startTest();
        ws_Diaries.GetDiaries(Date.today(), '84', '26', '767000', false);
        Test.stopTest();
    }

    private class GetDiaries_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"diaryRecords":[{"calendarCode":"504","date":"2021-01-28","description":"זמן מוחזק לטובת נטשה","startTime":"10:30","endTime":"13:00","type":"זמן מוחזק"},'+
            '{"calendarCode":"504","date":"2021-01-28","description":"לזימון באישור הנהלה בלבד","startTime":"12:00","endTime":"12:40","type":"משוריין ידנית"}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}