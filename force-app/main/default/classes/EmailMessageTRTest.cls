@isTest
private with sharing class EmailMessageTRTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        dBuilder.addCase('Appointments');
        dBuilder.insertCommonData();
    }

    @isTest
    static void validateTemplateMergeFieldErrorTest() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        try {
            insert new EmailMessage(
                ParentId = cas.Id,
                AccountId__c = patient.Id,
                EmailTemplateId = template.Id,
                FromName = 'No-Reply-Assuta',
                ToAddress = 'someone@assuta.co.il',
                TemplateMergeField__c = 'Survey_Taker__c',
                ExpectedSendingDateTime__c = System.now()
            );
        } catch (DmlException e) {
            System.assertEquals(Label.EmailMessage_TR_validateTemplateMergeField_Error, e.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest
    static void fillSubjectAndBodyFromTemplateTest() {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        insert new EmailMessage(
            ParentId = cas.Id,
            AccountId__c = patient.Id,
            EmailTemplateId = template.Id,
            FromName = 'No-Reply-Assuta',
            ToAddress = 'someone@assuta.co.il',
            FromAddress = 'nonreply@assuta.co.il',
            TemplateMergeField__c = 'AccountId__c',
            ExpectedSendingDateTime__c = System.now()
        );
        Test.stopTest();
    }
}