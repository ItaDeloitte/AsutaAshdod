// Test: PaymentIntegrationTest
public with sharing class PaymentIntegration {
    
    public PaymentIntegration() {}

    private static ENV__c env = ENV__c.getInstance();
    private static Credit_Guard_Env_Variables__mdt cgev = [SELECT Id, Username__c, Mid__c,Terminal_Number__c FROM Credit_Guard_Env_Variables__mdt WHERE Label =:env.Env_value__c LIMIT 1];

    @AuraEnabled(cacheable=false)
    public static Map<String,String> getIframeData () {
        System.debug('PaymentIntegration.getIframeData');
        return PaymentIntegration.getIframeDataHandler ();
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> inquireTransaction(String token) {
        System.debug('PaymentIntegration.inquireTransaction');
        return PaymentIntegration.inquireTransactionHandler(token);
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> sendGenericPayment(String SFId, String token, String creditCardTypeCode, String amountOfPayments, String address, String remark, String email, String payAmount, String cardExpDate, String accId, String city, String payType,String appointmentType) {
        System.debug('PaymentIntegration.sendGenericPayment');
        System.debug(SFId + ' ' +token + ' '+ creditCardTypeCode + ' ' + amountOfPayments + ' ' + address + ' ' + remark + ' ' + email + ' ' + payAmount + ' ' + cardExpDate + ' ' + accId);
        return PaymentIntegration.sendGenericPaymentHandler(SFId, token, creditCardTypeCode, amountOfPayments, address, remark, email, payAmount, cardExpDate, accId, city, payType,appointmentType);
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getAllowedPayments(){
        System.debug('PaymentIntegration.getAllowedPayments'); // get number of allowed payments from metadata setting
        Map<String,Object> paymentsAmountMap = new Map<String,Object>();
        for(Number_Of_Payments__mdt metadata :[SELECT Amount_Of_Payments_Allowed__c
                                                    , From_Payment_Amount__c
                                                    , To_Payment_Amount__c
                                                FROM Number_Of_Payments__mdt]) {
            System.debug(metadata); 
            paymentsAmountMap.put(String.valueOf(metadata.From_Payment_Amount__c),metadata.Amount_Of_Payments_Allowed__c);
        }
        return paymentsAmountMap; // default payments value;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getClubMember(Id appId) {
        System.debug('PaymentIntegration.getClubMember'); 
        Map<String,Object> paymentFields = new   Map<String,Object>();
        Appointment__c app = [SELECT PayerFactor__r.RelevantForDiscount__c
                                    , Patient_Account__r.Mailing_approval__c
                                    , Patient_Account__r.Email_Approval_Date__c
                                    , Medical_Procedure__r.MedicalProcedurePrice__c
                                    , Medical_Procedure__r.Price_After_Discount__c
                                    , Medical_Procedure__r.Note_for_Discount__c
                                    , Medical_Procedure__r.Discount_Start_Date__c
                                    , Medical_Procedure__r.Discount_End_Date__c
                                FROM Appointment__c
                                WHERE Id = :appId];
        if(app != null) {
            if (app.Medical_Procedure__r.MedicalProcedurePrice__c != app.Medical_Procedure__r.Price_After_Discount__c &&
                (app.Patient_Account__r.Mailing_approval__c == 'מאשר דיוור - הכל' || app.Patient_Account__r.Mailing_approval__c == 'מאשר דיוור - שיווקי') &&
                 app.Medical_Procedure__r.Discount_End_Date__c >= date.today() && app.Medical_Procedure__r.Discount_Start_Date__c <= date.today() &&
                 app.Patient_Account__r.Email_Approval_Date__c <= app.Medical_Procedure__r.Discount_Start_Date__c && app.PayerFactor__r.RelevantForDiscount__c) {                      
                    paymentFields.put('isDiscount', true);                    
                    paymentFields.put('PriceAfterDiscount', app.Medical_Procedure__r.Price_After_Discount__c); 
                    paymentFields.put('NoteForDiscount', app.Medical_Procedure__r.Note_for_Discount__c); 
                    paymentFields.put('MedicalProcedurePrice', app.Medical_Procedure__r.MedicalProcedurePrice__c);                    
            } else {
                paymentFields.put('isDiscount', false); 
                paymentFields.put('MedicalProcedurePrice', app.Medical_Procedure__r.MedicalProcedurePrice__c);  
                paymentFields.put('PriceAfterDiscount', app.Medical_Procedure__r.MedicalProcedurePrice__c); 
                paymentFields.put('NoteForDiscount', null);        
            }         
        }
        System.debug('paymentFields: ' + paymentFields);
        return paymentFields;
    }

    public static Map<String,String> getIframeDataHandler () {
        System.debug('PaymentIntegration.getIframeDataHandler');
        ws_creditGuardApi_REST cgws = new ws_creditGuardApi_REST(initXMLBody());
        try{/*Callout getIframeData*/
            return cgws.getIframe();
        } catch(Exception ex) {
            System.debug('getIframeDataHandler failed: '+ex);
        }
        return null;
    }

    public static Map<String,Object> inquireTransactionHandler (String token) {
        System.debug('PaymentIntegration.inquireTransactionHandler: with token: '+token);
        ws_creditGuardApi_REST cgws = new ws_creditGuardApi_REST(initInquireTransactionXML(token));
        try{/*Callout getIframeData*/
            return cgws.inquireTransaction();
        } catch(Exception ex) {
            System.debug('getIframeDataHandler failed: '+ex);
        }
        return null;
    }

    public static Map<String,Object> sendGenericPaymentHandler (String SFId, String token, String creditCardTypeCode, String amountOfPayments, String address, String remark, String email, String payAmount, String cardExpDate, String accId, String city, String payType,String appointmentType) {
        System.debug('PaymentIntegration.inquireTransactionHandler: with token: '+token);
        Map<String,Object> genericPaymentMap = new Map<String,Object>();
        Boolean paymentStatus = false;

        Decimal otherPayment;
        Decimal firstPayment;
        Decimal firstRoundedPayment;
        if(payAmount!='0.01'){
            if(amountOfPayments=='1'){
                otherPayment = 0;
            }else{
                Decimal firstNotRoundedPayment = Decimal.valueOf(payAmount) / Decimal.valueOf(amountOfPayments);
                Decimal roundedPayment = firstNotRoundedPayment.round(System.RoundingMode.DOWN);
                Decimal newPayAmount = roundedPayment * Decimal.valueOf(amountOfPayments);
                firstRoundedPayment = roundedPayment + (Decimal.valueOf(payAmount) - newPayAmount);              
                otherPayment = (Decimal.valueOf(payAmount) - firstRoundedPayment) / (Decimal.valueOf(amountOfPayments) - 1); 
            }
            firstPayment = firstRoundedPayment != null ? firstRoundedPayment : Decimal.valueOf(payAmount) - (otherPayment * (Integer.valueOf(amountOfPayments) - 1));
        }
        String requestString = initGenericPayment(Id.valueOf(SFId), token, Integer.valueOf(creditCardTypeCode), Integer.valueOf(amountOfPayments), address, city, remark, email, payAmount, cardExpDate,appointmentType);
        ws_GenericPayment_REST gpws = new ws_GenericPayment_REST(requestString);
 
        System.debug('request string '+ requestString);
        try{/*Callout getIframeData*/
            genericPaymentMap=  gpws.sendGenericPayment();
            System.debug('fields are: '+SFId+' '+accId+' '+genericPaymentMap.get('ReceiptNo1')+' '+genericPaymentMap.get('ResultStatus')+' '+genericPaymentMap.get('message')+' '+payAmount+' '+amountOfPayments+' '+payAmount+' '+payAmount+' '+city+' '+email+' '+payType+' '+remark);
            paymentStatus = createPaymentInstance(Id.ValueOf(SFId), Id.ValueOf(accId),genericPaymentMap.get('ReceiptNo1'), genericPaymentMap.get('ResultStatus') == '0' ? true : false, genericPaymentMap.get('message'), 
                                                Double.valueOf(payAmount),Integer.valueOf(amountOfPayments), firstPayment, otherPayment, city, address, email, payType, remark);
        } catch(Exception e) {
            System.debug('getIframeDataHandler failed: '+e);
            insert LogSettingService.getInstance().prepareLog('PaymentIntegration', e);
        }
        updateAppointmentPaymentStatus(Id.ValueOf(SFId),genericPaymentMap.get('ResultStatus') == '0' ? true : false, payType);
        return genericPaymentMap;
    }

    private static boolean createPaymentInstance(Id apptSFId, Id accId, Object receiptNumber, boolean isSuccess, Object error, Double payAmount, Integer amountOfPayments, Decimal firstPayment, Decimal extraPayment, String city, String address, String email, String paymentType, String paymentDesc){
        Payment__c payment = new Payment__c(
            Patient__c = accId,
            Appointment__c = apptSFId,
            PaymentsNumber__c = amountOfPayments,
            Amount__c = payAmount,
            FirstPayment__c = firstPayment,
            ExtraPayment__c = extraPayment,
            Country__c= 'Israel',
            City__c = city,
            Address__c = address,
            Email__c = email,
            ChargingCoin__c = 'NIS',
            ChargingType__c = paymentType,
            ChargeInfo__c = paymentDesc,
            ChargeStatus__c = isSuccess ? 'Valid' : 'Wrong',
            ReceiptNumber__c = receiptNumber != null ? String.valueOf(receiptNumber) : null,
            ErrorInfo__c = error != null ? String.valueOf(error) : null
        );

        try {
            insert payment;
            return true;
        } catch (Exception e) {
            System.debug('Error on attempt to insert payment: '+e);
            insert LogSettingService.getInstance().prepareLog('PaymentIntegration', e);
            return false;
        }
    }

    private static void updateAppointmentPaymentStatus(Id accId, Boolean status, String paymentType){
        try{
            Appointment__c appToUpodate = new Appointment__c( Id = accId, PaymentStatus__c = status ? 'Valid' : 'Wrong', PaymentSource__c='Agent');
            if(paymentType == 'reservationFee'){
                appToUpodate.Status_private_room__c = 'שוריין חדר';
            }
            update appToUpodate;
        }catch(Exception e){
            System.debug('updateAppointmentPaymentStatus failed: '+e);
            insert LogSettingService.getInstance().prepareLog('PaymentIntegration', e);
        }
    }

    private static String initGenericPayment(String SFId, String token, Integer creditCardTypeCode, Integer amountOfPayments, String address, String cityName, String remark, String email, String payAmount, String cardExpDate,String appointmentType){
        Appointment__c appt = [SELECT Id,
                                    Appointment_Date_Time__c,
                                    Accession_Number__c,
                                    Appointment_Type__c,
                                    Department__c,
                                    IDNumber__c,
                                    Patient_Account__r.FirstName,
                                    Patient_Account__r.LastName,
                                    Patient_Account__r.PersonBirthdate,
                                    Patient_Account__r.Father_Name__c,
                                    Medical_Procedure__r.Procedure_Code__c,
                                    Site__r.Site_Code__c,
                                    Domain__r.DomainCode__c,
                                    PayerFactor__r.TafnitPayerType__c,
                                    Spincal__c,
                                    Spincal__r.tafnitID__c
                              FROM Appointment__c 
                              WHERE Id =: SFId 
                              LIMIT 1];
        City__c city;
        try{
        	city = [SELECT Name, City_Code__c FROM City__c WHERE Name = :cityName LIMIT 1];
        }catch(Exception e){
            System.debug(e);
        }
        Decimal otherPayment;
        Decimal firstPayment;
        Decimal firstRoundedPayment;
        if(payAmount!='0.01'){
            if(amountOfPayments == 1){
                otherPayment = 0;
            }else{
                Decimal firstNotRoundedPayment = Decimal.valueOf(payAmount) / amountOfPayments;
                Decimal roundedPayment = firstNotRoundedPayment.round(System.RoundingMode.DOWN);
                Decimal newPayAmount = roundedPayment * amountOfPayments;
                firstRoundedPayment = roundedPayment + (Decimal.valueOf(payAmount) - newPayAmount);               
                otherPayment = (Decimal.valueOf(payAmount) - firstRoundedPayment) / (amountOfPayments - 1);  
            }
            firstPayment = firstRoundedPayment != null ? firstRoundedPayment : Decimal.valueOf(payAmount) - (otherPayment * (Decimal.valueOf(amountOfPayments) - 1));
        }

        List<PatientReciptRowData> prrdList = new List<PatientReciptRowData>();
        PatientReciptRowData prrd = new PatientReciptRowData('1', '4', payAmount, token, null, String.valueOf(creditCardTypeCode), String.valueOf(amountOfPayments), 
                                                            payAmount=='0.01'? '0.01' : String.valueOf(firstPayment), payAmount=='0.01'? '0' : 
                                                            String.valueOf(otherPayment), amountOfPayments > 1 ? '8' : '1',convertCGDateToERPDate(cardExpDate));        
        System.debug('PatientReciptRowData: ' + prrd);
        prrdList.add(prrd);

        List<PatientReciptData> prdList = new List<PatientReciptData>();
        PatientReciptData prd = new PatientReciptData(payAmount == '0.01' ? 'RFD' : 'RF' , String.valueOf(Datetime.now()).replaceAll(' ','T'), 
                                                      String.valueOf(payAmount), '857', address, city != null ? 
                                                      String.valueOf(city.City_Code__c) : '9999', null, 'NIS', remark,prrdList);
        System.debug('PatientReciptData: ' + prd);
        prdList.add(prd);        

        String tafnitId = null;
        String overrideIiResourceType = appt.PayerFactor__r.TafnitPayerType__c;
        String overrideIiItemNo = appt.PayerFactor__r.TafnitPayerType__c == 'I' ? '7720001' : appt.Medical_Procedure__r.Procedure_Code__c;
        if (appointmentType == 'Surgeries') {
            overrideIiResourceType = 'P';
            overrideIiItemNo = '7730001';
            tafnitId = appt.Spincal__c != null ? appt.Spincal__r.tafnitID__c: null;
        }
        List<PatientActData> padList = new List<PatientActData>();
        PatientActData pad = new PatientActData('1', overrideIiResourceType, overrideIiItemNo, appt.Medical_Procedure__r.Procedure_Code__c, payAmount, '1', 'NIS' , 
                                                appt.Id,appointmentType != 'Experts' ? String.ValueOf(appt.Site__r.Site_Code__c) : null, 
                                                appointmentType != 'Experts' ? String.ValueOf(appt.Domain__r.DomainCode__c) : null, appt.Accession_Number__c, tafnitId);
        System.debug('PatientActData: ' + pad);
        padList.add(pad);

        List<PatientData> pdList = new List<PatientData>();  

        String clientNo = (appointmentType == 'Experts' && appt.Department__c != null) ? appt.Department__c : '20421'; //2583228313
        //String clientNo = appointmentType == 'Experts' ? '20421' : null;
        if(appointmentType == 'Experts' && appt.Appointment_Type__c == 'Excellent' && appt.Department__c != null){
            clientNo = appt.Department__c;
        }
        PatientData pd = new PatientData(clientNo, '1', appt.IDNumber__c, 
                                        String.valueOf(appt.Appointment_Date_Time__c).replaceAll(' ','T'), appt.Patient_Account__r.FirstName, appt.Patient_Account__r.LastName, 
                                        String.valueOf(appt.Patient_Account__r.PersonBirthdate), 
                                        appt.Patient_Account__r.Father_Name__c==null? 'אין' : appt.Patient_Account__r.Father_Name__c , padList, prdList);
        System.debug('PatientData: ' + pd);
        pdList.add(pd);

        PaymentRequest paymentRequest = new PaymentRequest(generateUUID(), '16', 'I', 'U9999', 'COLLECTPIPE', 'Y', email, pdList);
        System.debug('paymentRequest is: ' + paymentRequest);
        return JSON.serialize(paymentRequest);
    }

    private static String generateUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    
    private static String convertCGDateToERPDate(String cgDate){
       return String.valueOf(System.today().year()).substring(0,2)+cgDate.substring(2)+cgDate.substring(0,2);
    }

    public static String initXMLBody(){
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(null, 'ashrait', null);
            w.writeStartElement(null, 'request', null);
                w.writeStartElement(null, 'version', null);
                w.writeCharacters('2000');
                w.writeEndElement(); //end version
                w.writeStartElement(null, 'language', null);
                w.writeCharacters('HEB');
                w.writeEndElement(); //end language
                w.writeStartElement(null, 'command', null);
                w.writeCharacters('doDeal');
                w.writeEndElement(); //end command
                w.writeStartElement(null, 'doDeal', null);
                    w.writeStartElement(null, 'terminalNumber', null);
                    w.writeCharacters(cgev.Terminal_Number__c);
                    w.writeEndElement(); //end version
                    w.writeStartElement(null, 'cardNo', null);
                    w.writeCharacters('CGMPI');
                    w.writeEndElement(); //end version
                    w.writeStartElement(null, 'total', null);
                    w.writeCharacters('1');
                    w.writeEndElement(); //end total
                    w.writeStartElement(null, 'transactionType', null);
                    w.writeCharacters('Debit');
                    w.writeEndElement(); //end transactionType
                    w.writeStartElement(null, 'creditType', null);
                    w.writeCharacters('RegularCredit');
                    w.writeEndElement(); //end creditType
                    w.writeStartElement(null, 'currency', null);
                    w.writeCharacters('ILS');
                    w.writeEndElement(); //end currency
                    w.writeStartElement(null, 'transactionCode', null);
                    w.writeCharacters('Phone');
                    w.writeEndElement(); //end transactionCode
                    w.writeStartElement(null, 'validation', null);
                    w.writeCharacters('TxnSetup');
                    w.writeEndElement(); //end validation
                    w.writeStartElement(null, 'user', null);
                    w.writeCharacters(''); /** cgev.Username__c */
                    w.writeEndElement(); //end user
                    w.writeStartElement(null, 'mid', null);
                    w.writeCharacters(cgev.Mid__c);
                    w.writeEndElement(); //end mid
                    w.writeStartElement(null, 'uniqueid', null);
                    w.writeCharacters(generateUUID());
                    w.writeEndElement(); //end uniqueid
                    w.writeStartElement(null, 'mpiValidation', null);
                    w.writeCharacters('Token'); /** AutoComm */
                    w.writeEndElement(); //end mpiValidation
                    w.writeStartElement(null, 'description', null);
                    w.writeCharacters('some description');
                    w.writeEndElement(); //end description
                    w.writeStartElement(null, 'email', null);
                    w.writeCharacters('test@creditguard.co.il');
                    w.writeEndElement(); //end email
                w.writeEndElement(); //end doDeal
            w.writeEndElement(); //end request
        w.writeEndElement(); //end ashrait
        String XMLString = w.getXmlString();
        return XMLString;

    }

    private static String initInquireTransactionXML(String token){
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(null, 'ashrait', null);
            w.writeStartElement(null, 'request', null);
                w.writeStartElement(null, 'version', null);
                w.writeCharacters('2000');
                w.writeEndElement(); //end version
                w.writeStartElement(null, 'language', null);
                w.writeCharacters('HEB');
                w.writeEndElement(); //end language
                w.writeStartElement(null, 'command', null);
                w.writeCharacters('inquireTransactions');
                w.writeEndElement(); //end command
                w.writeStartElement(null, 'inquireTransactions', null);
                    w.writeStartElement(null, 'terminalNumber', null);
                    w.writeCharacters(cgev.Terminal_Number__c);
                    w.writeEndElement(); //end version
                    w.writeStartElement(null, 'queryName', null);
                    w.writeCharacters('mpiTransaction');
                    w.writeEndElement(); //end version
                    w.writeStartElement(null, 'mid', null);
                    w.writeCharacters(cgev.Mid__c);
                    w.writeEndElement(); //end mid
                    w.writeStartElement(null, 'mpiTransactionId', null);
                    w.writeCharacters(token);
                    w.writeEndElement(); //end mpiTransactionId
                w.writeEndElement(); //end inquireTransactions
            w.writeEndElement(); //end request
        w.writeEndElement(); //end ashrait
        String XMLString = w.getXmlString();
        return XMLString;
    }
                        
    public class PaymentRequest {
        public String Guid {get;set;}
        public String SysType {get;set;}
        public String MsgType {get;set;}
        public String PWinUser {get;set;}
        public String RestName {get;set;}
        public String PayMail {get;set;}
        public String Email {get;set;}
        public List<PatientData> PatientData {get;set;}
        public PaymentRequest(String Guid, String SysType, String MsgType, String PWinUser, String RestName, String PayMail, String Email, List<PatientData> PatientData){
             this.Guid=Guid;
             this.SysType=SysType;
             this.MsgType=MsgType;
             this.PWinUser=PWinUser;
             this.RestName=RestName;
             this.PayMail=PayMail;
             this.Email=Email;
             this.PatientData=PatientData;
        }
    }
    
    public class PatientData {
        public String ClientNo {get;set;}
        public String PfIdType {get;set;}
        public String PfIdNo {get;set;}
        public String PfEntryDate {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String BirthDate {get;set;}
        public String ParentName {get;set;}
        public List<PatientActData> PatientActData {get;set;}
        public List<PatientReciptData> PatientReciptData {get;set;}
        public PatientData(String ClientNo,String PfIdType,String PfIdNo,String PfEntryDate,String FirstName,String LastName,String BirthDate,String ParentName,List<PatientActData> PatientActData,List<PatientReciptData> PatientReciptData){
             this.ClientNo=ClientNo;
             this.PfIdType=PfIdType;
             this.PfIdNo=PfIdNo;
             this.PfEntryDate=PfEntryDate;
             this.FirstName=FirstName;
             this.LastName=LastName;
             this.BirthDate=BirthDate;
             this.ParentName=ParentName;
             this.PatientActData=PatientActData;
             this.PatientReciptData=PatientReciptData;
        }
    }

    public class PatientActData {
        public String IiRowNum {get;set;}
        public String IiResourceType {get;set;}
        public String IiItemNo {get;set;}
        public String IiOrigActivity {get;set;}
        public String IiPrice {get;set;}
        public String IiQut {get;set;}
        public String IiCoin {get;set;}
        public String SfId {get;set;}
        public String AccessionNum {get;set;}
        public String SiteCode {get;set;}
        public String DomainCode {get;set;}
        public String TafnitId {get;set;}
        public PatientActData(String IiRowNum,String IiResourceType,String IiItemNo,String IiOrigActivity,String IiPrice,String IiQut,String IiCoin,String SfId,String SiteCode,String DomainCode,String AccessionNum, String TafnitId){
             this.IiRowNum=IiRowNum;
             this.IiResourceType=IiResourceType;
             this.IiItemNo=IiItemNo;
             this.IiOrigActivity=IiOrigActivity;
             this.IiPrice=IiPrice;
             this.IiQut=IiQut;
             this.IiCoin=IiCoin;
             this.SfId=SfId;
             this.SiteCode=SiteCode;
             this.DomainCode=DomainCode;
             this.AccessionNum = AccessionNum;
             this.TafnitId = TafnitId; 
        }
    }

    public class PatientReciptData {
        public String ReciptType {get;set;}
        public String PayDate {get;set;}
        public String PayAmount {get;set;}
        public String PayKpratim {get;set;}
        public String PayAddress {get;set;}
        public String PayCityCode {get;set;}
        public String PayZipCode {get;set;}
        public String PayCurrency {get;set;}
        public String PayRemark {get;set;}
        public List<PatientReciptRowData> PatientReciptRowData {get;set;}
        public PatientReciptData(String ReciptType,String PayDate,String PayAmount,String PayKpratim,String PayAddress,String PayCityCode,String PayZipCode,String PayCurrency,String PayRemark,List<PatientReciptRowData> PatientReciptRowData){
             this.ReciptType=ReciptType;
             this.PayDate=PayDate;
             this.PayAmount=PayAmount;
             this.PayKpratim=PayKpratim;
             this.PayAddress=PayAddress;
             this.PayCityCode=PayCityCode;
             this.PayZipCode=PayZipCode;
             this.PayCurrency=PayCurrency;
             this.PayRemark=PayRemark;
             this.PatientReciptRowData=PatientReciptRowData;
        }
    }

    public class PatientReciptRowData {
        public String RecRowNum {get;set;}
        public String RecRowType {get;set;}
        public String ResRowCurAmount {get;set;}
        public String Token {get;set;}
        public String ResRowMimsarNo {get;set;}
        public String ResRowKodBankCredit {get;set;}
        public String ResRowPaymentsNum {get;set;}
        public String ResFirstPaymentAmount {get;set;}
        public String ResOtherPaymentAmount {get;set;}
        public String ResChargCode {get;set;}
        public String ResTokenDate {get;set;}
        public PatientReciptRowData(String RecRowNum,String RecRowType,String ResRowCurAmount,String Token,String ResRowMimsarNo, String ResRowKodBankCredit,String ResRowPaymentsNum,String ResFirstPaymentAmount,String ResOtherPaymentAmount,String ResChargCode,String ResTokenDate){
             this.RecRowNum=RecRowNum;
             this.RecRowType=RecRowType;
             this.ResRowCurAmount=ResRowCurAmount;
             this.Token=Token;
             this.ResRowMimsarNo=ResRowMimsarNo;
             this.ResRowKodBankCredit=ResRowKodBankCredit;
             this.ResRowPaymentsNum=ResRowPaymentsNum;
             this.ResFirstPaymentAmount=ResFirstPaymentAmount;
             this.ResOtherPaymentAmount=ResOtherPaymentAmount;
             this.ResChargCode=ResChargCode;
             this.ResTokenDate=ResTokenDate;
        }
    }
}