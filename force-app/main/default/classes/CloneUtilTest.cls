// Test for: CloneUtil
@isTest
private class CloneUtilTest {

    @testSetup
    public static void setup() {
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
    }

    @isTest
    public static void getCloneTest() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        CloneUtil.CloneWrapper wrapper = CloneUtil.getClone('Account', 'Id =: acct.Id');
    }
}