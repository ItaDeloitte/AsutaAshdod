@IsTest
public class EmailSendingScheduleBatchTest {
    
    @TestSetup
    static void makeData(){
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;
        Account patient = TestDataFactory.getAccountPerson();
        insert patient;

        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c ppFactor = TestDataFactory.getPFactor();
        ppFactor.Insurance_Company__c = true;
        insert ppFactor;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = ppFactor.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;

        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;

        EmailTemplate template = [SELECT DeveloperName FROM EmailTemplate LIMIT 1];

        EmailMessage emailMessage = new EmailMessage(
            ExpectedSendingDateTime__c = Datetime.now().addMinutes(-1),
            EmailTemplateDeveloperName__c = template.DeveloperName,
            FromAddress = 'test@mail.com',
            ToAddress = 'test@mail.com',
            FromName = 'FromName',
            ParentId = cas.Id,
            Status = '0'
        );
        insert emailMessage;
        
        ContentVersion contVers = TestDataFactory.getContentVersion();
        insert contVers;
        ContentDocumentLink contDocLink = TestDataFactory.getContentDocLink(emailMessage.Id);
        contDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contVers.Id LIMIT 1].ContentDocumentId;
        insert contDocLink;  
    }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new EmailSendingScheduleBatch());
        Test.stopTest();
        EmailMessage emailMessage = [SELECT Id, Status, ActualSendingDateTime__c FROM EmailMessage LIMIT 1];
        System.assert(emailMessage.ActualSendingDateTime__c != null);
    }
}