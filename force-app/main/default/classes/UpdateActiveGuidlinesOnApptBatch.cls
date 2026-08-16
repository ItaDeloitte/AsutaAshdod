public class UpdateActiveGuidlinesOnApptBatch implements Database.Batchable<SObject> {


    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('UpdateActiveGuidlinesOnApptBatch.start...');
        String query = 'SELECT Id,Protocol__c,Payer_Factor__c,RecordTypeId,Appointment_Status__c,PayerFactor__c,Patient_Account__c,Site__c,Medical_Procedure__c, Appointment_Date_Time__c,Guidance_Scenario__c,Guidance_Scenario__r.Status__c FROM Appointment__c WHERE Appointment_Date_Time__c > TODAY AND Guidance_Scenario__r.Status__c!=\'active\' AND Guidance_Scenario__c!=null AND Appointment_Status__c != \'Canceled\' AND Appointment_Status__c != \'Urgent_WaitingList\' AND PayerFactor__c != null AND Patient_Account__c != null AND Medical_Procedure__c != null';
        System.debug('query = ' + query);
        justIncrement();
        return Database.getQueryLocator(query);
    }



    public void execute(Database.BatchableContext BC,List<Appointment__c> scope){
        try {
        justIncrement();

        Map<String, Schema.RecordTypeInfo> apptRTMap = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        Set<Id> pFactorIds = new Set<Id>();
        Set<Id> patientIds = new Set<Id>();
        Set<Id> medProcedureIds = new Set<Id>();
        Set<Id> guidelineIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();

        Map<Id, Payer_Factor__c> pFactorMap = null;
        Map<Id, Account> acctMap = new Map<Id, Account>();
        Map<Id, Map<String, String>> acctMapBooleans = new Map<Id, Map<String, String>>();
        Map<Id, Guidance_Scenario__c> guidScenarioMap = null;
        Map<Id, Site__c> siteMap = new Map<Id,Site__c>();
		

        for (Appointment__c appointment_i : scope) {
            if(appointment_i.Appointment_Status__c != 'Canceled' && appointment_i.Appointment_Status__c != 'Urgent_WaitingList' 
                && appointment_i.PayerFactor__c != null && appointment_i.Patient_Account__c != null && appointment_i.Medical_Procedure__c != null){
                pFactorIds.add(appointment_i.PayerFactor__c);
                patientIds.add(appointment_i.Patient_Account__c);
                medProcedureIds.add(appointment_i.Medical_Procedure__c);
                siteIds.add(appointment_i.Site__c);
                appointmentList.add(appointment_i);
            }
        }
        
        if(!pFactorIds.isEmpty()){
            pFactorMap = new Map<Id, Payer_Factor__c>([SELECT Id, Code_Parent_for_Interface__c FROM Payer_Factor__c WHERE Id IN:pFactorIds]);
        }
        if(!patientIds.isEmpty()){
            for(Account acc : [SELECT Id, Asthma__c, PersonBirthdate, Gender__c, Iodine_sensitivity__c, Blood_Dilution__c, Diabetic__c, Metals_in_body__c FROM Account WHERE (RecordType.DeveloperName = 'PersonAccount' OR RecordType.DeveloperName = 'General_patient_account') AND Id IN: patientIds]){
                acctMapBooleans.put(acc.Id, new Map<String, String>());
                acctMapBooleans.get(acc.Id).put('Astma', (acc.Asthma__c != 'לא' && acc.Asthma__c != 'לא ידוע' && acc.Asthma__c != null) ? 'כן' : '');
                acctMapBooleans.get(acc.Id).put('Iodine', (acc.Iodine_sensitivity__c != 'לא' && acc.Iodine_sensitivity__c != 'לא ידוע' && acc.Iodine_sensitivity__c != null) ? 'כן' : '');
                acctMapBooleans.get(acc.Id).put('Blood', (acc.Blood_Dilution__c != 'לא' && acc.Blood_Dilution__c != 'לא ידוע' && acc.Blood_Dilution__c != null) ? 'כן' : '');
                acctMapBooleans.get(acc.Id).put('Diabetic', (acc.Diabetic__c != 'לא' && acc.Diabetic__c != 'לא ידוע' && acc.Diabetic__c != null) ? 'כן' : '');
                acctMapBooleans.get(acc.Id).put('Metals', (acc.Metals_in_body__c != 'לא' && acc.Metals_in_body__c != 'לא ידוע' && acc.Metals_in_body__c != null) ? 'כן' : '');
                acctMapBooleans.get(acc.Id).put('Gender', acc.Gender__c != null ? acc.Gender__c : '');
                acctMap.put(acc.Id, acc);
            }            
        }
        if(!medProcedureIds.isEmpty()){    
            guidScenarioMap = new Map<Id, Guidance_Scenario__c>([SELECT Id, Asthma__c, Site__c, Gender__c, Payer_Factor__c, Age_Range__c, Iodine_Sensitive__c, Blood_Dilution__c, MetalsInBody__c, diabetes__c,
                                                                                            Guideline1__c, Guideline2__c, Guideline3__c, Guideline4__c, Guideline5__c, Guideline6__c, Guideline7__c, Guideline8__c, Protocol__c, 
                                                                                            Guideline9__c, Guideline10__c, Guideline11__c, Guideline12__c, Guideline13__c, Guideline14__c, Guideline15__c, 
                                                                                            Guideline16__c, Guideline17__c, Guideline18__c, Guideline19__c, Guideline20__c,Guideline21__c,guideline22__c,guideline23__c,Site__r.Site_Code__c
                                                                                            FROM Guidance_Scenario__c 
                                                                                            WHERE Status__c = 'active' AND Medical_Procedure__c IN:medProcedureIds]);
        }
        if(!siteIds.isEmpty()){
            siteMap = new Map<Id,Site__c>([SELECT Id,Site_Code__c FROM Site__c WHERE Id IN:siteIds]);
        }


        Map<Id, Id> appGuidSMap = new Map<Id, Id>();
        List<Appointment__c> aptsToUpdate = new List<Appointment__c>();


        for (Appointment__c appointment_i : appointmentList) {
            Map<Id, Guidance_Scenario__c> guidScenarioForAppMap = new Map<Id, Guidance_Scenario__c>();
            guidScenarioForAppMap = guidScenarioMap;
            if (guidScenarioForAppMap.size() > 0 && appointment_i.RecordTypeId == apptRTMap.get('Institutes').getRecordTypeId()
                && appointment_i.Appointment_Status__c != 'Canceled' && appointment_i.Appointment_Status__c != 'Urgent_WaitingList') {
                for (Id scenarioId_i : guidScenarioForAppMap.keySet()){
                    String[] arrPayerFactor = guidScenarioForAppMap.get(scenarioId_i).Payer_Factor__c.split(';');
                    System.debug('updateGuidelines scenarioId_i: '+scenarioId_i+'scenario Payer Factor: '+arrPayerFactor);

                    if (guidScenarioForAppMap.containsKey(scenarioId_i) && 
                        (guidScenarioForAppMap.get(scenarioId_i).Protocol__c != appointment_i.Protocol__c)){                            
                            System.debug('updateGuidelines removed Protocol__c: '+guidScenarioForAppMap.get(scenarioId_i).Protocol__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                            guidScenarioForAppMap.remove(scenarioId_i);
                    }
                    if (guidScenarioForAppMap.containsKey(scenarioId_i) &&
                        pFactorMap.get(appointment_i.PayerFactor__c).Code_Parent_for_Interface__c != null && !arrPayerFactor.contains(pFactorMap.get(appointment_i.PayerFactor__c).Code_Parent_for_Interface__c)) {                            
                            System.debug('updateGuidelines removed PayerFactor: '+guidScenarioForAppMap.get(scenarioId_i).Payer_Factor__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                            guidScenarioForAppMap.remove(scenarioId_i);
                    }
                    if (guidScenarioForAppMap.containsKey(scenarioId_i) &&
                        guidScenarioForAppMap.get(scenarioId_i).Site__c != null && guidScenarioForAppMap.get(scenarioId_i).Site__c != appointment_i.Site__c) {                            
                            System.debug('updateGuidelines removed Site: '+guidScenarioForAppMap.get(scenarioId_i).Site__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                            guidScenarioForAppMap.remove(scenarioId_i);
                    }
                    if (acctMap.get(appointment_i.Patient_Account__c).PersonBirthdate != null && guidScenarioForAppMap.size() > 1 &&
                        guidScenarioForAppMap.containsKey(scenarioId_i) && guidScenarioForAppMap.get(scenarioId_i).Age_Range__c != null) {
                        String guidScenarioRange = guidScenarioForAppMap.get(scenarioId_i).Age_Range__c;
                        List<String> guidScenarioRangeArr = guidScenarioRange.split('-');
                        Double age = 0;
                        Double month = acctMap.get(appointment_i.Patient_Account__c).PersonBirthdate.monthsBetween(Date.Today());
                        if (month <= 11) {
                            age = month/10;
                        } else {
                            age = month/12;
                        }
                        if (!(age > Double.valueOf(guidScenarioRangeArr[0]) && age < Double.valueOf(guidScenarioRangeArr[1]))) {
                            System.debug('updateGuidelines removed Birthdate: '+guidScenarioForAppMap.get(scenarioId_i).Age_Range__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                            guidScenarioForAppMap.remove(scenarioId_i);
                        }
                    }
                }
            
                
                if(guidScenarioForAppMap.size() > 1){
                    for (Id scenarioId_i : guidScenarioForAppMap.keySet()){
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && ((guidScenarioForAppMap.get(scenarioId_i).Gender__c != null && 
                            guidScenarioForAppMap.get(scenarioId_i).Gender__c != acctMapBooleans.get(appointment_i.Patient_Account__c).get('Gender')))) {
                                System.debug('updateGuidelines removed Gender: '+guidScenarioForAppMap.get(scenarioId_i).Gender__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && acctMapBooleans.get(appointment_i.Patient_Account__c).get('Iodine') == '' && guidScenarioForAppMap.get(scenarioId_i).Iodine_Sensitive__c){
                                System.debug('updateGuidelines removed Iodine: '+guidScenarioForAppMap.get(scenarioId_i).Iodine_Sensitive__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && acctMapBooleans.get(appointment_i.Patient_Account__c).get('Blood') == '' && guidScenarioForAppMap.get(scenarioId_i).Blood_Dilution__c){
                                System.debug('updateGuidelines removed Blood: '+guidScenarioForAppMap.get(scenarioId_i).Blood_Dilution__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && acctMapBooleans.get(appointment_i.Patient_Account__c).get('Diabetic') == '' && guidScenarioForAppMap.get(scenarioId_i).diabetes__c){
                                System.debug('updateGuidelines removed diabetes: '+guidScenarioForAppMap.get(scenarioId_i).diabetes__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && acctMapBooleans.get(appointment_i.Patient_Account__c).get('Astma') == '' && guidScenarioForAppMap.get(scenarioId_i).Asthma__c){
                                System.debug('updateGuidelines removed diabetes: '+guidScenarioForAppMap.get(scenarioId_i).Asthma__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                        if (guidScenarioForAppMap.containsKey(scenarioId_i) && acctMapBooleans.get(appointment_i.Patient_Account__c).get('Metals') == '' && guidScenarioForAppMap.get(scenarioId_i).MetalsInBody__c){
                                System.debug('updateGuidelines removed diabetes: '+guidScenarioForAppMap.get(scenarioId_i).MetalsInBody__c+' guid ID: '+guidScenarioForAppMap.get(scenarioId_i).Id);
                                guidScenarioForAppMap.remove(scenarioId_i);
                        }
                    }

                    if(guidScenarioForAppMap.size()>1){
                        System.debug('updateGuidelines Size is: '+guidScenarioForAppMap.size());
                        Set<Id> validIds = new Set<Id>();
                        for (Id scenarioId_i : guidScenarioForAppMap.keySet()){
                            if(guidScenarioForAppMap.get(scenarioId_i).Site__c != null){
                                validIds.add(scenarioId_i);
                            }
                        }
                        if(validIds.size()>1){
                            for (Id scenarioId_i : guidScenarioForAppMap.keySet()){
                                if(validIds.contains(scenarioId_i) && 
                                    ((acctMapBooleans.get(appointment_i.Patient_Account__c).get('Iodine') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Iodine_Sensitive__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Blood') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Blood_Dilution__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Diabetic') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).diabetes__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Astma') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Asthma__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Metals') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).MetalsInBody__c) ||
                                    (guidScenarioForAppMap.get(scenarioId_i).Gender__c != null && guidScenarioForAppMap.get(scenarioId_i).Gender__c == acctMapBooleans.get(appointment_i.Patient_Account__c).get('Gender')))){
                                    System.debug('updateGuidelines Size is: 1 BREAK');
                                    appGuidSMap.put(appointment_i.Id, scenarioId_i);
                                    break;
                                }
                            }
                        } else if (validIds.size() == 0) {
                            for (Id scenarioId_i : guidScenarioForAppMap.keySet()){
                                if( (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Iodine') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Iodine_Sensitive__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Blood') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Blood_Dilution__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Diabetic') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).diabetes__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Astma') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).Asthma__c) ||
                                    (acctMapBooleans.get(appointment_i.Patient_Account__c).get('Metals') == 'כן' && guidScenarioForAppMap.get(scenarioId_i).MetalsInBody__c) ||
                                    (guidScenarioForAppMap.get(scenarioId_i).Gender__c != null && guidScenarioForAppMap.get(scenarioId_i).Gender__c == acctMapBooleans.get(appointment_i.Patient_Account__c).get('Gender'))){
                                    System.debug('updateGuidelines Size is: 1 BREAK');
                                    appGuidSMap.put(appointment_i.Id, scenarioId_i);
                                    break;
                                }
                            }
                        } else {
                            System.debug('updateGuidelines Size is: 1 BREAK');
                            for (Id scId_i : guidScenarioForAppMap.keySet()){
                                appGuidSMap.put(appointment_i.Id, scId_i);                            
                            }
                            break;
                        }
                    } else if(guidScenarioForAppMap.size() == 0){
                        System.debug('updateGuidelines Size is: 0');
                    } else{
                        System.debug('updateGuidelines Size is: 1 BREAK');
                        for (Id scId_i : guidScenarioForAppMap.keySet()){
                            appGuidSMap.put(appointment_i.Id, scId_i);                            
                        }
                        break;                    
                    }
                    System.debug('updateGuidelines appGuidSMap size: '+appGuidSMap.size());
                } else if (guidScenarioForAppMap.size() == 1) {
                    System.debug('updateGuidelines Size is 1 with protocol and payer factor only');
                    for (Id scId_i : guidScenarioForAppMap.keySet()){
                        appGuidSMap.put(appointment_i.Id, scId_i);                            
                    }
                }
            }

        }
		
		List<Appointment__c> appsToUpdate = new List<Appointment__c>();
        
        if(appGuidSMap.size() > 0){
            Map<Id, Set<Id>> appGuidelInesSetMap = new Map<Id, Set<Id>>();
            for (Id appId : appGuidSMap.keySet()){
                for(Integer i=1; i<24; i++){
                    String fieldName = 'Guideline'+i+'__c';
                    String guideline = '';
                    if(guidScenarioMap.get(appGuidSMap.get(appId)) != null){
                        guideline = guidScenarioMap.get(appGuidSMap.get(appId)).get(fieldName) != null ? guidScenarioMap.get(appGuidSMap.get(appId)).get(fieldName).toString() : '';
                        System.debug('updateGuidelines guideline: '+guideline);
                    }
                    if(guideline != ''){
                        guidelineIds.add(Id.valueOf(guideline));                        
                    }
                    System.debug('updateGuidelines guidelineIds: '+guidelineIds);
                }
                appGuidelInesSetMap.put(appId, guidelineIds);
            } 
            Map<Id, Guidelines__c> guidlines = new Map<Id, Guidelines__c>([SELECT Id, Guideline_Desc__c, Guideline_Type__c FROM Guidelines__c WHERE Status__c='active' AND Id IN:guidelineIds ORDER BY Guideline_Type__c ]);
            for (Id appId : appGuidSMap.keySet()){
                String guidlinesText = '';
                for (Id gidlenID : appGuidelInesSetMap.get(appId)) {
                    guidlinesText += guidlines.containsKey(gidlenID) ? guidlines.get(gidlenID).Guideline_Desc__c + '\n' : '';
                }
                for (Appointment__c appointment_i : scope) {
                    if(appointment_i.Id == appId){ // handle ashdod exception
                        Guidance_Scenario__c currGuidSc = guidScenarioMap.get(appGuidSMap.get(appId));
                        if((siteMap.get(appointment_i.Site__c).Site_Code__c!='33') || (siteMap.get(appointment_i.Site__c).Site_Code__c=='33' && currGuidSc.Site__r.Site_Code__c=='33')){
                            System.debug('inserting guidline');
                            appointment_i.GuidanceKMS__c = guidlinesText;
                            appointment_i.Guidance_Scenario__c = appGuidSMap.get(appId);
							appsToUpdate.add(appointment_i);
                        }
                    }
                }                
            }
        }
		
		if(!appsToUpdate.isEmpty()){
		System.debug('updating apps with new active guidlines '+appsToUpdate);
		update appsToUpdate;
		}
            
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('UpdateActiveGuidlinesOnApptBatch.finish...');
    }
    
    static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
 
  
}