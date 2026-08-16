// Test: GateScannerFileServiceTest
public with sharing class GateScannerFileService {
    
    public static void restoreFileLocation (List <GateScanner_file__c> filtredFileList) {
        System.debug('GateScannerFileService.restoreFileLocation...');
        Map<String, String> locationToOriginalLocationMap = new Map<String, String>();
        List<ContentDocumentLink> linkListToInsert = new List<ContentDocumentLink>();

        Set<Id> emailMessageIds = new Set<Id>();
        for (GateScanner_file__c file_i : filtredFileList) {
            if (Id.valueOf(file_i.Original_location__c).getSobjectType() == EmailMessage.getSObjectType()) {
                emailMessageIds.add(file_i.Original_location__c);
            }
        }
        Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>([SELECT Id, ParentId FROM EmailMessage WHERE Id IN: emailMessageIds]);

        for (GateScanner_file__c file_i : filtredFileList) {
            //System.debug('Related to type '+Id.valueOf(file_i.Original_location__c).getSobjectType());
            if (Id.valueOf(file_i.Original_location__c).getSobjectType() == Case.getSObjectType()) {
                locationToOriginalLocationMap.put(file_i.id, file_i.Original_location__c);
            } else if (Id.valueOf(file_i.Original_location__c).getSobjectType() == EmailMessage.getSObjectType()) {
                locationToOriginalLocationMap.put(file_i.id, emailMessageMap.get(file_i.Original_location__c).ParentId);
            }
            System.debug('locationToOriginalLocationMap ' + locationToOriginalLocationMap);
        }

        List<File__c> filesToCase = new List<File__c>();
        Id RTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'General' AND SObjectType = 'File__c'].Id;
        for (Case case_i : [SELECT Id, AccountId FROM Case WHERE Id IN: locationToOriginalLocationMap.values()]) {
            filesToCase.add(new File__C(Case__c = case_i.Id, Account__c = case_i.AccountId, RecordTypeId = RTId));
        }
        System.debug('filesToCase ' + filesToCase);
        System.debug('filesToCase.size ' + filesToCase.size());
        if (!filesToCase.isEmpty()) {
            insert filesToCase;
        }

        Map<Id, File__c> caseIdToFileIdMap = new Map<Id, File__c>();
        for (File__c file_i : filesToCase) {
            caseIdToFileIdMap.put(file_i.Case__c, file_i);
        }

        for (ContentDocumentLink link_i : [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType FROM ContentDocumentLink 
                                           WHERE LinkedEntityId IN: locationToOriginalLocationMap.keySet()]) {
            System.debug('ContentDocumentLink link_i ' + link_i);
            ContentDocumentLink newDocLink = new ContentDocumentLink(
                ContentDocumentId = link_i.ContentDocumentId,
                LinkedEntityId = locationToOriginalLocationMap.get(link_i.LinkedEntityId),
                ShareType = link_i.ShareType
            ); 
            linkListToInsert.add(newDocLink);
        }

        for (ContentDocumentLink docLink_i : linkListToInsert) {
            docLink_i.LinkedEntityId = caseIdToFileIdMap.get(docLink_i.LinkedEntityId).Id;
        }

        System.debug('linkListToInsert.size ' + linkListToInsert.size());
        if (!linkListToInsert.isEmpty()) {
            insert linkListToInsert;
        }
    }
}