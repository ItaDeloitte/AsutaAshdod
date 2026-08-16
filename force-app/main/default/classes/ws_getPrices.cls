public with sharing class ws_getPrices {


    public Map<String, Object> getPrices(String jsonInput){

        Map<String, object> jsonMap = (Map<String, object>) JSON.deserializeUntyped(jsonInput);
        System.debug('JSONMAP: '+jsonMap);

        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/prices/SFPrices/GetPrices');
        JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject(); 
                        gen.writeStringField('Site', String.ValueOf(jsonMap.containsKey('siteCode') ? jsonMap.get('siteCode') : ''));//Site__c.Site_Code__c.Procedure_Code__c
                        gen.writeStringField('ClientNo', String.ValueOf(jsonMap.containsKey('payerFactorCode') ? jsonMap.get('payerFactorCode') : ''));//PayerFactor__c.InsuranceCode__c
                        gen.writeStringField('AnesthetizationActivity', String.ValueOf(jsonMap.containsKey('anesthetist') ? jsonMap.get('anesthetist') : ''));//Medical_Procedure__c.Category_for_anesthetist__c Anesthetizati
                        gen.writeStringField('ActivityDate', String.ValueOf(jsonMap.containsKey('activityDate') ? jsonMap.get('activityDate') : '')); //2019-11-04
                        gen.writeStringField('EmpNoType', '3');//3 = מספר רישיון
                        gen.writeStringField('EmpNo', String.ValueOf(jsonMap.containsKey('doctorCode') ? jsonMap.get('doctorCode') : ''));//Doctor_Account__c.Doctor_Code__c
                        gen.writeFieldName('Activities');
                        gen.writeStartArray();
                            if(jsonMap.containsKey('activityCode_1')){
                                gen.writeStartObject();
                                    gen.writeStringField('ActivityRow', '1');
                                    gen.writeStringField('ActivityCode', String.ValueOf(jsonMap.get('activityCode_1')));//Medical_Procedure__c.Procedure_Code__c
                                gen.writeEndObject();
                            }
                            if(jsonMap.containsKey('activityCode_2')){
                                gen.writeStartObject();
                                    gen.writeStringField('ActivityRow', '2');
                                    gen.writeStringField('ActivityCode', String.ValueOf(jsonMap.get('activityCode_2')));//Medical_Procedure__c2.Procedure_Code__c
                                gen.writeEndObject();
                            }
                            if(jsonMap.containsKey('activityCode_3')){
                                gen.writeStartObject();
                                    gen.writeStringField('ActivityRow', '3');
                                    gen.writeStringField('ActivityCode', String.ValueOf(jsonMap.get('activityCode_3')));//Medical_Procedure__c3.Procedure_Code__c
                                gen.writeEndObject();
                            }
                            if(jsonMap.containsKey('activityCode_4')){
                                gen.writeStartObject();
                                    gen.writeStringField('ActivityRow', '4');
                                    gen.writeStringField('ActivityCode', String.ValueOf(jsonMap.get('activityCode_4')));//Medical_Procedure__c4.Procedure_Code__c
                                gen.writeEndObject();
                            }
                        gen.writeEndArray();
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
            System.debug('Error: An exception has been encountered while calling out to getPrices:  ' + e.getMessage());
            return null;
        }

    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getPricesFromMedProcedure(String jsonInput){

        ws_getPrices getPricesCallout = new ws_getPrices();
        Map<String, Object> results = getPricesCallout.getPrices(jsonInput);
        return results;

    }


}