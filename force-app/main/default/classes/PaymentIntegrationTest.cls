@isTest
private class PaymentIntegrationTest {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        City__c city = new City__c(Name='Ashdod',City_Code__c=12345);
        insert city;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
		procedure.Reminder_required__c = true;
        procedure.SMS_Reminder__c = '0';
        insert procedure;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor('333');
        pFactorParent.Insurance_Company__c = true;
        insert pFactorParent;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = pFactorParent.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;
        Payer_Factor__c pFactorChild = TestDataFactory.getPFactor('333');
        pFactorChild.Name_of_parent__c = pFactor.Id;
        insert pFactorChild;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Case cas = TestDataFactory.getCase(patient.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.PayerFactor__c = pFactorChild.Id;
        appt.Accession_Number__c = '234567';
        appt.Doctor_Account__c = doctor.Id;
        appt.Name = 'Appointment app1234';
        appt.Site__c = site.Id;
        insert appt;
    }

    @isTest
    static void getIframeDataTest(){
        Test.setMock(HttpCalloutMock.class, new GetIFrame_Mock());
        Test.startTest();
        PaymentIntegration.getIframeData();
        Test.stopTest();
    }

    @isTest
    static void inquireTransactionTest(){
        Test.setMock(HttpCalloutMock.class, new InquireTransaction_Mock());
        Test.startTest();
        PaymentIntegration.inquireTransaction('dasda');
        Test.stopTest();
    }

    @isTest
    static void getAllowedPaymentsTest(){
        Test.startTest();
        PaymentIntegration.getAllowedPayments();
        Test.stopTest();
    }

    @isTest
    static void sendGenericPaymentTest(){
        Appointment__c appt = [SELECT Id,Patient_Account__c FROM Appointment__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new sendGenericPayment_Mock());
        Test.startTest();
        PaymentIntegration.sendGenericPayment(appt.Id, '1321425861235', '1', '1', 'homeless av 5', 'takeMyMoney', 'test@mail.com', '1', '052022', appt.Patient_Account__c, 'Ashdod', 'charge','Experts');
        Test.stopTest();
    }
    
     @isTest
    static void sendGenericPaymentFailTest(){
        Appointment__c appt = [SELECT Id,Patient_Account__c FROM Appointment__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new sendGenericPaymentFail_Mock());
        Test.startTest();
        PaymentIntegration.sendGenericPayment(appt.Id, '1321425861235', '1', '1', 'homeless av 5', 'takeMyMoney', 'test@mail.com', '1', '052022', appt.Patient_Account__c, 'Ashdod', 'charge','Experts');
        Test.stopTest();
    }

    private class GetIFrame_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('<?xml version=\'1.0\'?><ashrait><response><command>doDeal</command><dateTime>2021-06-21 17:20</dateTime><requestId/><tranId>62739941</tranId><result>000</result><message>Permitted transaction</message><userMessage>Permitted transaction</userMessage><additionalInfo/><version>2000</version><language>Eng</language><doDeal><status>000</status><statusText>Permitted transaction</statusText><extendedStatus/><extendedStatusText/><extendedUserMessage/><terminalNumber>0882810010</terminalNumber><cardBin>CG</cardBin><cardMask>CGMPI</cardMask><cardLength>5</cardLength><cardNo>CGMPI</cardNo><cardName/><cardExpiration/><cardType code=""/><extendedCardType code="0">Credit</extendedCardType><blockedCard/><lifeStyle/><customCardType/><creditCompany code=""/><cardBrand code=""/><cardAcquirer code=""/><serviceCode/><transactionType code="01">RegularDebit</transactionType><creditType code="1">RegularCredit</creditType><currency code="1">ILS</currency><baseCurrency/><baseAmount/><transactionCode code="50">Phone</transactionCode><total>1</total><firstPayment/><periodicalPayment/><numberOfPayments/><paymentsInterest/><mid>11713</mid><uniqueid>626ec0df-171e-4f5f-a61a-69a27af71558</uniqueid><mpiValidation>AutoComm</mpiValidation><token>1edf8bf3-f312-4186-96ad-51366e505efb</token><mpiHostedPageUrl>https://cgmpiuat.creditguard.co.il/CGMPI_Server/PerformTransaction?txId=1edf8bf3-f312-4186-96ad-51366e505efb</mpiHostedPageUrl><returnUrl/><successUrl/><errorUrl/><cancelUrl/><clubId/><validation code="106">TxnSetup</validation><idStatus code=""/><cvvStatus code=""/><authSource code="6">MPIServer</authSource><authNumber/><fileNumber/><slaveTerminalNumber/><slaveTerminalSequence/><eci/><clientIp/><email>test@creditguard.co.il</email><cavv code=""/><user>matrixemv</user><addonData/><supplierNumber/><id/><shiftId1/><shiftId2/><shiftId3/><shiftTxnDate/><cgUid>62739941</cgUid><cardHash/></doDeal></response></ashrait>'
            );
            response.setStatusCode(200);
            return response;
        }
    }

    private class InquireTransaction_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('<?xml version=\'1.0\' encoding=\'ISO-8859-8\'?><ashrait><response><command>inquireTransactions</command><dateTime>2021-07-04 14:13</dateTime><requestId/><tranId>62927441</tranId><result>000</result><message>עסקה תקינה</message><userMessage>עסקה תקינה</userMessage><additionalInfo/><version>2000</version><language>Heb</language><inquireTransactions><row><mpiTransactionId>fea459ac-c42c-47e9-a3a1-df239682a14d</mpiTransactionId><uniqueid>1f6634e2-a9d4-83e9-6ebf-637dfdaabddd</uniqueid><amount>1</amount><currency>ILS</currency><authNumber/><cardId>1031006201420575</cardId><languageCode>HE</languageCode><statusCode>0</statusCode><statusText>SUCCEEDED</statusText><errorCode>00</errorCode><errorText>הצלחה</errorText><cgGatewayResponseCode>000</cgGatewayResponseCode><cgGatewayResponseText>עסקה תקינה</cgGatewayResponseText><cgGatewayResponseXML><ashrait><response><command>doDeal</command><dateTime>2021-07-04 14:12</dateTime><requestId/><tranId>62927429</tranId><result>000</result><message>עסקה תקינה</message><userMessage>עסקה תקינה</userMessage><additionalInfo>Host Result Local 00-SUCCESS </additionalInfo><version>2000</version><language>Heb</language><doDeal><status>000</status><statusText>עסקה תקינה</statusText><extendedStatus/><extendedStatusText/><extendedUserMessage/><terminalNumber>0882812014</terminalNumber><cardId>1031006201420575</cardId><cardBin>532610</cardBin><cardMask>532610******0575</cardMask><cardLength>16</cardLength><cardNo>xxxxxxxxxxxx0575</cardNo><cardName>יורוקרד מסטרקרד</cardName><cardExpiration>0322</cardExpiration><cardType code="00">Local</cardType><extendedCardType code="0">Credit</extendedCardType><blockedCard/><lifeStyle/><customCardType/><creditCompany code="1">Isracard</creditCompany><cardBrand code="1">Mastercard</cardBrand><cardAcquirer code="1">Isracard</cardAcquirer><serviceCode/><transactionType code="01">RegularDebit</transactionType><creditType code="1">RegularCredit</creditType><currency code="1">ILS</currency><baseCurrency/><baseAmount/><transactionCode code="50">Phone</transactionCode><total>1</total><firstPayment/><periodicalPayment/><numberOfPayments>0</numberOfPayments><clubId/><validation code="4">AutoComm</validation><idStatus code=""/><cvvStatus code=""/><authSource code=""/><authNumber/><fileNumber>91</fileNumber><slaveTerminalNumber>014</slaveTerminalNumber><slaveTerminalSequence>104</slaveTerminalSequence><eci/><clientIp>172.16.100.81</clientIp><email>test@creditguard.co.il</email><cavv code=""/><user>matrixemv</user><addonData/><supplierNumber>71506</supplierNumber><id>890108558</id><shiftId1/><shiftId2/><shiftId3/><shiftTxnDate/><cgUid>62927422</cgUid><cardHash/><acquirerData><gateway>AshraitEmv</gateway><acquirerTranType>01</acquirerTranType><acquirerTranCode>50</acquirerTranCode></acquirerData><ashraitEmvData><uid>21070414124408828124296</uid><idFlag>1</idFlag><manufId>CGD</manufId><catLevel>0</catLevel><cvvFlag>1</cvvFlag><manufUse>001101</manufUse><ashVersion>x</ashVersion><ashTermType>0</ashTermType><deviceStatus>1111000000</deviceStatus><isDoReverseDeal>0</isDoReverseDeal></ashraitEmvData></doDeal></response></ashrait></cgGatewayResponseXML><queryErrorText>הצלחה</queryErrorText><xRem>matrixemv</xRem><personalId>890108558</personalId><cardExpiration>0322</cardExpiration></row><totals><pageNumber/><pagesAmount/><queryResultId/><total/><totalMatch/></totals></inquireTransactions></response></ashrait>'
            );
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class sendGenericPayment_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Guid":"067370c3-853f-4381-8d64-d5f4650ee21f","ResultStatus":"0","Receipts":[{"ReceiptNo":"201005907"}],"metadata":{"published_date":"2021-08-10 14:08:16","publisher":"TAFNIT"}}'
            );
            response.setStatusCode(200);
            return response;
        }
    }
    
      private class sendGenericPaymentFail_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Guid": "1234","ResultStatus": "1","Receipts": [],"metadata": {"published_date": "","publisher": "","module": ""},"ErrCodes": [{"Tag": "json/Email","ErrorCode": "10861","Message": "שגיאה בבדיקת כתובת מייל"}]}'
            );
            response.setStatusCode(200);
            return response;
        }
    }
    
}