/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Case 'Link To Case' quick action Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class LC_LinkToCaseTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        Case casePE1 = dBuilder.createCase('casePE1', 'PublicInquiries');
        casePE1.AccountId = dBuilder.patient.Id;
        Case casePE2 = dBuilder.createCase('casePE2', 'PublicInquiries');
        casePE2.AccountId = dBuilder.patient.Id;
        TestDataFactory.CommonData cData = dBuilder.insertCommonData();
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_LinkToCaseController().executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void obtainCasesTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];

        Test.startTest();
        new LC_LinkToCaseController().executeAction(new Map<String, Object>{
            'actionName' => 'obtainCases',
            'caseId' => cas.Id,
            'patientId' => patient.Id
        });
        Test.stopTest();
    }

    @IsTest
    static void submitTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Case selectedCase = [SELECT Id FROM Case WHERE Id != :cas.Id LIMIT 1];

        Test.startTest();
        new LC_LinkToCaseController().executeAction(new Map<String, Object>{
            'actionName' => 'submit',
            'caseId' => cas.Id,
            'selectedCaseId' => selectedCase.Id
        });
        Test.stopTest();
    }
}