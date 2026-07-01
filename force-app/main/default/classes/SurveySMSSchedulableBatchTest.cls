@isTest
private class SurveySMSSchedulableBatchTest {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.getENV();
        Map<String, Schema.RecordTypeInfo> SurveyTakerRTMap = Schema.SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName();
        Id docAdvisorRTId = SurveyTakerRTMap.get('Doc_Advisor').getRecordTypeId();
        Id digiFormsRTId = SurveyTakerRTMap.get('Digital_Forms').getRecordTypeId();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Survey__c survey = new Survey__c();
        insert survey;
        SurveyTaker__c st = new SurveyTaker__c();
        st.RecordTypeId = digiFormsRTId;
        st.SendTime__c = null;
        st.IsSent__c =false;
        st.sms_send_time__c = System.DateTime.now();
        st.Account__c = patient.Id;
        st.Survey__c = survey.Id;
        insert st;

        SurveyTaker__c st2 = new SurveyTaker__c();
        st2.RecordTypeId = docAdvisorRTId;
        st2.SendTime__c = null;
        st2.IsSent__c =false;
        st2.sms_send_time__c = System.DateTime.now();
        st2.Account__c = patient.Id;
        st2.Survey__c = survey.Id;
        insert st2;

        SurveyTaker__c st3 = new SurveyTaker__c();
        st3.RecordTypeId = docAdvisorRTId;
        st3.SendTime__c = null;
        st3.IsSent__c =false;
        st3.sms_send_time__c = System.DateTime.now().addDays(-4);
        st3.Account__c = patient.Id;
        st3.Survey__c = survey.Id;
        insert st3;

        DocAdvisorSetting__c docAdvDaysOffset =new DocAdvisorSetting__c();
        docAdvDaysOffset.Days_From_Release__c =4;
        docAdvDaysOffset.Days_Reminder_Offset__c =4;
        insert docAdvDaysOffset;
    }

    @IsTest
    static void batchTest(){
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new SurveySMSSchedulableBatch(
                'SELECT Id'
                + ', Account__c'
                + ', Account__r.Phone'
                + ', Appointment__c '
                + ', Case__c'
                + ', survey_link__c '
                + ', RecordTypeid '
                + ', sms_send_time__c '
               + ' FROM SurveyTaker__c'
            )
        );

        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job SMS Survey', '20 30 8 10 2 ?', new SurveySMSSchedulableBatch());
        Test.stopTest();
    }
}