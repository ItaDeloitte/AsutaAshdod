@isTest
public class LC_AvayaCommunicatorTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.ID_Number__c = '852986371';
        insert patient1;
        
        //patient2.ID_Number__c = '999658578';
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.X360_patient_checkbox__c = true;
        patient2.ID_Number__c = '999740731';
        insert patient2;
        //insert new List<Account>{doctor, patient1, patient2};
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas1 = TestDataFactory.getCase(doctor.Id, patient1.Id, con.Id, pFactor.Id);
        cas1.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        cas1.UCID__c = '00001056961577099994';
        Case cas2 = TestDataFactory.getCase(doctor.Id, patient2.Id, con.Id, pFactor.Id);
        cas2.RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case');       
        insert new List<Case>{cas1, cas2};
		patient2.Case_360__c = cas2.Id;
        update patient2;
        User user = TestDataFactory.getUser('System Administrator');
        user.Agent_ID__c = '13902';
        user.Extension = '4453';
        insert user;
        
        insert new List<Task>{
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001143181620759969;40_132042;360=N;;opt=1', '00001143181620759969'),
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001143181620759968;40_132042;360=N;;opt=1;CB=Y', '00001143181620759968'),
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001143181620759967;40_132042;360=Y;;opt=1', '00001143181620759967'),
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001056961577099994;40_132042;360=N;;opt=2', '00001056965577099994'),
            TestDataFactory.getLogACall(user.Id, false, '200001;852986371;00001012021667986742;40_132042;360=N;;opt=3', '00001012021667986742'),
            TestDataFactory.getLogACall(user.Id, false, '300001;852986371;00001056961577099996;40_132042;360=N;;opt=4', '00001056967577099996'),
            TestDataFactory.getLogACall(user.Id, false, '400001;999740731;00001056961577099997;40_132042;360=N;;opt=5', '00001056968577099997')
        };
    }
    
    @isTest
    static void getCaseIdTest() {
        Account acc = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        LC_AvayaCommunicator controller = new LC_AvayaCommunicator();
        Response getResInComming = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;000003335;00001143181620759969;187_220930;360=N;;opt=1","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","ucid":"00001143181620759969"}}'}
        );
        Response getResCallBack = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;852986371;00001143181620759968;187_220930;360=N;;opt=1;CB=Y","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","ucid":"00001143181620759968"}}'}
        );
        Response getRes360 = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;000000000;00001143181620759967;187_220930;360=N;;opt=1","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","ucid":"00001143181620759967"}}'}
        );
        Response getResTransfer = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;852986371;00001012021667986742;187_220930;360=Y;;opt=1","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","oldCallId":"901","oldUcid":"00001143181620759969", "ucid":"00001012021667986742"}}'}
        );
        Response getTransferredLeadEvent = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;852986371;00001012021667986742;187_220930;360=Y;;opt=100","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","oldCallId":"901","oldUcid":"00001143181620759969", "ucid":"00001012021667986742"}}'}
        );
        Response getLeadEvent = controller.executeAction(
            new Map<String, Object>{'actionName' => 'getRecordId', 'callDetails' => '{"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com","payload":{"callId":"15095","eventSource":"call","uui":"100001 ;852986371;00001012021667986742;187_220930;360=Y;;opt=100","eventType":"EstablishedEvent","dnis":"17733","ani":"0548559748","oldCallId":"901", "ucid":"00001012021667986742"}}'}
        );
        Test.stopTest();
    }


    @isTest
    static void getCaseIdTest2() {
        Account acc = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        LC_AvayaCommunicator controller = new LC_AvayaCommunicator();

        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_AvayaCommunicator controller = new LC_AvayaCommunicator();
        try {controller.executeAction(new Map<String, Object>{'actionName' => 'wrong'});} catch (Exception e) {}
        Test.stopTest();
    }
}