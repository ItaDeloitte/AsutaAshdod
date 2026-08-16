@isTest
private class AutenticationTokenTest {

    @isTest
    static void methodTest() {
        Test.startTest();
        AutenticationToken.UsernameToken wrapper = new AutenticationToken.UsernameToken('username', 'password');
        Test.stopTest();
    }
}