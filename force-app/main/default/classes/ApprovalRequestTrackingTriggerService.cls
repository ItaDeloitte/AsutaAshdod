public class ApprovalRequestTrackingTriggerService {

    public static void updateRequiredTable(Set<Id> approvalIds) {
        System.debug('ApprovalRequestTrackingTriggerService.updateRequiredTable...');
        Map<Id,Approval_Request_Tracking__c> currApprovalsMap = new Map<Id,Approval_Request_Tracking__c>();
        List<SObject> objectsToUpdate = new List<SObject>();
        // all available fields that can be updated in Doctors_in_clinic__c table
        List<String> docClinicFields =  new List<String>{'Floor__c','Room__c','Working_Hours__c','Email__c','Phone__c','PayerFactorMulti__c'};
        Set<Id> docClinicsDelIds = new Set<Id>();
        Map<Id,Approval_Request_Tracking__c> lookUpUpdateMap = new Map<Id,Approval_Request_Tracking__c>();
        List<String> subExpsCodes = new List<String>();
        Map<String,Id> subExpsMap = new Map<String,Id>();
        List<Approval_Request_Tracking__c> ApprovalsList = [SELECT  Id,
                                                                    Decision_Result__c,
                                                                    Created_Date__c,
                                                                    Name,
                                                                    Doctor_In_Clinic__c,
                                                                    Original_Value__c,
                                                                    Updated_Value__c,
                                                                    Declining_Reason__c,
                                                                    Doctor_Infirmary_Copy__c,
                                                                    Doctor_Account__c,
                                                                    Action_Value__c
                                                                    FROM Approval_Request_Tracking__c where Id IN :approvalIds];                                                                                                             
        for(Approval_Request_Tracking__c approval :ApprovalsList){
            if(approval.Action_Value__c=='Delete'){
                docClinicsDelIds.add(approval.Doctor_In_Clinic__c);
            }
            else if(approval.Action_Value__c=='Update' && approval.Name!= null){
                SObject obj = null;
            if(docClinicFields.contains(approval.Name)){
                 obj = convertToObject(approval.Doctor_In_Clinic__c,approval.Name,approval.Updated_Value__c,'Doctors_in_clinic__c');
                 if(obj != null){
                    objectsToUpdate.add(obj);
                 }
                 
            }else{
                if(String.valueOf(approval.Name).contains('_r')){
                    lookUpUpdateMap.put(approval.Doctor_Account__c,approval);
                    subExpsCodes.add(approval.Updated_Value__c); // collect all codes that can be updated
                }else{
                    obj = convertToObject(approval.Doctor_Account__c,approval.Name,approval.Updated_Value__c,'Account');
                    if(obj != null){
                        objectsToUpdate.add(obj);
                     }
                }
                
            }
            }    
        }

        if(lookUpUpdateMap.size()>0){ // if we need to update SubExpertise
           for (Sub_Expertise__c subExp : [SELECT Id,Sub_expertise_code__c FROM Sub_Expertise__c WHERE Sub_expertise_code__c IN :subExpsCodes]){
                subExpsMap.put(subExp.Sub_expertise_code__c,subExp.Id); // save the codes inside a map to avoid qurying again
           }
           for (Id key : lookUpUpdateMap.keySet()) {
                Approval_Request_Tracking__c approval = lookUpUpdateMap.get(key);
                SObject obj = convertToObject(approval.Doctor_Account__c,'Sub_Expertise__c',subExpsMap.get(approval.Updated_Value__c),'Account');
                if(obj != null){
                    objectsToUpdate.add(obj);
                 }
           }
        
        }

        if(!objectsToUpdate.isEmpty()){
            update objectsToUpdate;
        }
        if(!docClinicsDelIds.isEmpty()){
            List<Doctor_In_Clinic__c> docInClinics = [SELECT Id FROM Doctor_In_Clinic__c WHERE Id IN :docClinicsDelIds];
            delete docInClinics;
        }
        
    }

    // convert to json before updating the final object
    private static SObject convertToObject(Id id,String key,String value,String tableName){
        if(Id !=null && key !=null && tableName!=null){
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeStringField('Id',id);
            if(value==null){
                jsGen.writeNullField(key);
            }else{
                jsGen.writeStringField(key,value);
            }
            jsGen.writeEndObject();
            String json = jsGen.getAsString();
            switch on tableName {
                when 'Account' {
                    System.debug('Account Table');
                    Account acc = (Account) System.JSON.deserialize(json, Account.class);
                    return acc;
                }
                when else {
                    System.debug('Clinic Table');
                    Doctor_In_Clinic__c clinic = (Doctor_In_Clinic__c) System.JSON.deserialize(json,Doctor_In_Clinic__c.class);
                    return clinic;
                }
            }
        }
        return null;
    }
}