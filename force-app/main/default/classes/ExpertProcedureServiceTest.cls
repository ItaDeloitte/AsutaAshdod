@IsTest
private class ExpertProcedureServiceTest {

    @IsTest
    static void getAllTest() {
        Test.startTest();
        ExpertProcedureService.getInstance().getAll();
        Test.stopTest();
    }

    @IsTest
    static void getAllPublicTest() {
        Test.startTest();
        ExpertProcedureService.getInstance().getAllPublic();
        Test.stopTest();
    }

    @IsTest
    static void getAllPrivateTest() {
        Test.startTest();
        ExpertProcedureService.getInstance().getAllPrivate();
        Test.stopTest();
    }

    @IsTest
    static void getPublicDefaultTest() {
        Test.startTest();
        ExpertProcedureService.getInstance().getPublicDefault();
        Test.stopTest();
    }

    @IsTest
    static void getPrivateDefaultTest() {
        Test.startTest();
        ExpertProcedureService.getInstance().getPrivateDefault();
        Test.stopTest();
    }
}