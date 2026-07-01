public with sharing class InstitutesTRDispatcher {

    /**
     * Check if an Appointment already exist for the specified time (+- minutes from the Same_appointment_Minutes
     * custom label) for the chosen doctor/patient. Do not allow scheduling an appointment if another one already
     * in the system.
     */
    public static void checkExistingAppointments(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c checkExistingAppointments ... start');
        Integer offsetMinutes = Integer.valueOf(Label.Same_appointment_Minutes);
        Set<Id> patientIds = new Set<Id>();
        Set<Id> doctorIds = new Set<Id>();
        Datetime minDatetime;
        Datetime maxDatetime;

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Date_Time__c != null && !appt_i.IsForced__c) {
                if (maxDatetime == null || appt_i.Appointment_Date_Time__c.addMinutes(offsetMinutes) > maxDatetime) {
                    maxDatetime = appt_i.Appointment_Date_Time__c.addMinutes(offsetMinutes);
                }
                if (minDatetime == null || appt_i.Appointment_Date_Time__c.addMinutes(-1 * offsetMinutes) < minDatetime) {
                    minDatetime = appt_i.Appointment_Date_Time__c.addMinutes(-1 * offsetMinutes);
                }

                if (appt_i.Doctor_Account__c != null
                        && appt_i.Appointment_Status__c != 'Canceled'
                        && appt_i.Appointment_Status__c != 'Urgent_WaitingList'
                        && (Trigger.isInsert
                            || oldMap.get(appt_i.Id).Doctor_Account__c != appt_i.Doctor_Account__c
                            || oldMap.get(appt_i.Id).Appointment_Date_Time__c != appt_i.Appointment_Date_Time__c)) {
                    doctorIds.add(appt_i.Doctor_Account__c);
                }
                if (appt_i.Patient_Account__c != null
                        && appt_i.Appointment_Status__c != 'Canceled'
                        && appt_i.Appointment_Status__c != 'Urgent_WaitingList'
                        && (Trigger.isInsert
                            || oldMap.get(appt_i.Id).Patient_Account__c != appt_i.Patient_Account__c
                            || oldMap.get(appt_i.Id).Appointment_Date_Time__c != appt_i.Appointment_Date_Time__c)) {
                    patientIds.add(appt_i.Patient_Account__c);
                }
            }
        }
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
        System.debug('minDatetime: ' + minDatetime + ' maxDatetime: ' + maxDatetime);

        if (!patientIds.isEmpty() || !doctorIds.isEmpty()) {
            InstitutesTRService.checkExistingAppointments(newList, patientIds, doctorIds, minDatetime, maxDatetime);
        }
    }

    /**
     * Fill accurate_site__c and Exact_Location_In_Domain__c fields with values from a Site_Domain__c object
     * linked via Domain__c and Site__c lookup fields
     */
    public static void syncWithSiteDomain(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c syncWithSiteDomain ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> domainIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Site__c != null
                    //&& appt_i.Domain__c != null remove for Ashdod 2706244750
                    && (Trigger.isInsert
                        || oldMap.get(appt_i.Id).Site__c != appt_i.Site__c
                        || oldMap.get(appt_i.Id).Domain__c != appt_i.Domain__c)) {
                appts.add(appt_i);
                siteIds.add(appt_i.Site__c);
                domainIds.add(appt_i.Domain__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('domainIds: size: ' + domainIds.size() + ' value: ' + domainIds);
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);

        if (!appts.isEmpty()) {
            InstitutesTRService.syncWithSiteDomain(appts, domainIds, siteIds);
        }
    }
    
    /**
     * Retrieving Referrals and Commitments from Maccabi for Appointments scheduled in the
     * source system
     */
    public static void retAmbulatoryReferralsAndCommitments(List<Appointment__c> newList) {
        System.debug('TR Appointment__c retAmbulatoryReferralsAndCommitments ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.PayerFactor__c != null && appt_i.Medical_Procedure__c != null) {
                apptIds.add(appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            InstitutesTRService.retAmbulatoryReferralsAndCommitments(apptIds);
        }
    }

    /**
     * Fill PreSurgery__c field in Surgeries Appointment
     */
    public static void relatedPreSurgeryToSurgery(List<Appointment__c> newList) {
        System.debug('TR Appointment__c relatedPreSurgeryToSurgery ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('relatedPreSurgeryToSurgery', appt_i.Id)
                    && appt_i.Patient_Account__c != null && appt_i.Appointment_Date_Time__c != null) {
                apptIds.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('relatedPreSurgeryToSurgery', appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            InstitutesTRService.relatedPreSurgeryToSurgery(apptIds);
            System.debug('TR Appointment__c relatedPreSurgeryToSurgery ... future');
        }
    }

    /**
     * When a pre-surgery appointment is canceled the connection should be removed from the surgery
     */
    public static void cancelPreSurgery(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c cancelPreSurgery ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('cancelPreSurgery', appt_i.Id)    
                    && appt_i.Appointment_Status__c == 'Canceled'
                    && appt_i.Appointment_Status__c != oldMap.get(appt_i.Id).Appointment_Status__c) {
                apptIds.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('cancelPreSurgery', appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            InstitutesTRService.cancelPreSurgery(apptIds);
            System.debug('TR Appointment__c cancelPreSurgery ... future');
        }
    }

    /**
     * When updated appointment has to update file in RIS system 
     */
    public static void updateForwardToRIS(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateForwardToRIS ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('updateForwardToRIS', appt_i.Id)
                    && appt_i.SourceSystem__c == 'RIS'
                    && appt_i.Accession_Number__c != null
                    && (appt_i.Appointment_Status__c == 'WaitingForAppointment' || appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה')
                    && appt_i.Accession_Number__c != oldMap.get(appt_i.Id).Accession_Number__c) {
                apptIds.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('updateForwardToRIS', appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            InstitutesTRService.updateForwardToRIS(apptIds);
            System.debug('TR Appointment__c updateForwardToRIS ... future');
        }
    }
    
    /**
     * When inserted/updated appointment has to send WA to patient 
     */
    public static void SendingWhatsApp(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c SendingWhatsApp ... start');
        List<Appointment__c> filteredApptList = new List<Appointment__c>(); 
        Set<String> types = new Set<String>{'1','4','6','7'}; 
        Set<Id> apptIds = new Set<Id>();            

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('SendingWhatsApp', appt_i.Id)
                    && appt_i.Case__c != null
                    && appt_i.Patient_Account__c != null
                    && appt_i.Accession_Number__c  != null
                    && appt_i.Medical_Procedure__c != null
                    && appt_i.sendingByWhatsApp__c == true
                    && appt_i.sent_kit_confirmation__c == false
                    && !types.contains(appt_i.PatientType__c) ){      
                filteredApptList.add(appt_i);                
            }
        }
        System.debug('filteredApptList: [' + filteredApptList.size() + '] value: ' + filteredApptList);

        if (filteredApptList.isEmpty()) {
            return;
        }

        Map<Id, Appointment__c> appointmentMap = new Map<Id, Appointment__c>([
            SELECT Site__r.SiteReferenceDigitalLobby__c
                 , Medical_Procedure__r.Domain__r.DomainCode__c
              FROM Appointment__c
             WHERE Id IN :filteredApptList]);

        for (Appointment__c appt_i : filteredApptList) {            
            if ((oldMap == null
                        || (appt_i.Accession_Number__c != oldMap.get(appt_i.Id).Accession_Number__c
                        || (appt_i.ReceiptNum__c != null && appt_i.ReceiptNum__c != oldMap.get(appt_i.Id).ReceiptNum__c)
                        /*|| (appt_i.sendingByWhatsApp__c != oldMap.get(appt_i.Id).sendingByWhatsApp__c
                           && appt_i.manualRunWAR__c == oldMap.get(appt_i.Id).manualRunWAR__c)*/))
                    && ((oldMap != null && !(appt_i.Accession_Number__c != null && oldMap.get(appt_i.Id).Accession_Number__c == null))
                        || !appointmentMap.get(appt_i.Id).Site__r.SiteReferenceDigitalLobby__c
                        || appointmentMap.get(appt_i.Id).Medical_Procedure__r.Domain__r.DomainCode__c != 504)) {
                apptIds.add(appt_i.Id);                
                AppointmentTriggerUtil.addExecutedRecordId('SendingWhatsApp', appt_i.Id);               
            }
        }
        System.debug('apptIds: [' + apptIds.size() + '] value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            InstitutesTRService.SendingWhatsApp(apptIds);
            System.debug('TR Appointment__c SendingWhatsApp ... future');
        }
    }       
    
    /**
     * Associates urgent future appointments with canceled appointments 
     * that have the same calendar and procedure code, 
     * and locks the slot in the source system.
     */
    public static void checkUrgentAppointments(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c checkUrgentAppointments ... start');                
        Set<Id> calendarIdSet = new Set<Id>();
        Set<Id> procedureIdSet = new Set<Id>();
        Set<Id> appointmentIdSet = new Set<Id>();
        
        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('checkUrgentAppointments', appt_i.Id)  
                    && appt_i.Calendar__c != null
                    && appt_i.Medical_Procedure__c != null 
                    && appt_i.UrgentApptSaveSlot__c == true                    
                    && appt_i.UrgentApptSaveSlot__c != oldMap.get(appt_i.Id).UrgentApptSaveSlot__c) {
                appointmentIdSet.add(appt_i.Id);
                calendarIdSet.add(appt_i.Calendar__c);
                procedureIdSet.add(appt_i.Medical_Procedure__c); 
                AppointmentTriggerUtil.addExecutedRecordId('checkUrgentAppointments', appt_i.Id);                  
            }
        }
        
        System.debug('calendarIdSet: [' + calendarIdSet.size() + '] value: ' + calendarIdSet);
        System.debug('procedureIdSet: [' + procedureIdSet.size() + '] value: ' + procedureIdSet);
        System.debug('appointmentIdSet: [' + appointmentIdSet.size() + '] value: ' + appointmentIdSet);        

        if (!appointmentIdSet.isEmpty()) {           
            InstitutesTRService.checkUrgentAppointments(appointmentIdSet, calendarIdSet, procedureIdSet);
            System.debug('TR Appointment__c checkUrgentAppointments ... future');            
        }
    }
    
    /**
     * set appointment when UrgentApptStatus__c change to Early
     */
    public static void changeUrgentStatus(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c changeUrgentStatus ... start');                       
        Set<Id> appointmentIdSet = new Set<Id>();
        
        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('changeUrgentStatus', appt_i.Id) 
                    && appt_i.UrgentAppointment__c != null
                    && appt_i.UrgentApptStatus__c == 'Early'                    
                    && appt_i.UrgentApptStatus__c != oldMap.get(appt_i.Id).UrgentApptStatus__c) {
                appointmentIdSet.add(appt_i.Id); 
                AppointmentTriggerUtil.addExecutedRecordId('changeUrgentStatus', appt_i.Id);                             
            }
        }               
        System.debug('appointmentIdSet: [' + appointmentIdSet.size() + '] value: ' + appointmentIdSet);        

        if (!appointmentIdSet.isEmpty()) {           
            InstitutesTRService.changeUrgentStatus(appointmentIdSet);
            System.debug('TR Appointment__c changeUrgentStatus ... future');            
        }
    }

    /**
     * set BarcodeIdentifyTime field if BarcodeIdentifyPatient__c field in domain and site object equal to true.
     */
    public static void setBarcodeIdentifyTime(List<Appointment__c> newList,  Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c setBarcodeIdentifyTime ... start');                              
        Set<Id> siteIdSet = new Set<Id>();
        Set<Id> domainIdSet = new Set<Id>();
        List<Appointment__c> appointmentSet = new List<Appointment__c>();
        for (Appointment__c appt_i : newList) {
            if (appt_i.Site__c != null                   
                    && appt_i.Domain__c != null 
                    && appt_i.Appointment_Date_Time__c != null
                    && appt_i.sendingByWhatsApp__c == true
                    && (oldMap == null 
                        || appt_i.Site__c != oldMap.get(appt_i.Id).Site__c
                        || appt_i.Domain__c != oldMap.get(appt_i.Id).Domain__c   
                        || appt_i.manualRunWAR__c != oldMap.get(appt_i.Id).manualRunWAR__c                       
                        || appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c )){                                 
                siteIdSet.add(appt_i.Site__c);
                domainIdSet.add(appt_i.Domain__c);
                appointmentSet.add(appt_i);                                       
            }
        }               
        System.debug('siteIdSet: [' + siteIdSet.size() + '] value: ' + siteIdSet);        
        System.debug('domainIdSet: [' + domainIdSet.size() + '] value: ' + domainIdSet);        
        System.debug('appointmentSet: [' + appointmentSet.size() + '] value: ' + appointmentSet);        
        if (!appointmentSet.isEmpty()) {           
            InstitutesTRService.setBarcodeIdentifyTime(appointmentSet, domainIdSet, siteIdSet);
            System.debug('TR Appointment__c setBarcodeIdentifyTime');            
        }
    }

    /**
     * send Cpap Survey when SendSurvey__c field in appointment object equal to true.
     */
    public static void createCpapSurvey(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c createCpapSurvey ... start');                       
        Set<Id> appointmentIdSet = new Set<Id>();
        
        for (Appointment__c appt_i : newList) {
            if (appt_i.SendSurvey__c == true                                      
                    && appt_i.SendSurvey__c != oldMap.get(appt_i.Id).SendSurvey__c) {
                appointmentIdSet.add(appt_i.Id);                                                                       
            }
        }               
        System.debug('appointmentIdSet: [' + appointmentIdSet.size() + '] value: ' + appointmentIdSet);        

        if (!appointmentIdSet.isEmpty()) {           
            InstitutesTRService.createCpapSurvey(appointmentIdSet);
            System.debug('TR Appointment__c createCpapSurvey ... future');            
        }
    } 
    
    public static void linkAppointments(List<Appointment__c> newList) {
        System.debug('TR Appointment__c linkAppointments... start');
        Set<Id> patientIdSet = new Set<Id>();                                     
        Set<String> procedureCodes = new Set<String>();
        Map<Id, Appointment__c> appointmentMap = new Map<Id, Appointment__c>();  
         
        for (Appointment__c appt_i : newList) {
            if (appt_i.Domain__c != null
                    && appt_i.Patient_Account__c != null
                    && appt_i.Medical_Procedure__c != null                    
                    && appt_i.after_appointment__c == null) {                
                appointmentMap.put(appt_i.Id, appt_i);  
                procedureCodes.add(appt_i.MP_code__c);       
                patientIdSet.add(appt_i.Patient_Account__c);                
            }            
        }   

        //select Medical_Procedure_Link__mdt
        System.debug('procedureCodes: [' + procedureCodes.size() + '] value: ' + procedureCodes);                
        if (!procedureCodes.isEmpty()) {            
            Map<String, List<Medical_Procedure_Link__mdt>> medicalProcedureLinkMap = new Map<String, List<Medical_Procedure_Link__mdt>>();                
            for (Medical_Procedure_Link__mdt md : [
                SELECT ProcedureCode1__c, ProcedureCode2__c, DomainCode__c
                FROM Medical_Procedure_Link__mdt
                WHERE ProcedureCode1__c IN :procedureCodes
            ]) {
                if (!medicalProcedureLinkMap.containsKey(md.ProcedureCode1__c)){
                    medicalProcedureLinkMap.put(md.ProcedureCode1__c, new List<Medical_Procedure_Link__mdt>());      
                }   
                medicalProcedureLinkMap.get(md.ProcedureCode1__c).add(md);                            
            } 
            System.debug('medicalProcedureLinkMap: [' + medicalProcedureLinkMap.size() + '] value: ' + medicalProcedureLinkMap); 

            if (!medicalProcedureLinkMap.isEmpty()) {           
                InstitutesTRService.linkAppointments(appointmentMap, patientIdSet, medicalProcedureLinkMap);
                System.debug('TR Appointment__c linkAppointments ...');            
            }
        } 
    }  
}