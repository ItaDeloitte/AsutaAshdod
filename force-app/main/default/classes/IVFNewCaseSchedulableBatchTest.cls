@isTest
private class IVFNewCaseSchedulableBatchTest {
    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        
       
        List<Case> caseList = new List<Case>();
        Case case1 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        Date dateExp = date.today().addMonths(1);
        case1.Future_End_Freezing_Date__c = dateExp;
        case1.RecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'IVF_Freezing_Eggs' AND SobjectType = 'Case'].Id;
        caseList.add(case1);
        insert caseList;

    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new IVFNewCaseSchedulableBatch(
                'SELECT Id'
                + ', Female_Status__c'
                + ', Partner_Status__c'
                + ', Case_Route__c'
                + ', Freezing_Date__c'
                + ', Case_Status__c'
                + ', AccountId'
                + ', Partner_Name__c'
          + ' FROM Case'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job SMS', '20 30 8 10 2 ?', new IVFNewCaseSchedulableBatch(false));
        Test.stopTest();
    }

    
}