// Test: ContentDocumentLinkServiceTest
// author anatoly voronov (anatoly.voronov@synebo.io)
// created date : 05.06.2019
public without sharing class ContentDocumentLinkService {

    // author anatoly voronov (anatoly.voronov@synebo.io)
    public static void filterAndUpdateLinks(List<ContentDocumentLink> preFiltredList){
        System.debug('ContentDocumentLinkService.filterAndUpdateLinks');

        // 3 typs 
        // 1. scanned
        // 2. non scanned, but object exist 
        // 3. non scanned and object not exist

        Set <String> contentDocumentsIdSet = new Set <String> ();
        Set <String> currentLinksSet = new Set <String> ();
        for (ContentDocumentLink link_i : preFiltredList){
            contentDocumentsIdSet.add(link_i.ContentDocumentId);
            currentLinksSet.add(link_i.LinkedEntityId);
        }
        List <ContentDocumentLink> allDocumentLinks = new List <ContentDocumentLink> ();
        Set <String> otherLinkedEntityId = new Set <String> ();
        // check if file already linked
        for (ContentDocumentLink link_i : [SELECT ContentDocumentId, LinkedEntityId 
                                            FROM ContentDocumentLink 
                                            WHERE ContentDocumentId IN: contentDocumentsIdSet 
                                            AND LinkedEntityId NOT IN: currentLinksSet]){
            otherLinkedEntityId.add(link_i.LinkedEntityId);
            allDocumentLinks.add(link_i);   
        }

        Set <String> alreadyScanneFileIdSet = new Set <String> ();
        
        // check which id was passed
        System.debug('otherLinkedEntityId.size '+otherLinkedEntityId.size());
        
        for (GateScanner_file__c file_i : [SELECT ID, Status__c FROM GateScanner_file__c WHERE Status__c = 'Scanning passed' AND ID IN : otherLinkedEntityId]){
            alreadyScanneFileIdSet.add(file_i.id);
        }
        System.debug('alreadyScanneFileIdSet.size '+alreadyScanneFileIdSet.size());
        Set <String> alreadyScanneDocumentIdSet = new Set <String> ();
        for (ContentDocumentLink link_i : allDocumentLinks){
            if (alreadyScanneFileIdSet.contains(link_i.LinkedEntityId)){
                alreadyScanneDocumentIdSet.add(link_i.ContentDocumentId);
            }
        }
        System.debug('alreadyScanneDocumentIdSet.size '+alreadyScanneDocumentIdSet.size());
        // filtrate initaial links
        List <ContentDocumentLink> listToFutureCheck = new List <ContentDocumentLink>();
        for (ContentDocumentLink link_i : preFiltredList){
            if (!alreadyScanneDocumentIdSet.contains(link_i.ContentDocumentId)){
                listToFutureCheck.add(link_i);
            }
        }
        System.debug('listToFutureCheck.size '+listToFutureCheck.size());
        if (!listToFutureCheck.isEmpty()){
            System.enqueueJob(new ContentDocumentLinkQueueableProcessor(listToFutureCheck));
        }
    }

}