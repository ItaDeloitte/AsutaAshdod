public with sharing class SurgeriesTRService {

    public static void agreementCheckBoxPopulation(List<Appointment__c> newList) {
        Map<Id, Set<String>> doctorIdToPFsMap = new Map<Id, Set<String>>();

        for (Agreement__c agreement_i : [SELECT PayerFactor__c
                                              , Doctor_Account__c
                                           FROM Agreement__c
                                          WHERE Type_of_agreement__c = 'Surgery']) {
            if (!doctorIdToPFsMap.containsKey(agreement_i.Doctor_Account__c)) {
                doctorIdToPFsMap.put(agreement_i.Doctor_Account__c, new Set<String>());
            }
            doctorIdToPFsMap.get(agreement_i.Doctor_Account__c).add(agreement_i.PayerFactor__c);
        }
        System.debug('doctorIdToPFsMap: size: ' + doctorIdToPFsMap.size() + ' value: ' + doctorIdToPFsMap);

        for (Appointment__c appt_i : newList) {
            appt_i.No_agreement_between_doc_and_payer__c = !doctorIdToPFsMap.isEmpty()
                && (!doctorIdToPFsMap.containsKey(appt_i.Doctor_Account__c)
                    || !doctorIdToPFsMap.get(appt_i.Doctor_Account__c).contains(appt_i.PayerFactor__c));
        }
        System.debug('appts: size: ' + newList.size() + ' value: ' + newList);
        System.debug('TR Appointment__c agreementCheckBoxPopulation ... executed');
    }

    public static void calculateFinalPrices(List<Appointment__c> appts, Map<Id, Map<String, Integer>> apptIdToCostsMap) {
        for (Appointment__c appt_i : appts) {
            Integer maxValue_i = 0;
            String maxName_i;

            for (String cost_i : apptIdToCostsMap.get(appt_i.Id).keySet()) {
                if (apptIdToCostsMap.get(appt_i.Id).get(cost_i) > maxValue_i) {
                    maxValue_i = apptIdToCostsMap.get(appt_i.Id).get(cost_i);
                    maxName_i = cost_i;
                }
            }

            for (String cost_i : AppointmentTriggerUtil.COST_TO_FINAL_COST_MAP.keySet()) {
                String final_i = AppointmentTriggerUtil.COST_TO_FINAL_COST_MAP.get(cost_i);

                if (apptIdToCostsMap.get(appt_i.Id).containsKey(cost_i)) {
                    appt_i.put(
                        final_i,
                        maxName_i == cost_i
                            ? Integer.valueOf(appt_i.get(cost_i))
                            : Integer.valueOf((Integer.valueOf(appt_i.get(cost_i)) * 0.5).round(System.RoundingMode.HALF_UP)));
                } else {
                    appt_i.put(final_i, 0);
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c calculateFinalPrices ... executed');
    }

    public static void markMissMatchMP(List<Appointment__c> appts, Set<Id> spincalIds, Set<Id> referralIds) {
        Map<Id, Spincal__c> spincalsMap = new Map<Id, Spincal__c>([
            SELECT Opercode__c
                 , Opercode2__c
                 , Opercode3__c
                 , Opercode4__c
              FROM Spincal__c
             WHERE Id IN :spincalIds]);
        System.debug('spincalsMap: size: ' + spincalsMap.size() + ' value: ' + spincalsMap.values());

        Map<Id, Referral_from_doctor_website__c> referralsMap = new Map<Id, Referral_from_doctor_website__c>([
            SELECT Medical_Procedure_1__c
                 , Medical_Procedure_2__c
                 , Medical_Procedure_3__c
                 , Medical_Procedure_4__c
              FROM Referral_from_doctor_website__c
             WHERE Id IN :referralIds]);
        System.debug('referralsMap: size: ' + referralsMap.size() + ' value: ' + referralsMap.values());

        for (Appointment__c appt_i : appts) {
            Spincal__c spincal_i = spincalsMap.get(appt_i.Spincal__c);
            Referral_from_doctor_website__c referral_i = referralsMap.get(appt_i.Referral_from_doctor_website__c);
            appt_i.Miss_match_medical_pro_1__c = spincal_i.Opercode__c != referral_i.Medical_Procedure_1__c;
            appt_i.Miss_match_medical_pro_2__c = spincal_i.Opercode2__c != referral_i.Medical_Procedure_2__c;
            appt_i.Miss_match_medical_pro_3__c = spincal_i.Opercode3__c != referral_i.Medical_Procedure_3__c;
            appt_i.Miss_match_medical_pro_4__c = spincal_i.Opercode4__c != referral_i.Medical_Procedure_4__c;
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c markMissMatchMP ... executed');
    }

    public static void fillPatientEmail(List<Appointment__c> appts, Set<Id> patientIds) {
        Boolean logicExecuted = false;

        Map<Id, Account> patientsMap = new Map<Id, Account>([
            SELECT PersonEmail
              FROM Account
             WHERE Id IN: patientIds
               AND PersonEmail != null]);
        System.debug('patientsMap: size: ' + patientsMap.size() + ' value: ' + patientsMap);

        for (Appointment__c appt_i : appts) {
            if (patientsMap.containsKey(appt_i.Patient_Account__c)) {
                appt_i.Patient_Mail__c = patientsMap.get(appt_i.Patient_Account__c).PersonEmail;
                logicExecuted = true;
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c fillPatientEmail ... executed');
        }
    }

    public static void fillSurgeryDomain(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            appt_i.Domain__c = Label.Surgery_Domain_ID;
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c fillSurgeryDomain ... executed');
    }

    public static void updateMaccabiGuid(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            String guid = CommonService.generateRandomKey(34);
            appt_i.GuidForMaccabi__c = guid.left(8)
                + '-' + guid.substring(8, 12)
                + '-' + guid.substring(12, 16)
                + '-' + guid.substring(16, 20)
                + '-' + guid.right(12);
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c updateMaccabiGuid ... executed');
    }

    public static void relatedSurgeryToPreSurgery(List<Appointment__c> appts, Set<Id> patientIds) {
        Boolean logicExecuted = false;
        Integer numberOfDays;
        Map<Id, Id> surgeryToPreSurgeryMap = new Map<Id, Id>();
        Map<Id, List<Appointment__c>> patientToAppsMap = new Map<Id, List<Appointment__c>>();
        Set<Id> patients = new Set<Id>();

        for (Appointment__c appt_i :[SELECT Patient_Account__c
                                          , Date_of_appointment__c
                                       FROM Appointment__c
                                      WHERE RecordType.DeveloperName = 'Institutes'
                                        AND Patient_Account__c IN :patientIds
                                        AND Appointment_Status__c != 'Canceled'
                                        AND Domain__r.DomainCode__c = 504]) {
            if (!patientToAppsMap.containsKey(appt_i.Patient_Account__c)) {
                patientToAppsMap.put(appt_i.Patient_Account__c, new List<Appointment__c>()); 
            }
            patientToAppsMap.get(appt_i.Patient_Account__c).add(appt_i);
        }
        System.debug('patientToAppsMap: size: ' + patientToAppsMap.size() + ' value: ' + patientToAppsMap);

        if (!patientToAppsMap.isEmpty()) {
            for (Appointment__c appt_i :appts) {
                if (patientToAppsMap.containsKey(appt_i.Patient_Account__c)) {
                    for (Appointment__c preSurgery_i : patientToAppsMap.get(appt_i.Patient_Account__c)) {
                        numberOfDays = preSurgery_i.Date_of_appointment__c.daysBetween(appt_i.Date_of_appointment__c);
                        if (numberOfDays > 0 && numberOfDays < 12) {
                            surgeryToPreSurgeryMap.put(appt_i.Patient_Account__c, preSurgery_i.Id);
                        }
                    }
                } 
            } 
        }
        System.debug('surgeryToPreSurgeryMap: size: ' + surgeryToPreSurgeryMap.size() + ' value: ' + surgeryToPreSurgeryMap);

        if (!surgeryToPreSurgeryMap.isEmpty()) {
            for (Appointment__c appt_i :[SELECT PreSurgery__c
                                              , Patient_Account__c
                                           FROM Appointment__c
                                          WHERE RecordType.DeveloperName = 'Surgeries'
                                            AND Patient_Account__c IN :patientIds]) {
                if (appt_i.PreSurgery__c == null || appt_i.PreSurgery__c != surgeryToPreSurgeryMap.get(appt_i.Patient_Account__c)) {
                    patients.add(appt_i.Patient_Account__c);
                }
            }
        }
        System.debug('patients: size: ' + patients.size() + ' value: ' + patients);

        if (!patients.isEmpty()) {
            for (Appointment__c appt_i :appts) {
                if (patients.contains(appt_i.Patient_Account__c)) {
                    appt_i.PreSurgery__c = surgeryToPreSurgeryMap.get(appt_i.Patient_Account__c);
                    logicExecuted = true;
                }
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c relatedSurgeryToPreSurgery ... executed');
        }
    }

    public static void fillReferringDoctor(List<Appointment__c> appts, Set<Id> doctorIds) {
        Boolean logicExecuted = false;

        Map<Id, Account> doctorMap = new Map<Id, Account>([
            SELECT Doctor_Code__c
              FROM Account
             WHERE Id IN :doctorIds
               AND Doctor_Code__c != null]);
        System.debug('doctorMap: size: ' + doctorMap.size() + ' value: ' + doctorMap);

        for (Appointment__c appt_i :appts) {
            if (doctorMap.containsKey(appt_i.Doctor_Account__c)) {
                appt_i.Doctor_License_From_Referral__c = doctorMap.get(appt_i.Doctor_Account__c).Doctor_Code__c;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c fillReferringDoctor ... executed');
        }
    }

    public static void markFollowingTelemedicineSession(List<Appointment__c> appointmentList, Set<Id> procedureIdSet, Set<Id> patientIdSet) {
        Map<Id, Medical_Procedure__c> patientIdToProcedureMap = new Map<Id, Medical_Procedure__c>();
        Set<String> statusSet = new Set<String>();
        Boolean logicExecuted = false;

        for (StatusForTelemedicineReport__mdt mdt_i : StatusForTelemedicineReport__mdt.getAll().values()) {
            statusSet.add(mdt_i.Status__c);
        }
        System.debug('statusSet: size: ' + statusSet.size() + ' value: ' + statusSet);

        for (Appointment__c appt_i : [SELECT Patient_Account__c, Medical_Procedure__r.DomainForReport__c
                                        FROM Appointment__c
                                       WHERE Patient_Account__c IN :patientIdSet
                                         AND Appointment_Status__c IN :statusSet
                                         AND CreatedDate = LAST_90_DAYS
                                         AND Medical_Procedure__r.Telemedicine_Action__c = true
                                    ORDER BY CreatedDate]) {
            patientIdToProcedureMap.put(appt_i.Patient_Account__c, appt_i.Medical_Procedure__r);
        }
        System.debug('patientIdToProcedureMap: size: ' + patientIdToProcedureMap.size() + ' value: ' + patientIdToProcedureMap);

        if (!patientIdToProcedureMap.isEmpty()) {
            Map<Id, Medical_Procedure__c> procedureMap = new Map<Id, Medical_Procedure__c>([
                SELECT DomainForReport__c FROM Medical_Procedure__c WHERE Id IN :procedureIdSet]);
            System.debug('procedureMap: size: ' + procedureMap.size() + ' value: ' + procedureMap);

            for (Appointment__c appt_i : appointmentList) {
                if (procedureMap.containsKey(appt_i.Medical_Procedure__c)
                        && patientIdToProcedureMap.containsKey(appt_i.Patient_Account__c)
                        && procedureMap.get(appt_i.Medical_Procedure__c).DomainForReport__c == patientIdToProcedureMap.get(appt_i.Patient_Account__c).DomainForReport__c) {
                    appt_i.FollowingTheTelemedicineSession__c = true;
                    logicExecuted = true;
                }
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c markFollowingTelemedicineSession ... executed');
        }
    }

    public static void getPricesJob(Set<Id> apptIds) {
        List<Appointment__c> appts = [
            SELECT Date_of_appointment__c
                 , Site__r.Site_Code__c
                 , PayerFactor__r.InsuranceCode__c
                 , PayerFactor__r.Code_Parent_for_Interface__c
                 , Doctor_Account__r.Doctor_Code__c
                 , Doctor_Account__r.RecordType.DeveloperName
                 , Medical_Procedure__r.Procedure_Code__c
                 , Medical_Procedure__r.Category_for_anesthetist__c
                 , Medical_Procedure2__r.Procedure_Code__c
                 , Medical_Procedure3__r.Procedure_Code__c
                 , Medical_Procedure4__r.Procedure_Code__c
              FROM Appointment__c
             WHERE Id IN :apptIds];

        for (Appointment__c appt_i : appts) {
            Map<String, String> jsonInput = new Map<String, String>{'Guid' => appt_i.Id};

            if (appt_i.Site__c != null) {
                jsonInput.put('siteCode', appt_i.Site__r.Site_Code__c);
            }
            if (appt_i.PayerFactor__c != null) {
                jsonInput.put('payerFactorCode', appt_i.PayerFactor__r.InsuranceCode__c);
                jsonInput.put('payerFactorParent', appt_i.PayerFactor__r.Code_Parent_for_Interface__c);
            }
            if (appt_i.Doctor_Account__c != null && appt_i.Doctor_Account__r.RecordType.DeveloperName == 'Doctor_Account') {
                jsonInput.put('doctorCode', appt_i.Doctor_Account__r.Doctor_Code__c);
            }
            if (appt_i.Date_of_appointment__c != null) {
                jsonInput.put('activityDate', String.valueOf(appt_i.Date_of_appointment__c));
            } else {
                jsonInput.put('activityDate', String.valueOf(System.today()).leftPad(10));
            }
            if (appt_i.Medical_Procedure__c != null) {
                if (appt_i.Medical_Procedure__r.Category_for_anesthetist__c != null) {
                    jsonInput.put('anesthetist', appt_i.Medical_Procedure__r.Category_for_anesthetist__c);
                }
                jsonInput.put('activityCode_1', appt_i.Medical_Procedure__r.Procedure_Code__c);
            }
            if (appt_i.Medical_Procedure2__c != null) {
                jsonInput.put('activityCode_2', appt_i.Medical_Procedure2__r.Procedure_Code__c);
            }
            if (appt_i.Medical_Procedure3__c != null) {
                jsonInput.put('activityCode_3', appt_i.Medical_Procedure3__r.Procedure_Code__c);
            }
            if (appt_i.Medical_Procedure4__c != null) {
                jsonInput.put('activityCode_4', appt_i.Medical_Procedure4__r.Procedure_Code__c);
            }
            System.enqueueJob(new ws_getPrices_REST(JSON.serialize(jsonInput)));
        }
        System.debug('TR Appointment__c getPricesJob ... executed');
    }

    public static void createImplats(List<Appointment__c> appts, Set<Id> procedureIds) {
        Map<Id, List<Implants_to_med_prod__c>> procedureIdToImplantsMap = new Map<Id, List<Implants_to_med_prod__c>>();
        List<Implants_mp_apt__c> implantsToInsert = new List<Implants_mp_apt__c>();

        for (Implants_to_med_prod__c mpImplant_i : [SELECT notes__c
                                                         , Implants__c
                                                         , min_price__c
                                                         , max_price__c
                                                         , formula_imp_name__c
                                                         , Medical_Procedure__c
                                                      FROM Implants_to_med_prod__c
                                                     WHERE Medical_Procedure__c IN :procedureIds]) {
            if (!procedureIdToImplantsMap.containsKey(mpImplant_i.Medical_Procedure__c)) {
                procedureIdToImplantsMap.put(mpImplant_i.Medical_Procedure__c, new List<Implants_to_med_prod__c>());
            }
            procedureIdToImplantsMap.get(mpImplant_i.Medical_Procedure__c).add(mpImplant_i);
        }
        System.debug('procedureIdToImplantsMap: size: ' + procedureIdToImplantsMap.size() + ' value: ' + procedureIdToImplantsMap);

        for (Appointment__c appt_i : appts) {
            List<Implants_to_med_prod__c> implantsToMd = new List<Implants_to_med_prod__c>();

            for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                if (appt_i.get(procedureLookup_i) != null
                        && procedureIdToImplantsMap.containsKey(Id.valueOf((String) appt_i.get(procedureLookup_i)))) {
                    for (Implants_to_med_prod__c implant_i : procedureIdToImplantsMap.get(Id.valueOf((String) appt_i.get(procedureLookup_i)))) {
                        implantsToInsert.add(
                            new Implants_mp_apt__c(
                                Appointment__c = appt_i.Id,
                                Implants_mp__c = implant_i.Id,
                                Implants__c= implant_i.Implants__c,
                                Notes__c = implant_i.notes__c,
                                Name = implant_i.formula_imp_name__c,
                                min_price__c = implant_i.min_price__c,
                                max_price__c= implant_i.max_price__c));
                    }
                }
            }
        }
        System.debug('implantsToInsert: size: ' + implantsToInsert.size() + ' value: ' + implantsToInsert);

        if (!implantsToInsert.isEmpty()) {
            insert implantsToInsert;
            System.debug('TR Appointment__c createImplats ... executed');
        }
    }

    public static void updateSurgeryCase(List<Appointment__c> appts) {
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();

        for (Appointment__c appt_i : appts) {
            casesToUpdateMap.put(
                appt_i.Case__c,
                new Case(
                    Id = appt_i.Case__c,
                    Site__c = appt_i.Site__c,
                    Domain__c = appt_i.Domain__c,
                    Surgery_PayerFactor__c = appt_i.PayerFactor__c));
        }
        System.debug('casesToUpdateMap: size: ' + casesToUpdateMap.size() + ' value: ' + casesToUpdateMap);

        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
            System.debug('TR Appointment__c updateSurgeryCase ... executed');
        }
    }

    public static void assignSurgeryCaseToQueue(Set<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();

        for (Id caseId_i : caseIds) {
            casesToUpdate.add(
                new Case(
                    Id = caseId_i,
                    Status = 'New',
                    Problem_appointment__c = true,
                    OwnerId = Label.Surgeries_QueueId,
                    Surgeries_notes__c = 'למטפל לא קיים ערוץ מועדף לשליחת קיט. יש להגדיר בעבורו אחד'));
        }
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            System.debug('TR Appointment__c createKITFile (assignSurgeryCaseToQueue) ... executed');
        }
    }

    public static void createKITFile(Map<Id, SurgeriesTRDispatcher.KITWrapper> apptsMap) {
        EmailTemplate template = [SELECT Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Assuta_Kit_Surgery'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Appointment__c> appts = new List<Appointment__c>();
        List<File__c> files = new List<File__c>();
        List<SMS__c> smss = new List<SMS__c>();
        List<Case> cases = new List<Case>();
        Boolean logicExecuted = false;

        for (SurgeriesTRDispatcher.KITWrapper kitWrapper_i : apptsMap.values()) {
            // skip an Appointment if SMS/Email can't be sent
            if (!kitWrapper_i.isValid) {
                continue;
            }

            // update an Appointment's Status if needed
            if (kitWrapper_i.updateStatus) {
                kitWrapper_i.appt.Appointment_Status__c = 'WaitingForAppointment';
            }

            // prepare File if needed
            if (kitWrapper_i.sendFile) {
                kitWrapper_i.appt.text_for_kit__c = kitWrapper_i.textForKIT;
                kitWrapper_i.appt.Administrative_Status__c = 'הושלם';
                kitWrapper_i.appt.Didkitsent__c = true;
                files.add(prepareFile(kitWrapper_i.appt, kitWrapper_i.channelType));
            }

            // add an Appointment to the update list
            appts.add(kitWrapper_i.appt);
            // close an Appointment's Case
            cases.add(new Case(Id = kitWrapper_i.appt.Case__c, Status = 'Closed'));

            // prepare Email or SMS based on chosen Channel Type
            if (kitWrapper_i.channelType == 'Email') {
                mails.add(prepareMail(kitWrapper_i.appt, template));
            } else if (kitWrapper_i.channelType == 'SMS') {
                smss.add(prepareSMS(kitWrapper_i.appt, null, 'surgery_kit'));
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('files: size: ' + files.size() + ' value: ' + files);
        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);
        System.debug('smss: size: ' + smss.size() + ' value: ' + smss);

        if (!appts.isEmpty()) {
            logicExecuted = true;
            update appts;
            update cases;

            if (!files.isEmpty()) {
                insert files;
            }
            if (!smss.isEmpty()) {
                insert smss;
            }
            if (!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
            System.debug('TR Appointment__c createKITFile ... executed');
        }
    }

    // should be in sms service in the future
    private static SMS__c prepareSMS(Appointment__c appt, Id caseId, String smsTemp) {
        return new SMS__c(
            Phone_Number__c = appt.Patient_Account__r.SMS_Phone_Number__c,
            Appointment__c = appt.Id,
            Case__c = caseId,
            smsTemplate__c = smsTemp,
            Type__c = 'Outgoing',
            ExpectedSendingDateTime__c = Datetime.now()
        );
    }

    private static File__c prepareFile(Appointment__c appt, String channelType) {
        String remarks;
        if (channelType == 'Email') {
            remarks = 'נשלח כדואר אלקטרוני';
        } else if (channelType == 'SMS') {
            remarks = 'נשלח כ SMS';
        }

        return new File__c(
            RecordTypeId = Label.Kit_Record_Type,
            Send_File_Date__c = Date.today(),
            Account__c = appt.Patient_Account__c,
            URL__c = appt.Kit_Link__c,
            Appointment__c = appt.Id,
            file_type__c = 'קיט ניתוחי',
            Remarks__c = remarks,
            Name = 'קיט ניתוחי'
        );
    }

    private static Messaging.SingleEmailMessage prepareMail(Appointment__c appt, EmailTemplate template) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{appt.Patient_Mail__c});
        mail.setSenderDisplayName('Assuta No-Reply');
        mail.setReplyTo('nonreply@assuta.co.il');
        mail.setHtmlBody(template.HtmlValue);
        mail.setPlainTextBody(template.Body);
        mail.setTreatBodiesAsTemplate(true);
        mail.setSubject(template.Subject);
        mail.setWhatId(appt.Id);
        return mail;
    }

    public static void retServiceReferrals(Set<Id> apptIds, Set<Id> siteIds, Set<Id> doctorIds, Set<Id> procedureIds) {
        Map<Id, List<ExcludedParameters__c>> eParameters = new Map<Id, List<ExcludedParameters__c>>();
        Map<Id, Map<String, String>> apptMap = new Map<Id, Map<String, String>>();
        List<Appointment__c> apptsToUpdate = new List<Appointment__c>();
        Boolean isExcluded;

        List<Appointment__c> appts = [
            SELECT ID_Type__c
                 , PayerFactor__c
                 , Classification__c
                 , Patient_Account__c
                 , Medical_Procedure2__c
                 , Medical_Procedure3__c
                 , Medical_Procedure4__c
                 , IdNumberForMaccabi__c
                 , Date_of_appointment__c
                 , Site__r.Maccabi_Code__c
                 , Doctor_Account__r.Doctor_Code_Seven__c
                 , Medical_Procedure__r.Domain__r.DomainCode__c
              FROM Appointment__c
             WHERE Id IN :apptIds
               AND Classification__c != 'אדום'
               AND PayerFactor__r.Code_Parent_for_Interface__c = '3'];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty() && (!siteIds.isEmpty() || !doctorIds.isEmpty() || !procedureIds.isEmpty())) {
            List<ExcludedParameters__c> exParameters = [
                SELECT Site__c
                     , DoctorName__c
                     , MedicalProcedure__c
                  FROM ExcludedParameters__c
                 WHERE Status__c = 'Active'
                   AND (MedicalProcedure__c IN :procedureIds OR Site__c IN :siteIds OR DoctorName__c IN :doctorIds)];
            System.debug('exParameters: size: ' + exParameters.size() + ' value: ' + exParameters);

            if (!exParameters.isEmpty()) {
                for (ExcludedParameters__c exParameter_i : exParameters) {
                    if (exParameter_i.Site__c != null) {
                        if (!eParameters.containsKey(exParameter_i.Site__c)) {
                            eParameters.put(exParameter_i.Site__c, new List<ExcludedParameters__c>());
                        }
                        eParameters.get(exParameter_i.Site__c).add(exParameter_i);
                    }
                    if (exParameter_i.DoctorName__c != null) {
                        if (!eParameters.containsKey(exParameter_i.DoctorName__c)) {
                            eParameters.put(exParameter_i.DoctorName__c, new List<ExcludedParameters__c>());
                        }
                        eParameters.get(exParameter_i.DoctorName__c).add(exParameter_i);
                    }
                    if (exParameter_i.MedicalProcedure__c != null) {
                        if (!eParameters.containsKey(exParameter_i.MedicalProcedure__c)) {
                            eParameters.put(exParameter_i.MedicalProcedure__c, new List<ExcludedParameters__c>());
                        }
                        eParameters.get(exParameter_i.MedicalProcedure__c).add(exParameter_i);
                    }
                }
            }
        }

        for (Appointment__c appt_i : appts) {
            isExcluded = false;

            if (!eParameters.isEmpty()) {
                List<ExcludedParameters__c> exParameterslst = eParameters.containsKey(appt_i.Medical_Procedure__c)
                    ? eParameters.get(appt_i.Medical_Procedure__c)
                    : eParameters.containsKey(appt_i.Site__c)
                        ? eParameters.get(appt_i.Site__c)
                        : eParameters.containsKey(appt_i.Doctor_Account__c)
                            ? eParameters.get(appt_i.Doctor_Account__c)
                            : null;
                if (exParameterslst != null) {
                    for (ExcludedParameters__c exc_i : exParameterslst) {
                        if ((exc_i.MedicalProcedure__c == null
                                    || exc_i.MedicalProcedure__c == appt_i.Medical_Procedure__c
                                    || exc_i.MedicalProcedure__c == appt_i.Medical_Procedure2__c
                                    || exc_i.MedicalProcedure__c == appt_i.Medical_Procedure3__c
                                    || exc_i.MedicalProcedure__c == appt_i.Medical_Procedure4__c)
                                && (exc_i.DoctorName__c == null
                                    || exc_i.DoctorName__c == appt_i.Doctor_Account__c)
                                && (exc_i.Site__c == null
                                    || exc_i.Site__c == appt_i.Site__c)) {
                            isExcluded = true;
                        }
                    }
                }
            }

            if (!isExcluded) {
                apptMap.put(appt_i.Id, new Map<String, String>());
                apptMap.get(appt_i.Id).put('IDType__c', appt_i.ID_Type__c == 'דרכון' ? '9' : '0');
                apptMap.get(appt_i.Id).put('IDNumber__c', appt_i.IdNumberForMaccabi__c);
                apptMap.get(appt_i.Id).put('PayerFactor__c', appt_i.PayerFactor__c);
                apptMap.get(appt_i.Id).put('Patient_Account__c', appt_i.Patient_Account__c);
                apptMap.get(appt_i.Id).put('DoctorLicense', appt_i.Doctor_Account__r.Doctor_Code_Seven__c);

                if (appt_i.Site__c != null) {
                    apptMap.get(appt_i.Id).put('Site', appt_i.Site__r.Maccabi_Code__c);
                }
                if (appt_i.Medical_Procedure__c != null) {
                    apptMap.get(appt_i.Id).put('MedicalProcedure', String.valueOf(appt_i.Medical_Procedure__r.Domain__r.DomainCode__c));
                }
                if (appt_i.Date_of_appointment__c == null) {
                    apptMap.get(appt_i.Id).put('dateTreatment', String.valueOf(Date.today()));
                } else {
                    apptMap.get(appt_i.Id).put('dateTreatment', String.valueOf(appt_i.Date_of_appointment__c));
                }
                apptMap.get(appt_i.Id).put('From_object', 'Appointment');
            } else {
                apptsToUpdate.add(new Appointment__c(Id = appt_i.Id, excluded_from_maccabi__c = true));
            }
        }
        System.debug('apptMap: size: ' + apptMap.size() + ' value: ' + apptMap);
        System.debug('apptsToUpdate: size: ' + apptsToUpdate.size() + ' value: ' + apptsToUpdate);

        if (!apptMap.isEmpty() && !Test.isRunningTest()) {
            MaccabiIntegration.RetServiceReferrals(apptMap);
        }

        if (!apptsToUpdate.isEmpty()) {
            update apptsToUpdate;
        }

        if (!apptMap.isEmpty() || !apptsToUpdate.isEmpty()) {
            System.debug('TR Appointment__c retServiceReferrals ... executed');
        }
    }

    public static void updateShikumBaitCases(Map<Id, Appointment__c> apptMap) {
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        Map<Id, Set<Id>> apptToCaseIdsMap = new Map<Id, Set<Id>>();
        
        for (Case case_i : [SELECT Surgery_Name__c
                              FROM Case
                             WHERE Surgery_Name__c IN :apptMap.keyset()]) {
            if (!apptToCaseIdsMap.containsKey(case_i.Surgery_Name__c)) {
                apptToCaseIdsMap.put(case_i.Surgery_Name__c, new Set<Id>());
            }
            apptToCaseIdsMap.get(case_i.Surgery_Name__c).add(case_i.Id);
        }
        System.debug('apptToCaseIdsMap: size: ' + apptToCaseIdsMap.size() + ' value: ' + apptToCaseIdsMap);

        for (Appointment__c appt_i : apptMap.values()) {
            if (apptToCaseIdsMap.containsKey(appt_i.Id)) {
                for (Id caseId_i : apptToCaseIdsMap.get(appt_i.Id)) {
                    casesToUpdateMap.put(
                        caseId_i,
                        new Case(
                            Id = caseId_i,
                            Admission_Date__c = appt_i.Admission_Date__c,
                            Recommendation_Time__c = appt_i.Recommendation_Time__c, 
                            Release_Date__c = appt_i.Release_Date__c,
                            Shikum_Bait_Approval__c = appt_i.Shikum_Bait_Approval__c,
                            Shikum_Bait_Doctor_Rec__c = appt_i.Shikum_Bait_Doctor_Rec__c,
                            Site__c = appt_i.Site__c,
                            Surgery_Date__c = appt_i.Appointment_Date_Time__c, 
                            Surgery_PayerFactor__c = appt_i.PayerFactor__c,
                            Time_Approval_Shikum_Bait__c = appt_i.Time_Approval_Shikum_Bait__c
                        )
                    );
                }
            }
        }
        System.debug('casesToUpdateMap: size: ' + casesToUpdateMap.size() + ' value: ' + casesToUpdateMap);

        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
            System.debug('TR Appointment__c updateShikumBaitCases ... executed');
        }
    }
	
    public static void createConFormTaken(Set<Id> apptIds, Set<Id> siteIds) {
        Map<Id, ConsentFormToSite__c> siteToCftsIdMap = new Map<Id, ConsentFormToSite__c>();
        List<ConsentFormTaken__c> cftToInsert = new List<ConsentFormTaken__c>();
        List<Appointment__c> appointmentList = new List<Appointment__c>();

        for (ConsentFormToSite__c cfts : [SELECT Id
                                                , Site__c
                                                , ConsentForm__c 
                                            FROM ConsentFormToSite__c 
                                          WHERE Site__c IN: siteIds]) {
            siteToCftsIdMap.put(cfts.Site__c, cfts);
        }
        List<Appointment__c> appts = [SELECT Id
                                           , Case__c
                                           , Site__c
                                           , Domain__c
                                           , Patient_Account__c
                                           , Medical_Procedure__c
                                        FROM Appointment__c
                                       WHERE Id IN :apptIds];
        
        for (Appointment__c appt_i : appts) {
            if (siteToCftsIdMap.containsKey(appt_i.Site__c)) {
                cftToInsert.add(new ConsentFormTaken__c(
                                    Case__c = appt_i.Case__c,
                                    Site__c = appt_i.Site__c,
                                    Appointment__c = appt_i.Id,
                                    Account__c = appt_i.Patient_Account__c,
                                    Domain__c = appt_i.Domain__c,
                                    Medical_Procedure__c = appt_i.Medical_Procedure__c,
                                    ConsentForm__c = siteToCftsIdMap.get(appt_i.Site__c).ConsentForm__c,
                                    ConsentFormToSite__c = siteToCftsIdMap.get(appt_i.Site__c).Id));
                appointmentList.add(new Appointment__c(Id = appt_i.Id, RelevantInformedConsent__c = true)); 
            }
        }
        
        System.debug('cftsToInsert: size: ' + cftToInsert.size() + ' value: ' + cftToInsert);
        if (!cftToInsert.isEmpty()) {
            insert cftToInsert;
            update appointmentList; 
            System.debug('TR Appointment__c createConFormTaken ... executed');
        }
    }
    
    @future(callout=true)
    public static void createPreMedicalProcedure(Set<Id> apptIds) {
        Set<String> siteIds = new Set<String>();        
        Set<String> pCodes = new Set<String>();
        List<Appointment__c> appts = new List<Appointment__c>();
        Map<String, Id> pCodeToPreMedicalMap = new Map<String, Id>();
        List<PreMedicalForAppointment__c> prePcodeAppToDelete = new List<PreMedicalForAppointment__c>();
        List<PreMedicalForAppointment__c> prePcodeAppToInsert = new List<PreMedicalForAppointment__c>();


        for (PreMedicalForAppointment__c pre_i : [SELECT Id
                                                     ,Appointment__c                       
                                                   FROM PreMedicalForAppointment__c
                                                  WHERE Appointment__c IN :apptIds]) {            
            prePcodeAppToDelete.add(pre_i);
        }
        System.debug('prePcodeAppToDelete: size: ' + prePcodeAppToDelete.size() + ' value: ' + prePcodeAppToDelete);

        for (Appointment__c appt_i : [SELECT Id
                                           , Site__c   
                                           , Site__r.Site_Code__c                                         
                                           , Medical_Procedure__r.Procedure_Code__c
                                           , Medical_Procedure2__r.Procedure_Code__c
                                           , Medical_Procedure3__r.Procedure_Code__c
                                           , Medical_Procedure4__r.Procedure_Code__c
                                        FROM Appointment__c
                                       WHERE Id IN :apptIds]) {           
            appts.add(appt_i);
            siteIds.add(appt_i.Site__r.Site_Code__c);
            pCodes.addAll(getProcedureCode(appt_i));            
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);        
        System.debug('pCodes: size: ' + pCodes.size() + ' value: ' + pCodes);
                     
        for (PreMedicalProcedure__c  preMedical_i : [SELECT Id
                                                        , Site__c
                                                        , Site__r.Site_Code__c
                                                        , MedicalProcedure__c                                                    
                                                        , PreMedicalProcedure__c 
                                                        , MedicalProcedure__r.Procedure_Code__c
                                                   FROM PreMedicalProcedure__c 
                                                  WHERE Active__c = true
                                                   AND Site__r.Site_Code__c IN: siteIds
                                                   AND MedicalProcedure__r.Procedure_Code__c IN: pCodes]) {
            pCodeToPreMedicalMap.put(preMedical_i.MedicalProcedure__r.Procedure_Code__c + preMedical_i.Site__r.Site_Code__c, preMedical_i.Id);           
        }

        System.debug('pCodeToPreMedicalMap: size: ' + pCodeToPreMedicalMap.size() + ' value: ' + pCodeToPreMedicalMap);
       
        if (!pCodeToPreMedicalMap.isEmpty()) {
            for (Appointment__c appt_i : appts) {
                for (String pRelationship_j : AppointmentTriggerUtil.PROCEDURE_RELATIONSHIPS) {
                    if (appt_i.getSObject(pRelationship_j) != null && pCodeToPreMedicalMap.containsKey((String) appt_i.getSObject(pRelationship_j).get('Procedure_Code__c') + appt_i.Site__r.Site_Code__c )) {                        
                        prePcodeAppToInsert.add(new PreMedicalForAppointment__c(
                                                    Appointment__c = appt_i.Id,
                                                    PreMedicalProcedure__c = pCodeToPreMedicalMap.get((String) appt_i.getSObject(pRelationship_j).get('Procedure_Code__c') + appt_i.Site__r.Site_Code__c )));
                    } else {
                       break;
                    } 
                }
            }           
        }        
        System.debug('prePcodeAppToInsert: size: ' + prePcodeAppToInsert.size() + ' value: ' + prePcodeAppToInsert);

        // do dml
        if (!prePcodeAppToDelete.isEmpty()) {
            delete prePcodeAppToDelete;
        }

        if (!prePcodeAppToInsert.isEmpty()) {
            insert prePcodeAppToInsert;
            System.debug('TR Appointment__c createPreMedicalProcedure ... executed');
        }
    }

    public static Set<String> getProcedureCode(Appointment__c appt) {
        Set<String> pCodes = new Set<String>();
        for (String pRelationship_j : AppointmentTriggerUtil.PROCEDURE_RELATIONSHIPS) {
            if (appt.getSObject(pRelationship_j) != null) {
                pCodes.add((String) appt.getSObject(pRelationship_j).get('Procedure_Code__c'));
            }
        } 
        return pCodes;
    }    
}