// Test for: OpportunityTriggerDispatcher
// Created: Ortal kazum
// Date: 01.02.2021
@isTest
public class OpportunityTriggerDispatcherTest {
    @testSetup
    static void setup() {
        Opportunity opp =  new Opportunity( );
    }
    
    @isTest
    static void fillFormtitanId() {
        Opportunity opp = TestDataFactory.getOpportunity();
        Test.startTest();
        insert opp;
       	Test.stopTest();
    }
}