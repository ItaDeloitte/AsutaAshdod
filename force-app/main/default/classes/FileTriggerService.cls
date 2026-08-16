// Test: FileTriggerTest
public with sharing class FileTriggerService {

    public static void preventDuplicateCreation(Map<String, File__c> keyToFileMap, Set<String> acctIds, Set<String> referralNumbers) {
        List<File__c> files = [
            SELECT Id
                 , Account__c
                 , ReferralNumber__c
              FROM File__c
             WHERE Id NOT IN :keyToFileMap.values()
               AND Account__c IN :acctIds
               AND ReferralNumber__c IN :referralNumbers];

        for (File__c file_i : files) {
            if (keyToFileMap.containsKey(file_i.Account__c + '-' + file_i.ReferralNumber__c)) {
                keyToFileMap.get(file_i.Account__c + '-' + file_i.ReferralNumber__c).addError(Label.File_TR_preventDuplicateCreation_Error);
                System.debug('LOG File__c preventDuplicateCreation ... logic has been executed');
            }
        }
    }

    public static void fillLookups(List<File__c> files, Set<Id> apptIds, Set<Id> caseIds) {
        if(!apptIds.isEmpty()){
            Map<Id, Appointment__c> apptsMap = new Map<Id, Appointment__c>([
                SELECT Site__c
                    , Doctor_Account__c
                    , Patient_Account__c
                    , Medical_Procedure__c
                    , PayerFactor__c
                    , PayerFactor__r.Code_Parent_for_Interface__c
                FROM Appointment__c
                WHERE Id IN: apptIds]);
            System.debug('apptsMap: size: ' + apptsMap.size() + ' value: ' + apptsMap);

            for (File__c file_i : files) {
                Appointment__c appt_i = apptsMap.get(file_i.Appointment__c);

                if (file_i.Medical_Procedure__c == null) {
                    file_i.Medical_Procedure__c = appt_i.Medical_Procedure__c;
                }
                if (file_i.DoctorName__c == null && file_i.Maccabi_Doctor_code__c == null && file_i.Maccabi_Doctor_License__c == null) {
                    file_i.DoctorName__c = appt_i.Doctor_Account__c;
                }
                if (file_i.Site__c == null) {
                    file_i.Site__c = appt_i.Site__c;
                }
                if (file_i.Account__c  == null) {
                    file_i.Account__c = appt_i.Patient_Account__c ;
                }
                /*if (appt_i.PayerFactor__c != null && appt_i.PayerFactor__r.Code_Parent_for_Interface__c == '3') {
                    file_i.IsMaccabi__c  = true;
                } else {
                    file_i.IsMaccabi__c = false;
                }*/
            }
        }else if(!caseIds.isEmpty()){
            Map<Id, Id> casesMap = new Map<Id, Id>();
            Map<Id, Boolean> usersMap = new Map<Id, Boolean>();
            for(case cas_i :[SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds]){
                casesMap.put(cas_i.Id, cas_i.OwnerId);
            }
            for(User us_i :[SELECT Id, Ashdod_employee__c FROM User WHERE Id IN :casesMap.values()]){
                usersMap.put(us_i.Id, us_i.Ashdod_employee__c);
            }

            for (File__c file_i : files) {
                System.debug('IsSendAshdodPortal__c' + usersMap.get(casesMap.get(file_i.Case__c)));
                if (file_i.Site__c == null && usersMap.containsKey(casesMap.get(file_i.Case__c)) && usersMap.get(casesMap.get(file_i.Case__c)) != null ) {
                    file_i.IsSendAshdodPortal__c = usersMap.get(casesMap.get(file_i.Case__c));
                }
            }
        }
        System.debug('files: size: ' + files.size() + ' value: ' + files);
        System.debug('LOG File__c fillLookups ... logic has been executed');
    }

    public static void initDoctorPhoto(List<File__c> files, Set<Id> doctorIds) {
        System.debug('FileTriggerService.initDoctorPhoto...');
        Map<Id, Account> doctorsMap = new Map<Id, Account>([SELECT Id, Doctor_Code__c FROM Account WHERE Id IN: doctorIds]);
        Map<Id,String> ContDocFileNameMap = new Map<Id,String>();

        System.debug('doctorsMap: size: ' + doctorsMap.size() + ' value: ' + doctorsMap);

        for (File__c file_i : files) {
            file_i.Name = doctorsMap.get(file_i.DoctorName__c).Doctor_Code__c;
            ContDocFileNameMap.put(file_i.Content_Version_Id__c,doctorsMap.get(file_i.DoctorName__c).Doctor_Code__c);
        }

        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: ContDocFileNameMap.keySet()];
        for (ContentVersion cv : cvList){
            cv.Title = ContDocFileNameMap.get(cv.ContentDocumentId);
        }
        update cvList;
    }

    public static void markFileForDeletion(Map<String, Boolean> docIdsMap) {
        List<ContentVersion> versions = new List<ContentVersion>();

        for (ContentVersion cv_i : [SELECT Id, ContentDocumentId, IsNeedToBeDeleted__c FROM ContentVersion WHERE ContentDocumentId IN: docIdsMap.keySet()]) {
            cv_i.IsNeedToBeDeleted__c = docIdsMap.get(cv_i.ContentDocumentId);
            versions.add(cv_i);
        }
        System.debug('versions: size: ' + versions.size() + ' value: ' + versions);

        if (!versions.isEmpty()) {
            update versions;
            System.debug('LOG File__c markFileForDeletion ... logic has been executed');
        }
    }

    public static void updatePortalURL(List<File__c> files, Set<Id> apptIds) {
        Map<Id, Appointment__c> apptsToUpdateMap = new Map<Id, Appointment__c>();

        Map<Id, Appointment__c> apptsMap = new Map<Id, Appointment__c>([
            SELECT Id
                 , URL_To_ID_File__c
              FROM Appointment__c
             WHERE Id IN: apptIds]);
        System.debug('apptsMap: size: ' + apptsMap.size() + ' value: ' + apptsMap);

        for (File__c file_i : files) {
            Appointment__c appt_i = apptsMap.get(file_i.Appointment__c);

            if (appt_i.URL_To_ID_File__c != file_i.URL__c) {
                appt_i.URL_To_ID_File__c = file_i.URL__c;
                apptsToUpdateMap.put(appt_i.Id, appt_i);
            }
        }
        System.debug('apptsToUpdateMap: size: ' + apptsToUpdateMap.size() + ' value: ' + apptsToUpdateMap);

        if (!apptsToUpdateMap.isEmpty()) {
            update apptsToUpdateMap.values();
            System.debug('LOG File__c updatePortalURL ... logic has been executed');
        }
    }

    public static void markForwardToRIS(List<File__c> files, Set<Id> appIds) {
        System.debug('FileTriggerService.markForwardToRIS...');
        Map<Id, Appointment__c> apptsMap = new Map<Id, Appointment__c>([SELECT Id, SourceSystem__c FROM Appointment__c WHERE Id IN: appIds AND SourceSystem__c = 'RIS']);        
        System.debug('apptsMap: size: ' + apptsMap.size() + ' value: ' + apptsMap);

        for (File__c file_i : files) {
            if(apptsMap.containsKey(file_i.Appointment__c)) {
                file_i.ForwardToRIS__c  = true;
            }            
        } 
        System.debug('files: size: ' + files.size() + ' value: ' + files);
        System.debug('LOG File__c markForwardToRIS ... logic has been executed');       
    }
    
    public static void insertDocumentToPortal(List<File__c> files, Set<Id> docIds) {
        System.debug('FileTriggerService.insertDocumentToPortal...');               
        Map<Id, ContentVersion> docIdToDoc = new Map<Id, ContentVersion>();                       
                             
        for (ContentVersion cv_i : [SELECT Id
                                        , FileExtension
                                        , ContentDocumentId
                                        , VersionData                                             
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId IN: docIds]) {
            docIdToDoc.put(cv_i.ContentDocumentId, cv_i);            
        }
        System.debug('docIdToDoc: size: ' + docIdToDoc.size() + ' value: ' + docIdToDoc);        
        
        if (!docIdToDoc.isEmpty()) {       
            for (File__c file_i : files) {
                if(docIdToDoc.containsKey(file_i.Content_Version_Id__c)) {
                    Map<String, String> input = new Map<String, String>();
                    input.put('fileId', file_i.Id);                   
                    input.put('contDocumentId', file_i.Content_Version_Id__c);
                    input.put('contVersionId', docIdToDoc.get(file_i.Content_Version_Id__c).Id);                   
                    input.put('fileType', docIdToDoc.get(file_i.Content_Version_Id__c).FileExtension);             
                    System.enqueueJob(new ws_insertDocumentToPortalREST(input, docIdToDoc.get(file_i.Content_Version_Id__c).VersionData, true));
                }            
            }
            System.debug('LOG File__c insertDocumentToPortal ... logic has been executed');  
        }                 
    }
}