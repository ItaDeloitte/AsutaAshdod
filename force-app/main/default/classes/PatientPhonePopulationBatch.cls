global class PatientPhonePopulationBatch implements database.batchable<sobject>, Database.AllowsCallouts{
	// scope size only 100, please
    String query;	
    public PatientPhonePopulationBatch(){
        query = 'SELECT ID, Patient_Account__c, Patient_Account__r.Phone, Patient_Account__r.SMS_Phone_Number__c FROM Appointment__c WHERE Patient_Account__c != null AND Date_of_appointment__c >= TODAY';
        if (!Test.isRunningTest()){
            query += ' AND Patient_Account__r.Phone = NULL AND Patient_Account__r.SMS_Phone_Number__c = NULL';
        }
    }
    
    public PatientPhonePopulationBatch(String queryIn){
        this.query = queryIn;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return DataBase.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        Set <String> accountIdSet = new Set <String> ();
        for (Appointment__c app_i : scope){
            accountIdSet.add(app_i.Patient_Account__c);
        }
        System.debug('accountIdSet.size '+accountIdSet.size());
        DateTime startDate = System.now().addHours(-1);
        List <Account> accountToUpdateList = new List <Account> ();
        for (Account acc_i : [SELECT ID, 
                              		Last_update_demographic__c, 
                              		SorceSysCode__c, 
                              		QueryStatus__c, 
                              		ErrorMessage__c, 
                              		ErrorCode__c, 
                              		ID_Number__c, 
                              		ID_Type__c, 
                              		DisableValidation__c, 
                              		Start_Date_shaban_maccabi__c, 
                              		Insurance_is_valid__c, 
                              		Create_Tafnit_AC__c 
                              FROM Account WHERE (Last_update_demographic__c = null OR Last_update_demographic__c <: startDate) AND ID IN: accountIdSet]){
        	DemographyManager.AccountWithDisabilities wrapper = DemographyManager.updateAccountWithExtendedDetails(acc_i, acc_i.ID_Number__c, acc_i.ID_Type__c);    
            if (wrapper.isDemographyExist) {
                  wrapper.acct.Last_update_demographic__c = System.now();
                  accountToUpdateList.add(wrapper.acct);                    
            }                      
        }
        System.debug('accountToUpdateList.size '+accountToUpdateList.size());
        if (!accountToUpdateList.isEmpty()){
 			Database.update (accountToUpdateList, false);
        }
        
      
    }   

    global void finish(Database.BatchableContext BC) {}
}