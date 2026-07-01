@isTest
global class ws_getPrices_REST_Mock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');     
        response.setBody('{"Guid":"6436434666363","ActivityCode":"70450","Site":"20","EmpNoType":"3","EmpNo":"777","ClientNo":"0","AgreeYesNo":"Y","BuyAgree":"N","SurgeryAgreeSale":{"O_SURGDATA":{"Site":"0","EmpNoType":"3","EmpNo":"777","ClientNo":"0","ActivityCode":"70450","SalaryFlag":"N","AgreeNo":"1","NetPrice":1612.82,"PriceIncludeVat":"1887","Coin":"NIS"}},"ResultStatus":"","ErrCodes":[],}');
        response.setStatusCode(200);
        return response;
    }
}