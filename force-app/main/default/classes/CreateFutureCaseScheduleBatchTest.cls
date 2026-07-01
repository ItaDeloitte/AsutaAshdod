@isTest
private class CreateFutureCaseScheduleBatchTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        pFactor.Send_Home_Admission_Link__c = true;
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);        
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);        
        insert domain;
        Medical_Procedure__c procedure1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '13.0');        
        insert procedure1;
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '13.1');        
        insert procedure2;
        Medical_Procedure__c procedure3 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '13.2');        
        insert procedure3;
        Medical_Procedure__c procedure4 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '13.3');        
        insert procedure4;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);        
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Send_Home_Admission_Link__c = true;        
        insert site;
        SpinCal__c spincal = new SpinCal__c();
        spincal.Name = '12345';
        insert spincal;
        Appointment__c app = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure1.Id, patient.Id, calendar.Id, cas.Id);
        app.Didkitsent__c = true;
        app.Medical_Procedure2__c = procedure2.Id;
        app.Medical_Procedure3__c = procedure3.Id;
        app.Medical_Procedure4__c = procedure4.Id;
        app.TAF_Future_Case__c = '';
        app.Appointment_Status__c = 'WaitingForAppointment'; 
        app.Number_of_commitment__c = '12345';
        app.Number_of_referral__c = '12345';
        app.Deductibles__c = 23;
        app.Appointment_Date_Time__c = Datetime.now().addDays(5);
        app.PayerFactor__c = pFactor.Id;
        app.Doctor_Account__c = doctor.Id;
        app.Spincal__c = spincal.Id;
        app.Site__c = site.Id;
        app.Date_of_referral__c = Date.today();
        insert app;
    }

    @isTest
    static void batchResultStatus1Test() {
        System.debug('batch test');
        Test.setMock(HttpCalloutMock.class, new FutureCase_Mock());
        Test.startTest();
        Database.executeBatch(
            new CreateFutureCaseInTafnitScheduleBatch(
                'SELECT Id'
		            + ', IDNumber__c'   
			        + ', Patient_Account__r.ID_Type__c'
                    + ', Patient_Account__r.PersonMobilePhone'
                    + ', Patient_Account__r.FirstName'
                    + ', Patient_Account__r.LastName'
                    + ', Patient_Account__r.PersonBirthdate'
                    + ', Patient_Account__r.Gender__c'
                    + ', Patient_Account__r.PersonMailingCity'
                    + ', Patient_Account__r.PersonMailingStreet' 
                    + ', Doctor_Account__r.Name'
                    + ', Doctor_Account__r.FirstName'
                    + ', Doctor_Account__r.LastName'
                    + ', Doctor_Account__r.Doctor_Code__c'
                    + ', Doctor_Account__r.doctor_degree__c'                        
			        + ', Number_of_referral__c'   
                    + ', Date_of_referral__c'                                                                     
                    + ', Number_of_commitment__c'
                    + ', Date_of_commitment__c'
                    + ', Appointment_Date_Time__c'
                    + ', Date_of_appointment__c'                       
 		            + ', Expiration_date_commitment__c'
                    + ', Site__r.Site_code__c'
                    + ', PayerFactor__r.InsuranceCode__c'
                    + ', Medical_Procedure__r.Procedure_Code__c'
                    + ', Medical_Procedure2__r.Procedure_Code__c'
                    + ', Medical_Procedure3__r.Procedure_Code__c'
                    + ', Medical_Procedure4__r.Procedure_Code__c'                                                           
                    + ', Medical_Procedure__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c'
                    + ', Payment_to_Doctor__c'		            
                    + ', Deductibles__c'                    
                + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }
    
    @isTest
    static void batchResultStatus0Test() {
        System.debug('batch test');
        Test.setMock(HttpCalloutMock.class, new FutureCase_Mock2());
        Test.startTest();
        Database.executeBatch(
            new CreateFutureCaseInTafnitScheduleBatch(
                'SELECT Id'
		            + ', IDNumber__c'   
			        + ', Patient_Account__r.ID_Type__c'
                    + ', Patient_Account__r.PersonMobilePhone'
                    + ', Patient_Account__r.FirstName'
                    + ', Patient_Account__r.LastName'
                    + ', Patient_Account__r.PersonBirthdate'
                    + ', Patient_Account__r.Gender__c'
                    + ', Patient_Account__r.PersonMailingCity'
                    + ', Patient_Account__r.PersonMailingStreet' 
                    + ', Doctor_Account__r.Name'
                    + ', Doctor_Account__r.FirstName'
                    + ', Doctor_Account__r.LastName'
                    + ', Doctor_Account__r.Doctor_Code__c'
                    + ', Doctor_Account__r.doctor_degree__c'                        
			        + ', Number_of_referral__c'   
                    + ', Date_of_referral__c'                                                                     
                    + ', Number_of_commitment__c'
                    + ', Date_of_commitment__c'
                    + ', Appointment_Date_Time__c'
                    + ', Date_of_appointment__c'                       
 		            + ', Expiration_date_commitment__c'
                    + ', Site__r.Site_code__c'
                    + ', PayerFactor__r.InsuranceCode__c'
                    + ', Medical_Procedure__r.Procedure_Code__c'
                    + ', Medical_Procedure2__r.Procedure_Code__c'
                    + ', Medical_Procedure3__r.Procedure_Code__c'
                    + ', Medical_Procedure4__r.Procedure_Code__c'                                                           
                    + ', Medical_Procedure__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c'
                    + ', Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c'
                    + ', Payment_to_Doctor__c'		            
                    + ', Deductibles__c'                    
                + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job Day Before', '20 30 8 10 2 ?', new CreateFutureCaseInTafnitScheduleBatch());
        Test.stopTest();
    }

    private class FutureCase_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{'+
                             '"Guid": "EFF52CD8-2C8A-4D12-B323-7C690A008EBE",'+
                             '"ResultStatus": "1",'+
                             '"IdType": "1",'+
                             '"IdNo": "311049191",'+
                             '"PFirstName": "testFirstName",'+
                             '"PLastName": "testFirstName",'+
                             '"ClientNo": "20001",'+
                             '"FileNo": "6636071",'+
                             '"ErrCodes": ['+
                             '{'+
                             '"Tag": "",'+
                             '"ErrorCode": "1234",'+
                             '"Message": "Test"'+
                             '}'+
                             ']'+
                             '}'
            );
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class FutureCase_Mock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{'+
                             '"Guid": "EFF52CD8-2C8A-4D12-B323-7C690A008EBE",'+
                             '"ResultStatus": "0",'+
                             '"IdType": "1",'+
                             '"IdNo": "311049191",'+
                             '"PFirstName": "testFirstName",'+
                             '"PLastName": "testFirstName",'+
                             '"ClientNo": "20001",'+
                             '"FileNo": "6636071",'+
                             '"ErrCodes": ['+
                             '{'+
                             '"Tag": "",'+
                             '"ErrorCode": "",'+
                             '"Message": ""'+
                             '}'+
                             ']'+
                             '}'
            );
            response.setStatusCode(200);
            return response;
        }
    }
}