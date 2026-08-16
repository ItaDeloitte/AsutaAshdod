/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          07-02-2022
* @modified         DD-MM-YYYY
* @description      An interface for get Ambulatory Commitment from Maccabi
* @test             GetAmbulatoryCommitmentBatchTest    
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ws_getAmbulatoryCommitment {

    public Map<String, Object> getCommitment(String jsonInput){

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        System.debug('JSONMAP: '+jsonMap);

        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/maccabicommitments/getcommitment');
    
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('PatientID', jsonMap.containsKey('idNumber') ? String.valueOf(jsonMap.get('idNumber')) : '');
            gen.writeStringField('ProcedureCode', jsonMap.containsKey('procedureCode') ? String.valueOf(jsonMap.get('procedureCode')) : '');
            gen.writeStringField('AppointmentDate', jsonMap.containsKey('appDate') ? String.valueOf(jsonMap.get('appDate')) : '');
            gen.writeStringField('ServiceProviderCode', jsonMap.containsKey('siteCode') ? String.valueOf(jsonMap.get('siteCode')) != '33' ? '1701' : '1608' : '');
            gen.writeEndObject();              
        String sendMsg = gen.getAsString();
        System.debug('sendMsg: '+sendMsg);
        request.setBody(sendMsg);
        try{
            HttpResponse response = http.send(request);
            System.debug('response: '+response);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return results;
            }
            return null;
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to getAmbulatoryCommitment: ' + e.getMessage());
            return null;
        }
    }
}