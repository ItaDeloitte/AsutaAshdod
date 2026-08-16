//Test: UrgentAppointmentsSchedulableBatchTest
global with sharing class UrgentAppointmentsSchedulableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    Set<Id> appSaveSlotIdSet = new Set<Id>();
    List<SMS__c> smsToInsertList = new List<SMS__c>();
    List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

    public UrgentAppointmentsSchedulableBatch() {}
    

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('UrgentAppointmentsSchedulableBatch ... start');        
        return Database.getQueryLocator([
            SELECT Id
                    , case__c
                    , Case__r.SMS_Phone_Number__c
                    , Site__c
                    , Calendar__c
                    , Calendar__r.ServiceId__c
                    , Medical_Procedure__c
                    , Medical_Procedure__r.Name
                    , Medical_Procedure__r.Procedure_Code__c
                    , Appointment_Status__c
                    , Days_Until_Appointment__c                  
                    , Patient_Account__r.ID_Type__c
                    , Patient_Account__r.ID_Number__c
                    , Patient_Account__r.SMS_Phone_number__c
                    , PayerFactor__r.InsuranceCode__c 
                    , UrgentRefusalNum__c
                    , UrgentApptStatus__c
                    , UrgentApptTitanLink__c
                    , UrgentApptMessageDate__c
                    , UrgentAppointment__c 
                    , UrgentAppointment__r.Duration__c
                    , UrgentAppointment__r.Calendar__c
                    , UrgentAppointment__r.AppointmentTime__c  
                    , UrgentAppointment__r.Appointment_Date__c                                                                               
                    , UrgentAppointment__r.Appointment_Date_Time__c 
                    , UrgentAppointment__r.Calendar__r.ServiceId__c
                    , UrgentAppointment__r.Medical_Procedure__c
                    , UrgentAppointment__r.Medical_Procedure__r.Name
                    , UrgentAppointment__r.Medical_Procedure__r.Procedure_Code__c                                                  
                FROM Appointment__c
               WHERE Is_Urgent__c = true
                AND UrgentAppointment__c != null  
                AND Appointment_Date_Time__c >= TODAY 
                AND Medical_Procedure__r.Confidentiality__c = false  
                AND UrgentAppointment__r.UrgentApptSaveSlot__c = true                                                                                              
                AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed')                                                 
            ]
        );
    }
    
    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('UrgentAppointmentsSchedulableBatch ... execute');                                 
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();
        Map<Id, Boolean> preventMap = PreventMessagingUtils.isMessagingPrevented(scope);

        for (Appointment__c appointment_i : scope) { 
             //check if messaging is prevented if so, skip and do NOT send message 
            if (preventMap.get(appointment_i.Id)) {
                System.debug('Messaging prevented for appointment ' + appointment_i.Id);
                continue; 
            }          
            appointment_i = this.checkUrgentAppointmentStatus(appointment_i);
            if (appointment_i != null) appointmentToUpdateList.add(appointment_i);            
        }

        if (!appSaveSlotIdSet.isEmpty()) {
            List<Appointment__c> appts = findOtherUrgentApp(appSaveSlotIdSet);
            if (appts != null) appointmentToUpdateList.addAll(appts);           
        }
        
        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);
        AsyncUtil.doUpdate(appointmentToUpdateList);    

        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);
        AsyncUtil.doInsert(smsToInsertList);            
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('UrgentAppointmentsSchedulableBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
       // skip if this job run in J_Holiday
       if (SMSUtils.checkBusinessDay(Date.today())) {  
            Database.executeBatch(new UrgentAppointmentsSchedulableBatch(), 25);
       }
    }

    public Appointment__c checkUrgentAppointmentStatus(Appointment__c appointment) {        
        System.debug('checkUrgentAppointmentStatus... appointment.UrgentApptStatus__c ' + appointment.UrgentApptStatus__c);                         
        Appointment__c appointmentToReturn;
        try {                         
            switch on appointment.UrgentApptStatus__c {                                
                when 'NotEarly' { 
                    appSaveSlotIdSet.add(appointment.UrgentAppointment__c);                                         
                    appointmentToReturn = new Appointment__c(
                        Id = appointment.Id,
                        UrgentAppointment__c = null,
                        UrgentRefusalNum__c = appointment.UrgentRefusalNum__c+1                                                                  
                    );
                }               
                when 'Unsubscribe' {
                    appSaveSlotIdSet.add(appointment.UrgentAppointment__c);  
                    appointmentToReturn = new Appointment__c(
                        Id = appointment.Id,
                        Is_Urgent__c = false,
                        UrgentAppointment__c = null 
                    );
                }
                when 'MessSent' {
                    Datetime now = Datetime.now();
                    if (appointment.UrgentApptMessageDate__c < now.addMinutes(-15)) {
                        appSaveSlotIdSet.add(appointment.UrgentAppointment__c);                        
                        appointmentToReturn = new Appointment__c(
                            Id = appointment.Id,
                            UrgentApptStatus__c = 'NotAnswer',
                            UrgentAppointment__c = null,
                            UrgentRefusalNum__c = appointment.UrgentRefusalNum__c == null ? 1  : appointment.UrgentRefusalNum__c + 1  
                        );                            
                    }                   
                } 
                when null {
                    if (appointment.UrgentApptMessageDate__c == null) {
                        smsToInsertList.add(prepareSMS(appointment)); 
                        appointmentToReturn = new Appointment__c(
                            Id = appointment.Id,
                            UrgentApptStatus__c = 'MessSent',                            
                            UrgentApptMessageDate__c = Datetime.now() 
                        ); 

                    }
                }                    
            }          
        } catch(Exception e) {
            System.debug('Error: An exception has been encountered UrgentAppointmentsSchedulableBatch: ' + e.getMessage());
        }

        System.debug('appointmentToReturn: ' + appointmentToReturn);
        return appointmentToReturn;   
    }                

    public List<Appointment__c> findOtherUrgentApp(Set<Id> appointmentIdSet) {
        Set<Id> calendarIdSet = new Set<Id>();
        Set<Id> procedureIdSet = new Set<Id>();
        List<Appointment__c> saveApptsList = new List<Appointment__c>();
        List<Appointment__c> unLockSlotApp = new List<Appointment__c>();
        List<Appointment__c> appointmentsToReturn = new List<Appointment__c>();       
        Map<String, Map<Id, Appointment__c>> keyToApptsMap = new Map<String, Map<Id, Appointment__c>>();
    
        for (Appointment__c appt_i : [SELECT Id
                                          , case__c
                                          , Case__r.SMS_Phone_Number__c
                                          , Site__c
                                          , Calendar__c
                                          , Calendar__r.ServiceId__c
                                          , Medical_Procedure__c
                                          , Medical_Procedure__r.Name
                                          , Medical_Procedure__r.Procedure_Code__c
                                          , Appointment_Status__c
                                          , Days_Until_Appointment__c                  
                                          , Patient_Account__r.ID_Type__c
                                          , Patient_Account__r.ID_Number__c
                                          , Patient_Account__r.SMS_Phone_number__c
                                          , PayerFactor__r.InsuranceCode__c 
                                          , Duration__c
                                          , Appointment_Date__c                                                                               
                                          , Appointment_Date_Time__c 
                                     FROM Appointment__c
                                     WHERE Id IN :appointmentIdSet
                                     AND UrgentApptSaveSlot__c = true
                                     AND Appointment_Date_Time__c > TODAY]) {
            saveApptsList.add(appt_i);
            calendarIdSet.add(appt_i.Calendar__c);
            procedureIdSet.add(appt_i.Medical_Procedure__c);            
        }
        
        for (Appointment__c appt_j : [SELECT Id
                                            , case__c
                                            , Case__r.SMS_Phone_Number__c
                                            , Site__c
                                            , Calendar__c
                                            , Calendar__r.ServiceId__c
                                            , Medical_Procedure__c
                                            , Medical_Procedure__r.Name
                                            , Medical_Procedure__r.Procedure_Code__c
                                            , Appointment_Status__c
                                            , Days_Until_Appointment__c                  
                                            , Patient_Account__r.ID_Type__c
                                            , Patient_Account__r.ID_Number__c
                                            , Patient_Account__r.SMS_Phone_number__c
                                            , PayerFactor__r.InsuranceCode__c 
                                            , UrgentRefusalNum__c
                                            , UrgentApptStatus__c
                                            , UrgentApptTitanLink__c
                                            , UrgentApptMessageDate__c
                                            , UrgentAppointment__c 
                                            , UrgentAppointment__r.Duration__c
                                            , UrgentAppointment__r.Calendar__c
                                            , UrgentAppointment__r.Appointment_Date__c                                                                               
                                            , UrgentAppointment__r.Appointment_Date_Time__c 
                                            , UrgentAppointment__r.Calendar__r.ServiceId__c
                                            , UrgentAppointment__r.Medical_Procedure__c
                                            , UrgentAppointment__r.Medical_Procedure__r.Name
                                            , UrgentAppointment__r.Medical_Procedure__r.Procedure_Code__c             
                                    FROM Appointment__c
                                    WHERE Is_Urgent__c = true                                                        
                                        AND UrgentAppointment__c = null                                     
                                        AND Appointment_Date_Time__c >= TODAY 
                                        AND Calendar__c IN :calendarIdSet
                                        AND Medical_Procedure__c IN :procedureIdSet
                                        AND Medical_Procedure__r.Confidentiality__c = false
                                        AND (UrgentApptMessageDate__c = null OR UrgentApptMessageDate__c != TODAY )
                                        AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed') 
                                    ORDER BY UrgentPointNum__c DESC]) {
            if (!keyToApptsMap.containsKey(appt_j.Medical_Procedure__c + '-' + appt_j.Calendar__c)) {
                keyToApptsMap.put(appt_j.Medical_Procedure__c + '-' + appt_j.Calendar__c, new Map<Id, Appointment__c>());
            }
            keyToApptsMap.get(appt_j.Medical_Procedure__c + '-' + appt_j.Calendar__c).put(appt_j.Id, appt_j);                            
        }
        
        System.debug('keyToApptsMap: [' + keyToApptsMap.size() + '] value: ' + keyToApptsMap);       
        if (!keyToApptsMap.isEmpty()) {
            for (Appointment__c appt :saveApptsList) {
                Map<Id, Appointment__c> apptMap = keyToApptsMap.containsKey(appt.Medical_Procedure__c + '-' + appt.Calendar__c) ? keyToApptsMap.get(appt.Medical_Procedure__c + '-' + appt.Calendar__c) : null;
                if (apptMap != null && !apptMap.isEmpty()) {
                    Appointment__c firstApp = apptMap.values()[0];                 
                    appointmentsToReturn.add(new Appointment__c(
                                                    Id = firstApp.Id,
                                                    UrgentAppointment__c = appt.Id,
                                                    UrgentApptStatus__c = 'MessSent',                            
                                                    UrgentApptMessageDate__c = Datetime.now()                                                               
                                                ));
                    smsToInsertList.add(prepareSMS(firstApp)); 
                    keyToApptsMap.get(appt.Medical_Procedure__c + '-' + appt.Calendar__c).remove(firstApp.Id);
                } else{
                    unLockSlotApp.add(appt);
                }
            }
        } else {
            unLockSlotApp.addAll(saveApptsList);
        }   
                
        if (!unLockSlotApp.isEmpty()) {
            for (Appointment__c appt_i :unLockSlotApp) {
                 ws_RisRemarks.updateRemark('unlockSlotSF'
                                            , appt_i.Medical_Procedure__r.Name
                                            , appt_i.Medical_Procedure__r.Procedure_Code__c
                                            , appt_i.Calendar__r.ServiceId__c
                                            , String.valueOf(appt_i.Appointment_Date_Time__c) 
                                            , Integer.valueOf(appt_i.Duration__c));                                                                                     
                         
                appointmentsToReturn.add(new Appointment__c(
                                                Id = appt_i.Id,
                                                UrgentApptSaveSlot__c = false                                                                                                            
                                            ));
            }
        }
        System.debug('appointmentsToReturn: ' + appointmentsToReturn);
        return appointmentsToReturn;
    }   
    
    public SMS__c prepareSMS(Appointment__c appt) {
        return new SMS__c(
            Type__c = 'Outgoing',            
            Appointment__c = appt.Id,
            Phone_Number__c = getPhoneNumber(appt),
            smsTemplate__c = 'WaitingListApptProposalSMS', 
            Automation_name__c = 'UrgentAppointmentsSchedulableBatch'        
        );
    }

    public String getPhoneNumber(Appointment__c appt) {
        String phone = appt.Case__c != null && appt.Case__r.SMS_Phone_Number__c != null
            ? appt.Case__r.SMS_Phone_Number__c
            : appt.Patient_Account__r.SMS_Phone_number__c;
        return phone;
    }
}