public class LC_AvayaCommunicator implements ILCController {
    
	public class LC_AvayaCommunicatorException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        System.debug('actionName ' + actionName);
        switch on actionName {
            when 'getRecordId' {
                return this.getRecordId((Map<String, Object>) JSON.deserializeUntyped((String)params.get('callDetails')));
            }
            when else {
                throw new LC_AvayaCommunicatorException('UNKNOWN ACTION '+ actionName);
            }
        }
    }
    /*{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com",
       "payload":{"callId":"15095","eventSource":"call","uui":"100001 ;000003335;00001143181620759969;187_220930;360=N;a037E00000B29qFQAR;opt=1",
	   "eventType":"IncomingEvent","dnis":"17733","ani":"0548559748","ucid":"00001143181620759969"}}*/    
    private Response getRecordId(Map<String, Object> callDetails) {
        System.debug('getRecordId \ncallDetails: ' + callDetails);   
        String currentUserId = UserInfo.getUserId();
        Map<String, Object> payloadData = (Map<String, Object>) ((Object)callDetails.get('payload'));
		System.debug('payloadData: ' + payloadData);                
        if (String.valueOf(payloadData.get('eventType')) == 'EstablishedEvent') {
            
            String ani = String.valueOf(payloadData.get('ani'));
            String dnis = String.valueOf(payloadData.get('dnis'));
            Map<String, String> UUIData = parseUUI(String.valueOf(payloadData.get('uui')));
            System.debug('UUIData' + UUIData);
            if (UUIData.get('chosenOpt').right(3) == '100') { // for pop lead
                if(payloadData.containskey('oldUcid')) {
                    System.debug('oldUcid: ' + String.valueOf(payloadData.get('oldUcid'))); 
                    return new Response(transferredLeadEvent(currentUserId, String.valueOf(payloadData.get('oldUcid'))));
                }// pop new lead
                return new Response(leadEvent(UUIData, currentUserId, ani, dnis));                                
            } else { // for pop case
                //Get cases for calls that were transferred from another agent.

                if([SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1]?.Name == 'Agent 360'){
                    return new Response('No record to pop');
                }

                if(payloadData.containskey('oldUcid')) {
                    System.debug('oldUcid: ' + String.valueOf(payloadData.get('oldUcid'))); 
                    return new Response(transferredCaseEvent(currentUserId, String.valueOf(payloadData.get('oldUcid'))));
                }

                Id caseId = getCaseId(UUIData.get('CID'));
                System.debug('caseId: ' + caseId);

                if ((UUIData.get('CID') == payloadData.get('ucid') && caseId == null) || (UUIData.containsKey('isCallback') && UUIData.get('isCallback') == 'CB=Y')) {                    
                    Id accountId = null;

                    if (UUIData.get('patientId') != null && UUIData.get('patientId') != '000000000') {
                        Account patient = createThinPatient(UUIData.get('patientId'));
                        if (patient.Id != null) {
                            accountId = patient.Id;
                        }
                    }
                    String classifiedLog = logClassifier(UUIData);
                    System.debug('classifiedLog: ' + classifiedLog);
                    if(classifiedLog == '360') {
                        return new Response(Case360Event(accountId, currentUserId, UUIData.get('CID')));
                    }
                    if(classifiedLog == 'callback') {
                        return new Response(CallbackCaseEvent(accountId, UUIData , currentUserId, UUIData.get('CID')));
                    }
                    if(classifiedLog == 'incomingOrTransferred') {
                        return new Response(otherCaseEvent(accountId, UUIData, currentUserId, UUIData.get('CID'), dnis));
                    }
                } else if (caseId != null) {
                    return new Response(new popRecordWrapper(caseId, currentUserId));
                }
            }
        }
        return new Response('No record to pop');
    }

    public static Id getCaseId(String ucid) {
        return [SELECT Id FROM Case WHERE UCID__c = :ucid LIMIT 1]?.Id;
    }

    //payload":{"uui":"100001 ;000003335;00001143181620759969;187_220930;360=N;a037E00000B29qFQAR;opt=1"}
    public static Map<String, String> parseUUI(String UUI) {
        Map<String, String> UUIData =  new Map<String, String>();
        System.debug('************UUI **************' + UUI);
        List<String> parsedUUI = UUI.split(';');
        System.debug('************parsedUUI **************' + parsedUUI);

        System.debug('UUI size is: ' + parsedUUI.size());
        if (parsedUUI.size() >= 7) {
            UUIData.put('reserved', parsedUUI[0]);
            UUIData.put('patientId', parsedUUI[1]);
            UUIData.put('CID', parsedUUI[2]);
            UUIData.put('times', parsedUUI[3]);
            UUIData.put('360', parsedUUI[4]);
            UUIData.put('aptSfid', parsedUUI[5]);
            UUIData.put('chosenOpt', parsedUUI[6]);
            if (parsedUUI.size() == 8) {
                UUIData.put('isCallback', parsedUUI[7]);
            }
        }

        if (UUIData.containsKey('times') && UUIData.get('times') != null) {
            List<String> times = UUIData.get('times').split('_');
            
            if (times.size() > 0 && times[0] != null) {
                UUIData.put('IVRSeconds', times[0]);
            }

            if (times.size() > 1 && times[1] != null) {
                UUIData.put('waitStartTimeStamp', times[1]);
            }
        }
        return UUIData;
    }


    public static String logClassifier(Map<String, String> UUIData) {
        System.debug('logsClassifier \nUUIData: ' + UUIData);
        String classifiedLog;            
        if (UUIData.containsKey('360') && UUIData.get('360') == '360=Y') {
            System.debug('logsClassifier 360');
            classifiedLog = '360';
        }
        else if (UUIData.containsKey('isCallback') && UUIData.get('isCallback') == 'CB=Y') {
            System.debug('logsClassifier isCallback');
            classifiedLog = 'callback';
        }
        else {
            System.debug('logsClassifier incomingOrTransferred');
            classifiedLog = 'incomingOrTransferred';
        }
        return classifiedLog;
    } 
    
	/*For Transfer:
    payloadData: {ani=0502674491, callId=1202, dnis=5329, eventSource=call, eventType=EstablishedEvent, oldCallId=901,
    oldUcid=00001007971667986576, ucid=00001012021667986742, uui=100001;999801517;00001007971667986576;17_113646;360=N;;opt=1}*/   
    public static Response transferredCaseEvent(String currentUserId, String ucidCall) {
        System.debug('transferredCaseEvent \ncurrentUserId: ' + currentUserId + '\nucidCall: ' + ucidCall);         
        List<Case> caseExist = [SELECT Id, UCID__c, AccountId FROM Case WHERE UCID__c = :ucidCall];
        if(!caseExist.isEmpty()){  
            case cas = caseExist[0];
            connectLogtoCase(cas, ucidCall, cas.AccountId);
            return new Response(new popRecordWrapper(cas.Id, currentUserId));
        }
        return new Response('No case to pop');        
    }    

    public static Response Case360Event(Id accountId, String currentUserId, String ucidCall) {
        System.debug('Case360Event \naccountId: ' + accountId + '\ncurrentUserId: ' + currentUserId + '\nucidCall: ' + ucidCall);         
        List<Account> acc = [SELECT Id, Case_360__c FROM Account WHERE Id = :accountId AND X360_patient_checkbox__c = true Limit 1];
        if(!acc.isEmpty()){
            Case case360 = [SELECT Id FROM Case WHERE Id = :acc[0].Case_360__c];
            connectLogtoCase(case360, ucidCall, accountId);
            return new Response(new popRecordWrapper(case360.Id, currentUserId));
        }
        return new Response('No case to pop');        
    }

    public static Response CallbackCaseEvent(Id accountId, Map<String, String> UUIData, String currentUserId, String ucidCall) {
        System.debug('CallbackCaseEvent \naccountId: ' + accountId + '\nUUIData: ' + UUIData + '\ncurrentUserId: ' + currentUserId + '\nucidCall: ' + ucidCall);
        List<Case_Classification_by_IVR__mdt> caseMappingByIVR = [SELECT IVR_Option_Number__c, RecordTypeId__c, Case_Subject__c, Sub_Case_Subject__c FROM Case_Classification_by_IVR__mdt];
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = BuildIVROptionToCaseTrioMap(caseMappingByIVR);
        
        Case newCase = new Case(OwnerId = currentUserId, AccountId = accountId, Origin = 'שיחה יוצאת חיצונית');
        String option = '';
        if(UUIData.containsKey('chosenOpt')) {
            if(IVROptionToMapping.containsKey(UUIData.get('chosenOpt').right(1))) {
                option = UUIData.get('chosenOpt').right(1);
                
                if(IVROptionToMapping.get(option).RecordTypeId__c != null) {
                    newCase.RecordTypeId = IVROptionToMapping.get(option).RecordTypeId__c;
                }
                
                if(IVROptionToMapping.get(option).Case_Subject__c != null) {
                    newCase.Case_subject__c = IVROptionToMapping.get(option).Case_Subject__c;
                }
                
                if(IVROptionToMapping.get(option).Sub_Case_Subject__c != null) {
                    newCase.sub_case_subject__c = IVROptionToMapping.get(option).Sub_Case_Subject__c;
                }
            }
        }

        if(UUIData.containsKey('CID') && UUIData.get('CID') != null) {
            newCase.UCID__c = UUIData.get('CID');
        }
        insert newCase;
            
        //createAptAndCaseJunc(newCase, UUIData);
        //Point the call logs to the appropriate case.
        connectLogtoCase(newCase, ucidCall, accountId);
        //Point callback logs to the appropriate case.
        connectCallbackLogsToCase(newCase);
        return new Response(new popRecordWrapper(newCase.Id, currentUserId));
    }

    public static Response otherCaseEvent(Id accountId, Map<String, String> UUIData, String currentUserId, String ucidCall, String dnis) {
        System.debug('otherCaseEvent \naccountId: ' + accountId + '\nUUIData: ' + UUIData + '\ncurrentUserId: ' + currentUserId + '\nucidCall: ' + ucidCall);
        Case newCase;
        List<Case_Classification_by_IVR__mdt> caseMappingByIVR = [SELECT IVR_Option_Number__c, RecordTypeId__c, Case_Subject__c, Sub_Case_Subject__c FROM Case_Classification_by_IVR__mdt];
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = BuildIVROptionToCaseTrioMap(caseMappingByIVR);
        //Get cases for calls that were transferred from another agent.
        //List<Case> transferredCases = [SELECT Id, UCID__c FROM Case WHERE UCID__c IN :CIDToUCID.keySet()];
        //Point relevant logs to the cases found above.
        //connectLogtoCase(transferredCases, UCIDToLog);
        //Add events to the list.
        //addCasePopEvents(recordPopEvents, transferredCases, currentUserId);

        //Extract VDNs for remaining logs and map UCID to VDN.
        VDN__c VDNInfo = getVDNCodeToVDN(dnis);
        //Iterate over the rest of the logs (logs for regular incoming calls).
        
        newCase = new Case(OwnerId = currentUserId, AccountId = accountId, Origin = 'שיחה נכנסת חיצונית');
        String callCenter = (VDNInfo != null && VDNInfo.CallCenter__c != null) ? VDNInfo.CallCenter__c : null;
        switch on callCenter {
            when 'מרכז מידע וזימון תורים' {
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
            }
            when 'אסותא אשדוד' {
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
            }
            when 'מרכז מומחים' {
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DOC_expert').getRecordTypeId();
            }
            when 'מרכז הניתוחים' {
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surgery').getRecordTypeId();
            }
        }
        //Fill subject and sub case subject according to IVR choice.
        String option = '';
        if(UUIData.containsKey('chosenOpt')) {
            if(IVROptionToMapping.containsKey(UUIData.get('chosenOpt').right(1))) {
                option = UUIData.get('chosenOpt').right(1);
                
                if(newCase.RecordTypeId == null && IVROptionToMapping.get(option).RecordTypeId__c != null) {
                    newCase.RecordTypeId = IVROptionToMapping.get(option).RecordTypeId__c;
                }
                
                if(IVROptionToMapping.get(option).Case_Subject__c != null) {
                    newCase.Case_subject__c = IVROptionToMapping.get(option).Case_Subject__c;
                }
                
                if(IVROptionToMapping.get(option).Sub_Case_Subject__c != null) {
                    newCase.sub_case_subject__c = IVROptionToMapping.get(option).Sub_Case_Subject__c;
                }
            }
        }
        
        if(UUIData.containsKey('CID') && UUIData.get('CID') != null) {
            newCase.UCID__c = UUIData.get('CID');
        }
    
        if(newCase != null) {
            insert newCase;
            //Create junctions for case for which an appointment SFID was received.
            //createAptAndCaseJunc(newCase, UUIData);
            //Point relevant log to the new case.
            //connectLogtoCase(newCase, ucidCall, accountId);            
        }
        return new Response(new popRecordWrapper(newCase.Id, currentUserId));
    }

    public static void createAptAndCaseJunc(Case newCase, Map<String, String> UUIData) {
        if(UUIData.containsKey('aptSfid') && String.isNotBlank(UUIData.get('aptSfid'))) {
          cases_and_appoitments__c junction = new cases_and_appoitments__c(
              Case__c = newCase.Id,
              Appointment__c = UUIData.get('aptSfid')
          );
          insert junction; 
        } 
    }

    public static void connectLogtoCase(Case newCase, String ucidCall, Id accountId) {
        List<Task> taskCall = [SELECT Id, CallObject, WhatId, related_account__c, Called__c FROM Task WHERE Call_ID__c = :ucidCall];
        if(!taskCall.isEmpty()){
            Task taskToUpdate = new Task(
                Id = taskCall.get(0).Id,
                WhatId = newCase.Id,
                related_account__c = accountId
            );
            update taskToUpdate;
        }
    }

    public static void connectCallbackLogsToCase(Case newCase) {        
        List<Task> callbackLogs = [SELECT Id, Call_ID__c FROM Task WHERE Call_ID__c = :newCase.UCID__c AND WhatId = null];
		if(!callbackLogs.isEmpty()){
            for(Task log : callbackLogs) {
                log.WhatId = newCase.Id;
            }
            update callbackLogs;
        }
    }

    public static VDN__c getVDNCodeToVDN (String dnis) {
       // Task taskCall = [SELECT Id, Called__c FROM Task WHERE Call_ID__c = :ucidCall];
        List<VDN__c> VDNList = [SELECT CodeVDN__c, CallCenter__c FROM VDN__c WHERE CodeVDN__c = :dnis];
        if(!VDNList.isEmpty())
        {
        	return VDNList.get(0);
        }
        return null;
    }


    //Creates a map between the original UCID received in the UUI and the UCID from the connector (which might be different from the original one).
    /*public static Map<String, String> buildCIDToUCIDMap(Map<String, Task> UCIDToLog) {
        Map<String, String> CIDToUCID = new Map<String, String>();

        for(String ucid : UCIDToLog.keySet()) {
            CIDToUCID.put(UCIDToLog.get(ucid).Call_ID__c, ucid);
        }

        return CIDToUCID;
    }*/
    
    public static Account createThinPatient(String patientId) {
        try {
            List<Account> patients = [SELECT Id FROM Account WHERE  ID_Number__c = :patientId AND ID_Type__c = '1' AND RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
                System.debug(' ***patients*** ' + patients);
                if(patients.Size() > 0){
                    return patients[0];
                }
                else{
                    Account patient = new Account(
                        ID_Number__c = patientId,
                        ID_Type__c = '1',
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
                    );
                    DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(patient, patient.ID_Number__c, patient.ID_Type__c);
                    if (accountWithDemography.IsDemographyExist) {
                        insert accountWithDemography.acct;
                        return accountWithDemography.acct;
                    } 
                    else{
                        Account generalPatient = new Account(
                        ID_Number__c = patientId,
                        ID_Type__c = '1',
                        LastName = patientId,
                        FirstName = patientId,
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
                        );
                        insert generalPatient;
                        return generalPatient;
                    }      
                }            
        }
        catch(Exception e) {
            System.debug('Error on line :'+e.getLineNumber()+' stack trace '+e.getStackTraceString()+ ' message '+e.getMessage());
            return new Account();
        }
    }

    public static Map<String, Case_Classification_by_IVR__mdt> BuildIVROptionToCaseTrioMap(List<Case_Classification_by_IVR__mdt> caseMappingByIVR) {
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = new Map<String, Case_Classification_by_IVR__mdt>();

        for(Case_Classification_by_IVR__mdt mapping : caseMappingByIVR) {
            IVROptionToMapping.put(mapping.IVR_Option_Number__c, mapping);
        }

        return IVROptionToMapping;
    }

    public static Response leadEvent(Map<String, String> UUIData, String currentUserId, String ani, string dnis) {
        System.debug('leadEvent \nUUIData: ' + UUIData + '\ncurrentUserId: ' + currentUserId + '\nani: ' + ani + '\ndnis: ' + dnis);
        
        if (dnis == '17320') {  //2840700504 
            List<Lead> ExsitsLead = [SELECT Id, Name FROM Lead 
                                        WHERE LeadSource = 'Inbound_Call'AND CreatedDate = TODAY AND CreatedBy.Name = 'Zapier API User' 
                                        AND LeadSource_Details__c = 'at-home.assuta' AND Phone = :ani 
                                        ORDER BY CreatedDate Desc];  
            System.debug(' ***ExsitsLead*** ' + ExsitsLead);
            if (!ExsitsLead.isEmpty()) {
                return new Response(new popRecordWrapper(ExsitsLead[0].Id, currentUserId));
            }
        }

        Lead newLead = new Lead(OwnerId = currentUserId, LeadSource = 'Inbound_Call', Phone = ani, smsPhoneNumber__c = ani);                                        
        if (UUIData.get('patientId') != null && UUIData.get('patientId') != '000000000') { 
            List<Account> patients = [SELECT Id, FirstName, LastName FROM Account WHERE ID_Number__c = :UUIData.get('patientId') AND ID_Type__c = '1' AND RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
            System.debug(' ***patients*** ' + patients);
            if (patients.Size() > 0) {
                newLead.ExistingAccount__c = patients[0].Id;
                newLead.FirstName = patients[0].FirstName;
                newLead.LastName = patients[0].LastName;
            }

            newLead.IdNumber__c = UUIData.get('patientId'); 

            if(newLead.ExistingAccount__c == null){
                newLead.FirstName = newLead.IdNumber__c;
                newLead.LastName = newLead.IdNumber__c;
            }
        }                                       

        if(UUIData.containsKey('CID') && UUIData.get('CID') != null) {
            newLead.UCID__c = UUIData.get('CID');
        }
    
        if(newLead != null) {
            insert newLead;           
        }
        return new Response(new popRecordWrapper(newLead.Id, currentUserId));
    } 
    
    public static Response transferredLeadEvent(String currentUserId, String ucidCall) {
        System.debug('transferredLeadEvent \ncurrentUserId: ' + currentUserId + '\nucidCall: ' + ucidCall);         
        List<Lead> leadExist = [SELECT Id, UCID__c FROM Lead WHERE UCID__c = :ucidCall];
        if(!leadExist.isEmpty()){  
            Lead lead = leadExist[0];            
            return new Response(new popRecordWrapper(lead.Id, currentUserId));
        }
        return new Response('No lead to pop');        
    }    
    
    public class popRecordWrapper {
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String userId {get;set;}
        public popRecordWrapper(String recordId, String userId) {
            this.recordId = recordId;
            this.userId = userId;
        }       
   }
}