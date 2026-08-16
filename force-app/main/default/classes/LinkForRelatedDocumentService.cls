//Test: ContentDocumentLinkServiceTest
public with sharing class LinkForRelatedDocumentService {        

    public static void createLink (Set<Id> contentDocIds) {
        System.debug('LinkForRelatedDocumentService.createLink:'); 
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
        List<ContentDistribution> conDisToInsert = new List<ContentDistribution>();
        List<ContentVersion> versionToUpdate = new List<ContentVersion>(); 

        for (ContentVersion version_i : [SELECT Id, ContentDocumentId, RelatedDocumentUrl__c 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN: contentDocIds 
                                        AND RelatedDocumentUrl__c = null]) {
            contentVersionMap.put(version_i.Id, version_i);
        }
        System.debug('contentVersionMap: size: ' + contentVersionMap.size() + ' value: ' + contentVersionMap);

        if(!contentVersionMap.isEmpty()){
            for(Id vId_i :contentVersionMap.keySet()) {
                conDisToInsert.add(createContentDistribution(vId_i));
            }
            System.debug('conDisToInsert.size ' + conDisToInsert.size());
        }    

        if(!conDisToInsert.isEmpty()){
            Set<Id> contentDisIds = AsyncUtil.doInsert(conDisToInsert);                        
            System.debug('contentDisIds.size ' + contentDisIds.size());    

            for (ContentDistribution cd_i : [SELECT Id, ContentVersionId, DistributionPublicUrl 
                                            FROM ContentDistribution 
                                            WHERE Id IN: contentDisIds]) {
                if(contentVersionMap.containsKey(cd_i.ContentVersionId)){
                    ContentVersion conVersion = new ContentVersion(Id = contentVersionMap.get(cd_i.ContentVersionId).Id);
                    conVersion.RelatedDocumentUrl__c = cd_i.DistributionPublicUrl;
                    versionToUpdate.add(conVersion);
                }            
            }

            if(!versionToUpdate.isEmpty()){
                AsyncUtil.doUpdate(versionToUpdate);  
            } 
        }               
    }
    
    private static ContentDistribution createContentDistribution (Id conVersionId) {
        ContentDistribution cDistribution = new ContentDistribution();
        cDistribution.ContentVersionId = conVersionId;
        cDistribution.name = 'RelatedDoc ' + conVersionId;                
        cDistribution.PreferencesAllowViewInBrowser = true;
        cDistribution.PreferencesPasswordRequired = false;
        return cDistribution;
    }
}