global with sharing class UtilGetObjectData {


    @AuraEnabled(cacheable=true) 
    public static List<Site__c> getSiteList() {
        return [SELECT Id, Name, Portal_Code__c, Maccabi_Code__c FROM Site__c];
    }

    @AuraEnabled(cacheable=true) 
    public static List<Portal__mdt> getDocTypeForPortal() {
        return [SELECT Name__c, Code__c FROM Portal__mdt];
    }

    @AuraEnabled(cacheable=false) 
    public static Account getAccount(Id recordId) {
        return [SELECT Id, ID_Number__c, ID_Type__c FROM Account WHERE Id=:recordId LIMIT 1];
    }

    @AuraEnabled(cacheable=true) 
    public static User getUser(Id OwnerId) {
        return [SELECT Id, Agent_ID__c, Extension FROM User WHERE Id=:OwnerId LIMIT 1];
    }

    @AuraEnabled(cacheable=false) 
    public static List<File__c> getFileByAppointment(Id appId) {
        return [SELECT Id, toLabel(ReferralErrorCode__c), ReferralsExistErrorCode__c, toLabel(ReferralsExistErrorCode__c) RefCode, Referral_Type__c, toLabel(CommitmentStatus__c) 
                FROM File__c 
                WHERE Appointment__c=:appId LIMIT 1];
    }

    @AuraEnabled(cacheable=false) 
    public static List<File__c> getFile(Id recordId) {
        return [SELECT Id, toLabel(CommitmentStatus__c) ComStatus, CommitmentStatus__c, Case__c, Appointment__c
                FROM File__c 
                WHERE Id=:recordId LIMIT 1];
    }

    @AuraEnabled(cacheable=false) 
    public static List<Appointment__c> getAppointment(Id recordId) {
        return [SELECT Id, PayerFactor__c, PayerFactor__r.Code_Parent_for_Interface__c, Referral_Status_Maccabi__c, Number_of_commitment__c 
                FROM Appointment__c 
                WHERE Id=:recordId LIMIT 1];
    }

    @AuraEnabled(cacheable=false) 
    public static List<ContentDocumentLink> getContentDocumentLink(Id entitytId) {
        return [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:entitytId and IsDeleted=false]; 
    }

    @AuraEnabled(cacheable=true) 
    public static Map<Id, Medical_Procedure__c> getMedProcedureMap(Id[] ids) {
        Map<Id, Medical_Procedure__c> medPrMap = new Map<Id, Medical_Procedure__c>([SELECT Id, Procedure_Code__c FROM Medical_Procedure__c WHERE Id IN:ids]);
        return medPrMap;
    }

    @AuraEnabled(cacheable=true) 
    public static Payer_Factor__c getPayerFactor(Id pfId) {
        return [SELECT Id, Parent_Code__c, Code_Parent_for_Interface__c FROM Payer_Factor__c WHERE Id=: pfId LIMIT 1];
    }

    @AuraEnabled(cacheable=true) 
    public static List<RecordType> getRecordType(String developerName) {
        return [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName=:developerName];
    }

    @AuraEnabled(cacheable=true) 
    public static List<Case> getCaseByAccount(String accID) {
        System.debug('SELECT FROM CASE : '+accID);
        return [SELECT Id, CaseNumber, Status, Origin, RecordType.Name, Case_subject__c, sub_case_subject__c, CreatedDate FROM Case WHERE AccountId=:Id.valueOf(accID)];
    }

    @AuraEnabled(cacheable=true) 
    public static List<Appointment__c> getAppointmentByAccount(String accID) {
        return [SELECT Id, Name, Case__c, Site__r.Name, Appointment_Date_Time__c, Appointment_Status__c, CreatedDate, RecordType.DeveloperName, Medical_Procedure__r.Confidentiality__c FROM Appointment__c WHERE Patient_Account__c=:Id.valueOf(accID)];
    }

    @AuraEnabled(cacheable=true) 
    public static List<Appointment__c> getInstitutesAppointment(String accID) {
        Datetime currentDatetime = System.now();
        return [SELECT Id, Name, Case__c, Site__r.Name, Appointment_Date_Time__c, Appointment_Status__c, CreatedDate, RecordType.DeveloperName, 
                        Medical_Procedure__r.Confidentiality__c, Guidance_Scenario__r.Recording_Code_1__c, Guidance_Scenario__r.Recording_Code_2__c,
                        Guidance_Scenario__r.Recording_Code_3__c, Guidance_Scenario__r.Recording_Code_4__c, Guidance_Scenario__r.Recording_Code_5__c, 
                        Guidance_Scenario__r.Recording_Code_6__c, Medical_Procedure__r.Domain__r.Recording_Code__c
                FROM Appointment__c 
                WHERE Patient_Account__c=:Id.valueOf(accID)
                AND (Appointment_Status__c = 'WaitingForAppointment' OR Appointment_Status__c = 'וידוא הגעה לפגישה')
                AND RecordType.DeveloperName = 'Institutes'
                AND Medical_Procedure__r.Confidentiality__c = False
                AND Site__c != null
                AND Appointment_Date_Time__c >= :currentDatetime
                ORDER BY Appointment_Date_Time__c
                LIMIT 4];
    }

    @AuraEnabled(cacheable=false) 
    public static List<File__c> getFilesByAccount(String accID) {
        return [SELECT Id, Name, RecordType.Name, CreatedDate FROM File__c WHERE Account__c=:Id.valueOf(accID)];
    }
    
    @AuraEnabled(cacheable=false) 
    public static List<Disabilities__c> getDisabilitiesByAccount(String accID) {
        return [SELECT Id, toLabel(Type_of_disability__c) type, Name, Description__c, Disability__c, toLabel(Type_of_Assist__c) assType, Status_Disability__c, CreatedDate FROM Disabilities__c WHERE Patient_Account__c=:Id.valueOf(accID)];
    }
      
    @AuraEnabled(cacheable=false) 
    public static List<Task> getTasksByAccount(String accID) {
        return [SELECT Id, AccountId, Subject, Agent_assigned_name__c, CALLBACK_status__c, CreatedDate FROM Task Where AccountId=:Id.valueOf(accID)];
    }

    @AuraEnabled(cacheable=false) 
    public static List<Contact> getContactsByAccount(String accID) {
        return [SELECT Id, Name, Description, CreatedDate FROM Contact WHERE Id=:Id.valueOf(accID)];
    }

    @AuraEnabled(cacheable=false) 
    public static List<AccountContactRelation> getAccountContactByAccount(String accID) {
        return [SELECT Id, ContactId, Roles, title__c, icon_identification__c, CreatedDate  FROM AccountContactRelation WHERE AccountId=:Id.valueOf(accID)];
    }

    @AuraEnabled(cacheable=false)
    public static List<Callout_Timeout__mdt> getCalloutTimeout(String devName) {
        return [SELECT Id, DeveloperName, Timeout__c FROM Callout_Timeout__mdt WHERE DeveloperName=:devName];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Appointment__History> getAppHistory(String accID){
        Set<Id> ids = (new Map<Id, Appointment__c>([SELECT Id FROM Appointment__c WHERE Patient_Account__c=:Id.valueOf(accID)])).keySet();
        return [SELECT Id, oldValue, toLabel(NewValue) newVal, ParentId, Parent.Name, CreatedDate, CreatedBy.Name, IsDeleted, toLabel(OldValue) oldVal 
                FROM Appointment__History 
                WHERE ParentId IN:ids 
                AND Field='Appointment_Status__c'];
    }

    @AuraEnabled(cacheable=true)
    public static String getTimeZone(){
        //Integer tz = UserInfo.getTimeZone().getOffset(system.now());
        DateTime now = DateTime.now();
        Integer hours = now.hour(), minutes = now.minute(), seconds = now.second(), year = now.year(), month = now.month(), day = now.day();
        return year+'-'+month+'-'+day+' '+hours+':'+minutes+':'+seconds;
    }

    @AuraEnabled
    public static List<Appointment__c> getWaitingAppointments(String waitingListId) {
        System.debug('UtilGetObjectData.getWaitingAppointments...\nwaitingListId: ' + waitingListId);
        Id pApptId = [SELECT Id, Appointment__c FROM waiting_list__c WHERE Id =: waitingListId].Appointment__c;
        Appointment__c pAppt = [SELECT Id, Appointment_Date_Time__c, Site__c, Medical_Procedure__r.Domain__c FROM Appointment__c WHERE Id =: pApptId];
        System.debug('pAppt: ' + pAppt);

        Set<Id> procedureIds = new Set<Id>();
        for (Medical_Procedure__c procedure_i : [SELECT Id FROM Medical_Procedure__c WHERE Domain__c =: pAppt.Medical_Procedure__r.Domain__c]) {
            procedureIds.add(procedure_i.Id);
        }
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);

        List<Appointment__c> apps = new List<Appointment__c>();
        for (Appointment__c appt_i : [SELECT Id
                                           , Name
                                           , Appointment_Status__c
                                           , Appointment_Date_Time__c
                                           , Date_of_appointment__c
                                           , AppointmentTime__c
                                           , Medical_Procedure__c
                                           , Site__c
                                           , Site__r.Name
                                      FROM Appointment__c
                                      WHERE Appointment_Status__c = 'Urgent_WaitingList'
                                      AND Medical_Procedure__c IN: procedureIds
                                      AND CreatedDate > 2020-07-23T00:00:00Z
                                      AND Apt_date_time_not_yet__c = true]) {
            if (appt_i.Appointment_Date_Time__c < pAppt.Appointment_Date_Time__c && appt_i.Site__c == pAppt.Site__c) {
                apps.add(appt_i);
            }
        }
        System.debug('apps: size: ' + apps.size() + ' value: ' + apps);

        return apps;
    }

    @AuraEnabled
    public static void updateMaccabi(String accID){
        update new Account(Id=accID, Last_update_maccabi__c = datetime.now());
    }

    @AuraEnabled
    public static void updatePortal(String accID) {
        update new Account(Id = accID, Last_update_portal__c = datetime.now());
    }

    @AuraEnabled(cacheable=true)
    public static List<Records> fetchRecords(String ObjectName, String field1, String field2, String searchString, Integer numRecords, String condition) {
        List<Records> recordsList = new List<Records>();

        if (condition != '') {
            condition = ' AND ' + condition;
        }
        try {
            String keyWord = '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            System.debug('keyWord: ' + keyWord);

            String query = 'SELECT Id, ' + field1 + ', ' + field2 + ' FROM ' + objectName + ' WHERE ';
            if (objectName == 'Payer_Factor__c' || objectName == 'Site__c') {
                query += '(' + field1 + ' LIKE ' + keyWord + ' OR ' + field2 + ' LIKE ' + keyWord + ')';
            } else {
                query += field1 + ' LIKE ' + keyWord;
            }
            query += condition + ' LIMIT ' + numRecords;
            System.debug(query);
            for (SObject s : Database.query(query)) {
                Records record = new Records();
                record.Id = String.valueOf(s.get('id'));
                record.val1 = String.valueOf(s.get(field1));
                record.val2 = String.valueOf(s.get(field2));
                recordsList.add(record);
            } 
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
        return recordsList;
    }

    @AuraEnabled(cacheable=false) 
    public static String getContentVersion(Id entitytId) {
        Id conDocId = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:entitytId Limit 1].ContentDocumentId; 
        ContentVersion contVers = [SELECT Id, ContentDocumentId, FileExtension FROM ContentVersion WHERE ContentDocumentId =:conDocId Limit 1];
        return JSON.serialize(contVers);
    }

    @AuraEnabled(cacheable=false) 
    public static Boolean checkRelatedReferral(Id appId) {
        List<File__c> files = [SELECT Id, Appointment__c, RecordType.DeveloperName  
                               FROM File__c 
                               WHERE Appointment__c =:appId 
                               AND RecordType.DeveloperName = 'Referral']; 
        if(files.size() > 0){
            return true;
        }
        return false;
    }

/**
   * @author    Yulia Liberman 
   * @since     17/01/2025
   * @desc      Generic functions for LWC
   * @param     
*/
    @AuraEnabled(cacheable=false)
    public static List<sObject> fetchRecordsByQuery(String queryStr) {
        List<sObject> sobjList = new List<sObject>();
        try {
            System.debug(queryStr);
            sobjList = Database.query(queryStr);
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
        return sobjList;
    }

    @AuraEnabled
    public static String getFieldValue(String recId, String fieldName){
        try {
            SObjectType sObjectType = Id.valueOf(recId).getSObjectType();
            String query = 'SELECT Id, ' + fieldName + ' FROM ' + sObjectType + ' WHERE Id = \'' + recId + '\' LIMIT 1';
            sObject obj = Database.Query(query);
            return (String)obj.get(fieldName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRecord(String recId, String sObjectAPIName, String fieldName, String fieldValue) {
        sObject sobjRec = Schema.getGlobalDescribe().get(sObjectAPIName).newSObject();
        sobjRec.put('Id', recId);
        sobjRec.put(fieldName, fieldValue);
        try {
            update(sobjRec);
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRecordCheckBox(String recId, String sObjectAPIName, String fieldName, Boolean fieldValue) {
        sObject sobjRec = Schema.getGlobalDescribe().get(sObjectAPIName).newSObject();
        sobjRec.put('Id', recId);
        sobjRec.put(fieldName, fieldValue);
        try {
            update(sobjRec);
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }


    @AuraEnabled
    public static void createRecord(String sObjectAPIName, String fieldsCmpMap) {
        sObject sobjRec = Schema.getGlobalDescribe().get(sObjectAPIName).newSObject();
        Map<String, String> fieldsMap = (Map<String, String>)JSON.deserialize(fieldsCmpMap, Map<String, String>.class);
        for(String fieldName : fieldsMap.keySet()){
            sobjRec.put(fieldName, fieldsMap.get(fieldName));
        }
        try {
            insert(sobjRec);
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    @AuraEnabled
    public static String getSObjectAPINameById(String id){
        Id sObjId = id;
        return String.valueOf(sObjId.getSObjectType());
    }

    public class Records {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String val1 {get;set;}
        @AuraEnabled public String val2 {get;set;}
    }
}