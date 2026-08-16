@IsTest
private class LC_RecommendExamCaseTest {

    @TestSetup
    static void makeData() {
        Account patient = TestDataFactory.getAccountPerson();
        insert patient;
        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase('Assuta_360', doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        insert new Recommendations_after_exam__c(Patient__c = patient.Id, Case360__c = cas.Id);
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_RecommendExamCase().executeAction(new Map<String, Object>{
                'actionName' => 'exception'
            });
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void obtainCasesTest() {
        Recommendations_after_exam__c rae = [SELECT Id FROM Recommendations_after_exam__c LIMIT 1];

        Test.startTest();
        new LC_RecommendExamCase().executeAction(new Map<String, Object>{
            'actionName' => 'obtainCases',
            'recordId' => rae.Id,
            'keyWord' => ''
        });
        Test.stopTest();
    }

    @IsTest
    static void setCaseTest() {
        Recommendations_after_exam__c rae = [SELECT Id FROM Recommendations_after_exam__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        new LC_RecommendExamCase().executeAction(new Map<String, Object>{
            'actionName' => 'setCase',
            'recordId' => rae.Id,
            'caseId' => cas.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void setCaseBlankTest() {
        Recommendations_after_exam__c rae = [SELECT Id FROM Recommendations_after_exam__c LIMIT 1];

        Test.startTest();
        new LC_RecommendExamCase().executeAction(new Map<String, Object>{
            'actionName' => 'setCase',
            'recordId' => rae.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void getCaseTest() {
        Recommendations_after_exam__c rae = [SELECT Id FROM Recommendations_after_exam__c LIMIT 1];

        Test.startTest();
        new LC_RecommendExamCase().executeAction(new Map<String, Object>{
            'actionName' => 'getCase',
            'recordId' => rae.Id
        });
        Test.stopTest();
    }
}