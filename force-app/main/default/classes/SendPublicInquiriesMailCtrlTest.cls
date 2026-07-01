@isTest
public class SendPublicInquiriesMailCtrlTest {
    
    @testSetup
    static void setup() {
        Assuta_Employee__c ae1= TestDataFactory.getAssutaEmployee();
        ae1.Email__c = 'test1@assuta.co.il';
        Assuta_Employee__c ae2= TestDataFactory.getAssutaEmployee();
        ae2.Email__c = 'test2@assuta.co.il';
        insert new List<Assuta_Employee__c>{ae1, ae2};

        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PublicInquiries' LIMIT 1].Id;
        Case parentCase = new Case(RecordTypeId = rtId);
        insert parentCase;        
        Case childCase1 = new Case(ParentId = parentCase.Id, Responsible_Employee__c = ae1.Id, Treating_Employee__c = ae2.Id);
        Case childCase2 = new Case(ParentId = parentCase.Id, Responsible_Employee__c = ae2.Id, Treating_Employee__c = ae1.Id);
        insert new List<Case>{childCase1, childCase2};
            
        File__C file = TestDataFactory.getFile();
        file.Case__c = childCase1.Id;
	    insert file;
        ContentVersion contVers = TestDataFactory.getContentVersion();
        insert contVers;
        ContentDocumentLink contDocLink = TestDataFactory.getContentDocLink(file.Id);
        contDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contVers.Id LIMIT 1].ContentDocumentId;
        insert contDocLink;   
    }
    @isTest static void testFunction() {                
        Id parentCaseId = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'PublicInquiries' LIMIT 1].Id;   
        Id fileId = [SELECT Id FROM File__c LIMIT 1].Id;
        Test.startTest();
        List<SendPublicInquiriesMailCtrl.CaseWrapper> wList = SendPublicInquiriesMailCtrl.getChildCases(parentCaseId);
        for(SendPublicInquiriesMailCtrl.CaseWrapper cas_i :wList) {
            cas_i.fileIds.add(fileId);
        }
        String jsonStr = JSON.serialize(wList);        
        SendPublicInquiriesMailCtrl.sendEmail(jsonStr, parentCaseId);
        Test.stopTest();
    }
}