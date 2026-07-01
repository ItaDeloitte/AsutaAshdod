public with sharing class LC_UtilityBarService {

    public class LC_UtilityBarException extends Exception {}

    private static LC_UtilityBarService instance;

    private User currentUser;

    public static LC_UtilityBarService getInstance() {
        if (instance == null) {
            instance = new LC_UtilityBarService();
        }
        return instance;
    }

    private LC_UtilityBarService() {
        this.currentUser = LC_UtilityBarUtils.obtainUser(System.UserInfo.getUserId());
    }

    public Boolean isUserCanRefreshDashboard() {
        List<String> profilesNames = LC_UtilityBarUtils.getSupportProfilesForDashboardRefresh();
        System.debug('profilesNames: size: ' + profilesNames.size() + ' values: ' + profilesNames);

        if (profilesNames.isEmpty()) {
            return true;
        } else {
            return profilesNames.contains(this.currentUser.Profile.Name);
        }
    }

    public Response refreshDashboard(String dashboardId, Integer refreshTime) {
        Response apiResponse = new Response();

        String statusDashboardURL = LC_UtilityBarUtils.buildDashboardsStatusURL(dashboardId);
        System.debug('statusDashboardURL: ' + statusDashboardURL);
        StatusResposne statusResponseApi = mapStatusResposne(makeHttpCall(statusDashboardURL, 'GET', null, new Map<String, String>{}));
        System.debug('statusResponseApi: ' + statusResponseApi);

        if (statusResponseApi.isSuccess) {
            if (isTimeToRefreshDasboard(statusResponseApi, refreshTime)) {
                String refreshDashboardURL = LC_UtilityBarUtils.buildDashboardsURL(dashboardId);
                System.debug('refreshDashboardURL: ' + refreshDashboardURL);
                apiResponse = mapRefreshDashboardResponse((makeHttpCall(refreshDashboardURL, 'PUT', '{}', new Map<String, String>{})));
            } else {
                apiResponse.responseObj = LC_UtilityBarUtils.MSG_DASBOARD_UP_TO_DATE;
            }
        } else {
            apiResponse.responseObj = statusResponseApi.errors;
        }
        System.debug('apiresponse: ' + apiresponse);
        return apiResponse;
    } 

    private Boolean isTimeToRefreshDasboard(StatusResposne statusResponseApi, Integer refreshTime) {
        Boolean result = false;
        DateTime lastRefreshDate = null;
        DateTime currentDate = System.now();

        refreshTime = refreshTime < LC_UtilityBarUtils.DEFAULT_REFRESH_TIME
            ? LC_UtilityBarUtils.DEFAULT_REFRESH_TIME 
            : refreshTime;

        for (ComponentStatus status_i : statusResponseApi.componentStatus) {
            if (status_i.refreshDate != null) {
                lastRefreshDate = lastRefreshDate == null 
                    ? status_i.refreshDate 
                        : lastRefreshDate > status_i.refreshDate 
                            ? status_i.refreshDate
                            : lastRefreshDate;
            }
        }
        System.debug('lastRefreshDate :' + lastRefreshDate);
        System.debug('currentDate :' + currentDate);

        if (lastRefreshDate == null ) {
            result = true;
        } else {
            System.debug('currentDate.getTime() - lastRefreshDate.getTime() :' + (currentDate.getTime() - lastRefreshDate.getTime()));
            result = (currentDate.getTime() - lastRefreshDate.getTime()) >= (refreshTime * LC_UtilityBarUtils.MILLISECONDS); 
        }
        return result;
    }

    private HttpResponse makeHttpCall(String endpoint, String httpMethod, String reqBody, Map<String, String> headers) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        req.setEndpoint(endpoint);
        req.setMethod(httpMethod);
        req.setTimeout(30000);
        if (!String.isBlank(reqBody)) {
            req.setBody(reqBody);
        }
        if (!headers.isEmpty()) {
            for (String key_i : headers.keySet()) {
                req.setHeader(key_i, headers.get(key_i));
                System.debug('header: ' + key_i + '>' + headers.get(key_i));
            }
        } 
        System.debug('endpoint: ' + endpoint);
        HttpResponse res = http.send(req);
        System.debug('res: ' + res);
        return res;
    }

    private StatusResposne mapStatusResposne(HttpResponse apiReponse) {
        StatusResposne response = new StatusResposne();

        response.isSuccess = (apiReponse.getStatusCode() < 300);
        if (!response.isSuccess) {
            response.errors = (List<Error>) JSON.deserialize(apiReponse.getBody(), List<Error>.class);
        } else {
            response = (StatusResposne) JSON.deserialize(apiReponse.getBody(), StatusResposne.class);
            response.isSuccess = true;
        }
        return response;
    }

    private Response mapRefreshDashboardResponse(HttpResponse apiReponse) {
        Response response = new Response();

        response.isSuccess = apiReponse.getStatusCode() < 300;
        if (!response.isSuccess) {
            response.responseObj = (List<Error>) JSON.deserialize(apiReponse.getBody(), List<Error>.class);
        } else {
            response.responseObj = (String) ((Map<String, Object>) JSON.deserializeUntyped(apiReponse.getBody())).get('statusUrl');
        }
        return response;
    }

    public class SalesforceAPIMock implements HttpCalloutMock {
        
        private Boolean isSuccess;

        public SalesforceAPIMock() {
            this(true);
        }

        public SalesforceAPIMock(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            
            if (isSuccess) {
                response.setBody(getBodyForEndpoint(request.getEndpoint()));
                response.setStatusCode(200);
            } else {
                response.setBody(getErrorBodyForEndpoint(request.getEndpoint()));
                response.setStatusCode(401);
            }
            return response; 
        }

        private String getBodyForEndpoint(String endpoint) {
            if (endpoint.contains(LC_UtilityBarUtils.API_PATH_STATUS)) {
                return '{"componentStatus": [{"componentId": "01a7E000000P5ruQAC","refreshDate": "2024-09-16T12:02:39.000+0000","refreshStatus": "IDLE"}]}';
            } else if (endpoint.contains(LC_UtilityBarUtils.API_PATH_DASHBOARDS)) {
                return '{"statusUrl": "/services/data/v61.0/analytics/dashboards/01Z7E000001WTbJUAW/status"}';
            } else {
                return '{"success":true}';
            }
        }

        private String getErrorBodyForEndpoint(String endpoint) {
            if (endpoint.contains(LC_UtilityBarUtils.API_PATH_STATUS)) {
                return '[{"message": "invalid parameter value","errorCode": "UNKNOWN_EXCEPTION"}]';
            } else if (endpoint.contains(LC_UtilityBarUtils.API_PATH_DASHBOARDS)) {
                return '[{"message": "insufficient access rights on cross-reference id","errorCode": "INSUFFICIENT_ACCESS"}]';
            } else {
                return '{"success":false}'; 
            }
        }
    }

    public class Error {
        @AuraEnabled
        public String message {set;get;}
        @AuraEnabled
        public String errorCode {set;get;}
    }

    public class StatusResposne {
        public List<Error> errors {set;get;}
        public Boolean isSuccess {set;get;}
        public List<ComponentStatus> componentStatus {set;get;}
    }

    public class ComponentStatus {
        String componentId {set;get;}
        Datetime refreshDate {set;get;}
        String refreshStatus {set;get;}
    }
}