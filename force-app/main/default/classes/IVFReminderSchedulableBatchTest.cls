@isTest
private class IVFReminderSchedulableBatchTest {
    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.PersonEmail =  'maxf@assuta.co.il';
        patient.Mailing_approval__c = 'מאשר דיוור - הכל';
        patient.SMS_Phone_number__c = '0546666666';
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
       
        List<Case> caseList = new List<Case>();
        Id IVFFreezingEggsRecordId = [SELECT ID FROM RecordType WHERE DeveloperName = 'IVF_Freezing_Eggs' AND SobjectType = 'Case'].Id;

        DateTime today = date.today();
        DateTime todayMin7Days = today.adddays(-7).addHours(-2);
        DateTime todayMin6Days = today.adddays(-6).addHours(-2);
        DateTime todayMin13Days = today.addDays(-13).addHours(-2);
        DateTime todayMin12Days = today.addDays(-12).addHours(-2);
        Date dateExp = date.today().addMonths(1);

        Case case1 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
       
        case1.Future_End_Freezing_Date__c = dateExp;
        case1.RecordTypeId = IVFFreezingEggsRecordId;
        case1.Kit_Sending_Date_Female_IVF__c = todayMin6Days;
        case1.Case_Route__c='Seperate_Route';
        case1.email_from_patient__c = 'maxf@assuta.co.il';
        case1.Partner_Name__c = patient.Id;
        case1.Reminder_After_10_Days_FemalePatient__c = false;
        case1.Female_Stage__c='Documents_Management';
        case1.Female_Status__c='Documents_Holds';
        case1.SMS_Phone_Number__c = '0546666666';
        case1.Case_site__c='Ramat_Hahayal';
        case1.Male_First_Name__c='Muhamed bin laden';
        caseList.add(case1);

        Case case2 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case2.Future_End_Freezing_Date__c = dateExp;
        case2.RecordTypeId = IVFFreezingEggsRecordId;
        case2.Kit_Sending_Date_Partner_IVF__c  = todayMin6Days;
        case2.Case_Route__c='Seperate_Route';
        case2.Reminder_After_10_Days_Partner__c = false;
        case2.Partner_Stage__c='Documents_Management';
        case2.Partner_Status__c='Documents_Holds';
        case2.Partner_Name__c = patient.Id;
        case2.SMS_Phone_Number__c = '0546666666';
        case2.Case_site__c='Rishon_Letzion';
        case2.Male_First_Name__c='Muhamed bin laden';
        caseList.add(case2);

        Case case22 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case22.Future_End_Freezing_Date__c = dateExp;
        case22.RecordTypeId = IVFFreezingEggsRecordId;
        case22.Kit_Sending_Date_Partner_IVF__c  = todayMin6Days;
        case22.Case_Route__c='Seperate_Route';
        case22.Reminder_After_10_Days_Partner__c = false;
        case22.Partner_Stage__c='Documents_Management';
        case22.Partner_Status__c='Documents_Holds';
        case22.Partner_Name__c = patient.Id;
        case22.SMS_Phone_Number__c = '0546666666';
        case22.Case_site__c='Ramat_Hahayal';
        case22.Male_First_Name__c='Muhamed bin laden';
        caseList.add(case22);

        Case case3 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case3.Future_End_Freezing_Date__c = dateExp;
        case3.RecordTypeId = IVFFreezingEggsRecordId;
        case3.Kit_Sending_Date_Female_IVF__c = todayMin6Days;
        case3.Case_Route__c='Double_Route';
        case3.Case_Stage__c ='Documents_Management';
        case3.Case_Status__c='Documents_Holds';
        case3.Reminder_After_10_Days_FemalePatient__c = false;
        case3.email_from_patient__c= 'maxf@assuta.co.il';
        case3.Partner_Name__c = patient.Id;
        case3.SMS_Phone_Number__c = '0546666666';
        case3.Case_site__c='Ramat_Hahayal';
        caseList.add(case3);

        Case case4 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case4.Future_End_Freezing_Date__c = dateExp;
        case4.RecordTypeId = IVFFreezingEggsRecordId;
        case4.Kit_Sending_Date_Female_IVF__c = todayMin12Days;
        case4.Case_Route__c='Seperate_Route';
        case4.Reminder_After_10_Days_FemalePatient__c = true;
        case4.Partner_Name__c = patient.Id;
        case4.email_from_patient__c= 'maxf@assuta.co.il';
        case4.SMS_Phone_Number__c = '0546666666';
        case4.Case_site__c='Rishon_Letzion';
        caseList.add(case4);

        Case case5 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case5.Future_End_Freezing_Date__c = dateExp;
        case5.RecordTypeId = IVFFreezingEggsRecordId;
        case5.Kit_Sending_Date_Partner_IVF__c = todayMin12Days;
        case5.Case_Route__c='Seperate_Route';
        case5.Reminder_After_10_Days_Partner__c = true;
        case5.Partner_Name__c = patient.Id;
        case5.email_from_patient__c= 'maxf@assuta.co.il';
        case5.SMS_Phone_Number__c = '0546666666';
        case5.Kit_Sending_Date_Partner_IVF__c = Date.today();
        case5.Case_site__c='Rishon_Letzion';
        caseList.add(case5);

        Case case6 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case6.Future_End_Freezing_Date__c = dateExp;
        case6.RecordTypeId = IVFFreezingEggsRecordId;
        case6.Kit_Sending_Date_Female_IVF__c = todayMin12Days;
        case6.Case_Route__c='Double_Route';
        case6.Case_Stage__c ='Documents_Management';
        case6.Case_Status__c='Documents_Holds';
        case6.Case_site__c='Rishon_Letzion';
        case6.Reminder_After_10_Days_FemalePatient__c = true;
        case6.Partner_Name__c = patient.Id;
        case6.email_from_patient__c= 'maxf@assuta.co.il';
        case6.SMS_Phone_Number__c = '0546666666';
        case6.Male_First_Name__c='Donald duck';
        caseList.add(case6);

        Case case7 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case7.Future_End_Freezing_Date__c = dateExp;
        case7.RecordTypeId = IVFFreezingEggsRecordId;
        case7.Kit_Sending_Date_Female_IVF__c = todayMin6Days;
        case7.Kit_Sending_Date_Partner_IVF__c = todayMin6Days;
        case7.Partner_Stage__c='Documents_Management';
        case7.Female_Stage__c='Documents_Management';
        case7.Female_Status__c='Documents_Holds';
        case7.Partner_Status__c='Documents_Holds';
        case7.Case_Route__c='Seperate_Route';
        case7.Case_site__c='Rishon_Letzion';
        case7.Reminder_After_10_Days_FemalePatient__c = false;
        case7.Partner_Name__c = patient.Id;
        case7.email_from_patient__c= 'maxf@assuta.co.il';
        case7.SMS_Phone_Number__c = '0546666666';
        case7.Male_First_Name__c='Donald duck';
        caseList.add(case7);

        Case case8 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case8.Future_End_Freezing_Date__c = dateExp;
        case8.RecordTypeId = IVFFreezingEggsRecordId;
        case8.Kit_Sending_Date_Female_IVF__c = todayMin12Days;
        case8.Kit_Sending_Date_Partner_IVF__c = todayMin12Days;
        case8.Partner_Stage__c='Documents_Management';
        case8.Female_Stage__c='Documents_Management';
        case8.Female_Status__c='Documents_Holds';
        case8.Partner_Status__c='Documents_Holds';
        case8.Case_Route__c='Seperate_Route';
        case8.Case_site__c='Rishon_Letzion';
        case8.Reminder_After_10_Days_FemalePatient__c = false;
        case8.Reminder_After_10_Days_Partner__c = true;
        case8.Partner_Name__c = patient.Id;
        case8.email_from_patient__c= 'maxf@assuta.co.il';
        case8.SMS_Phone_Number__c = '0546666666';
        case8.Male_First_Name__c='Donald duck';
        caseList.add(case8);

        Case case9 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case9.Future_End_Freezing_Date__c = dateExp;
        case9.RecordTypeId = IVFFreezingEggsRecordId;
        case9.Kit_Sending_Date_Partner_IVF__c = todayMin12Days;
        case9.Partner_Stage__c='Documents_Management';
        case9.Partner_Status__c='Documents_Holds';
        case9.Case_Route__c='Seperate_Route';
        case9.Case_site__c='Rishon_Letzion';
        case9.Reminder_After_10_Days_Partner__c = true;
        case9.Partner_Name__c = patient.Id;
        case9.email_from_patient__c= 'maxf@assuta.co.il';
        case9.SMS_Phone_Number__c = '0546666666';
        case9.Male_First_Name__c='Donald duck';
        caseList.add(case9);

        Case case10 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case10.Future_End_Freezing_Date__c = dateExp;
        case10.RecordTypeId = IVFFreezingEggsRecordId;
        case10.Kit_Sending_Date_Partner_IVF__c = todayMin12Days;
        case10.Partner_Stage__c='Documents_Management';
        case10.Partner_Status__c='Documents_Holds';
        case10.Case_Route__c='Seperate_Route';
        case10.Case_site__c='Rishon_Letzion';
        case10.Reminder_After_10_Days_Partner__c = true;
        case10.Partner_Name__c = patient.Id;
        case10.email_from_patient__c= 'maxf@assuta.co.il';
        case10.SMS_Phone_Number__c = '0546666666';
        case10.Male_First_Name__c='Donald duck';
        caseList.add(case10);

        
        Case case11 =  TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        case11.Future_End_Freezing_Date__c = dateExp;
        case11.RecordTypeId = IVFFreezingEggsRecordId;
        case11.Kit_Sending_Date_Female_IVF__c = todayMin12Days;
        case11.Female_Stage__c='Documents_Management';
        case11.Female_Status__c='Documents_Holds';
        case11.Case_Route__c='Seperate_Route';
        case11.Case_site__c='Rishon_Letzion';
        case11.Reminder_After_10_Days_FemalePatient__c = true;
        case11.Partner_Name__c = patient.Id;
        case11.email_from_patient__c= 'maxf@assuta.co.il';
        case11.SMS_Phone_Number__c = '0546666666';
        case11.Male_First_Name__c='Donald duck';
        caseList.add(case11);


        insert caseList;


    }

    @isTest
    static void batchTest(){
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new IVFReminderSchedulableBatch(
                'SELECT Id'
                 + ', Female_Status__c'
                      + ', Partner_Status__c'
                      + ', Case_Route__c'
                      + ', Case_Status__c'
                      + ', email_from_patient__c '
                      + ', Partner_Name__r.PersonEmail'
        			  + ', Partner_Name__r.SMS_Phone_Number__c'
                      + ', Reminder_After_10_Days_Partner__c'
                      + ', Reminder_After_10_Days_FemalePatient__c'
                      + ', Kit_Sending_Date_Female_IVF__c'
                      + ', link_upload_files__c'
                      + ', Fax_Number_IVF__c'
                      + ', Site_Email__c'
                      + ', Case_site__c'
                      + ', Kit_Sending_Date_Partner_IVF__c'
                      + ', SMS_Phone_Number__c'
                      + ', AccountId'
                      + ', Account.SMS_Phone_number__c'
                      + ', Reminders_Needed__c'
                      + ', Expiration_Decision_Making_Male_IVF__c'
                      + ', Expiration_Decision_Making_Female_IVF__c'
                      + ', Male_First_Name__c'
                      + ', Female_First_Name__c'
          + ' FROM Case'
            )
        );
        Test.stopTest();
    }
    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Job IVF', '20 30 14 10 2 ?', new IVFReminderSchedulableBatch(false));
        Test.stopTest();
    }

}