// Test for: LC_CaseAppointmentButtons
@isTest
public class LC_CaseAppointmentButtonsTest {

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
            .addCase('PublicInquiries')
            .addProcedure('procI', '70551')
            .addProcedure('procE', '99400')
            .addProcedure('procS', '70124')
            .addAppoitment(TestDataFactory.APPT_I_RT_NAME, 'procI', 'caseA')
            .addAppoitment(TestDataFactory.APPT_E_RT_NAME, 'procE', 'caseE')
            .addAppoitment(TestDataFactory.APPT_S_RT_NAME, 'procS', 'caseS');

        dBuilder.insertCommonData();
    }

    @isTest
    static void checkObject_Case_General_Info() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'General_Info'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_Assuta_360() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Assuta_360'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_DOC_expert() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'DOC_expert'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_Appointments() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Appointments'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_Surgery() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Surgery'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_CaseAfterSale() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'CaseAfterSale'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_transfer_to_secretaries() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'transfer_to_secretaries'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }
    
    @isTest
    static void checkObject_Case_PublicInquiries() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'PublicInquiries'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Appt_Institutes() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Institutes'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => appt.Id});
        Test.stopTest();
    }
    
    @isTest
    static void checkObject_Appt_Experts() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Experts'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => appt.Id});
        Test.stopTest();
    }
    
    @isTest
    static void checkObject_Appt_Surgeries() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE RecordType.DeveloperName = 'Surgeries'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => appt.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Oppt() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => oppt.Id});
        Test.stopTest();
    }

    @isTest
    static void checkObject_Recommendation_Memo() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Recommendations_after_exam__c recommendation = new Recommendations_after_exam__c(RecordTypeId = TestDataFactory.getRTId('Memo', 'Recommendations_after_exam__c'));
        insert recommendation;

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => recommendation.Id});
        Test.stopTest();
    }

    @isTest
    static void executeActionExceptionTest() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();

        Test.startTest();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void checkObject_Case_Home_Diagnosis() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Case cas = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Home_diagnosis'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => cas.Id});
        Test.stopTest();
    }
    
    @isTest
    static void IVFCaseModalLinkTest() {
        Case cas = new Case(RecordTypeId = TestDataFactory.getRTId('IVF_Freezing_Eggs', 'Case'));
        cas.email_from_patient__c = 'test@assuta.co.il';
        cas.Partner_Email__c = 'test@assuta.co.il';
        insert cas;

        Test.startTest();
        LC_CaseAppointmentButtons.sendIVFLink('female',cas.Id,'sms');
        LC_CaseAppointmentButtons.sendIVFLink('female',cas.Id,'email');
        LC_CaseAppointmentButtons.sendIVFLink('female',cas.Id,'both');
        LC_CaseAppointmentButtons.sendIVFLink('partner',cas.Id,'sms');
        LC_CaseAppointmentButtons.sendIVFLink('partner',cas.Id,'email');
        LC_CaseAppointmentButtons.sendIVFLink('partner',cas.Id,'both');
        LC_CaseAppointmentButtons.sendIVFLink('both',cas.Id,'sms');
        LC_CaseAppointmentButtons.sendIVFLink('both',cas.Id,'email');
        LC_CaseAppointmentButtons.sendIVFLink('both',cas.Id,'both');
        Test.stopTest();
    }
    
    @isTest
    static void checkObject_Acc_PersonAccount() {
        LC_CaseAppointmentButtons controller = new LC_CaseAppointmentButtons();
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'checkObject', 'recordId' => acc.Id});
        Test.stopTest();
    }
    
    
}