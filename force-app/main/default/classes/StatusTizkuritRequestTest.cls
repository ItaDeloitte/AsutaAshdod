@isTest
private class StatusTizkuritRequestTest {

    @isTest
    static void methodTest() {
        StatusTizkuritRequest cnt = new StatusTizkuritRequest();
        StatusTizkuritRequest.parse('{"methodName":"method name","Records":[{"AccessionNumber":"test","FollowUpTypeCode":"test"}]}');
    }
}