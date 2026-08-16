@RestResource(urlMapping='/titan/getSurveyLink')
global with sharing class ws_TitanSurveyLinkService {
    
    global class RequestWrapper {
        public String surveyTaker;
    }
    
    global class TokenResponse {
        public Boolean success;
        public DataWrapper data;
    }
    
    public class DataWrapper {
        public String token;
    }
    
    @HttpPost
    global static String getSurveyLink() {
        
        // 1. Parse JSON
        RequestWrapper req;
        try {
            req = (RequestWrapper) JSON.deserialize(
                RestContext.request.requestBody.toString(),
                RequestWrapper.class
            );
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return '{"error":"Invalid JSON"}';
        }
        
        if (String.isBlank(req.surveyTaker)) {
            RestContext.response.statusCode = 400;
            return '{"error":"Missing surveyTaker"}';
        }
        
        
        // 2. Query SurveyTaker + Survey
        SurveyTaker__c st = [
            SELECT Id,
            Survey__c,
            Survey__r.titan_project_id__c,
            Survey__r.titan_token_expiration_time__c,
            Survey__r.formtitan_param__c,
            Survey__r.formtitan_salt__c,
            survey_link_with_token__c
            FROM SurveyTaker__c
            WHERE Id = :req.surveyTaker
            LIMIT 1
        ];
        
        String projectId        = st.Survey__r.titan_project_id__c;
        String expiration       = String.valueOf(st.Survey__r.titan_token_expiration_time__c);
        String surveyLink       = st.survey_link_with_token__c;
        
        // NEW variables
        String formTitanParam   = st.Survey__r.formtitan_param__c;
        String formTitanSalt    = st.Survey__r.formtitan_salt__c;
        
        // 3. Domain from Custom Setting
        Form_Titan_Domain__c cs = Form_Titan_Domain__c.getInstance();
        String titanDomain = cs.Domain__c;
        
        String baseUrl = 'https://' + titanDomain +
            '/api/v1/web/token/' + projectId;
        
        // 4. Query params
        Map<String, String> params = new Map<String, String>{
            'salt'         => formTitanSalt,
                'expiration'   => expiration,
                'parameterKey' => formTitanParam
                };
                    
                    String fullUrl = baseUrl + '?' + stringizeParams(params);
        
        // 5. Load API key from Custom Metadata
        Titan_API__mdt api = Titan_API__mdt.getInstance('API_key');
        String apiKey = api.API_Key__c;
        
        
        // Safety check
        if (String.isBlank(apiKey)) {
            RestContext.response.statusCode = 500;
            return '{"error":"Titan API key not found in Custom Metadata"}';
        }
        
        // 6. HTTP Callout
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(fullUrl);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('ftAPIKey', apiKey);
        
        Http http = new Http();
        HttpResponse httpRes = http.send(httpReq);
        
        if (httpRes.getStatusCode() >= 300) {
            RestContext.response.statusCode = 500;
            return '{"error":"Failed to retrieve token from FormTitan"}';
        }
        
        // 7. Parse Token JSON
        TokenResponse tokenRes = (TokenResponse) JSON.deserialize(httpRes.getBody(), TokenResponse.class);
        
        if (!tokenRes.success || tokenRes.data == null || String.isBlank(tokenRes.data.token)) {
            RestContext.response.statusCode = 500;
            return '{"error":"Token missing in FormTitan response"}';
        }
        
        // 8. Build final link
        String finalLink = surveyLink + '&t=' + tokenRes.data.token;
        
        return finalLink;
    }
    
    private static String stringizeParams(Map<String, String> params) {
        List<String> parts = new List<String>();
        for (String key : params.keySet()) {
            parts.add(
                key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8')
            );
        }
        return String.join(parts, '&');
    }
}