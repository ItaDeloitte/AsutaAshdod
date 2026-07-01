@IsTest
public with sharing class LC_CampaignSelectionTest {

    public static final String CAMPAIGN_NAME = 'testCampaign';

    @TestSetup 
    static void makeData() {
        Lead lead1 = TestDataFactory.getLead();
        insert lead1;

        Campaign cam = new Campaign(Name = CAMPAIGN_NAME, DoctorSurvey__c = true);
        cam.Status = 'Active';
        insert cam;
    }

    @IsTest 
    static void initTest() {
        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LC_CampaignSelectionController controller = new LC_CampaignSelectionController();
        Response res = controller.executeAction(
            new Map<String, Object>{
                'actionName' => 'init',
                'recordId' => lead1.Id}
        );
        Test.stopTest();
        System.assert(res.isSuccess);
    }
    
    @IsTest 
    static void searchCampaignTest() {
        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];
        Campaign cam = [SELECT Id, Name FROM Campaign WHERE Name = :CAMPAIGN_NAME];

        Test.startTest();
        LC_CampaignSelectionController controller = new LC_CampaignSelectionController();
        Response res = controller.executeAction(
            new Map<String, Object>{
                'actionName' => 'searchCampaign',
                'recordId' => lead1.Id,
                'keyword' => cam.Name}
        );
        Test.stopTest();
        System.assert(res.isSuccess);
    }

    @IsTest 
    static void assignCampaignTest() {
        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];
        Campaign cam = [SELECT Id, Name FROM Campaign WHERE Name = :CAMPAIGN_NAME];

        Test.startTest();
        LC_CampaignSelectionController controller = new LC_CampaignSelectionController();
        Response res = controller.executeAction(
            new Map<String, Object>{
                'actionName' => 'assignCampaign',
                'recordId' => lead1.Id,
                'campaignId' => cam.Id}
        );
        Test.stopTest();
        System.assert(res.isSuccess);
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_CampaignSelectionController controller = new LC_CampaignSelectionController();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'ex'});
            System.assert(false);
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION ex', e.getMessage());
        }
        Test.stopTest();
    }
}