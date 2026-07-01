// Test: ContentDocumentLinkServiceTest
// author anatoly voronov (anatoly.voronov@synebo.io)
// created date : 05.06.2019
// file processor for gate scanner check
global without sharing class ContentDocumentLinkQueueableProcessor implements Queueable {

    List <ContentDocumentLink> linkListToProcess = new list <ContentDocumentLink> ();

    public ContentDocumentLinkQueueableProcessor(List <ContentDocumentLink> incommintList){
        this.linkListToProcess = incommintList;
    }

    
    public void execute(QueueableContext context) {
        System.debug('ContentDocumentLinkQueueableProcessor.execute');
        System.debug('linkListToProcess.size '+linkListToProcess.size());
        List <GateScanner_file__c> fileToInsertList = new List <GateScanner_file__c>();
        for (ContentDocumentLink link_i : linkListToProcess){
            GateScanner_file__c file = new GateScanner_file__c(
                Original_location__c = link_i.LinkedEntityId,
                Status__c = 'Unscanned'
            );
            fileToInsertList.add(file);
        }
        System.debug('fileToInsertList.size '+fileToInsertList.size());
        if (!fileToInsertList.isEmpty()){
            insert fileToInsertList;
        }

        Map <String, String> originalToNewLocationMap = new Map <String, String> ();
        for (GateScanner_file__c file_i : [SELECT Id, Original_location__c FROM GateScanner_file__c WHERE ID IN: fileToInsertList]){
            originalToNewLocationMap.put(file_i.Original_location__c, file_i.id);
        }
        System.debug('originalToNewLocationMap.size '+originalToNewLocationMap.size());
        LIst <ContentDocumentLink> docLinkToInsert = new LIst <ContentDocumentLink> ();
        LIst <ContentDocumentLink> docLinkToDelete = new LIst <ContentDocumentLink> ();
        for (ContentDocumentLink link_i : linkListToProcess){
            docLinkToInsert.add(
                new ContentDocumentLink(
                    ContentDocumentId = link_i.ContentDocumentId,
                    LinkedEntityId = originalToNewLocationMap.get(link_i.LinkedEntityId), 
                    ShareType = link_i.ShareType
                ));
            docLinkToDelete.add(link_i);
        }
        System.debug('docLinkToDelete.size '+docLinkToDelete.size());
        if (!docLinkToDelete.isEmpty()){
            delete docLinkToDelete;
        }
        System.debug('docLinkToInsert.size '+docLinkToInsert.size());
        if (!docLinkToInsert.isEmpty()){
            insert docLinkToInsert;
        }
    }
}