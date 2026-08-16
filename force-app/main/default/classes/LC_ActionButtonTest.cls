/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Custom Buttons component Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             27-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class LC_ActionButtonTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder =  TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        Case caseGI = dBuilder.createCase('General_Info');
        caseGI.Case_subject__c = 'מועמד ל-360';

        Case case360 = dBuilder.createCase('Assuta_360');
        case360.Surgeon_Doctor__c = dBuilder.doctor.Id;
        case360.AccountId = dBuilder.patient.Id;

        Case caseS = dBuilder.createCase('caseS', 'Surgery');
        caseS.AccountId = dBuilder.patient.Id;

        dBuilder
            .addCase('caseE', 'DOC_expert')
            .addCase('caseA', 'Appointments')
            .addCase('CaseAfterSale')
            .addCase('transfer_to_secretaries')
            .addCase('Home_diagnosis')
            .addCase('Home_Hospitalization')
            .addCase('PublicInquiries')
            .addCase('YadBeYad_Breast')
            .addProcedure('procI', '70551')
            .addProcedure('procE', '99400')
            .addProcedure('procS', '70124')
            .addAppoitment('apptI', TestDataFactory.APPT_I_RT_NAME, 'procI', 'caseA')
            .addAppoitment('apptE', TestDataFactory.APPT_E_RT_NAME, 'procE', 'caseE')
            .addAppoitment('apptS', TestDataFactory.APPT_S_RT_NAME, 'procS', 'caseS');

        dBuilder.insertCommonData();

        insert new Recommendations_after_exam__c(RecordTypeId = TestDataFactory.getRTId('Memo', 'Recommendations_after_exam__c'));
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_ActionButtonController().executeAction(new Map<String, Object>{
                'actionName' => 'exception'
            });
        } catch (Exception e) {
            System.assertEquals(LC_ActionButtonUtil.ERR_UNKNOWN_ACTION, e.getMessage());
        }
        Test.stopTest();
    }

    /** Account */
    @IsTest
    static void obtainButtons_Acct_PersonAccount_Test() {
        Account acct = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => acct.Id});
        Test.stopTest();
    }

    /** Case */
    @IsTest
    static void obtainButtons_Case_Appointments_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Appointments'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_Assuta360_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Assuta_360'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void obtainButtons_Case_Yadbeyad_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'YadBeYad_Breast'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }


    @IsTest
    static void obtainButtons_Case_CaseAfterSale_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'CaseAfterSale'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_DOCExpert_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'DOC_expert'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_GeneralInfo_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'General_Info'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_HomeDiagnosis_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Home_diagnosis'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_HomeHospitalization_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Home_Hospitalization'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_PublicInquiries_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'PublicInquiries'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Case_Surgery_Test() {
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Surgery'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => cas.Id});
        Test.stopTest();
    }

    /** Opportunity */
    @IsTest
    static void obtainButtons_Oppt_Test() {
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => oppt.Id});
        Test.stopTest();
    }

    /** Appointment__c */
    @IsTest
    static void obtainButtons_Appt_Experts_Test() {
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Experts'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => appt.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Appt_Institutes_Test() {
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Institutes'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => appt.Id});
        Test.stopTest();
    }

    @IsTest
    static void obtainButtons_Appt_Surgeries_Test() {
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Surgeries'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => appt.Id});
        Test.stopTest();
    }

    /** Recommendations_after_exam__c */
    @IsTest
    static void obtainButtons_Recomm_Memo_Test() {
        Recommendations_after_exam__c recomm = [SELECT Id FROM Recommendations_after_exam__c WHERE RecordType.DeveloperName = 'Memo'];

        Test.startTest();
        new LC_ActionButtonController().executeAction(new Map<String, Object>{'actionName' => 'obtainButtons', 'recordId' => recomm.Id});
        Test.stopTest();
    }
}