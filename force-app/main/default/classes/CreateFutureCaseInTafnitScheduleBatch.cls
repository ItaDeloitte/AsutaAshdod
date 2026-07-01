/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Create Future Case In Tafnit Schedule Batch Apex class web service
 *
 * Test                 CreateFutureCaseScheduleBatchTest 
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             14-06-2022             <ortalk@assuta.co.il>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class CreateFutureCaseInTafnitScheduleBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    DateTime todayPlus2Days = date.today().adddays(+2);
    DateTime todayPlus1EndDay = todayPlus2Days.addMinutes(-1);
    String query = 'SELECT Id'
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
                + ' WHERE Appointment_Date_Time__c > :todayPlus1EndDay'		
                + ' AND RecordType.DeveloperName = \'Surgeries\''
                + ' AND Appointment_Status__c =\'WaitingForAppointment\''
                + ' AND open_future_case__c = true'
                + ' AND Number_of_commitment__c != null'
                + ' AND Number_of_referral__c != null'
                + ' AND Date_of_commitment__c != null'
                + ' AND Date_of_referral__c != null'
                + ' AND Spincal__c != null'
                + ' AND Medical_Procedure__c != null'
                + ' AND Medical_Procedure__r.Dont_Send_Home_Admission_Link__c = false'
                + ' AND Medical_Procedure__r.Procedure_Code__c != null'
                + ' AND PayerFactor__c != null'
                + ' AND PayerFactor__r.Send_Home_Admission_Link__c = true' 
                + ' AND PayerFactor__r.InsuranceCode__c != null'
                + ' AND Site__c != null'
                + ' AND Site__r.Send_Home_Admission_Link__c = true'
                + ' AND Patient_Account__c != null'
                + ' AND Patient_Account__r.ID_Type__c != null'
                + ' AND TAF_Future_Case__c = null'
                + ' AND TAF_Future_Case_Status__c = null'
                + ' AND FutureCaseError__c = null';     
                
    global CreateFutureCaseInTafnitScheduleBatch() {}

    global CreateFutureCaseInTafnitScheduleBatch(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CreateFutureCaseInTafnitScheduleBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('CreateFutureCaseInTafnitScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        ws_FutureCaseInTafnit service = new ws_FutureCaseInTafnit();
        Map<Id,  Map<String, String>> responseMap = new Map<Id,  Map<String, String>>();

        for (Appointment__c app_i : scope) {
            if (isDontSendHomeAdmission(app_i)) {
                continue;
            }
            responseMap.put(app_i.Id, service.sendFutureCase(app_i));
        }
        System.debug('responseMap: size: ' + responseMap.size() + ' value: ' + responseMap);

        if (!responseMap.isEmpty()) {
            updateAppointment(responseMap);
        }
    }

    private static void updateAppointment(Map<Id,  Map<String, String>> responseMap) {
        List<Appointment__c> appList = new List<Appointment__c>();

        for (Id appId_i : responseMap.keySet()) {
            if (responseMap.get(appId_i) != null) {
                if (responseMap.get(appId_i).containsKey('FileNo')) {
                    appList.add(                   
                        new Appointment__c(
                            Id = appId_i,                        
                            TAF_Future_Case__c = responseMap.get(appId_i).get('FileNo'),
                            TAF_Future_Case_Status__c = '1'                    
                        )
                    );
                } else if (responseMap.get(appId_i).containsKey('Message')) {
                    appList.add(                   
                        new Appointment__c(
                            Id = appId_i,                        
                            FutureCaseError__c = responseMap.get(appId_i).get('Message')                    
                        )
                    );                   
                }                                  
            }            
        }
        System.debug('appList: size: ' + appList.size() + ' value: ' + appList);

        AsyncUtil.doUpdate(appList);
    }  

    global void finish(Database.BatchableContext BC) {
        System.debug('CreateFutureCaseInTafnitScheduleBatch ... finish');
        Datetime now = System.now().addMinutes(60);
        String CRONEXP = '' + now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('Create Future Case In Tafnit #' + now.getTime(), CRONEXP, new CreateFutureCaseInTafnitScheduleBatch());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new CreateFutureCaseInTafnitScheduleBatch(), 25);
    }

    private Boolean isDontSendHomeAdmission(Appointment__c appt){
        if(appt.Medical_Procedure2__r.Dont_Send_Home_Admission_Link__c || 
           appt.Medical_Procedure3__r.Dont_Send_Home_Admission_Link__c ||
           appt.Medical_Procedure4__r.Dont_Send_Home_Admission_Link__c){
            return true;
        }
        return false;
    }
}