@isTest
private with sharing class LC_FillAccountTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        dBuilder.oppt.AccountId = dBuilder.patient.Id;
        update dBuilder.oppt;

        dBuilder.insertCommonData();
    }

    @isTest
    static void exceptionTest() {
        LC_FillAccountController controller = new LC_FillAccountController();

        Test.startTest();
        try {
            controller.executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void isAccountFullTest() {
        LC_FillAccountController controller = new LC_FillAccountController();
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'isAccountFull', 'opptId' => oppt.Id});
        Test.stopTest();
    }

    @isTest
    static void getAccountTest() {
        LC_FillAccountController controller = new LC_FillAccountController();
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'getAccount', 'opptId' => oppt.Id});
        Test.stopTest();
    }

    @isTest
    static void setAccountTest() {
        LC_FillAccountController controller = new LC_FillAccountController();
        Opportunity oppt = [SELECT Id FROM Opportunity LIMIT 1];
        String acctDataJSON = JSON.serialize(
            new Map<String, Object>{
                'firstName' => 'firstName',
                'lastName' => 'lastName',
                'idNumber' => '123456789',
                'idType' => '8',
                'phone' => '0500000000',
                'gender' => 'ז',
                'mailingApproval' => 'מאשר דיוור - הכל',
                'insurerFactor' => '2',
                'otherHealthServices' => 'ללא',
                'birthDay' => Date.today().addYears(-1)
            }
        );

        Test.startTest();
        controller.executeAction(new Map<String, Object>{'actionName' => 'setAccount', 'opptId' => oppt.Id, 'accountData' => acctDataJSON});
        Test.stopTest();
    }
}