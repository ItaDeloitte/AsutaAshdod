@isTest
public class GuidanceScenarioTriggerTest {

    @testSetup
    static void setup() {
        Payer_Factor__c ppFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        ppFactor.Insurance_Company__c = true;
        insert ppFactor;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('3');
        pFactor.Name_of_parent__c = ppFactor.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c ultrasound = new Medical_Procedure__c(Procedure_Code__c = '760904');
        insert ultrasound;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '3';
        procedure.SMS_Reminder__c = '1';
        procedure.Humen__c = '3';
        insert procedure;
        Guidelines__c guidline = TestDataFactory.getGuidelines();       
        insert guidline;
        Guidance_Scenario__c guidlineScenario2 = new Guidance_Scenario__c(Medical_Procedure__c = procedure.Id, Payer_Factor__c = '3', Guideline1__c = guidline.Id, Iodine_Sensitive__c = false, Blood_Dilution__c = false, 
                                                                            MetalsInBody__c = false, diabetes__c = false, Status__c = 'active');
        insert guidlineScenario2;
    }



    @isTest
    static void createGuidlineScenario() {
        Medical_Procedure__c mp = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '760904' LIMIT 1];
        Guidelines__c guidline = [SELECT Id FROM Guidelines__c LIMIT 1];
        Guidance_Scenario__c guidlineScenario1 = new Guidance_Scenario__c(Medical_Procedure__c = mp.Id, Payer_Factor__c = '3', Guideline1__c = guidline.Id, Asthma__c = true, Iodine_Sensitive__c = false, 
                                                                        Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false, Status__c = 'active');
        Test.startTest();
            insert guidlineScenario1;
            guidlineScenario1.MetalsInBody__c = true;
            update guidlineScenario1;
        Test.stopTest();
        List<Guidance_Scenario__c> guidSList = [SELECT Id FROM Guidance_Scenario__c];
        System.assertEquals(2, guidSList.size());
    }

    @isTest
    static void createGuidScenarioError() {
        Medical_Procedure__c mp = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '760904' LIMIT 1];
        Guidelines__c guidline = [SELECT Id FROM Guidelines__c LIMIT 1];
        Guidance_Scenario__c guidlineScenario1 = new Guidance_Scenario__c(Medical_Procedure__c = mp.Id, Guideline1__c = guidline.Id, Payer_Factor__c = '3', Asthma__c = true, Iodine_Sensitive__c = false, 
                                                                        Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false, Status__c = 'active');
        Guidance_Scenario__c guidlineScenario2 = new Guidance_Scenario__c(Medical_Procedure__c = mp.Id, Payer_Factor__c = '3', Guideline1__c = guidline.Id, 
                                                                        Iodine_Sensitive__c = false, Blood_Dilution__c = false, MetalsInBody__c = false, diabetes__c = false, Status__c = 'active');
        Guidance_Scenario__c guidlineScenario3 = new Guidance_Scenario__c(Medical_Procedure__c = mp.Id, Payer_Factor__c = '555', Guideline1__c = guidline.Id, Iodine_Sensitive__c = false, Blood_Dilution__c = false, 
                                                                        MetalsInBody__c = false, diabetes__c = false, Status__c = 'active');
        Test.startTest();
            try{
                insert guidlineScenario1;
                insert guidlineScenario2;
                insert guidlineScenario3;
            } catch (Exception e) {
                System.debug('Error: '+e);
            }

        Test.stopTest();
        List<Guidance_Scenario__c> guidSList = [SELECT Id FROM Guidance_Scenario__c];
        System.assertEquals(3, guidSList.size());
    }

}