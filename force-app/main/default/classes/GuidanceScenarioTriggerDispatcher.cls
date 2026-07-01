public with sharing class GuidanceScenarioTriggerDispatcher {

    public static void checkDuplicates(List<Guidance_Scenario__c> newList, Map <Id, Guidance_Scenario__c> oldMap){
        System.debug('GuidanceScenarioTriggerDispatcher.checkDuplicates...');
        Map<Id, String> activeGuids = new Map<Id, String>();
        Map<Id, String> activeGuidsPF = new Map<Id, String>(); 
        Set<Id> medPodIds = new Set<Id>();
        for (Guidance_Scenario__c guidScen : newList) {
            if(guidScen.Status__c == 'active'){
                medPodIds.add(guidScen.Medical_Procedure__c);
            }            
        }
        for( Guidance_Scenario__c gs : [SELECT Id, Site__c, Gender__c, Payer_Factor__c, Age_Range__c, Asthma__c, Iodine_Sensitive__c, 
                                                Blood_Dilution__c, MetalsInBody__c, diabetes__c, Protocol__c, Medical_Procedure__c  
                                        FROM Guidance_Scenario__c 
                                        WHERE Status__c = 'active'
                                        AND Medical_Procedure__c IN:medPodIds]){
            String key = ''+gs.Site__c+gs.Medical_Procedure__c+gs.Gender__c+gs.Age_Range__c+gs.Asthma__c+gs.Iodine_Sensitive__c+gs.Blood_Dilution__c+gs.MetalsInBody__c+gs.diabetes__c+gs.Protocol__c;
            activeGuids.put(gs.Id, key);
            activeGuidsPF.put(gs.Id, gs.Payer_Factor__c);
        }
        for (Guidance_Scenario__c guidScen : newList) {   
            if(guidScen.Status__c == 'active'){         
                Set<String> arrPayerFactorNew = (guidScen.Payer_Factor__c != null) ? new Set<String>(guidScen.Payer_Factor__c.split(';')) : null;
                String newkey = ''+guidScen.Site__c+guidScen.Medical_Procedure__c+guidScen.Gender__c+guidScen.Age_Range__c+guidScen.Asthma__c+guidScen.Iodine_Sensitive__c+guidScen.Blood_Dilution__c+guidScen.MetalsInBody__c+guidScen.diabetes__c+guidScen.Protocol__c; 
                for (Id guid : activeGuids.keySet()){
                    Set<String> arrPayerFactorExist = activeGuidsPF.get(guid) != null ? new Set<String>(activeGuidsPF.get(guid).split(';')) : null;
                    System.debug('oldMap: '+oldMap);
                    System.debug('guidScen.Id: '+guidScen.Id);
                    System.debug('guid: '+guid);
                    if ((oldMap == null || (oldMap != null && guidScen.Id != guid)) && newkey == activeGuids.get(guid) && arrPayerFactorExist.containsAll(arrPayerFactorNew)) {
                        guidScen.addError('Duplicates detected');
                        System.debug('Duplicates detected newkey: '+newkey+' existKey: '+activeGuids.get(guid));
                    }
                }
            }
        }
    }

}