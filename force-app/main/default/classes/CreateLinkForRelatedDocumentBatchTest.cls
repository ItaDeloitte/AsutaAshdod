/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 *  create public link for related Document Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             10-04-2022             <ortalk@assuta.co.il>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class CreateLinkForRelatedDocumentBatchTest {

    @TestSetup
    static void makeData() {
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Related_document__c relatedDoc = TestDataFactory.getRelatedDoc(procedure.Id, 'אסותא השלום');
        insert relatedDoc;
        insert TestDataFactory.getContentVersion();
        
    }

    @IsTest
    static void batchTest() {
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;
        Id relDocId = [SELECT Id FROM Related_document__c LIMIT 1].Id;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = relDocId;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        Test.startTest();
        Database.executeBatch(new CreateLinkForRelatedDocumentBatch());
        Test.stopTest();
    }
}