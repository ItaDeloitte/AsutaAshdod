/*
* @author         Ortal Kazum   <ortalk@assuta.co.il>
* @Test           ws_TizkuritTest
* @modifiedBy     
* @version        1.0
* @created        26-08-2020
* @modified       DD-MM-YYYY
* @description    An interface for update reminderStatus about appointments that set in RIS/QFlow       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ws_UpdateReminderStatus {

    @future(callout=true)
    public static void sendUpdateRemindersRequest(Set<String> jsonInputs) {
        for (String jsonInput_i : jsonInputs) {
            doPost((Map<String, object>) JSON.deserializeUntyped(jsonInput_i));
        }
    }

    private static void doPost(Map<String, Object> jsonInput) {
        System.debug('jsonInput: ' + jsonInput);
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_' + env.Env_value__c + '/Tizkurit/SFTizkurit/UpdateRemindStatus');
        JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
                jsGen.writeStringField('accessionNumber', String.ValueOf(jsonInput.get('accessionNumber')));
                jsGen.writeStringField('followUpTypeCode', String.ValueOf(jsonInput.get('followUpTypeCode')));
            jsGen.writeEndObject();
        String sendMsg = jsGen.getAsString();
        System.debug('sendMsg: '+ sendMsg);
        request.setBody(sendMsg);
        try {
            HttpResponse response = http.send(request);
            System.debug('response: '+ response);
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to ws_UpdateRemindStatus:  ' + e.getMessage());
        }
    }
}