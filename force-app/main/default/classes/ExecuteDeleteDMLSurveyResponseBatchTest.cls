@IsTest
public class ExecuteDeleteDMLSurveyResponseBatchTest {

    @TestSetup
    static void makeData(){
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        Account doc = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert patient;
        insert doc;

        Survey__c survey = new Survey__c();
        survey.SurveyCode__c = 'DocAdvisor';
        insert survey;

        SurveyTaker__c st = new SurveyTaker__c(RecordTypeId=TestDataFactory.getRTId('Doc_Advisor','SurveyTaker__c'));
        st.SendTime__c = null;
        st.IsSent__c =false;
        st.sms_send_time__c = System.DateTime.now();
        st.Account__c = patient.Id;
        st.Doctor__c = doc.Id;
        st.Survey__c = survey.Id;
        st.IsProcessed__c = false;
        st.Status__c = 'active';
        st.Taken__c = 'true';
        insert st;

        List<Survey_Question__c> sqList = new List<Survey_Question__c>();
        Survey_Question__c sq1= new Survey_Question__c(Name='Courtesy',Survey__c =survey.Id,OrderNumber__c=1, Question__c='test', Type__c='StarRating');
        Survey_Question__c sq2= new Survey_Question__c(Name='Availability',Survey__c =survey.Id,OrderNumber__c=1, Question__c='test', Type__c='StarRating');
        Survey_Question__c sq3= new Survey_Question__c(Name='Professionalism',Survey__c =survey.Id,OrderNumber__c=1, Question__c='test', Type__c='StarRating');
        Survey_Question__c sq4= new Survey_Question__c(Name='General_impression',Survey__c =survey.Id,OrderNumber__c=1, Question__c='test', Type__c='StarRating');
        sqList.add(sq1);
        sqList.add(sq2);
        sqList.add(sq3);
        sqList.add(sq4);
        insert sqList;

        List<SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
        SurveyQuestionResponse__c sqr1 = new SurveyQuestionResponse__c(Rate__c=8,SurveyTaker__c=st.Id, Survey_Question__c=sq1.Id);
        SurveyQuestionResponse__c sqr2 = new SurveyQuestionResponse__c(Rate__c=6,SurveyTaker__c=st.Id, Survey_Question__c=sq2.Id);
        SurveyQuestionResponse__c sqr3 = new SurveyQuestionResponse__c(Rate__c=3,SurveyTaker__c=st.Id, Survey_Question__c=sq3.Id);
        SurveyQuestionResponse__c sqr4 = new SurveyQuestionResponse__c(Rate__c=1,SurveyTaker__c=st.Id, Survey_Question__c=sq4.Id);
        sqrList.add(sqr1);
        sqrList.add(sqr2);
        sqrList.add(sqr3);
        sqrList.add(sqr4);
        insert sqrList;
    }

    @isTest
    static void batchTest(){
        System.debug('batch test');
        List<SurveyQuestionResponse__c> surveyQuestionResponses = [SELECT Id,SurveyTaker__c,Survey_Question__c FROM SurveyQuestionResponse__c];
        Test.startTest();
        Database.executeBatch(
            new ExecuteDeleteDMLSurveyResponseBatch(surveyQuestionResponses)
        );
        Test.stopTest();
    }

}