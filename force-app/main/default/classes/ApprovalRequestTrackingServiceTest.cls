@isTest
private class ApprovalRequestTrackingServiceTest {
    
    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor1.Experts_center__c = true;
        insert doctor1;
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        insert clinic;
        Doctor_in_Clinic__c docClinic = new Doctor_in_Clinic__c(Doctors__c = doctor1.Id,Clinic__c = clinic.Id);
        insert docClinic;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        subExpertise.Sub_expertise_code__c ='5424';
        insert subExpertise;
    }

    @isTest
    static void createApprovalRequestTest() {
        Account doctor1 = [SELECT Id FROM Account WHERE Doctor_Code__c !=null LIMIT 1];
        Doctor_in_Clinic__c docClinic = [SELECT Id FROM Doctor_in_Clinic__c LIMIT 1];
        List<Approval_Request_Tracking__c> approvalsList = new List<Approval_Request_Tracking__c>();
        Approval_Request_Tracking__c art1 = new Approval_Request_Tracking__c();
        Approval_Request_Tracking__c art2 = new Approval_Request_Tracking__c();
        Approval_Request_Tracking__c art3 = new Approval_Request_Tracking__c();
        Approval_Request_Tracking__c art4 = new Approval_Request_Tracking__c();

        art1.Action_Value__c='Update';
        art1.Updated_Value__c='NewValue1';
        art1.Original_Value__c='Oldvalue1';
        art1.Doctor_Account__c=doctor1.Id;
        art1.Doctor_In_Clinic__c=docClinic.Id;
        art1.Name = 'Floor__c';

        art2.Action_Value__c='Update';
        art2.Updated_Value__c='NewValue2';
        art2.Original_Value__c='Oldvalue2';
        art2.Doctor_Account__c=doctor1.Id;
        art2.Doctor_In_Clinic__c=docClinic.Id;
        art2.Name = 'doctor_degree__c';

        art3.Action_Value__c='Update';
        art3.Updated_Value__c='5424';
        art3.Original_Value__c='Oldvalue2';
        art3.Doctor_Account__c=doctor1.Id;
        art3.Doctor_In_Clinic__c=docClinic.Id;
        art3.Name = 'Sub_Expertise__r.Sub_expertise_code__c';

        art4.Action_Value__c='Delete';
        art4.Updated_Value__c='5424';
        art4.Original_Value__c='Oldvalue2';
        art4.Doctor_Account__c=doctor1.Id;
        art4.Doctor_In_Clinic__c=docClinic.Id;
        art4.Name = 'Floor__c';

        approvalsList.add(art1);
        approvalsList.add(art2);
        approvalsList.add(art3);
        approvalsList.add(art4);
        insert approvalsList;

        Test.startTest();
        art1.Decision_Result__c='Approved';
        art2.Decision_Result__c='Approved';
        art3.Decision_Result__c='Approved';
        art4.Decision_Result__c='Approved';
        update art1;
        update art2;
        update art3;
        update art4;
        Test.stopTest();
    }

}