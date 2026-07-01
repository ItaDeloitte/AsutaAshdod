@isTest(seeAllData=true)
private class MedicalProcedurePlanServiceTest {

    @isTest
    static void testMatchingMetadata() {
        // Arrange
        MedicalProcedurePlanService.MedicalPlanRequest req = 
            new MedicalProcedurePlanService.MedicalPlanRequest();
        req.siteCode = 'TEST_SITE';
        req.procedureCode1 = 'PROC1';

        List<MedicalProcedurePlanService.MedicalPlanRequest> requests = new List<MedicalProcedurePlanService.MedicalPlanRequest>();
        requests.add(req);

        // Act
        Test.startTest();
        List<MedicalProcedurePlanService.MedicalPlanResponse> res =
            MedicalProcedurePlanService.getMedicalPlanSettings(requests);
        Test.stopTest();

        // Assert
        System.assertEquals(1, res.size());
        System.assertEquals('PROC1', res[0].procedureCode);
        System.assertEquals('TEST_SITE', res[0].siteCode);
      
        System.assertNotEquals(null, res[0].found);
        System.assertNotEquals(null, res[0].sendMessage);
    }

    @isTest
    static void testNoMatchingMetadata() {
        // Arrange
        MedicalProcedurePlanService.MedicalPlanRequest req = 
            new MedicalProcedurePlanService.MedicalPlanRequest();
        req.siteCode = 'NO_MATCH_SITE';
        req.procedureCode1 = 'NO_MATCH_PROC';

        List<MedicalProcedurePlanService.MedicalPlanRequest> requests = new List<MedicalProcedurePlanService.MedicalPlanRequest>{ req };

        // Act
        List<MedicalProcedurePlanService.MedicalPlanResponse> res =
            MedicalProcedurePlanService.getMedicalPlanSettings(requests);

        // Assert
        System.assertEquals(1, res.size());
        System.assertEquals(false, res[0].found);
        System.assertEquals(false, res[0].sendMessage);
        System.assertEquals('NO_MATCH_PROC', res[0].procedureCode);
    }

    @isTest
    static void testEarlyReturnWhenBothNull() {
        // Arrange
        MedicalProcedurePlanService.MedicalPlanRequest req = 
            new MedicalProcedurePlanService.MedicalPlanRequest();
        req.siteCode = 'ANY_SITE';
        req.procedureCode1 = null;
        req.procedureCode2 = null;

        List<MedicalProcedurePlanService.MedicalPlanRequest> requests = new List<MedicalProcedurePlanService.MedicalPlanRequest>{ req };

        // Act
        List<MedicalProcedurePlanService.MedicalPlanResponse> res =
            MedicalProcedurePlanService.getMedicalPlanSettings(requests);

        // Assert - בגלל ה-return המוקדם בלולאה
        System.assertEquals(0, res.size());
    }

    @isTest
    static void testFlowMethodWrapper() {
        MedicalProcedurePlanService.MedicalPlanRequest req =
            new MedicalProcedurePlanService.MedicalPlanRequest();
        req.siteCode = 'TEST_SITE';
        req.procedureCode2 = 'PROC2';

        List<MedicalProcedurePlanService.MedicalPlanRequest> requests =
            new List<MedicalProcedurePlanService.MedicalPlanRequest>{ req };

        Test.startTest();
        List<MedicalProcedurePlanService.MedicalPlanResponse> res =
            MedicalProcedurePlanService.getMedicalPlanFLOW(requests);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
    }
}