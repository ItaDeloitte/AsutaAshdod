/*
* @author           Max Feldman   <maxf@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          10-03-2019
* @modified         DD-MM-YYYY
* @description      An interface for Creating new future case in Tafnit 
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_FutureCase implements Queueable, Database.AllowsCallouts {

    public List<Map<Id,String>> messageBodyList;

    public ws_FutureCase(List<Map<Id,String>> input) {
        system.debug('input' + input);
        messageBodyList = input;
    }
  
  
    // List<Map<String, Object>>
    public void execute(QueueableContext context){

        for(Map<Id,String> mapMessageBody : messageBodyList){
            for (Id appId : mapMessageBody.keySet()) {
                String messageBody = mapMessageBody.get(appId);
                System.debug('The appointment Id :' + appId);
                
                ENV__c env = ENV__c.getInstance();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                System.debug('the body is : '+messageBody);    
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setEndpoint('callout:Ensemble_Rest_'+ env.Env_value__c +'/TafnitHomeAdmission/futureCase/CreateFutureCase');
                request.setTimeout(25000);
                //request.setEndpoint('callout:Ensemble_Rest_QA'+'/TafnitHomeAdmission/futureCase/CreateFutureCase');
                request.setBody(messageBody);
                try{
                    HttpResponse response = http.send(request);
                    // If the request is successful, parse the JSON response.
                    if (response.getStatusCode() != 200) {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    } else {
                        System.debug(response.getBody());
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        String resultStatus = (String)results.get('ResultStatus');
                        if(resultStatus=='0'){
                            Integer fileNo = (Integer)results.get('FileNo');
                            updateFileToAppointment(appId, String.valueOf(fileNo));
                        }else{
                            System.debug('Error from tafnit : result status is not equall to 0');
                        }
                    }
                } catch (exception e) {
                    System.debug('Error: An exception has been encountered while calling out to FutureCase:' + e.getMessage());
                }
            }
        }
    }

    private void updateFileToAppointment(Id appointmentId, String fileNo){
        System.debug('trying to update for key '+appointmentId);
        Appointment__c appointment = [SELECT Id FROM Appointment__c WHERE Id =:appointmentId LIMIT 1];
        appointment.TAF_Future_Case__c = fileNo;
        appointment.TAF_Future_Case_Status__c = '1';
        System.debug('file no is '+fileNo+' and appointmentId is '+appointmentId);
        update appointment;
    }
}