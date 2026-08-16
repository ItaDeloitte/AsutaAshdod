public with sharing class ws_creditGuardApi_REST{

    public String messageBody;

    public ws_creditGuardApi_REST(String input) {
        system.debug('input' + input);
        messageBody = input;
    }

    public Map<String,String> getIframe(){
        Callout_Properties__mdt calloutProperties = [SELECT Id, Username__c, Password__c,Endpoint__c FROM Callout_Properties__mdt WHERE Label ='Credit_Guard'];
        String payload = 'int_in='+EncodingUtil.urlEncode(messageBody,'UTF-8')+'&user='+EncodingUtil.urlEncode(calloutProperties.Username__c,'UTF-8')+'&password='+EncodingUtil.urlEncode(calloutProperties.Password__c,'UTF-8');
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,String> responseMap = new Map<String,String>();
        //System.debug('the body is : '+messageBody);    
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndpoint(calloutProperties.Endpoint__c+'/xpo/Relay');
        request.setTimeout(25000);
        request.setBody(payload);
        try{
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug('StatusCode :'+response.getStatusCode());
                System.debug('response body is :'+response.getBody());
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode ashrait = doc.getRootElement();
                Dom.XMLNode responseNode = ashrait.getChildElement('response', null);
                Dom.XMLNode doDeal = responseNode.getChildElement('doDeal', null);
                responseMap.put('iframe',doDeal.getChildElement('mpiHostedPageUrl', null).getText());
                responseMap.put('token',doDeal.getChildElement('token', null).getText());
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to creditGuard:' + e.getMessage());
        }
        return responseMap;
    }

    public Map<String,Object> inquireTransaction(){
        Callout_Properties__mdt calloutProperties = [SELECT Id, Username__c, Password__c,Endpoint__c FROM Callout_Properties__mdt WHERE Label ='Credit_Guard'];
        String payload = 'int_in='+EncodingUtil.urlEncode(messageBody,'UTF-8')+'&user='+EncodingUtil.urlEncode(calloutProperties.Username__c,'UTF-8')+'&password='+EncodingUtil.urlEncode(calloutProperties.Password__c,'UTF-8');
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,Object> responseMap = new Map<String,Object>();
        //System.debug('the body is : '+messageBody);    
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndpoint(calloutProperties.Endpoint__c+'/xpo/Relay');
        request.setTimeout(25000);
        request.setBody(payload);
        try{
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug('response body is :'+response.getBody());
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode ashrait = doc.getRootElement();
                Dom.XMLNode responseNode = ashrait.getChildElement('response', null);
                String result = responseNode.getChildElement('result', null).getText();
                responseMap.put('result',result);
                responseMap.put('message',responseNode.getChildElement('message', null).getText());
                if(result=='000'){
                    Dom.XMLNode inquireTransactions = responseNode.getChildElement('inquireTransactions', null);
                    Dom.XMLNode row = inquireTransactions.getChildElement('row', null);
                    responseMap.put('done',true);
                    responseMap.put('cardId',row.getChildElement('cardId', null).getText());
                    Dom.XmlNode cgGatewayResponseXML = row.getChildElement('cgGatewayResponseXML', null);
                    Dom.XmlNode ashrait2 = cgGatewayResponseXML.getChildElement('ashrait', null);
                    Dom.XmlNode response2 = ashrait2.getChildElement('response', null);
                    Dom.XmlNode doDeal = response2.getChildElement('doDeal', null);
                    responseMap.put('cardExpiration',doDeal.getChildElement('cardExpiration', null).getText());
                    responseMap.put('creditCompany',doDeal.getChildElement('creditCompany', null).getAttributeValue('code', null));
                }else{
                    responseMap.put('message',responseNode.getChildElement('message', null).getText());
                    responseMap.put('done',false);
                    System.debug('ws_creditGuardApi_REST : result not 000');
                }
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to creditGuard:' + e.getMessage());
            responseMap.put('done',false);
            responseMap.put('message','Error: An exception has been encountered while calling out to creditGuard:' + e.getMessage());
        }
        //System.debug('responseMap is: '+responseMap);
        return responseMap;

    }
}