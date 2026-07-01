/*
* @author         Ortal Kazum   <ortalk@assuta.co.il>
* @Test           ws_TizkuritTest
* @modifiedBy     
* @version        1.0
* @created        01-07-2019
* @modified       DD-MM-YYYY
* @description    An interface for update reminderStatus about appointments that set in RIS/QFlow 
                  and not modified by Dev Integration user.       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ws_UpdateRemindStatus implements Queueable, Database.AllowsCallouts{

    public List<String> messBodiestLst;

    public ws_UpdateRemindStatus(List<String> input) {
       system.debug('input' + input);
       messBodiestLst = input;
    }
    
    public void execute(QueueableContext context){
        ENV__c env = ENV__c.getInstance();
        for(String mess_i : messBodiestLst){
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/Tizkurit/SFTizkurit/UpdateRemindStatus');
            request.setBody(mess_i); 
            try{
                HttpResponse response = http.send(request);
                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                }
            } catch (exception e) {
                System.debug('Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage());
            }
        }
    }  
}