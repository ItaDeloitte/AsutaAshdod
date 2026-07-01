@IsTest
public class GuidlinesWrapperTest {

    @TestSetup
    static void makeData() {
        Guidelines__c g1 = new Guidelines__c(Guideline_Type__c ='A');
        Guidelines__c g2 = new Guidelines__c(Guideline_Type__c ='M');
        Guidelines__c g3 = new Guidelines__c(Guideline_Type__c ='A');

        insert new List<Guidelines__c>{g1, g2, g3};

        insert new Guidance_Scenario__c(Age_Range__c = '0-1', Guideline1__c = g1.Id, Guideline2__c = g2.Id, Guideline3__c = g3.Id);
    }
    
    @IsTest
    static void test() {
        Guidance_Scenario__c scenario = [
            SELECT Asthma__c
                 , Gender__c
                 , Protocol__c
                 , Diabetes__c
                 , Age_Range__c
                 , Payer_Factor__c
                 , MetalsInBody__c
                 , Blood_Dilution__c
                 , Iodine_Sensitive__c
                 , Medical_Procedure__c
                 , Site__r.Site_Code__c
                 , Guideline1__r.Guideline_Desc__c
                 , Guideline1__r.Guideline_Type__c
                 , Guideline2__r.Guideline_Desc__c
                 , Guideline2__r.Guideline_Type__c
                 , Guideline3__r.Guideline_Desc__c
                 , Guideline3__r.Guideline_Type__c
                 , Guideline4__r.Guideline_Desc__c
                 , Guideline4__r.Guideline_Type__c
                 , Guideline5__r.Guideline_Desc__c
                 , Guideline5__r.Guideline_Type__c
                 , Guideline6__r.Guideline_Desc__c
                 , Guideline6__r.Guideline_Type__c
                 , Guideline7__r.Guideline_Desc__c
                 , Guideline7__r.Guideline_Type__c
                 , Guideline8__r.Guideline_Desc__c
                 , Guideline8__r.Guideline_Type__c
                 , Guideline9__r.Guideline_Desc__c
                 , Guideline9__r.Guideline_Type__c
                 , Guideline10__r.Guideline_Desc__c
                 , Guideline10__r.Guideline_Type__c
                 , Guideline11__r.Guideline_Desc__c
                 , Guideline11__r.Guideline_Type__c
                 , Guideline12__r.Guideline_Desc__c
                 , Guideline12__r.Guideline_Type__c
                 , Guideline13__r.Guideline_Desc__c
                 , Guideline13__r.Guideline_Type__c
                 , Guideline14__r.Guideline_Desc__c
                 , Guideline14__r.Guideline_Type__c
                 , Guideline15__r.Guideline_Desc__c
                 , Guideline15__r.Guideline_Type__c
                 , Guideline16__r.Guideline_Desc__c
                 , Guideline16__r.Guideline_Type__c
                 , Guideline17__r.Guideline_Desc__c
                 , Guideline17__r.Guideline_Type__c
                 , Guideline18__r.Guideline_Desc__c
                 , Guideline18__r.Guideline_Type__c
                 , Guideline19__r.Guideline_Desc__c
                 , Guideline19__r.Guideline_Type__c
                 , Guideline20__r.Guideline_Desc__c
                 , Guideline20__r.Guideline_Type__c
                 , Guideline21__r.Guideline_Desc__c
                 , Guideline21__r.Guideline_Type__c
                 , Guideline22__r.Guideline_Desc__c
                 , Guideline22__r.Guideline_Type__c
                 , Guideline23__r.Guideline_Desc__c
                 , Guideline23__r.Guideline_Type__c
                 , Guideline1_Sort_Order__c
                 , Guideline2_Sort_Order__c
                 , Guideline3_Sort_Order__c
                 , Guideline4_Sort_Order__c
                 , Guideline5_Sort_Order__c
                 , Guideline6_Sort_Order__c
                 , Guideline7_Sort_Order__c
                 , Guideline8_Sort_Order__c
                 , Guideline9_Sort_Order__c
                 , Guideline10_Sort_Order__c
                 , Guideline11_Sort_Order__c
                 , Guideline12_Sort_Order__c
                 , Guideline13_Sort_Order__c
                 , Guideline14_Sort_Order__c
                 , Guideline15_Sort_Order__c
                 , Guideline16_Sort_Order__c
                 , Guideline17_Sort_Order__c
                 , Guideline18_Sort_Order__c
                 , Guideline19_Sort_Order__c
                 , Guideline20_Sort_Order__c
                 , Guideline21_Sort_Order__c
                 , Guideline22_Sort_Order__c
                 , Guideline23_Sort_Order__c
              FROM Guidance_Scenario__c
             LIMIT 1];

        Test.startTest();
        GuidlinesWrapper.ScenarioWrp scenarioWrp = new GuidlinesWrapper.ScenarioWrp(scenario);
        scenarioWrp.getGuidelineMessage();
        Test.stopTest();
    }
}