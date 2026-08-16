@isTest
private class ResponseTest {

    @isTest
    static void responseTest() {
        Test.startTest();
        GeneralResponse gres1 = new GeneralResponse(true, 'success');
        GeneralResponse gres2 = new GeneralResponse();
        
        Response res1 = new Response(true, 'success');
        Response res2 = new Response('success');
        Response res3 = new Response();
        try {
            insert new Account();
        } catch (Exception e) {
            Response res4 = new Response(e);
            GeneralResponse gres3 = new GeneralResponse(e);
        }
        Test.stopTest();
    }
}