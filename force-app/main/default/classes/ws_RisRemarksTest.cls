@isTest
public class ws_RisRemarksTest {
	
    @testSetup
    static void setup() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();        
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);        
        insert procedure;
        Site__c site = TestDataFactory.getSite('85');
		insert site;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.AppointmentSys__c = 'RIS';
        calendar.BranchName__c = site.Id;
        insert calendar;
    }
    
    @isTest
    public static void checkWs() {
        Medical_Procedure__c procedure = [SELECT Id, Name, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id, ServiceId__c FROM Calendar__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new updateRemark_Mock());
        Test.startTest();
        ws_RisRemarks.updateRemark('lockSlotSF', procedure.Name, procedure.Procedure_Code__c , calendar.ServiceId__c , String.valueOf(Date.today()), 30);
        Test.stopTest();
    }

    
    public class updateRemark_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Success" : true, "ErrorMessage" : "Success"}');
            response.setStatusCode(200);
            return response;
        }
    }
}