// Test: FileTriggerTest
public with sharing class FileTriggerDispatcher {

    public static Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Check if such a File already exists in SalesForce (key: Account__c + ReferralNumber__c) and throw an error if it is
     * 
     * Event            BEFORE_INSERT, BEFORE_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @created          27-08-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void preventDuplicateCreation(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c preventDuplicateCreation ... start');
        Map<String, File__c> keyToFileMap = new Map<String, File__c>();
        Set<String> referralNumbers = new Set<String>();
        Set<String> acctIds = new Set<String>();

        for (File__c file_i : newList) {
            if (file_i.Account__c != null &&
                    file_i.ReferralNumber__c != null &&
                    (oldMap == null ||
                        oldMap.get(file_i.Id).Account__c != file_i.Account__c ||
                        oldMap.get(file_i.Id).ReferralNumber__c != file_i.ReferralNumber__c)) {
                if (!keyToFileMap.containsKey(file_i.Account__c + '-' + file_i.ReferralNumber__c)) {
                    keyToFileMap.put(file_i.Account__c + '-' + file_i.ReferralNumber__c, file_i);
                    referralNumbers.add(file_i.ReferralNumber__c);
                    acctIds.add(file_i.Account__c);
                } else {
                    file_i.addError(Label.File_TR_preventDuplicateCreation_Error);
                }
            }
        }
        System.debug('keyToFileMap: size: ' + keyToFileMap.size() + ' value: ' + keyToFileMap);
        System.debug('acctIds: size: ' + acctIds.size() + ' value: ' + acctIds);
        System.debug('referralNumbers: size: ' + referralNumbers.size() + ' value: ' + referralNumbers);

        if (!keyToFileMap.isEmpty()) {
            FileTriggerService.preventDuplicateCreation(keyToFileMap, acctIds, referralNumbers);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Fill Medical_Procedure__c, DoctorName__c, Site__c, Account__c fields and mark IsMaccabi__c checkbox with values from
     * related Appointment via Appointment__c field
     * 
     * Event            BEFORE_INSERT, BEFORE_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         10-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillLookups(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c fillLookups ... start');
        List<File__c> files = new List<File__c>();
        Set<Id> apptIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();

        for (File__c file_i : newList) {
            if (
                (file_i.Appointment__c != null  || file_i.Case__c != null) && 
                (
                    oldMap == null ||
                    oldMap.get(file_i.Id).Appointment__c != file_i.Appointment__c ||
                    oldMap.get(file_i.Id).Case__c != file_i.Case__c
                )
            ) {
                if(file_i.Appointment__c != null){
                    apptIds.add(file_i.Appointment__c);
                } else{
                    caseIds.add(file_i.Case__c);
                }
                files.add(file_i);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);
        System.debug('files: size: ' + files.size() + ' value: ' + files);

        if (!files.isEmpty()) {
            FileTriggerService.fillLookups(files, apptIds, caseIds);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Mark IsNeedToBeDeleted__c as true on ContentVersion related via Content_Version_Id__c field
     * 
     * Event            AFTER_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @created          10-03-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void markFileForDeletion(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c markFileForDeletion ... start');
        Map<String, Boolean> docIdsMap = new Map<String, Boolean>();

        for (File__c file_i : newList) {
            if (
                file_i.Content_Version_Id__c != null &&
                (
                    oldMap.get(file_i.Id).Content_Version_Id__c != file_i.Content_Version_Id__c ||
                    oldMap.get(file_i.Id).GateScaner_FileScanStatus__c != file_i.GateScaner_FileScanStatus__c
                )
            ) {
                if (file_i.GateScaner_FileScanStatus__c == '1' || file_i.GateScaner_FileScanStatus__c == '3') {
                    docIdsMap.put(file_i.Content_Version_Id__c, true);
                } else {
                    docIdsMap.put(file_i.Content_Version_Id__c, false);
                }
            }
        }
        System.debug('docIdsMap: size: ' + docIdsMap.size() + ' value: ' + docIdsMap);

        if (!docIdsMap.isEmpty()) {
            FileTriggerService.markFileForDeletion(docIdsMap);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Fill URL_To_ID_File__c on Appointment related via Appointment__c field
     * 
     * Event            AFTER_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         10-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void updatePortalURL(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c updatePortalURL ... start');
        List<File__c> files = new List<File__c>();
        Set<Id> apptIds = new Set<Id>();

        for (File__c file_i : newList) {
            if (
                file_i.Appointment__c != null &&
                file_i.file_type__c == '13' &&
                file_i.URL__c != null &&
                (
                    oldMap.get(file_i.Id).Appointment__c != file_i.Appointment__c ||
                    oldMap.get(file_i.Id).file_type__c != file_i.file_type__c ||
                    oldMap.get(file_i.Id).URL__c != file_i.URL__c
                )
            ) {
                apptIds.add(file_i.Appointment__c);
                files.add(file_i);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);
        System.debug('files: size: ' + files.size() + ' value: ' + files);

        if (!files.isEmpty()) {
            FileTriggerService.updatePortalURL(files, apptIds);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Update File Name based on Doctor_Code__c field on Account connected via doctorName__c lookup
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      Doctor_Photo
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Max Feldman                 <maxf@assuta.co.il>
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         15-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void initDoctorPhoto(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c initDoctorPhoto ... start');
        Id docPhotoRTId = fileRTMap.get('Doctor_Photo').getRecordTypeId();
        List<File__c> files = new List<File__c>();
        Set<Id> doctorIds = new Set<Id>();

        for (File__c file_i : newList) {
            if (file_i.RecordTypeId == docPhotoRTId && file_i.DoctorName__c != null && file_i.Content_Version_Id__c != null && 
                oldMap != null && file_i.Content_Version_Id__c != oldMap.get(file_i.Id).Content_Version_Id__c) {
                doctorIds.add(file_i.DoctorName__c);
                files.add(file_i);
            }
        }
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
        System.debug('files: size: ' + files.size() + ' value: ' + files);

        if (!files.isEmpty()) {
            FileTriggerService.initDoctorPhoto(files, doctorIds);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Mark ForwardToRIS__C as true on File related via Appointment field    
     * Event            BEFORE_UPDATE
     * User             *
     * Profile          *
     * Record Type      Referral
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           ortalk                 <ortalk@assuta.co.il>
     * @created          23.10.2022    
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void markForwardToRIS(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c markForwardToRIS ... start');
        Id referralRTId = fileRTMap.get('Referral').getRecordTypeId();
        List<File__c> files = new List<File__c>();
        Set<Id> appIds = new Set<Id>();

        for (File__c file_i : newList) {
            if (file_i.RecordTypeId == referralRTId && file_i.URL__C  != null && file_i.Appointment__c != null &&
                oldMap != null && file_i.Appointment__c != oldMap.get(file_i.Id).Appointment__c) {
                appIds.add(file_i.Appointment__c);
                files.add(file_i);
            }
        }
        System.debug('appIds: size: ' + appIds.size() + ' value: ' + appIds);
        System.debug('files: size: ' + files.size() + ' value: ' + files);

        if (!files.isEmpty()) {
            FileTriggerService.markForwardToRIS(files, appIds);
        }
    }
    
    public static void updateFileName(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c updateFileName ... start');
        Map<String, PicklistUtil.PicklistValue> picklistMap = PicklistUtil.buildPicklistMapping('File__c', 'File_Type__c');

        for (File__c file_i : newList) {
            if (file_i.File_Type__c != null
                && (oldMap == null
                || (oldMap.get(file_i.Id).File_Type__c != file_i.File_Type__c))) {
                Datetime createdDate_i = oldMap == null ? Datetime.now() : file_i.CreatedDate;
                file_i.Name = createdDate_i.format('dd/MM/yyyy') + ' ' + picklistMap.get(file_i.File_Type__c)?.label;
            }
        }
    }
    
    public static void insertDocumentToPortal(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c insertDocumentToPortal ... start');
        Set<Id> docIds = new Set<Id>();               
        List<File__c> files = new List<File__c>();               

        for (File__c file_i : newList) {
            if (file_i.File_Type__c != null
                && file_i.URL__c == null
                && file_i.Content_Version_Id__c != null               
                && oldMap.get(file_i.Id).File_Type__c != file_i.File_Type__c
                && (file_i.GateScaner_FileScanStatus__c == '0' || file_i.GateScaner_FileScanStatus__c == '2')) {                                                       
                    files.add(file_i);
                    docIds.add(file_i.Content_Version_Id__c);                    
            }
        }        
        System.debug('files: size: ' + files.size() + ' value: ' + files);

        if (!files.isEmpty()) {
            FileTriggerService.insertDocumentToPortal(files, docIds);
        }
    }
    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Updates each Appointment’s Required_documents_status__c based on whether required documents were uploaded.
     * Event            AFTER_INSERT, AFTER_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           ortalk                 <ortalk@assuta.co.il>
     * @created          07.01.2026    
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void updateStatusForReqDocument(List<File__c> newList, Map<Id, File__c> oldMap) {
        System.debug('LOG File__c updateStatusForReqDocument ... start'); 
        Set<Id> appointmentIds = new Set<Id>();              

        for (File__c file_i : newList) {
            if (file_i.Appointment__c != null 
                && (oldMap == null || (oldMap.get(file_i.Id).Appointment__c != file_i.Appointment__c))) {                                  
                appointmentIds.add(file_i.Appointment__c);
            }
        }        
        System.debug('appointmentIds: size: ' + appointmentIds.size() + ' value: ' + appointmentIds);                       
        if (!appointmentIds.isEmpty()) {
            RequiredDocuments.updateStatus(appointmentIds);
        }
    }
}