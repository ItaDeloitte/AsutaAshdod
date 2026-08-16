public with sharing class SurgeriesTRDispatcher {

    public static void agreementCheckBoxPopulation(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c agreementCheckBoxPopulation ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        
        for (Appointment__c appt_i: newList) {
            if (appt_i.Check_Trigger_Agreement_to_Doctor__c
                    && (Trigger.isInsert
                        || appt_i.PayerFactor__c != oldMap.get(appt_i.Id).PayerFactor__c
                        || appt_i.Doctor_Account__c != oldMap.get(appt_i.Id).Doctor_Account__c)) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' values: ' + appts);

        if (!appts.isEmpty()) {
            SurgeriesTRService.agreementCheckBoxPopulation(appts);
        }
    }

    /**
     * Calculate Final_Cost_of_Med_1__c/-2/-3/-4 based on Cost_of_medical_operation1__c/-2/-3/-4 values
     */
    public static void calculateFinalPrices(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c calculateFinalPrices ... start');
        Map<Id, Map<String, Integer>> apptIdToCostsMap = new Map<Id, Map<String, Integer>>();
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (Trigger.isInsert
                    || oldMap.get(appt_i.Id).Cost_of_medical_operation1__c != appt_i.Cost_of_medical_operation1__c
                    || oldMap.get(appt_i.Id).Cost_of_medical_operation2__c != appt_i.Cost_of_medical_operation2__c
                    || oldMap.get(appt_i.Id).Cost_of_medical_operation3__c != appt_i.Cost_of_medical_operation3__c
                    || oldMap.get(appt_i.Id).Cost_of_medical_operation4__c != appt_i.Cost_of_medical_operation4__c) {
                appts.add(appt_i);
                apptIdToCostsMap.put(appt_i.Id, new Map<String, Integer>());
                for (String cost_i : AppointmentTriggerUtil.COST_TO_FINAL_COST_MAP.keySet()) {
                    if (appt_i.get(cost_i) != null && appt_i.get(cost_i) != '0') {
                        apptIdToCostsMap.get(appt_i.Id).put(cost_i, Integer.valueOf(appt_i.get(cost_i)));
                    }
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('apptIdToCostsMap: size: ' + apptIdToCostsMap.size() + ' value: ' + apptIdToCostsMap);

        if (!appts.isEmpty()) {
            SurgeriesTRService.calculateFinalPrices(appts, apptIdToCostsMap);
        }
    }

    /**
     * Mark Miss_match_medical_pro_1__c/-2/-3/-4 if Spincal__c and Referral_from_doctor_website__c
     * are not null and Spincal__r.Opercode__c/-2/-3/-4 is not equal to
     * Referral_from_doctor_website__r.Medical_Procedure_1__c/-2/-3/-4
     */
    public static void markMissMatchMP(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c markMissMatchMP ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> referralIds = new Set<Id>();
        Set<Id> spincalIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Spincal__c != null
                    && appt_i.Referral_from_doctor_website__c != null
                    && (Trigger.isInsert
                        || oldMap.get(appt_i.Id).Spincal__c != appt_i.Spincal__c
                        || oldMap.get(appt_i.Id).Referral_from_doctor_website__c != appt_i.Referral_from_doctor_website__c)) {
                appts.add(appt_i);
                spincalIds.add(appt_i.Spincal__c);
                referralIds.add(appt_i.Referral_from_doctor_website__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('spincalIds: size: ' + spincalIds.size() + ' value: ' + spincalIds);
        System.debug('referralIds: size: ' + referralIds.size() + ' value: ' + referralIds);

        if (!appts.isEmpty()) {
            SurgeriesTRService.markMissMatchMP(appts, spincalIds, referralIds);
        }
    }

    /**
     * Fill Patient_Mail__c field with value from a Patient_Account__c
     */
    public static void fillPatientEmail(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillPatientEmail ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> patientIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Patient_Account__c != null && appt_i.Patient_Mail__c == null) {
                patientIds.add(appt_i.Patient_Account__c);
                appts.add(appt_i);
            }
        }
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            SurgeriesTRService.fillPatientEmail(appts, patientIds);
        }
    }

    /**
     * Fill Domain__c field with default value from the Surgery_Domain_ID custom label
     */
    public static void fillSurgeryDomain(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillSurgeryDomain ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            appts.add(appt_i);
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            SurgeriesTRService.fillSurgeryDomain(appts);
        }
    }

    /**
     * Fill GuidForMaccabi__c field by generated randomly key
     */
    public static void updateMaccabiGuid(List<Appointment__c> newList) {
        System.debug('TR Appointment__c updateMaccabiGuid ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            appts.add(appt_i);
        }
        
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        if(!appts.isEmpty()){
            SurgeriesTRService.updateMaccabiGuid(appts);
        }
    }

    /**
     * Fill PreSurgery__c field by preSurgery Appointment
     */
    public static void relatedSurgeryToPreSurgery(List<Appointment__c> newList) {
        System.debug('TR Appointment__c RelatedSurgeryToPreSurgery ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> patientIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Patient_Account__c != null && appt_i.Appointment_Date_Time__c != null) {
                appts.add(appt_i);
                patientIds.add(appt_i.Patient_Account__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);

        if (!appts.isEmpty() && !patientIds.isEmpty()) {
            SurgeriesTRService.relatedSurgeryToPreSurgery(appts, patientIds);
        }
    }

    /**
     * Set Doctor_License_From_Referral__c based on Doctor_Account__r.Doctor_Code__c value
     */
    public static void fillReferringDoctor(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillReferringDoctor ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> doctorIds = new Set<Id>();
               
        for (Appointment__c appt_i : newList) {
            if (appt_i.Doctor_Account__c != null && appt_i.Doctor_License_From_Referral__c == null) {
                appts.add(appt_i);
                doctorIds.add(appt_i.Doctor_Account__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        if (!appts.isEmpty()) {
            SurgeriesTRService.fillReferringDoctor(appts, doctorIds);
        }
    }

    /**
     * Mark FollowingTheTelemedicineSession__c if conditions are met
     */
    public static void markFollowingTelemedicineSession(List<Appointment__c> newList) {
        System.debug('TR Appointment__c markFollowingTelemedicineSession ... start');
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        Set<Id> procedureIdSet = new Set<Id>();
        Set<Id> patientIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Patient_Account__c != null
                    && appt_i.Medical_Procedure__c != null) {
                appointmentList.add(appt_i);
                patientIdSet.add(appt_i.Patient_Account__c);
                procedureIdSet.add(appt_i.Medical_Procedure__c);
            }
        }
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);
        System.debug('procedureIdSet: size: ' + procedureIdSet.size() + ' value: ' + procedureIdSet);
        System.debug('patientIdSet: size: ' + patientIdSet.size() + ' value: ' + patientIdSet);

        if (!appointmentList.isEmpty()) {
            SurgeriesTRService.markFollowingTelemedicineSession(appointmentList, procedureIdSet, patientIdSet);
        }
    }

    /**
     * Enqueue ws_getPrices_REST job with Surgeries Appointment details
     */
    public static void getPricesJob(List<Appointment__c> newList) {
        System.debug('TR Appointment__c getPricesJob ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            apptIds.add(appt_i.Id);
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            SurgeriesTRService.getPricesJob(apptIds);
        }
    }

    /**
     * Create new Implants_mp_apt__c record based on Implants_to_med_prod__c
     * records linked via Medical_Procedure__c/-2/-3/-4
     */
    public static void createImplats(List<Appointment__c> newList) {
        System.debug('TR Appointment__c createImplats ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> procedureIds = new Set<Id>();

        for (Appointment__c appt_i : newList) { 
            appts.add(appt_i);
            for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                if (appt_i.get(procedureLookup_i) != null) {
                    procedureIds.add(Id.valueOf((String) appt_i.get(procedureLookup_i)));
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' values: ' + appts);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' values: ' + procedureIds);

        if (!appts.isEmpty() && !procedureIds.isEmpty()) {
            SurgeriesTRService.createImplats(appts, procedureIds);
        }
    }

    /**
     * Update the related Case's Domain__c, Site__c and Surgery_PayerFactor__c
     * fields with values from the Appointment fields
     */
    public static void updateSurgeryCase(List<Appointment__c> newList) {
        System.debug('TR Appointment__c updateSurgeryCase ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Case__c != null) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            SurgeriesTRService.updateSurgeryCase(appts);
        }
    }

    /**
     * Assign Case to the 'Surgeries' Queue (Surgeries_QueueId custom label) if the
     * Patient_Account__c.Preferred_Channel__c is blank. Create Assuta KIT File, update
     * an appointment's status and close the related case
     */
    public static void createKITFile(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c createKITFile ... start');
        Map<Id, KITWrapper> apptsMap = new Map<Id, KITWrapper>();
        Set<Id> caseIdsToAssignToQueue = new Set<Id>();
        Set<Id> apptIds = new Set<Id>();
        Boolean digitalLobby = false;

        for (Appointment__c appt_i : newList) {
            if (appt_i.Case__c != null
                    && appt_i.Patient_Account__c != null
                    && appt_i.Date_of_appointment__c != null
                    && (Trigger.isInsert
                        || oldMap.get(appt_i.Id).Commitment_Status__c != appt_i.Commitment_Status__c
                        || oldMap.get(appt_i.Id).Appointment_Status__c != appt_i.Appointment_Status__c
                        || oldMap.get(appt_i.Id).Agreement_with_assuta__c != appt_i.Agreement_with_assuta__c)) {
                apptIds.add(appt_i.Id);
            }
        }

        List<Appointment__c> appts = [
            SELECT Id
                 , Case__c
                 , Kit_Link__c
                 , Didkitsent__c
                 , Deductibles__c
                 , Patient_Mail__c
                 , text_for_kit__c
                 , No_Automation__c
                 , Classification__c
                 , Commitment_Status__c
                 , Medical_Procedure__c
                 , Appointment_Status__c
                 , Prevent_Automation__c
                 , Help_Parent_Code_in__c
                 , Date_of_appointment__c
                 , Agreement_with_assuta__c
                 , Administrative_Status__c
                 , not_equal_doc_name__c
                 , not_equal_medp_name__c
                 , not_equal_medp2_name__c
                 , not_equal_medp3_name__c
                 , not_equal_medp4_name__c
                 , Miss_match_medical_pro_1__c
                 , Miss_match_medical_pro_2__c
                 , Miss_match_medical_pro_3__c
                 , Miss_match_medical_pro_4__c
                 , No_agreement_between_doc_and_payer__c
                 , Site__c
                 , Site__r.Name
                 , Site__r.Address__c
                 , Patient_Account__c
                 , Patient_Account__r.Phone
                 , Patient_Account__r.SMS_Phone_Number__c
                 , Patient_Account__r.Mailing_approval__c
                 , Patient_Account__r.Preferred_Channel__c
                 , Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c 
                 , Medical_Procedure2__r.Domain__r.ReferenceDigitalLobby__c
                 , Medical_Procedure3__r.Domain__r.ReferenceDigitalLobby__c
                 , Medical_Procedure4__r.Domain__r.ReferenceDigitalLobby__c
              FROM Appointment__c
             WHERE Id IN: apptIds];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Appointment__c appt_i : appts) {
            // without preferred channel
            if (appt_i.Patient_Account__r.Preferred_Channel__c == null) {
                // update appointment status without sending a file or assign case to the Surgeries queue
                if (appt_i.Help_Parent_Code_in__c == '4' || appt_i.Help_Parent_Code_in__c == '5') {
                    apptsMap.put(appt_i.Id, new KITWrapper(appt_i, null, true, false));
                } else {
                    caseIdsToAssignToQueue.add(appt_i.Case__c);
                }
            } else if (appt_i.Patient_Account__r.Mailing_approval__c != 'לא מאשר דיוור - הכל'
                    && !appt_i.Prevent_Automation__c
                    && !appt_i.No_Automation__c
                    && !appt_i.Didkitsent__c) {
                digitalLobby = checkDigitalLobby(appt_i);               
                if (appt_i.Medical_Procedure__c != null
                        && appt_i.Commitment_Status__c == '0'
                        && appt_i.Help_Parent_Code_in__c == '3'
                        && appt_i.Agreement_with_assuta__c == 'Y'
                        && appt_i.Classification__c != 'כתום'
                        && (appt_i.Deductibles__c == 0 || appt_i.Deductibles__c == null)
                        && !appt_i.not_equal_doc_name__c
                        && !appt_i.not_equal_medp_name__c
                        && !appt_i.not_equal_medp2_name__c
                        && !appt_i.not_equal_medp3_name__c
                        && !appt_i.not_equal_medp4_name__c
                        && !appt_i.Miss_match_medical_pro_1__c
                        && !appt_i.Miss_match_medical_pro_2__c
                        && !appt_i.Miss_match_medical_pro_3__c
                        && !appt_i.Miss_match_medical_pro_4__c
                        && !appt_i.No_agreement_between_doc_and_payer__c
                        && !digitalLobby) {
                    apptsMap.put(appt_i.Id, new KITWrapper(appt_i, 'Kit Maccabi', true, true));
                } else if (appt_i.Help_Parent_Code_in__c != '3'
                        && appt_i.Help_Parent_Code_in__c != '4'
                        && appt_i.Help_Parent_Code_in__c != '5'
                        && appt_i.Agreement_with_assuta__c == 'Y'
                        && !appt_i.No_agreement_between_doc_and_payer__c
                        && appt_i.Appointment_Status__c == 'WaitingForAppointment') {
                    apptsMap.put(appt_i.Id, new KITWrapper(appt_i, 'Kit NOT Maccabi', false, true));
                } else if ((appt_i.Help_Parent_Code_in__c == '4' || appt_i.Help_Parent_Code_in__c == '5')
                        && appt_i.Agreement_with_assuta__c == 'Y'
                        && appt_i.Appointment_Status__c == 'בטיפול אדמיניסטרטיבי'
                        && !digitalLobby) {
                    apptsMap.put(appt_i.Id, new KITWrapper(appt_i, 'Kit Leumit Meuhedet', true, true));
                } else if (appt_i.Classification__c == 'כתום'
                        && appt_i.Commitment_Status__c == '0'
                        && !digitalLobby
                        && (appt_i.Deductibles__c == 0 || appt_i.Deductibles__c == null)) {
                    apptsMap.put(appt_i.Id, new KITWrapper(appt_i, 'Maccabi Orange', true, true));
                }
            }
        }
        System.debug('caseIdsToAssignToQueue: size: ' + caseIdsToAssignToQueue.size() + ' value: ' + caseIdsToAssignToQueue);
        System.debug('apptsMap: size: ' + apptsMap.size() + ' value: ' + apptsMap.values());

        if (!caseIdsToAssignToQueue.isEmpty()) {
            SurgeriesTRService.assignSurgeryCaseToQueue(caseIdsToAssignToQueue);
        }

        if (!apptsMap.isEmpty()) {
            SurgeriesTRService.createKITFile(apptsMap);
        }
    }

    private static Boolean checkDigitalLobby(Appointment__c appt) {
        Integer counter = 0;
        if(appt.Medical_Procedure__c != null && appt.Medical_Procedure__r.Domain__c != null) {                                       
            counter ++;
        } 
        if(appt.Medical_Procedure2__c != null && appt.Medical_Procedure2__r.Domain__c != null) {
            counter ++;
        }
        if(appt.Medical_Procedure3__c != null && appt.Medical_Procedure3__r.Domain__c != null) {
            counter ++;
        }
        if(appt.Medical_Procedure4__c != null && appt.Medical_Procedure4__r.Domain__c != null) {
            counter ++;
        }
        System.debug('counter... ' +  counter);
        for(integer i = 1; i <= counter; i++){
            switch on i {
                when 1 {
                    return appt.Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c;                   
                }
                when 2 {
                    return appt.Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure2__r.Domain__r.ReferenceDigitalLobby__c;        
                }
                when 3 {
                    return appt.Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure2__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure3__r.Domain__r.ReferenceDigitalLobby__c;
                }
                when 4 {
                    return appt.Medical_Procedure__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure2__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure3__r.Domain__r.ReferenceDigitalLobby__c &&
                           appt.Medical_Procedure4__r.Domain__r.ReferenceDigitalLobby__c;
                }               
                when else{
                    return false;
                } 
            }
        }
        return false;
    }
       
    public class KITWrapper {
        public Appointment__c appt {get;set;}
        public String channelType {get;set;} // SMS / Email
        public String textForKIT {get;set;}
        public Boolean updateStatus {get;set;}
        public Boolean sendFile {get;set;}
        public Boolean isValid {get;set;}

        public KITWrapper(Appointment__c appt, String textForKIT, Boolean updateStatus, Boolean sendFile) {
            this.appt = appt;
            this.sendFile = sendFile;
            this.textForKIT = textForKIT;
            this.updateStatus = updateStatus;
            this.isValid = textForKIT == null ? true : false;

            if ((appt.Patient_Mail__c != null
                        && appt.Patient_Account__r.Preferred_Channel__c == 'Email')
                    || (appt.Site__c != null
                        && appt.Patient_Account__r.SMS_Phone_Number__c != null
                        && ((textForKIT == 'Kit Maccabi'
                                && (appt.Patient_Account__r.Preferred_Channel__c == 'SMS'
                                    || appt.Patient_Account__r.Preferred_Channel__c == 'Mail'
                                    || appt.Patient_Account__r.Preferred_Channel__c == 'Phone'))
                            || (textForKIT != 'Kit Maccabi'
                                && appt.Patient_Account__r.Preferred_Channel__c != 'Email')))) {
                this.channelType = appt.Patient_Account__r.Preferred_Channel__c == 'Email' ? 'Email' : 'SMS';
                this.textForKIT += ' ' + this.channelType;
                this.isValid = true;
            }
        }
    }

    /**
     * Retrieve referrals from Maccabi when Appointment creates
     */
    public static void retServiceReferrals(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c retServiceReferrals ... start');
        Set<Id> apptIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> doctorIds = new Set<Id>();
        Set<Id> procedureIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Agreement_with_assuta__c != oldMap.get(appt_i.Id).Agreement_with_assuta__c
                    || appt_i.Error_description_Mehironim__c != oldMap.get(appt_i.Id).Error_description_Mehironim__c ) {
                apptIds.add(appt_i.Id);
                if (appt_i.Site__c != null) {
                    siteIds.add(appt_i.Site__c);
                }
                if (appt_i.Doctor_Account__c != null) {
                    doctorIds.add(appt_i.Doctor_Account__c);
                }
                for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                    if (appt_i.get(procedureLookup_i) != null) {
                        procedureIds.add(Id.valueOf((String) appt_i.get(procedureLookup_i)));
                    }
                }
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);

        if (!apptIds.isEmpty()) {
            SurgeriesTRService.retServiceReferrals(apptIds, siteIds, doctorIds, procedureIds);
        }
    }

    /**
     * if appointment's agreement has changed to Y and it has an implant- call calculateImplantsForApp
     */
    public static void updateImplantsPrices(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateImplantsPrices ... start');
        Set<Id> apptIds = new Set<Id>();
        Set<String> skipCodes = new Set<String>{'3', '4', '5', '6', '7'};

        for (Appointment__c appt_i : newList) {
            if (appt_i.Agreement_with_assuta__c == 'Y'
                    && !skipCodes.contains(appt_i.Help_Parent_Code_in__c)
                    && (oldMap.get(appt_i.Id).PayerFactor__c != appt_i.PayerFactor__c
                        || oldMap.get(appt_i.Id).Agreement_with_assuta__c != appt_i.Agreement_with_assuta__c)) {
                apptIds.add(appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            Implants_mp_aptTriggerService.calculateImplantsForApp(apptIds);
        }
    }

    /**
     * Update all cases that related appointment by Surgery_Name__c field
     */
    public static void updateShikumBaitCases(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateShikumBaitCase... start');
        Map<Id, Appointment__c> apptMap = new Map<Id, Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Release_Date__c != oldMap.get(appt_i.Id).Release_Date__c
                    || appt_i.Admission_Date__c != oldMap.get(appt_i.Id).Admission_Date__c
                    || appt_i.Recommendation_Time__c != oldMap.get(appt_i.Id).Recommendation_Time__c
                    || appt_i.Shikum_Bait_Approval__c != oldMap.get(appt_i.Id).Shikum_Bait_Approval__c
                    || appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c
                    || appt_i.Shikum_Bait_Doctor_Rec__c != oldMap.get(appt_i.Id).Shikum_Bait_Doctor_Rec__c
                    || appt_i.Time_Approval_Shikum_Bait__c != oldMap.get(appt_i.Id).Time_Approval_Shikum_Bait__c) {
                apptMap.put(appt_i.Id, appt_i);
            }
        }
        System.debug('apptMap: size: ' + apptMap.size() + ' value: ' + apptMap);

        if (!apptMap.isEmpty()) {
            SurgeriesTRService.updateShikumBaitCases(apptMap);
        }
    }

    /**
     * Schedule IsServiceRetAnswSchedulableBatch directly for 1 minute ahead
     */
    public static Boolean isRetAnsFromTRIsFirstRun = true;
    public static void isRetAnsFromTR(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c isRetAnsFromTR... start');               
        Map<Id, Boolean> apptIdToResend = new Map<Id, Boolean>(); 

        for (Appointment__c appt_i : newList) {
            if (appt_i.IdNumberForMaccabi__c != null                    
                    && (appt_i.Commitment_Status__c == '6' || appt_i.Commitment_Status__c == '1b')
                    && ((appt_i.Classification__c == 'אדום' && appt_i.GuidForMaccabi__c != null) || appt_i.Classification__c != 'אדום')){
                    	if (appt_i.Number_batch_maccabi__c == null && oldMap.get(appt_i.Id).Commitment_Status__c != appt_i.Commitment_Status__c) {
                        	apptIdToResend.put(appt_i.Id, false);
                        } else if (oldMap.get(appt_i.Id).Number_of_commitment__c != appt_i.Number_of_commitment__c  
                                       && oldMap.get(appt_i.Id).Number_of_commitment__c != null) {
                        	apptIdToResend.put(appt_i.Id, true);
            			}            
        	}
        }
        System.debug('apptIdToResend: size: ' + apptIdToResend.size() + ' values: ' + apptIdToResend);

        if (!apptIdToResend.isEmpty() && isRetAnsFromTRIsFirstRun) { 
            Datetime dt = System.now().addSeconds(30);
            String CRONEXP = '' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            System.schedule('IsRetAns from trigger #' + dt.getTime(), CRONEXP, new IsServiceRetAnswSchedulableBatch(apptIdToResend));
            System.debug('TR Appointment__c isRetAnsFromTR ... future');
            isRetAnsFromTRIsFirstRun = false;
        }
    }
    
    /**
     * create ConsentFormTaken__c record for surgery Appointment
     * fields with values from the Appointment fields
     */
    public static void createConFormTaken(List<Appointment__c> newList) {
        System.debug('TR Appointment__c updateSurgeryCase ... start');
        Set<Id> apptIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Patient_Account__c != null
                    //&& appt_i.Domain__c != null
                    && appt_i.Site__c != null
                    && appt_i.Case__c != null) {
                apptIds.add(appt_i.Id);
                siteIds.add(appt_i.Site__c);
            }
        }
        System.debug('apptIds: [' + apptIds.size() + '] value: ' + apptIds);
        System.debug('siteIds: [' + siteIds.size() + '] value: ' + siteIds);
        if (!apptIds.isEmpty()) {
            SurgeriesTRService.createConFormTaken(apptIds, siteIds);
        }
    }
    
     /**
     * Create PreMedicalForAppointment__c records for surgery order PreMedicalProcedure__c obj
     */
    public static void createPreMedicalProcedure(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c createPreMedicalProcedure ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.site__c != null 
                    && appt_i.Medical_Procedure__c != null
                    && (Trigger.isInsert
                        || oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c
                        || oldMap.get(appt_i.Id).Medical_Procedure2__c != appt_i.Medical_Procedure2__c
                        || oldMap.get(appt_i.Id).Medical_Procedure3__c != appt_i.Medical_Procedure3__c
                        || oldMap.get(appt_i.Id).Medical_Procedure4__c != appt_i.Medical_Procedure4__c)) {
                apptIds.add(appt_i.Id);
                
            }
        }
        System.debug('apptIds: [' + apptIds.size() + '] value: ' + apptIds);        
        if (!apptIds.isEmpty()) {
         SurgeriesTRService.createPreMedicalProcedure(apptIds);
        }
    }
}