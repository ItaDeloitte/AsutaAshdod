// Test for: CampaignTriggerDispatcherTest
// Created: Ortal kazum
// Date: 01.02.2021
@isTest
public class CampaignTriggerDispatcherTest {
    @testSetup
    static void setup() {
      insert new Campaign( Name = 'TEST');
        
    }
    
    @isTest
    static void fillFormtitanId() {
        Test.startTest();
        insert new Campaign(Name = 'TEST');
       	Test.stopTest();
    }
}