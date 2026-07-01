@isTest
public class TaskTriggerDispatcherTest {

    @testSetup
    static void setup() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.Create_Source_System__c = false;
        patient1.ID_Number__c = '852986371';
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.Create_Source_System__c = false;
        patient2.ID_Number__c = '999088396';
        Contact con = TestDataFactory.getContact(patient2.Id);
        insert con;
        insert new List<Account>{doctor, patient1, patient2};
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;

        User user = TestDataFactory.getUser('System Administrator');
        user.Agent_ID__c = '13902';
        user.Extension = '4453';
        insert user;

        Case cas1 = TestDataFactory.getCase(doctor.Id, patient2.Id, con.Id, pFactor.Id);
        cas1.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        cas1.UCID__c = '00001056961577099994';
        Case cas2 = TestDataFactory.getCase(doctor.Id, patient2.Id, con.Id, pFactor.Id);
        cas2.RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case');
        insert new List<Case>{cas1, cas2};

        insert new List<Task>{
            TestDataFactory.getLogACall(user.Id, false, '100001;999740731;00001056961577099991;40_132042;360=N;;opt=1', '00001056962577099991'),
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001056961577099992;40_132042;360=N;;opt=1;CB=Y', '00001056963577099991'),
            TestDataFactory.getLogACall(user.Id, false, '100001;852986371;00001056961577099993;40_132042;360=Y;;opt=1', '00001056964577099991'),
            TestDataFactory.getLogACall(user.Id, false, '100001;999088396;00001056961577099994;40_132042;360=N;;opt=2', '00001056965577099991'),
            TestDataFactory.getLogACall(user.Id, false, '200001;999740731;00001056961577099995;40_132042;360=N;;opt=3', '00001056966577099991'),
            TestDataFactory.getLogACall(user.Id, false, '300001;999740731;00001056961577099996;40_132042;360=N;;opt=4', '00001056967577099991'),
            TestDataFactory.getLogACall(user.Id, false, '400001;999740731;00001056961577099997;40_132042;360=N;;opt=5', '00001056968577099991')
        };
    }

    @isTest
    public static void populateFromUUITest() {
        Map<String, List<String>> CIDToExpectedValues = new Map<String, List<String>>{
            '00001056961577099991' => new List<String>{'1'},
            '00001056961577099992' => new List<String>{'1'},
            '00001056961577099993' => new List<String>{'1'},
            '00001056961577099994' => new List<String>{'1'},
            '00001056961577099995' => new List<String>{'2'},
            '00001056961577099996' => new List<String>{'3'},
            '00001056961577099997' => new List<String>{'4'}
        };

        Test.startTest();
        for (Task task_i : [SELECT Call_ID__c, Caller_Language__c FROM Task where Subject = 'Call' and Call_ID__c != null]) {
            System.assertEquals(task_i.Caller_Language__c, CIDToExpectedValues.get(task_i.Call_ID__c)[0]);
        }
        Test.stopTest();
    }
}