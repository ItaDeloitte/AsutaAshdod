public with sharing class ws_GetCampaigns_REST {

    public String messageBody;
    
    public ws_GetCampaigns_REST(String messageBody) {
        this.messageBody = messageBody;
    }

    public Map<String,Object> getCampaigns(){
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,Object> responseMap = new Map<String,Object>();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+ env.Env_value__c +'/SF2Pulseem/get-campaign-report-by-receipients');
        //request.setTimeout(25000);
        System.debug('ws_GetCampaigns_REST body is:');
        System.debug(messageBody);
        request.setBody(messageBody);
        try{
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
                System.debug('response is:'+response.getBody());
                GetCampaignReportByReceipientsResponse getCampaignsRes = (GetCampaignReportByReceipientsResponse)JSON.deserialize(String.valueOf(response.getBody()), GetCampaignReportByReceipientsResponse.class);
                System.debug(getCampaignsRes);
                responseMap.put('ResultStatus', getCampaignsRes.Status);
                responseMap.put('Message', getCampaignsRes.Message);
                if(getCampaignsRes.Error == null && getCampaignsRes.Status=='Success'){
                    responseMap.put('Data',getCampaignsRes.Data);
                }
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to getCampaigns:' + e.getMessage());
            responseMap.put('message',e.getMessage());
        }
        return responseMap;
    }

    public class GetCampaignReportByReceipientsRequest {
        public String Email;
        public Boolean IsIncludeSenderInfo;
    }

    public class GetCampaignReportByReceipientsResponse {
        public String SessionId;
        public String Status;
        public String Error;
        public String Message;
        public Data Data;
    }

    public class Data {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Status;
        public CampaignStatistics CampaignStatistics;
        public List<Campaign> Campaigns;
    }
    public class CampaignStatistics {
        public String Sent;
        public String UniqueOpened;
        public String UnOpened;
        public String ClicksCount;
        public String ErrorCount;
        public String RemovedCount;        
    }

    public class Campaign {
        public String CampaignId;
        public String CampaignName;
        public String FromEmail;
        public String FromName;
        public String StatusId;
        public String Status;
        public String SendDate;
        public String Subject;
        public String OpenCount;
        public String UniqueOpenCount;
        public String OpeningDate;
        public String PreviewLink;
        public String ErrorType;
    }
}