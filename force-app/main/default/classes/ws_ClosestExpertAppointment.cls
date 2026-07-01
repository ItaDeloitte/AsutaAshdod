/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * GetCalendars REST Apex class to get the closest available Appointment slot per Doctor
 * 
 * Test                 ws_ClosestExpertAppointmentTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             24-06-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class ws_ClosestExpertAppointment {

    private static final ENV__c ENV = ENV__c.getInstance();
    private static final String NAMED_CREDENTIAL = 'callout:Ensemble_Rest_' + ENV.Env_value__c;
    private static final String REST_RESOURCE = '/closestexpertappointment/getcalendars';
    private static final String ENDPOINT = NAMED_CREDENTIAL + REST_RESOURCE;

    public static GetCalendarsResponse getCalendars(String expertiseCode, String subExpertiseCode) {
        System.debug('ws_ClosestExpertAppointment.getCalendars ...');

        String reqBody = JSON.serialize(new GetCalendarsRequest(expertiseCode, subExpertiseCode));
        System.debug('ws_ClosestExpertAppointment.getCalendars Request: ' + reqBody);

        try {
            HttpResponse hRes = doGet(reqBody);
            System.debug('ws_ClosestExpertAppointment.getCalendars Status: ' + hRes.getStatus());
            System.debug('ws_ClosestExpertAppointment.getCalendars StatusCode: ' + hRes.getStatusCode());

            String resBody = hRes.getBody();
            System.debug('ws_ClosestExpertAppointment.getCalendars Response: ' + resBody);

            if (hRes.getStatusCode() == 200) {
                return (GetCalendarsResponse) JSON.deserialize(resBody, GetCalendarsResponse.class);
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to ' + REST_RESOURCE + ':' + e.getMessage());
        }

        return new GetCalendarsResponse();
    }

    private static HttpResponse doGet(String body) {
        Http http = new Http();
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Content-Type', 'application/json');
        hReq.setEndpoint(ENDPOINT);
        hReq.setTimeout(14000);
        hReq.setMethod('GET');
        hReq.setBody(body);
        return http.send(hReq);
    }

    /** WRAPPERS */
    public class GetCalendarsRequest {
        public String ExpertiseCode;
        public String SubExpertiseCode;

        public GetCalendarsRequest(String expertiseCode, String subExpertiseCode) {
            this.ExpertiseCode = expertiseCode;
            this.SubExpertiseCode = subExpertiseCode;
        }
    }

    public class GetCalendarsResponse {
        public Boolean Success;
        public String ErrorMessage;
        public List<DoctorCalendar> DoctorCalendars;
    }

    public class DoctorCalendar {
        public String ServiceId;
        public String LicenseNumber;
        public String ClosestDateTime;
    }

    /** MOCK */
    global class ws_ClosestExpertAppointmentHttpMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            GetCalendarsResponse mock = new GetCalendarsResponse();
            mock.Success = true;
            mock.DoctorCalendars = new List<DoctorCalendar>{new DoctorCalendar()};
            mock.DoctorCalendars.get(0).ServiceId = '0';
            mock.DoctorCalendars.get(0).LicenseNumber = '0';
            mock.DoctorCalendars.get(0).ClosestDateTime = '2041-06-27 13:23:00';

            HttpResponse hRes = new HttpResponse();
            hRes.setHeader('Content-Type', 'application/json');
            hRes.setBody(JSON.serialize(mock));
            hRes.setStatusCode(200);
            return hRes;
        }
    }
}