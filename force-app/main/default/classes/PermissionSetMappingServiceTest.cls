@isTest
private class PermissionSetMappingServiceTest {

    @isTest
    static void getServiceCloudMappingTest() {
        Test.startTest();
        PermissionSetMappingService.getInstance().getServiceCloudMapping();
        Test.stopTest();
    }

    @isTest
    static void getAllPSMappingTest() {
        Test.startTest();
        PermissionSetMappingService.getInstance().getAllPSMapping();
        Test.stopTest();
    }

    @isTest
    static void getRemovablePSMappingTest() {
        Test.startTest();
        PermissionSetMappingService.getInstance().getRemovablePSMapping();
        Test.stopTest();
    }
}