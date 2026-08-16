@isTest
public class LC_CaseExpertiseTest {

    @TestSetup
    static void setup() { 
        Account acct = new Account(Name = 'test account1', ID_Number__c = '123456789', RoleCode__c = 15);
        insert acct;
        Case cas = new Case(AccountId = acct.Id, Case_subject__c = 'זימון רופא מומחה');
        insert cas;

        Expertise__c expertise = new Expertise__c(Name = 'expertise');
        insert expertise;
        Sub_Expertise__c subExpertise = new Sub_Expertise__c(Name = 'subExpertise', Expertise__c = expertise.Id);
        insert subExpertise;
        Medical_Procedure__c procedure = new Medical_Procedure__c(Name = 'procedure', Procedure_Code__c = 'Test', Sub_Expertise__c = subExpertise.Id);
        insert procedure;
    }

    @isTest
    static void getExpertisesTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getExpertises');
        params.put('expertiseName', 'exper');

        Test.startTest();
        LC_CaseExpertise controller = new LC_CaseExpertise();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void getSubExpertisesTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getSubExpertises');
        params.put('experiseId', [SELECT Id FROM Expertise__c LIMIT 1].Id);
        params.put('subExpertiseName', 'subEx');

        Test.startTest();
        LC_CaseExpertise controller = new LC_CaseExpertise();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void getProceduresTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getProcedures');
        params.put('subExperiseId', [SELECT Id FROM Sub_Expertise__c LIMIT 1].Id);
        params.put('procedureName', 'proced');

        Test.startTest();
        LC_CaseExpertise controller = new LC_CaseExpertise();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void setExpertisesTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'setExpertises');
        params.put('caseId', [SELECT Id FROM Case LIMIT 1].Id);
        params.put('experiseId', [SELECT Id FROM Expertise__c LIMIT 1].Id);
        params.put('subExperiseId', [SELECT Id FROM Sub_Expertise__c LIMIT 1].Id);
        params.put('procedureId', '');

        Test.startTest();
        LC_CaseExpertise controller = new LC_CaseExpertise();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'wrong action');

        Test.startTest();
        try {
            LC_CaseExpertise controller = new LC_CaseExpertise();
            Response res = controller.executeAction(params);
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong action', e.getMessage());
        }
        Test.stopTest();
    }
}