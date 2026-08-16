/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        04-11-2019
* @modified       
* @description    An interface for get prices  
* @Input           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_getPrices_REST implements Queueable, Database.AllowsCallouts{

    private String jsonInput = '';

    public ws_getPrices_REST(String jsonInput) {
        this.jsonInput = jsonInput;
    }

    public void execute(QueueableContext context){
        getPrices();
    }

    public void getPrices(){
        Map<String, object> jsonMap = (Map<String, object>) JSON.deserializeUntyped(jsonInput);
        ws_getPrices getPrices_request = new ws_getPrices();
        Map<String, Object> results = getPrices_request.getPrices(jsonInput);
        if(results!=null){
                System.debug('results: '+results);
                updateAppointment(results, String.valueOf(jsonMap.get('Guid')), String.valueOf(jsonMap.get('payerFactorParent')), String.valueOf(jsonMap.get('payerFactorCode')));
        }
    }

    @TestVisible
    private void updateAppointment(Map<String, Object> getPriceRes, String appId, String payerFactor, String insuranceCode){
        
        List<Object> errorCodesObj = (List<Object>) getPriceRes.get('ErrCodes'); // ErrCodes=({ErrorCode=1266, Message=תאריך לא יכול להיות קטן מהיום, Tag=ActivityDate})
        if(errorCodesObj.size()>0){
            for (Object errCode : errorCodesObj) {
                Map<String,Object> err = (Map<String,Object>)errCode;
                System.debug('Error code: '+String.valueOf(err.get('ErrorCode')));
                System.debug('Error description: '+String.valueOf(err.get('Message'))); 
                update new Appointment__c(Id = Id.valueOf(appId), Error_description_Mehironim__c = String.valueOf(err.get('Message')));
            }
        } else {
            Appointment__c appToUpdate = new Appointment__c();
            appToUpdate.id = Id.valueOf(appId);
            appToUpdate.Error_description_Mehironim__c = null;
            appToUpdate.Agreement_with_assuta__c = String.valueOf(getPriceRes.get('AgreeYesNo'));
            appToUpdate.Number_of_agreement__c = String.valueOf(getPriceRes.get('AgreeNo')) != '' ? String.valueOf(getPriceRes.get('AgreeNo')) : null;
            if(String.valueOf(getPriceRes.get('BuyAgree')) == 'Y' && payerFactor == '3'){
                appToUpdate.Classification__c = 'אדום';
            }
            List<Object> surgeryAgreeSales = (List<Object>) getPriceRes.get('SurgeryAgreeSales');
            System.debug('surgeryAgreeSales size : '+surgeryAgreeSales.size());
            for (Integer i=0; i < surgeryAgreeSales.size(); i++) {
                Map<String,Object> sa = (Map<String,Object>)surgeryAgreeSales[i];
                System.debug('surgeryAgreeSales: '+sa);
                switch on i {
                    when 0{ appToUpdate.Cost_of_medical_operation1__c = insuranceCode != '1111' ? String.valueOf(sa.get('PriceIncludeVat')) : String.valueOf(sa.get('NetPrice')); }  
                    when 1{ appToUpdate.Cost_of_medical_operation2__c = insuranceCode != '1111' ? String.valueOf(sa.get('PriceIncludeVat')) : String.valueOf(sa.get('NetPrice')); }
                    when 2{ appToUpdate.Cost_of_medical_operation3__c = insuranceCode != '1111' ? String.valueOf(sa.get('PriceIncludeVat')) : String.valueOf(sa.get('NetPrice')); }
                    when 3{ appToUpdate.Cost_of_medical_operation4__c = insuranceCode != '1111' ? String.valueOf(sa.get('PriceIncludeVat')) : String.valueOf(sa.get('NetPrice')); }
                }
                System.debug('PriceIncludeVat '+ i+ ' : '+String.valueOf(sa.get('PriceIncludeVat')));
            } 
            if (surgeryAgreeSales.size() == 0) {
                appToUpdate.Cost_of_medical_operation1__c = null;
                appToUpdate.Cost_of_medical_operation2__c = null;
                appToUpdate.Cost_of_medical_operation3__c = null;
                appToUpdate.Cost_of_medical_operation4__c = null;
            }

            List<Object> surgeryAgreeResources = (List<Object>) getPriceRes.get('SurgeryAgreeResources');
            System.debug('surgeryAgreeResources size : '+surgeryAgreeResources.size());
            for (Integer i=0; i < surgeryAgreeResources.size(); i++) {
                Map<String,Object> sar = (Map<String,Object>)surgeryAgreeResources[i];
                System.debug('SurgeryAgreeResources: '+sar);
                if(payerFactor != '3' && payerFactor != '4' && payerFactor != '5' && payerFactor != '7' && payerFactor != '6'){ // רק אם זה פרטי
                    appToUpdate.Operating_room_cost__c = String.valueOf(sar.get('PriceIncludeVat1')); 
                    appToUpdate.Cost_of_frozen_cut__c = String.valueOf(sar.get('PriceIncludeVat2'));
                    appToUpdate.Pathology_cost__c = String.valueOf(sar.get('PriceIncludeVat3'));
                    appToUpdate.Operating_room_plastic__c = String.valueOf(sar.get('PriceIncludeVat4'));
                    appToUpdate.Cost_of_private_anesthetist__c = String.valueOf(sar.get('PriceIncludeVat5'));                    
                } else {
                    appToUpdate.Operating_room_cost__c = null; 
                    appToUpdate.Cost_of_frozen_cut__c = null; 
                    appToUpdate.Pathology_cost__c = null; 
                    appToUpdate.Operating_room_plastic__c = null; 
                    appToUpdate.Cost_of_private_anesthetist__c = null; 
                }
                appToUpdate.Cost_of_private_room__c = String.valueOf(sar.get('PriceIncludeVat6')) != '' ? String.valueOf(sar.get('PriceIncludeVat6')) : null;
                System.debug('PriceIncludeVat '+ i+ ' : '+String.valueOf(sar.get('PriceIncludeVat')));
            }

            updateAppointment(appToUpdate);            
        }
    }


    private void updateAppointment(Appointment__c app){
        Database.SaveResult updateResult  = Database.update(app, false);
        if(updateResult.isSuccess()){
            System.debug('#######updateAppointment: succsess: ' + updateResult);
        } else {
            for(Database.Error err : updateResult.getErrors()) {
                System.debug('#######updateAppointment: failed: ' + updateResult);
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Appointment__c fields that affected this error: ' + err.getFields());
            }
            
        }
    }

/**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Called from GetPricesFromAppointment LWC
    * Only if Type - Institutes
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @author           Yulia Liberman          <yliberman@deloitte.co.il>
    * @created          02-02-2020
    * @modifiedBy       
    * @modified         
    * @description      Get prices and update Appointmnet  
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled(cacheable=false)
    public static void getPricesFromAppointment(String jsonInput){
        System.enqueueJob(new ws_getPrices_REST(jsonInput));
    }

}