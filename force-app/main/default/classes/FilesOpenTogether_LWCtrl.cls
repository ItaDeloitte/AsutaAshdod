public with sharing class FilesOpenTogether_LWCtrl {

    @AuraEnabled(cacheable=true)
    public static List<FileWrapper> getFilesForAccount(Id accountId) {
        List<FileWrapper> results = new List<FileWrapper>();
        Map<Id, String> filesMap = new Map<Id, String>();
        Map<Id, String> fileTypeMap = new Map<Id, String>();
        Map<Id, File__c> fileURLMap = new Map<Id, File__c>();
        Set<Id> fileIds = new Set<Id>();
        for(File__c file : [SELECT Id, Name, toLabel(file_type__c), Account__c, URL__c FROM File__c WHERE Account__c = :accountId]){
            fileIds.add(file.Id);
            filesMap.put(file.Id, file.Name);
            fileTypeMap.put(file.Id, file.file_type__c);
            if(file.URL__c != null){
                fileURLMap.put(file.Id, file);
            }            
        }

        List<ContentDocumentLink> links = [
                                            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title,
                                                ContentDocument.LatestPublishedVersionId, ContentDocument.FileExtension 
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId IN:fileIds
                                        ];
        List<String> docTypesImg = new List<String>{'png', 'jpeg', 'jpg'};
        for (ContentDocumentLink link : links) {//.jpg
            String url = '/sfc/servlet.shepherd/' + 
                        (!(docTypesImg.contains(link.ContentDocument.FileExtension)) ? 
                        'version/download/' : 
                        (docTypesImg.contains(link.ContentDocument.FileExtension) ? 'version/renditionDownload?rendition=ORIGINAL_Png&versionId=' : 'version/renditionDownload?rendition=THUMB720BY480&versionId=')) + 
                        link.ContentDocument.LatestPublishedVersionId;
            String title = filesMap.get(link.LinkedEntityId);
            String type = fileTypeMap.get(link.LinkedEntityId);
            fileURLMap.remove(link.LinkedEntityId);
            results.add(new FileWrapper(
                link.ContentDocumentId,
                title,
                type,
                link.ContentDocument.LatestPublishedVersionId,
                url
            ));
        }

        for(Id fileId : fileURLMap.keySet()){            
            results.add(new FileWrapper(
                fileId,
                fileURLMap.get(fileId).Name,
                '',
                fileId,
                fileURLMap.get(fileId).URL__c
            ));
        }
        return results;
    }

    public class FileWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String type;
        @AuraEnabled public String versionId;
        @AuraEnabled public String downloadUrl;

        public FileWrapper(String docId, String title, String type, String versionId, String downloadUrl) {
            this.id = id;
            this.title = title;
            this.type = type;
            this.versionId = versionId;
            this.downloadUrl = downloadUrl;
        }
    }
}