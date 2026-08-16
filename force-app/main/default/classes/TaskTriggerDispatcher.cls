// Test: TaskTriggerDispatcherTest
public class TaskTriggerDispatcher {
    public static void populateLogFromUUI(List<Task> newList) {
        Map<String, Map<String, String>> UCIDToUUIData = new Map<String, Map<String, String>>();
        Map<String, Task> UCIDToLog = new Map<String, Task>();
        for (Task callLog : newList) {
            if(callLog.Subject == 'Call') {
                if (callLog.UUI__c != null) {
                    UCIDToLog.put(callLog.CallObject, callLog);
                    parseUUI(UCIDToUUIData, callLog);
                }
            }
        }
        System.debug('Finished parsing');
        fillLanguage(UCIDToUUIData, UCIDToLog);
        System.debug('Filled language');
        for (String ucid : UCIDToLog.keySet()) {
            if (UCIDToUUIData.get(ucid).get('patientId') != null) {
                UCIDToLog.get(ucid).Caller_ID__c = UCIDToUUIData.get(ucid).get('patientId');
                Account patient = createThinPatient(UCIDToUUIData.get(ucid).get('patientId'));
                
                if (patient.Id != null) {
                    UCIDToLog.get(ucid).related_account__c = patient.Id;
                    UCIDToLog.get(ucid).WhoId = patient.PersonContactId;
                }
            }

            if (UCIDToUUIData.get(ucid).get('CID') != null) {
                UCIDToLog.get(ucid).Call_ID__c = UCIDToUUIData.get(ucid).get('CID');
            }
            System.debug('******isCallback******' + UCIDToUUIData.get(ucid).get('isCallback'));
            //System.debug('*******UCIDToUUIData.get(ucid) **********' + UCIDToUUIData.get(ucid).get('isCallback') == 'CB=Y');
            if (UCIDToUUIData.get(ucid).get('isCallback') == 'CB=Y') {
                UCIDToLog.get(ucid).CALLBACK__c = true;
            }
        }
        System.debug('Populated patient id and CID');
        calculateIVRTime(UCIDToUUIData, UCIDToLog);
        System.debug('IVR time populated');
        System.debug('Populate extension start');
        populateExtension(UCIDToLog);
        System.debug('Populate extension done');
    }

    public static void populateExtension (Map<String, Task> UCIDToLog) {
        List<ID> userIds = new List<ID>();
        Map<Id, List<Task>> userIdToTasks = new Map<Id, List<Task>>();
        for (String UCID : UCIDToLog.keySet()) {
            if (UCIDToLog.get(UCID).OwnerId != null) {
                userIds.add(UCIDToLog.get(UCID).OwnerId);
                
                if(!userIdToTasks.containsKey(UCIDToLog.get(UCID).OwnerId)) {
                    userIdToTasks.put(UCIDToLog.get(UCID).OwnerId, new List<Task> {UCIDToLog.get(UCID)});
                }
                else {
                    userIdToTasks.get(UCIDToLog.get(UCID).OwnerId).add(UCIDToLog.get(UCID));
                }
            }
        }
        Map<ID ,User> logsWithUserExtension = new Map<ID ,User>([SELECT Id, Extension FROM User WHERE Id IN :userIds]);
        for (Id userId : userIdToTasks.keySet()) {
            if(logsWithUserExtension.containsKey(userId)) {
                for (Task log : userIdToTasks.get(userId)) {
                    log.Extension__c = logsWithUserExtension.get(userId).Extension;
                }
            }
        }
    }

    public static void populateWaintingTime(List<Task> newList) {
        System.debug('populateWaintingTime START');
        Map<String, Map<String, String>> UCIDToUUIData = new Map<String, Map<String, String>>();
        Map<String, Task> UCIDToLog = new Map<String, Task>();
        for (Task callLog : newList) {
            if (callLog.UUI__c != null) {
                UCIDToLog.put(callLog.CallObject, callLog);
                parseUUI(UCIDToUUIData, callLog);
            }
        }
        System.debug('popcalculateWaitTime START');
        calculateWaitTime(UCIDToUUIData, UCIDToLog);
    }
    
    //After update
    /*public static void calculateCallDuration(List<Task> newList) {
        List<Task> logsToUpdate = new List<Task>();
        for (Task callLog : newList) {
            if (callLog.Call_Duration__c != null && callLog.Status == 'Completed') {
                DateTime createdDate = callLog.CreatedDate;
                DateTime lastModifiedDate = callLog.LastModifiedDate;

                Long createdDateDelta = createdDate.getTime();
                Long lastModifiedDateDelta = lastModifiedDate.getTime();
                Long callDurationInMinutes = ((lastModifiedDateDelta - createdDateDelta) / 1000) /*/ /*60;*/

                //callLog.Call_Duration__c = String.valueOf(callDurationInMinutes);
                /*logsToUpdate.add(new Task(Id = callLog.Id, Call_Duration__c = String.valueOf(callDurationInMinutes)));
            }
        }
        update logsToUpdate;
    }*/

    public static void parseUUI(Map<String, Map<String, String>> UCIDToUUIData, Task callLog) {
        UCIDToUUIData.put(callLog.CallObject, new Map<String, String>());
        System.debug('************callLog.UUI__c **************' + callLog.UUI__c);
        List<String> parsedUUI = callLog.UUI__c.split(';');
        System.debug('************parsedUUI **************' + parsedUUI);

        System.debug('UUI size is: ' + parsedUUI.size());
        if (parsedUUI.size() >= 7) {
            UCIDToUUIData.get(callLog.CallObject).put('reserved', parsedUUI[0]);
            UCIDToUUIData.get(callLog.CallObject).put('patientId', parsedUUI[1]);
            UCIDToUUIData.get(callLog.CallObject).put('CID', parsedUUI[2]);
            UCIDToUUIData.get(callLog.CallObject).put('times', parsedUUI[3]);
            UCIDToUUIData.get(callLog.CallObject).put('360', parsedUUI[4]);
            UCIDToUUIData.get(callLog.CallObject).put('aptSfid', parsedUUI[5]);
            UCIDToUUIData.get(callLog.CallObject).put('chosenOpt', parsedUUI[6]);
            if (parsedUUI.size() == 8) {
                UCIDToUUIData.get(callLog.CallObject).put('isCallback', parsedUUI[7]);
            }
        }

        if (UCIDToUUIData.get(callLog.CallObject).containsKey('times') && UCIDToUUIData.get(callLog.CallObject).get('times') != null) {
            List<String> times = UCIDToUUIData.get(callLog.CallObject).get('times').split('_');
            
            if (times.size() > 0 && times[0] != null) {
                UCIDToUUIData.get(callLog.CallObject).put('IVRSeconds', times[0]);
            }

            if (times.size() > 1 && times[1] != null) {
                UCIDToUUIData.get(callLog.CallObject).put('waitStartTimeStamp', times[1]);
            }
        }
    }

    public static void fillLanguage(Map<String, Map<String, String>> UCIDToUUIData, Map<String, Task> UCIDToLog) {
        for (String ucid : UCIDToUUIData.keySet()) {
            if (UCIDToUUIData.get(ucid).get('reserved') != null) {
                switch on UCIDToUUIData.get(ucid).get('reserved').left(1) {
                    when '1' { //Hebrew
                        UCIDToLog.get(ucid).Caller_Language__c = '1';
                    }
                    when '2' { //Russian
                        UCIDToLog.get(ucid).Caller_Language__c = '2';
                    }
                    when '3' { //English
                        UCIDToLog.get(ucid).Caller_Language__c = '3';
                    }
                    when '4' { //Arabic   
                        UCIDToLog.get(ucid).Caller_Language__c = '4';
                    }
                }
            }
        }
    }

    public static Account createThinPatient(String patientId) {
        try {
            List<Account> patients = [SELECT Id, PersonContactId FROM Account WHERE ID_Number__c = :patientId LIMIT 1];
            if (patients.size() == 0) {
                List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
                Account thinPatient = new Account(RecordTypeId = rTypes[0].Id, LastName = patientId, ID_Number__c = patientId);
                insert thinPatient;
                return thinPatient;
            }
            else {
                return patients[0];
            }    
        }
        catch(Exception e) {
            System.debug('Error on line :'+e.getLineNumber()+' stack trace '+e.getStackTraceString()+ ' message '+e.getMessage());
            return new Account();
        }
    }

    public static void calculateIVRTime(Map<String, Map<String, String>> UCIDToUUIData, Map<String, Task> UCIDToLog) {
        for (String ucid : UCIDToUUIData.keySet()) {
            if (UCIDToUUIData.get(ucid).containsKey('IVRSeconds')) {
                Double timeInSeconds = Double.valueOf(UCIDToUUIData.get(ucid).get('IVRSeconds'));
                UCIDToLog.get(ucid).Time_In_IVR__c = String.valueOf(timeInSeconds);
            }
        }
    }

    //AfterInsert
    public static void calculateWaitTime(Map<String, Map<String, String>> UCIDToUUIData, Map<String, Task> UCIDToLog) {
        List<Task> logsToUpdate = new List<Task>();
        for (String ucid : UCIDToUUIData.keySet()) {
            if (UCIDToUUIData.get(ucid).containsKey('waitStartTimeStamp')) {
                Map<String, String> brokenTimeStamp = new Map<String, String>();
                brokenTimeStamp.put('hours', UCIDToUUIData.get(ucid).get('waitStartTimeStamp').substring(0, 2));
                brokenTimeStamp.put('minutes', UCIDToUUIData.get(ucid).get('waitStartTimeStamp').substring(2, 4));
                brokenTimeStamp.put('seconds', UCIDToUUIData.get(ucid).get('waitStartTimeStamp').substring(4, 6));

                Time waitStartTime = Time.newInstance(Integer.valueOf(brokenTimeStamp.get('hours')), Integer.valueOf(brokenTimeStamp.get('minutes')), Integer.valueOf(brokenTimeStamp.get('seconds')), 0);
                DateTime waitStart = DateTime.newInstance(System.today(), waitStartTime);
                DateTime logCreationDateTime = UCIDToLog.get(ucid).CreatedDate;

                /*if (waitStart > logCreationDateTime) {
                    waitStart = waitStart.addDays(-1);
                }*/
                
                Long waitStartDelta = waitStart.getTime();
                Long logCreationDelta = logCreationDateTime.getTime();
                Long waitTimeInSeconds = ((logCreationDelta - waitStartDelta) / 1000);
                System.debug('Wait time calculated' + waitTimeInSeconds);
                //UCIDToLog.get(ucid).Waiting_Time__c = String.valueOf(waitTimeInSeconds);
                logsToUpdate.add(new Task(Id = UCIDToLog.get(ucid).Id, Waiting_Time__c = String.valueOf(waitTimeInSeconds)));
                System.debug('Wait time populated');
            }
        }
        update logsToUpdate;
        System.debug('Logs updated');
    }

    //Before insert
    public static void popCase(List<Task> newList) {
        String currentUserId = UserInfo.getUserId();
        List<Pop_Record__e> recordPopEvents = new List<Pop_Record__e>();
        Map<String, Map<String, String>> UCIDToUUIData = new Map<String, Map<String, String>>();
        Map<String, Task> UCIDToLog = new Map<String, Task>();
        for (Task callLog : newList) {
            if (callLog.UUI__c != null) {
                UCIDToLog.put(callLog.CallObject, callLog);
                parseUUI(UCIDToUUIData, callLog);
            }
        }

        Map<String, List<String>> classifiedLogs = logsClassifier(UCIDToUUIData);
        if(!classifiedLogs.get('360').isEmpty()) {
            add360CaseEvents(classifiedLogs.get('360'), UCIDToLog, recordPopEvents, currentUserId);
        }
        if(!classifiedLogs.get('callback').isEmpty()) {
            addCallbackCaseEvents(classifiedLogs.get('callback'), UCIDToLog, UCIDToUUIData, recordPopEvents, currentUserId);
        }
        if(!classifiedLogs.get('incomingOrTransferred').isEmpty()) {
            addOtherCaseEvents(classifiedLogs.get('incomingOrTransferred'), UCIDToLog, UCIDToUUIData, recordPopEvents, currentUserId);
        }

        List<Database.SaveResult> results = EventBus.publish(recordPopEvents);

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }      
        }
    }

    public static Map<String, List<String>> logsClassifier(Map<String, Map<String, String>> UCIDToUUIData) {
        Map<String, List<String>> classifiedLogs = new Map<String, List<String>>{'360' => new List<String>(), 'callback' => new List<String>(), 
        'incomingOrTransferred' => new List<String>()};

        for (String ucid : UCIDToUUIData.keySet()) {
            if (UCIDToUUIData.get(ucid).containsKey('360') && UCIDToUUIData.get(ucid).get('360') == '360=Y') {
                classifiedLogs.get('360').add(ucid);
            }
            else if (UCIDToUUIData.get(ucid).containsKey('isCallback') && UCIDToUUIData.get(ucid).get('isCallback') == 'CB=Y') {
                classifiedLogs.get('callback').add(ucid);
            }
            else {
                classifiedLogs.get('incomingOrTransferred').add(ucid);
            }
        }

        return classifiedLogs;
    }

    public static void add360CaseEvents(List<String> logsUCID, Map<String, Task> UCIDToLog, List<Pop_Record__e> recordPopEvents, String currentUserId) {
        Map<String, String> patientIdToUCID = buildpatientIdToUCIDMap(UCIDToLog);
        String case360RTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Assuta_360' LIMIT 1].Id;
        List<Case> patient360Cases = [SELECT Id, AccountId FROM Case WHERE AccountId IN :patientIdToUCID.keySet() AND RecordTypeId = :case360RTId];
        
        for (Case case360 : patient360Cases) {
            UCIDToLog.get(patientIdToUCID.get(case360.AccountId)).WhatId = case360.Id;
            recordPopEvents.add(new Pop_Record__e(Record_ID__c = case360.Id, User_ID__c = currentUserId));
        }
    }

    public static void addCallbackCaseEvents(List<String> logsUCID, Map<String, Task> UCIDToLog, Map<String, Map<String, String>> UCIDToUUIData, List<Pop_Record__e> recordPopEvents, String currentUserId) {
        List<Case> casesToInsert = new List<Case>();
        List<Case_Classification_by_IVR__mdt> caseMappingByIVR = [SELECT IVR_Option_Number__c, RecordTypeId__c, Case_Subject__c, Sub_Case_Subject__c FROM Case_Classification_by_IVR__mdt];
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = BuildIVROptionToCaseTrioMap(caseMappingByIVR);

        for (String ucid : logsUCID) {
            Case newCase = new Case(OwnerId = currentUserId, AccountId = UCIDToLog.get(ucid).related_account__c, Origin = 'שיחה יוצאת חיצונית');
            String option = '';
            if(UCIDToUUIData.get(ucid).containsKey('chosenOpt')) {
                if(IVROptionToMapping.containsKey(UCIDToUUIData.get(ucid).get('chosenOpt').right(1))) {
                    option = UCIDToUUIData.get(ucid).get('chosenOpt').right(1);

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

            if(UCIDToUUIData.get(ucid).containsKey('CID') && UCIDToUUIData.get(ucid).get('CID') != null) {
                newCase.UCID__c = UCIDToUUIData.get(ucid).get('CID');
            }

            casesToInsert.add(newCase);
        }
        if(!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
        createAptAndCaseJunc(casesToInsert, UCIDToLog, UCIDToUUIData);
        //Point the call logs to the appropriate case.
        connectLogtoCase(casesToInsert, UCIDToLog);
        //Point callback logs to the appropriate case.
        connectCallbackLogsToCase(casesToInsert);
        //Add case events to the list.
        addCasePopEvents(recordPopEvents, casesToInsert, currentUserId);
    }

    public static void addOtherCaseEvents(List<String> logsUCID, Map<String, Task> UCIDToLog, Map<String, Map<String, String>> UCIDToUUIData, List<Pop_Record__e> recordPopEvents, String currentUserId) {
        Map<String, String> CIDToUCID = buildCIDToUCIDMap(UCIDToLog);
        List<Case> newCases = new List<Case>();
        List<Case_Classification_by_IVR__mdt> caseMappingByIVR = [SELECT IVR_Option_Number__c, RecordTypeId__c, Case_Subject__c, Sub_Case_Subject__c FROM Case_Classification_by_IVR__mdt];
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = BuildIVROptionToCaseTrioMap(caseMappingByIVR);
        //Get cases for calls that were transferred from another agent.
        //List<Case> transferredCases = [SELECT Id, UCID__c FROM Case WHERE UCID__c IN :CIDToUCID.keySet()];
        //Point relevant logs to the cases found above.
        //connectLogtoCase(transferredCases, UCIDToLog);
        //Add events to the list.
        //addCasePopEvents(recordPopEvents, transferredCases, currentUserId);

        //Extract VDNs for remaining logs and map UCID to VDN.
        Map<String, VDN__c> VDNCodeToVDN = buildVDNCodeToVDNMap(logsUCID, UCIDToLog);
        //Iterate over the rest of the logs (logs for regular incoming calls).
        for(String ucid : logsUCID) {
            if(UCIDToLog.get(ucid).WhatId == null) {
                Case newCase = new Case(OwnerId = currentUserId, AccountId = UCIDToLog.get(ucid).related_account__c, Origin = 'שיחה נכנסת חיצונית');
                String callCenter = VDNCodeToVDN.containsKey(UCIDToLog.get(ucid).Called__c) ? VDNCodeToVDN.get(UCIDToLog.get(ucid).Called__c).CallCenter__c : null;
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
                if(UCIDToUUIData.get(ucid).containsKey('chosenOpt')) {
                    if(IVROptionToMapping.containsKey(UCIDToUUIData.get(ucid).get('chosenOpt').right(1))) {
                        option = UCIDToUUIData.get(ucid).get('chosenOpt').right(1);

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

                if(UCIDToUUIData.get(ucid).containsKey('CID') && UCIDToUUIData.get(ucid).get('CID') != null) {
                    newCase.UCID__c = UCIDToUUIData.get(ucid).get('CID');
                }

                newCases.add(newCase);
            }
        }
        if(!newCases.isEmpty()) {
            insert newCases;

            //Create junctions for cases for which an appointment SFID was received.
            createAptAndCaseJunc(newCases, UCIDToLog, UCIDToUUIData);
            //Point relevant logs to the new cases.
            connectLogtoCase(newCases, UCIDToLog);
            //Add events to list.
            addCasePopEvents(recordPopEvents, newCases, currentUserId);
        }
    }

    public static void createAptAndCaseJunc(List<Case> cases, Map<String, Task> UCIDToLog, Map<String, Map<String, String>> UCIDToUUIData) {
        Map<String, String> CIDToUCID = buildCIDToUCIDMap(UCIDToLog);
        List<cases_and_appoitments__c> junctions = new List<cases_and_appoitments__c>();
        
        for(Case c : cases) {
            if(UCIDToUUIData.get(CIDToUCID.get(c.UCID__c)).containsKey('aptSfid') && String.isNotBlank(UCIDToUUIData.get(CIDToUCID.get(c.UCID__c)).get('aptSfid'))) {
                System.debug('Case id: ' + c.Id);
                System.debug('Apointment id: ' + UCIDToUUIData.get(CIDToUCID.get(c.UCID__c)).get('aptSfid'));
                junctions.add(new cases_and_appoitments__c(Case__c = c.Id, Appointment__c = UCIDToUUIData.get(CIDToUCID.get(c.UCID__c)).get('aptSfid')));
            }
        }
        
        if(!junctions.isEmpty()) {
            insert junctions;
        }
    }

    public static void connectLogtoCase(List<Case> cases, Map<String, Task> UCIDToLog) {
        Map<String, String> CIDToUCID = buildCIDToUCIDMap(UCIDToLog);
        for(Case c : cases) {
            UCIDToLog.get(CIDToUCID.get(c.UCID__c)).WhatId = c.Id;
        }
    }

    public static void addCasePopEvents(List<Pop_Record__e> recordPopEvents, List<Case> cases, String currentUserId) {
        for (Case c : cases) {
            recordPopEvents.add(new Pop_Record__e(Record_ID__c = c.Id, User_ID__c = currentUserId));
        }
    }

    public static void connectCallbackLogsToCase(List<Case> cases) {
        Map<String, Case> UCIdToCase = buildUCIdToCaseMap(cases);
        
        List<Task> callbackLogs = [SELECT Id, Call_ID__c FROM Task WHERE Call_ID__c IN :UCIdToCase.keySet() AND WhatId = null];

        for(Task log : callbackLogs) {
            log.WhatId = UCIdToCase.get(log.Call_ID__c).Id;
        }

        if(!callbackLogs.isEmpty()) {
            update callbackLogs;
        }
    }

    public static Map<String, VDN__c> buildVDNCodeToVDNMap(List<String> logsUCID, Map<String, Task> UCIDToLog) {
        List<String> VDNCodes = new List<String>();
        for(String ucid : logsUCID) {
            if(UCIDToLog.get(ucid).WhatId == null) {
                VDNCodes.add(UCIDToLog.get(ucid).Called__c);
            }
        }
        List<VDN__c> VDNList = [SELECT CodeVDN__c, CallCenter__c FROM VDN__c WHERE CodeVDN__c IN :VDNCodes];
        Map<String, VDN__c> VDNCodeToVDN = new Map<String, VDN__c>();
        for(VDN__c vdn : VDNList) {
            VDNCodeToVDN.put(vdn.CodeVDN__c, vdn);
        }

        return VDNCodeToVDN;
    }

    public static Map<String, Case> buildUCIdToCaseMap(List<Case> cases) {
        Map<String, Case> UCIdToCase = new Map<String, Case>();
        for (Case c : cases) {
            UCIdToCase.put(c.UCID__c, c);
        }

        return UCIdToCase;
    }

    public static Map<String, String> buildpatientIdToUCIDMap(Map<String, Task> UCIDToLog) {
        Map<String, String> patientIdToUCID = new Map<String, String>();

        for(String ucid : UCIDToLog.keySet()) {
            patientIdToUCID.put(UCIDToLog.get(ucid).related_account__c, ucid);
        }

        return patientIdToUCID;
    }

    //Creates a map between the original UCID received in the UUI and the UCID from the connector (which might be different from the original one).
    public static Map<String, String> buildCIDToUCIDMap(Map<String, Task> UCIDToLog) {
        Map<String, String> CIDToUCID = new Map<String, String>();

        for(String ucid : UCIDToLog.keySet()) {
            CIDToUCID.put(UCIDToLog.get(ucid).Call_ID__c, ucid);
        }

        return CIDToUCID;
    }

     public static Map<String, Case_Classification_by_IVR__mdt> BuildIVROptionToCaseTrioMap(List<Case_Classification_by_IVR__mdt> caseMappingByIVR) {
        Map<String, Case_Classification_by_IVR__mdt> IVROptionToMapping = new Map<String, Case_Classification_by_IVR__mdt>();

        for(Case_Classification_by_IVR__mdt mapping : caseMappingByIVR) {
            IVROptionToMapping.put(mapping.IVR_Option_Number__c, mapping);
        }

        return IVROptionToMapping;
    }
}