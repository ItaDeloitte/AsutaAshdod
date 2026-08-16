/*
* @author         Avraham Dasa   <adasa@deloitte.co.il>
* @Test           ws_KmsGuidanceTest
* @modifiedBy     
* @version        1.0
* @created        23-09-2019
* @modified       DD-MM-YYYY
* @description   update Kms Guidance  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/KMS_Guidance/*')
global class ws_KmsGuidance  {

    @HttpPost
    global static void getKMSGuidance () {
        
        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();

        try{
            
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            System.debug('jsonMap' + jsonMap);
            String AccessionNumber = String.valueOf(jsonMap.get('AccessionNumber'));
            system.debug('Accession Number' + AccessionNumber);
            String guidance = String.valueOf(jsonMap.get('Guidance'));
            List<Appointment__c> appointments = [SELECT Id, Accession_Number__c FROM Appointment__c WHERE Accession_Number__c = : AccessionNumber LIMIT 1];   
            system.debug('appointments is empty: ' + appointments.isEmpty());
      
            if(!appointments.isEmpty() && guidance != null){                

                appointments[0].GuidanceKMS__c = guidance;
                update appointments;
               
                JSONGenerator jsGen = JSON.createGenerator(true);
                RestContext.response.addHeader('Content-Type', 'application/json');
                jsGen.writeStartObject();
                jsGen.writeStringField('Success','true');
                jsGen.writeStringField('Error','');
                jsGen.writeEndObject();
                RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString()); 
            }
                      
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            JSONGenerator jsGen = JSON.createGenerator(true);
            RestContext.response.addHeader('Content-Type', 'application/json');
            jsGen.writeStartObject();
            jsGen.writeStringField('Success','false');
            jsGen.writeStringField('Error', e.getMessage());
            jsGen.writeEndObject();
            RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString()); 
        } 
	}
}