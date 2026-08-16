/*
* @author           Yulia Liberman   <yliberman@deloitte.co.il>
* @modifiedBy     
* @version          1.0
* @created          16-07-2019
* @modified         DD-MM-YYYY
* @description      An interface for document management in front of the portal            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/


global with sharing class ws_DocumentsSyncPortalREST{

    public ws_DocumentsSyncPortalREST() {
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive a list of documents according to patient details
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    hospital        Site - Portal_Code__c
    * @param    patientId       Patient ID number (passport number)
    * @param    idType          Patient ID type
    * @return   result          Result of type XML 
    *                           result.Items - array of ducument items
    *                           result.Path - link to PDF 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)   
    public static String portalGetPages(String patientId, String idType) {
        ENV__c env = ENV__c.getInstance();
        String itemsData = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String messageType = '';

        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');        
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/SalesForce/SalesForce2Portal/GetPages');
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('PatientId', patientId);
            gen.writeNumberField('IdType', Integer.valueOf(idType));
            gen.writeEndObject();
        String sendMsg = gen.getAsString();
        request.setBody(sendMsg);
        try{
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> items = (List<Object>) results.get('Items');
                System.debug('Received the following Items:');
                JSONGenerator genitemsData = JSON.createGenerator(true);
                genitemsData.writeStartObject();
                genitemsData.writeFieldName('Items');
                genitemsData.writeStartArray();              
                    for (Object item: items) {
                        Map<String,Object> data = (Map<String,Object>)item;
                            genitemsData.writeStartObject();
                                genitemsData.writeStringField('path', String.valueOf(data.get('Path')));
                                genitemsData.writeStringField('type', String.valueOf(data.get('MessageSubType')));
                                genitemsData.writeStringField('name', String.valueOf(data.get('OriginalFileName')));
                                genitemsData.writeStringField('date', String.valueOf(data.get('ExecuteTime')));
                            genitemsData.writeEndObject(); 
                    }
                genitemsData.writeEndArray();
                genitemsData.writeEndObject(); 
                itemsData =  genitemsData.getAsString();
                System.debug('itemsData: '+itemsData);
            }
        return itemsData;
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to GetPages:  ' + e.getMessage());
            return '';
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive a list of documents according to patient details
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    itemNum         The item number that returned from portalGetPages
    * @return   result          Result of type XML 
    *                           result.Base64File - document in base64 type
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @RemoteAction 
    global static String portalGetDocument(String docPath, String patID) {
        ENV__c env = ENV__c.getInstance();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/SalesForce/SalesForce2Portal/PortalUrl2Base64');
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('DocPath', docPath);
            gen.writeStringField('PatID', patID);
            gen.writeEndObject();
            String sendMsg = gen.getAsString();
        request.setBody(sendMsg);
        try{
            System.debug('request' + request);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {                
				Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object base = results.get('Base64File');
				System.debug('results' + results);
                System.debug('base' + base);

                return String.valueOf(base);
            } else {
                return '';
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage());
            return '';
        }
    }    


}