public with sharing class ws_GenericPayment_REST {

    public String messageBody;
    public ws_GenericPayment_REST(String messageBody) {
        this.messageBody = messageBody;
    }

    
    public class PaymentResponse {
        public String Guid;
        public String ResultStatus;
        public List<Receipt> Receipts;
        public List<ErrCodes> ErrCodes;
        public Metadata metadata;
    }

    public class ErrCodes {
        public String ErrorCode;
        public String Message;
    }
    public class Metadata {
        public String published_date;
        public String publisher;
        public String module;
    }

    public class Receipt {
        public String ReceiptNo;
    }
    
    public Map<String,Object> sendGenericPayment(){
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,Object> responseMap = new Map<String,Object>();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+ env.Env_value__c +'/Payment/ExecuteGenericPayment');
        request.setTimeout(25000);
        System.debug('ws_GenericPayment_REST body is:');
        System.debug(messageBody);
        request.setBody(messageBody);
        try{
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
                System.debug('response is:');
                PaymentResponse paymentResponse = (PaymentResponse)JSON.deserialize(String.valueOf(response.getBody()), PaymentResponse.class);
                System.debug(paymentResponse);
                if(paymentResponse.ErrCodes != null && paymentResponse.ErrCodes.size() > 0){
                    responseMap.put('message',paymentResponse.ErrCodes.get(0).Message);
                    responseMap.put('ResultStatus','1');
                    System.debug('Error from Ensemble :');
                }else{
                    responseMap.put('ResultStatus',paymentResponse.ResultStatus);
                    if(paymentResponse.ResultStatus=='0'){
                        System.debug('Payment Success');
                        responseMap.put('ReceiptNo1',paymentResponse.Receipts.get(0).ReceiptNo);
                        responseMap.put('ResultStatus','0');
                    }else{
                        responseMap.put('message',paymentResponse.ErrCodes.get(0).Message);
                        responseMap.put('ResultStatus','1');
                    }
                }
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to Payment:' + e.getMessage());
            responseMap.put('message',e.getMessage());
        }
        return responseMap;
    }
    
}