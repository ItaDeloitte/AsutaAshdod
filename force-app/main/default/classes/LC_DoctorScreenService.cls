/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Scheduling Screen Apex Service class to keep main logic
 *
 * Test                 LC_DoctorScreenTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_DoctorScreenService {

    public class LC_DoctorScreenException extends Exception {}

    private static LC_DoctorScreenService instance;

    private Case cas;

    public static LC_DoctorScreenService getInstance(String caseId) {
        if (instance == null) {
            instance = new LC_DoctorScreenService(caseId);
        }
        return instance;
    }

    /** CONSTRUCTOR */
    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The constructor obtains current Case details
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    private LC_DoctorScreenService(String caseId) {
        this.cas = LC_DoctorScreenUtil.obtainCase(caseId);
        System.debug('case: ' + this.cas);
    }

    /** METHODS */
    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to check if the doctor screen is available for current Case
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public void isAvailable() {
        if (this.cas.Recommended_doc__c != null) {
            if (this.cas.Channel__c == null ||
                    (this.isPublicChannel() && this.cas.Agreement__c == null) ||
                    (this.isPrivateChannel() && this.cas.Doctor_Arrangement__c == null)) {
                throw new LC_DoctorScreenException(LC_DoctorScreenUtil.ERR_CASE);
            } else if (this.obtainClinics(this.cas.Recommended_doc__c).isEmpty()) {
                throw new LC_DoctorScreenException(LC_DoctorScreenUtil.ERR_CLINIC);
            }
        } else if (this.cas.Account.ID_Type__c == '1' && this.cas.Account.Insurer_factor__c == null) {
            throw new LC_DoctorScreenException(LC_DoctorScreenUtil.ERR_IFACTOR);
        } else if (this.cas.PayerFactor__c == null && this.cas.Account.ID_Type__c != '9') {
            throw new LC_DoctorScreenException(LC_DoctorScreenUtil.ERR_PFACTOR);
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to obtain config for the doctor screen
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public ConfigWrp init() {
        ConfigWrp config = new ConfigWrp(this.cas);

        for (Arrangements__c arrangement_i : LC_DoctorScreenUtil.obtainArrangements(this.isPrivateChannel())) {
            config.arrangements.add(new OptionWrp(arrangement_i.Name, arrangement_i.Id));
        }
        for (AggregateResult settlementAR_i : LC_DoctorScreenUtil.obtainARSettlements()) {
            config.settlements.add(new OptionWrp((String) settlementAR_i.get('Area__c')));
        }

        config.fillDefauls(this.cas);

        return config;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to search expertises that are available to schedule an appointment
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             10-12-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public List<ExpertiseWrp> searchExpertises(String keyword) {
        List<ExpertiseWrp> expertises = new List<ExpertiseWrp>();

        for (Expertise__c expertise_i : LC_DoctorScreenUtil.obtainExpertises(keyword)) {
            expertises.add(new ExpertiseWrp(expertise_i));
        }
        System.debug('expertises: size: ' + expertises.size() + ' value: ' + expertises);

        return expertises;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to search sub expertises that are available to schedule an appointment
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             10-12-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public List<SubExpertiseWrp> searchSubExpertises(String expertiseId, String keyword) {
        List<SubExpertiseWrp> subExpertises = new List<SubExpertiseWrp>();

        for (Sub_Expertise__c subExpertise_i : LC_DoctorScreenUtil.obtainSubExpertises(expertiseId, keyword)) {
            subExpertises.add(new SubExpertiseWrp(subExpertise_i));
        }
        System.debug('subExpertises: size: ' + subExpertises.size() + ' value: ' + subExpertises);

        return subExpertises;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to search procedures that are available to schedule an appointment
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             10-12-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public List<ProcedureWrp> searchProcedures(String subExpertiseId, String keyword) {
        List<ProcedureWrp> procedures = new List<ProcedureWrp>();

        List<String> procedureCodes = this.isPrivateChannel()
            ? ExpertProcedureService.getInstance().getAllPrivate()
            : ExpertProcedureService.getInstance().getAllPublic();
        procedureCodes.addAll(LC_DoctorScreenUtil.obtainExcellentProcedureCodes());

        for (Medical_Procedure__c procedure_i : LC_DoctorScreenUtil.obtainProcedures(procedureCodes, subExpertiseId, keyword)) {
            procedures.add(new ProcedureWrp(procedure_i));
        }
        System.debug('procedures: size: ' + procedures.size() + ' value: ' + procedures);

        return procedures;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to search doctors that are available to schedule an appointment
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             20-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public SearchDoctorsWrp searchDoctors(String searchType, String doctorName, String procedureId, String expertiseId, String subExpertiseId, List<String> arrangements, List<String> settlements, Boolean onlyRecommended) {
        List<DoctorWrp> allDoctors = new List<DoctorWrp>();
        List<DoctorWrp> expertDoctors = new List<DoctorWrp>();
        List<DoctorWrp> alertedDoctors = new List<DoctorWrp>();
        List<DoctorWrp> promotedDoctors = new List<DoctorWrp>();

        Set<String> genders = new Set<String>();
        Set<String> degrees = new Set<String>();
        Set<String> quantities = new Set<String>();
        Set<String> procedureIds = new Set<String>();

        Map<String, SObject> siteMap = new Map<String, SObject>();
        Map<String, SObject> arrangementMap = new Map<String, SObject>();

        Map<Id, List<String>> doctorToSitesMap = new Map<Id, List<String>>();
        Map<Id, List<OptionWrp>> doctorToArrangementsMap = new Map<Id, List<OptionWrp>>();

        Boolean skipArrangement = arrangements == null;
        Boolean skipSettlement = settlements == null;

        String settlementCondition = this.obtainSettlementCondition(settlements, skipSettlement);

        Set<String> recommendedDoctorIds = this.obtainRecommendedDoctorIds();
        Set<String> doctorIds = onlyRecommended ? recommendedDoctorIds : this.obtainDoctorIds(procedureId, arrangements, skipArrangement);
        System.debug('doctorIds before query: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        Map<String, Account> doctorMap = new Map<String, Account>(
            LC_DoctorScreenUtil.obtainDoctors(doctorIds, doctorName, procedureId, subExpertiseId, settlementCondition, onlyRecommended, skipArrangement, skipSettlement)
        );
        doctorIds = doctorMap.keySet();
        System.debug('doctorIds after query: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        Map<String, Decimal> doctorToRankMap = this.obtainDoctorToRankMap(doctorIds);
        Map<String, Integer> doctorToQuantityMap = this.obtainDoctorToQuantityMap(doctorIds, procedureId, expertiseId);
        Map<String, Datetime> doctorCodeToSlotDTMap = searchType != LC_DoctorScreenUtil.BY_DOCTOR
            ? this.obtainDoctorCodeToSlotTimeMap(expertiseId, subExpertiseId)
            : new Map<String, Datetime>();

        for (String doctorId_i : doctorIds) {
            Account doctorObj_i = doctorMap.get(doctorId_i);

            if (doctorObj_i.All_medical_procedures_ids__c != null) {
                procedureIds.addAll(doctorObj_i.All_medical_procedures_ids__c.split(','));
            }

            DoctorWrp doctorWrp_i = new DoctorWrp(
                doctorObj_i,
                doctorToQuantityMap.get(doctorId_i),
                recommendedDoctorIds.contains(doctorId_i),
                doctorCodeToSlotDTMap.get(doctorObj_i.Doctor_Code__c));

            if (doctorWrp_i.gender != null) {
                genders.add(doctorWrp_i.gender);
            }
            if (doctorWrp_i.degree != null) {
                degrees.add(doctorWrp_i.degree);
            }
            if (doctorWrp_i.quantity != null) {
                quantities.add(String.valueOf(doctorWrp_i.quantity));
            }

            if (doctorWrp_i.isPromoted) {
                promotedDoctors.add(doctorWrp_i);
            } else if (doctorWrp_i.isExpert || doctorWrp_i.isExcellent) {
                expertDoctors.add(doctorWrp_i);
            } else {
                alertedDoctors.add(doctorWrp_i);
            }
        }
        System.debug('promotedDoctors: size: ' + promotedDoctors.size() + ' value: ' + promotedDoctors);
        System.debug('expertDoctors: size: ' + expertDoctors.size() + ' value: ' + expertDoctors);
        System.debug('alertedDoctors: size: ' + alertedDoctors.size() + ' value: ' + alertedDoctors);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);
        System.debug('quantities: size: ' + quantities.size() + ' value: ' + quantities);
        System.debug('degrees: size: ' + degrees.size() + ' value: ' + degrees);
        System.debug('genders: size: ' + genders.size() + ' value: ' + genders);

        Map<String, SObject> procedureMap = new Map<String, SObject>(LC_DoctorScreenUtil.obtainProcedures(procedureIds));
        System.debug('procedureMap: size: ' + procedureMap.size() + ' value: ' + procedureMap);

        for (Doctor_in_site__c docSite_i : LC_DoctorScreenUtil.obtainDoctorSites(doctorIds)) {
            siteMap.put(docSite_i.Site__c, docSite_i);
            if (!doctorToSitesMap.containsKey(docSite_i.Account__c)) {
                doctorToSitesMap.put(docSite_i.Account__c, new List<String>());
            }
            doctorToSitesMap.get(docSite_i.Account__c).add(docSite_i.Site__c);
        }
        System.debug('siteMap: size: ' + siteMap.size() + ' value: ' + siteMap);
        System.debug('doctorToSitesMap: size: ' + doctorToSitesMap.size() + ' value: ' + doctorToSitesMap);

        for (Doctor_arrangement__c docArrangement_i : LC_DoctorScreenUtil.obtainDoctorArrangements(doctorIds, arrangements)) {
            arrangementMap.put(docArrangement_i.Arrangement__c, docArrangement_i);
            if (!doctorToArrangementsMap.containsKey(docArrangement_i.Doctor__c)) {
                doctorToArrangementsMap.put(docArrangement_i.Doctor__c, new List<OptionWrp>());
            }
            OptionWrp option_i = new OptionWrp(docArrangement_i.Arrangement__r.Name, docArrangement_i.Arrangement__c);
            if (docArrangement_i.Arrangement__r.PayerFactor__r.InsuranceCode__c == '0') {
                option_i.label += ' - ' + docArrangement_i.self_payment__c;
            }
            option_i.isSurgery = docArrangement_i.SurgeryArrangement__c && docArrangement_i.StatusTafnitIsActiveSurg__c;
            doctorToArrangementsMap.get(docArrangement_i.Doctor__c).add(option_i);
        }
        System.debug('arrangementMap: size: ' + arrangementMap.size() + ' value: ' + arrangementMap);
        System.debug('doctorToArrangementsMap: size: ' + doctorToArrangementsMap.size() + ' value: ' + doctorToArrangementsMap);

        allDoctors.addAll(promotedDoctors);
        allDoctors.addAll(randomize(expertDoctors));
        allDoctors.addAll(randomize(alertedDoctors));

        if (searchType == LC_DoctorScreenUtil.FOR_THIS_WEEK) {
            allDoctors.sort();
        }

        for (DoctorWrp doctor_i : allDoctors) {
            if (doctorToRankMap.containsKey(doctor_i.id)) {
                doctor_i.rank = doctorToRankMap.get(doctor_i.id);
            }
            if (doctorToSitesMap.containsKey(doctor_i.id)) {
                doctor_i.sites = doctorToSitesMap.get(doctor_i.id);
            }
            if (doctorMap.get(doctor_i.id).All_medical_procedures_ids__c != null) {
                doctor_i.procedures = doctorMap.get(doctor_i.id).All_medical_procedures_ids__c.split(',');
            }
            if (doctorToArrangementsMap.containsKey(doctor_i.id)) {
                doctor_i.arrangements = doctorToArrangementsMap.get(doctor_i.id);
                doctor_i.setDefaultArrangement(arrangements);
            }
        }

        SearchDoctorsWrp wrapper = new SearchDoctorsWrp(allDoctors);
        wrapper.filterOptions.degrees.addAll(wrapper.filterOptions.prepareOptions(degrees));
        wrapper.filterOptions.quantities.addAll(wrapper.filterOptions.prepareOptions(quantities));
        wrapper.filterOptions.sites.addAll(wrapper.filterOptions.prepareOptions(siteMap.values()));
        wrapper.filterOptions.procedures.addAll(wrapper.filterOptions.prepareOptions(procedureMap.values()));
        wrapper.filterOptions.arrangements.addAll(wrapper.filterOptions.prepareOptions(arrangementMap.values()));
        wrapper.filterOptions.genders.addAll(wrapper.filterOptions.prepareOptions(genders, PicklistUtil.buildPickListOptionsBySchema('Account', 'Gender__c', false)));

        return wrapper;
    }

    private Set<String> obtainRecommendedDoctorIds() {
        Set<String> recommendedDoctorIds = new Set<String>();

        for (Case_Recommended_Doctor__c recommendation_i : LC_DoctorScreenUtil.obtainRecommendations(this.cas.Id)) {
            recommendedDoctorIds.add(recommendation_i.Doctor__c);
        }
        System.debug('recommendedDoctorIds: size: ' + recommendedDoctorIds.size() + ' value: ' + recommendedDoctorIds);

        return recommendedDoctorIds;
    }

    private Set<String> obtainDoctorIds(String procedureId, List<String> arrangements, Boolean skipArrangement) {
        Set<String> doctorIds = new Set<String>();

        if (!skipArrangement) {
            for (Doctor_arrangement__c docArrangement_i : LC_DoctorScreenUtil.obtainDoctorArrangements(null, arrangements)) {
                doctorIds.add(docArrangement_i.Doctor__c);
            }
        }

        if (procedureId != null) {
            Set<String> innerDoctorIds = new Set<String>();
            for (Doctor_Medical_Procedure__c junction_i : LC_DoctorScreenUtil.obtainDoctorProcedures(doctorIds, procedureId)) {
                innerDoctorIds.add(junction_i.Doctor__c);
            }
            for (calendar_medp__c junction_i : LC_DoctorScreenUtil.obtainExcellentCalendarProcedures(procedureId)) {
                innerDoctorIds.add(junction_i.Calendar__r.Doctor__c);
            }
            doctorIds = innerDoctorIds;
        }
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        return doctorIds;
    }

    private String obtainSettlementCondition(List<String> settlements, Boolean skipSettlement) {
        String settlementCondition;

        if (!skipSettlement) {
            List<String> conditions = new List<String>();
            for (String settlement_i : settlements) {
                conditions.add('districts__c LIKE \'' + LC_DoctorScreenUtil.wrap(String.escapeSingleQuotes(settlement_i)) + '\'');
            }
            settlementCondition = '(' + String.join(conditions, ' OR ') + ')';
        }
        System.debug('settlementCondition: ' + settlementCondition);

        return settlementCondition;
    }

    private Map<String, Integer> obtainDoctorToQuantityMap(Set<String> doctorIds, String procedureId, String expertiseId) {
        Map<String, Integer> doctorToQuantityMap = new Map<String, Integer>();

        for (String doctorId_i : doctorIds) {
            doctorToQuantityMap.put(doctorId_i, 0);
        }
        for (Doctors_Statistics__c stat_i : LC_DoctorScreenUtil.obtainDoctorStatistics(doctorIds, procedureId, expertiseId)) {
            doctorToQuantityMap.put(stat_i.Doctor_Account__c, Integer.valueOf(stat_i.Total__c + doctorToQuantityMap.get(stat_i.Doctor_Account__c)));
        }
        System.debug('doctorToQuantityMap: size: ' + doctorToQuantityMap.size() + ' value: ' + doctorToQuantityMap);

        return doctorToQuantityMap;
    }

    private Map<String, Decimal> obtainDoctorToRankMap(Set<String> doctorIds) {
        Map<String, Decimal> doctorToRankMap = new Map<String, Decimal>();

        for (Doctor_rank__c docRank_i : LC_DoctorScreenUtil.obtainDoctorRanks(doctorIds)) {
            doctorToRankMap.put(docRank_i.doctor__c, docRank_i.rank_value__c);
        }
        System.debug('doctorToRankMap: size: ' + doctorToRankMap.size() + ' value: ' + doctorToRankMap);

        return doctorToRankMap;
    }

    private List<DoctorWrp> randomize(List<DoctorWrp> doctors) {
        Integer currentIndex = doctors.size();
        Integer randomIndex;
        DoctorWrp tempDoctor;

        while (currentIndex != 0) {
            randomIndex = Integer.valueOf(Math.floor(Math.random() * currentIndex));
            currentIndex -= 1;

            tempDoctor = doctors[currentIndex];
            doctors[currentIndex] = doctors[randomIndex];
            doctors[randomIndex] = tempDoctor;
        }
        return doctors;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to obtain the closest available slot time and auto-refresh the info in the Doctor Screen
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             28-06-2022             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public Map<String, String> obtainClosestAvailableSlotInfo(Set<String> doctorIds, String expertiseId, String subExpertiseId) {
        Map<String, String> doctorToStrSlotDTMap = new Map<String, String>();

        Map<String, Datetime> doctorCodeToSlotDTMap = this.obtainDoctorCodeToSlotTimeMap(expertiseId, subExpertiseId);

        for (Account doctor_i : LC_DoctorScreenUtil.obtainDoctors(doctorIds)) {
            String closestAvailableSlotInfo_i = doctorCodeToSlotDTMap.containsKey(doctor_i.Doctor_Code__c)
                ? LC_DoctorScreenUtil.prettifyTime(doctorCodeToSlotDTMap.get(doctor_i.Doctor_Code__c))
                : '';
            doctorToStrSlotDTMap.put(doctor_i.Id, closestAvailableSlotInfo_i);
        }
        System.debug('doctorToStrSlotDTMap: size: ' + doctorToStrSlotDTMap.size() + ' value: ' + doctorToStrSlotDTMap);

        return doctorToStrSlotDTMap;
    }

    private Map<String, Datetime> obtainDoctorCodeToSlotTimeMap(String expertiseId, String subExpertiseId) {
        Map<String, Datetime> doctorCodeToSlotDTMap = new Map<String, Datetime>();

        if (expertiseId != null && subExpertiseId != null) {
            Expertise__c expertise = LC_DoctorScreenUtil.obtainExpertise(expertiseId);
            Sub_Expertise__c subExpertise = LC_DoctorScreenUtil.obtainSubExpertise(subExpertiseId);

            ws_ClosestExpertAppointment.GetCalendarsResponse response = ws_ClosestExpertAppointment.getCalendars(
                expertise.Expertise_Code__c, subExpertise.Sub_expertise_code__c);

            if (response?.DoctorCalendars != null && !response.DoctorCalendars.isEmpty()) {
                for (ws_ClosestExpertAppointment.DoctorCalendar doctor_i : response.DoctorCalendars) {
                    doctorCodeToSlotDTMap.put(doctor_i.LicenseNumber, Datetime.valueOf(doctor_i.ClosestDateTime));
                }
            }
        }
        System.debug('doctorCodeToSlotDTMap: size: ' + doctorCodeToSlotDTMap.size() + ' value: ' + doctorCodeToSlotDTMap);

        return doctorCodeToSlotDTMap;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to recommend chosen doctors
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             15-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public void recommendDoctors(Set<String> doctorIds) {
        List<Case_Recommended_Doctor__c> recommendationsToInsert = new List<Case_Recommended_Doctor__c>();

        List<Case_Recommended_Doctor__c> recommendationsToDelete = LC_DoctorScreenUtil.obtainRecommendations(this.cas.Id);
        System.debug('recommendationsToDelete: size: ' + recommendationsToDelete.size() + ' value: ' + recommendationsToDelete);

        if (!recommendationsToDelete.isEmpty()) {
            delete recommendationsToDelete;
        }

        for (String doctorId_i : doctorIds) {
            recommendationsToInsert.add(new Case_Recommended_Doctor__c(Case__c = this.cas.Id, Doctor__c = doctorId_i));
        }
        System.debug('recommendationsToInsert: size: ' + recommendationsToInsert.size() + ' value: ' + recommendationsToInsert);

        if (!recommendationsToInsert.isEmpty()) {
            insert recommendationsToInsert;
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to send doctor advisor and recommend chosen doctors
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             15-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public void sendDoctorAdvisor(Set<String> doctorIds) {
        this.cas.Send_DocAdvisor__c = true;
        update this.cas;

        this.recommendDoctors(doctorIds);
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to search clinics related to the chosen doctor
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             13-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public List<ClinicWrp> obtainClinics(String doctorId) {
        List<ClinicWrp> clinics = new List<ClinicWrp>();

        for (Calendar__c calendar_i : LC_DoctorScreenUtil.obtainExcellentCalendars(doctorId)) {
            clinics.add(new ClinicWrp(calendar_i));
        }

        Map<String, Payer_Factor__c> pfMap = this.obtainPFMap();

        List<Doctor_in_Clinic__c> docClinics = LC_DoctorScreenUtil.obtainDoctorClinics(doctorId);
        System.debug('docClinics: size: ' + docClinics.size() + ' value: ' + docClinics);

        Set<String> siteIdsWithProcedure = this.obtainSiteIdsWithProcedure(doctorId, docClinics);
        Set<String> agreementPFCodes = new Set<String>{'0', '1111', '0;1111'};

        for (Doctor_in_Clinic__c docClinic_i : docClinics) {
            if ((docClinic_i.Schedule_System__c == 'QFlow' && !siteIdsWithProcedure.contains(docClinic_i.Clinic__r.Site__c)) ||
                    (this.isPublicChannel() && agreementPFCodes.contains(docClinic_i.PayerFactorMulti__c))) {
                System.debug('clinic ' + docClinic_i.Clinic__r.Name + ' (' + docClinic_i.Clinic__c + ') was skipped');
                continue;
            }

            List<String> codes_i = docClinic_i.PayerFactorMulti__c != null
                ? docClinic_i.PayerFactorMulti__c.split(';')
                : new List<String>();

            if (this.isPublicChannel() ||
                    (this.isPrivateChannel() && (codes_i.contains('0') || codes_i.contains('1111')))) {
                clinics.add(new ClinicWrp(docClinic_i, this.replacePFCodesByNames(pfMap, codes_i)));
            }
        }
        System.debug('clinics: size: ' + clinics.size() + ' value: ' + clinics);

        return clinics;
    }

    private Map<String, Payer_Factor__c> obtainPFMap() {
        Map<String, Payer_Factor__c> pfMap = new Map<String, Payer_Factor__c>();

        for (Payer_Factor__c pf_i : LC_DoctorScreenUtil.obtainPFs()) {
            pfMap.put(pf_i.InsuranceCode__c, pf_i);
        }
        System.debug('pfMap: size: ' + pfMap.size() + ' value: ' + pfMap);

        return pfMap;
    }

    private Set<String> obtainSiteIdsWithProcedure(String doctorId, List<Doctor_in_Clinic__c> docClinics) {
        Set<String> siteIdsWithProcedure = new Set<String>();
        Set<String> siteIds = new Set<String>();

        ExpertProcedureService sExpertProcedure = ExpertProcedureService.getInstance();

        List<String> procedureCodes = this.cas.sub_case_subject__c == 'המלצה על רופא מומחה'
            ? this.isPrivateChannel() ? sExpertProcedure.getPrivateDefault() : sExpertProcedure.getPublicDefault()
            : this.isPrivateChannel() ? sExpertProcedure.getAllPrivate() : sExpertProcedure.getAllPublic();
        procedureCodes.addAll(LC_DoctorScreenUtil.obtainExcellentProcedureCodes());
        System.debug('procedureCodes: size: ' + procedureCodes.size() + ' value: ' + procedureCodes);

        for (Doctor_in_Clinic__c docClinic_i : docClinics) {
            if (docClinic_i.Schedule_System__c == 'QFlow') {
                siteIds.add(docClinic_i.Clinic__r.Site__c);
            }
        }
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);

        for (calendar_medp__c calendarProcedure_i : LC_DoctorScreenUtil.obtainCalendarProcedures(doctorId, siteIds, procedureCodes)) {
            siteIdsWithProcedure.add(calendarProcedure_i.Calendar__r.BranchName__c);
            siteIdsWithProcedure.add(calendarProcedure_i.Calendar__r.CalenderInClinic__r.Clinic__r.Site__c);
        }
        System.debug('siteIdsWithProcedure: size: ' + siteIdsWithProcedure.size() + ' value: ' + siteIdsWithProcedure);

        return siteIdsWithProcedure;
    }

    private String replacePFCodesByNames(Map<String, Payer_Factor__c> pfMap, List<String> codes) {
        List<String> names = new List<String>();

        for (String code_i : codes) {
            names.add(pfMap.containsKey(code_i) ? pfMap.get(code_i).Name : code_i);
        }

        return String.join(names, '; ');
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to split logic between scheduling an appointment and creating a new one
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             14-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public SelectedClinicWrp chooseClinic(String recordId) {
        if (Id.valueOf(recordId).getSobjectType() == Calendar__c.getSObjectType()) {
            Calendar__c calendar = LC_DoctorScreenUtil.obtainExcellentCalendar(recordId);
            System.debug('calendar: ' + calendar);

            /** schedule appointment screen excellent clinic */
            return new SelectedClinicWrp(calendar);
        }

        Doctor_in_Clinic__c docClinic = LC_DoctorScreenUtil.obtainDoctorClinic(recordId);
        System.debug('docClinic: ' + docClinic);

        if (docClinic.Schedule_System__c == 'QFlow' || docClinic.Schedule_System__c == 'Shidurit') {
            /** schedule appointment screen */
            return new SelectedClinicWrp(docClinic);
        } else {
            /** new appointment creating */
            ExpertProcedureService sExpertProcedure = ExpertProcedureService.getInstance();

            Medical_Procedure__c procedure = LC_DoctorScreenUtil.obtainProcedure(
                this.isPrivateChannel() ? sExpertProcedure.getPrivateDefault() : sExpertProcedure.getPublicDefault());

            Map<String, Object> defaultFieldValues = new Map<String, Object>{
                'Appointment_Status__c' => 'NewAppointment',
                'Name' => 'פגישה חדשה',
                'type_of_consult__c' => this.cas.sub_case_subject__c,
                'Patient_Account__c' => this.cas.AccountId,
                'Case_Hidden__c' => this.cas.Id,
                'Case__c' => this.cas.Id,
                'SourceSystem__c' => docClinic.Schedule_System__c,
                'Clinic__c' => docClinic.Clinic__c,
                'Medical_Procedure__c' => procedure.Id
            };

            if (this.cas.Recommended_doc__c != null) {
                defaultFieldValues.put('Doctor_Account__c', this.cas.Recommended_doc__c);
            } else if (this.cas.RecordType.DeveloperName == 'Assuta_360') {
                defaultFieldValues.put('Doctor_Account__c', this.cas.Contact_doctor__c);
            }

            if (this.cas.RecordType.DeveloperName == 'CaseAfterSale' || this.cas.RecordType.DeveloperName == 'DOC_expert') {
                defaultFieldValues.put('Opportunity__c', this.cas.Opportunity__c);
            } else if (this.cas.RecordType.DeveloperName == 'Assuta_360') {
                defaultFieldValues.put('Case_360__c', this.cas.Id);
            }

            return new SelectedClinicWrp(new SObjectWrapper('Appointment__c', LC_DoctorScreenUtil.APPT_RT_MAP.get('Experts').getRecordTypeId(), defaultFieldValues));
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * The method to schedule an appointment and recommend doctors
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @created             15-10-2021             <evgeniy.kravchuk@synebo.io>
     * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public void schedule(String selectedDoctorId, String arrangementId, Set<String> doctorIds) {
        if (arrangementId == null) {
            throw new LC_DoctorScreenException(LC_DoctorScreenUtil.ERR_ARRANGEMENT);
        }

        Boolean hasExcellentCalendars = !LC_DoctorScreenUtil.obtainExcellentCalendars(selectedDoctorId).isEmpty();

        Doctor_Arrangement__c selectedDocArrangement = LC_DoctorScreenUtil.obtainDoctorArrangement(selectedDoctorId, arrangementId);
        Doctor_Arrangement__c privateDocArrangement = selectedDocArrangement;

        if (selectedDocArrangement?.Arrangement__r.PayerFactor__r.InsuranceCode__c != '9'
                && selectedDocArrangement?.Arrangement__r.PayerFactor__r.InsuranceCode__c != '24'
                && selectedDocArrangement?.Arrangement__r.PayerFactor__r.InsuranceCode__c != '41') {
            privateDocArrangement = LC_DoctorScreenUtil.obtainDoctorArrangement(selectedDoctorId, '0');
        }

        //this.cas.Recommended_doc__c = selectedDoctorId;
        this.cas.Doctor_Arrangement__c = hasExcellentCalendars ? selectedDocArrangement?.Id : privateDocArrangement?.Id;
        this.cas.SurgeryMatchedArrangement__c = hasExcellentCalendars ? null : selectedDocArrangement?.Id;
        this.cas.sub_case_subject__c = 'זימון תור לאחר המלצה';
        this.cas.Case_subject__c = 'זימון רופא מומחה';
        this.cas.Channel__c = 'פרטי';

        if (this.cas.RecordType.DeveloperName == 'Assuta_360') {
            this.cas.Contact_doctor__c = selectedDoctorId;
        } else if (this.cas.RecordType.DeveloperName == 'CaseAfterSale' && this.cas.Opportunity__c != null) {
            update new Opportunity(
                Id = this.cas.Opportunity__c,
                //Recommended_doc__c = selectedDoctorId,
                Doctor_Arrangement__c = privateDocArrangement?.Id,
                Channel__c = 'פרטי');
        }
        update this.cas;

        doctorIds.add(selectedDoctorId);
        this.recommendDoctors(doctorIds);
    }

    /** INNER METHODS */
    private Boolean isPrivateChannel() {
        return this.cas.Channel__c == 'פרטי';
    }

    private Boolean isPublicChannel() {
        return this.cas.Channel__c == 'קופה';
    }

    /** WRAPPERS */
    public class ConfigWrp {
        @AuraEnabled
        public DefaultDataWrp defaultData {get;set;}
        @AuraEnabled
        public String selectedDoctorId {get;set;}
        @AuraEnabled
        public List<OptionWrp> arrangements  {get;set;}
        @AuraEnabled
        public List<OptionWrp> settlements {get;set;}
        @AuraEnabled
        public String alertMessage {get;set;}
        @AuraEnabled
        public List<String> alertProcedureCodes {get;set;}

        public ConfigWrp(Case cas) {
            this.defaultData = new DefaultDataWrp(cas);

            if (cas.Recommended_doc__c != null) {
                this.selectedDoctorId = cas.Recommended_doc__c;
            } else if (cas.RecordType.DeveloperName == 'Assuta_360') {
                this.selectedDoctorId = cas.Contact_doctor__c;
            }

            this.alertMessage = instance.isPublicChannel()
                ? Label.MSG_Private_Procedure_in_Public_Channel
                : Label.MSG_Public_Procedure_in_Private_Channel;
            this.alertProcedureCodes = instance.isPublicChannel()
                ? ExpertProcedureService.getInstance().getAllPrivate()
                : ExpertProcedureService.getInstance().getAllPublic();

            this.arrangements = new List<OptionWrp>();
            this.settlements = new List<OptionWrp>();
        }

        public void fillDefauls(Case cas) {
            this.defaultData.arrangements = this.getValues(this.arrangements);

            if (cas.Account.Area__c != null) {
                this.defaultData.settlements.add(cas.Account.Area__c);
            } else {
                this.defaultData.settlements = this.getValues(this.settlements);
            }
        }

        private List<String> getValues(List<OptionWrp> options) {
            List<String> values = new List<String>();
            for (OptionWrp option_i : options) {
                values.add(option_i.value);
            }
            return values;
        }
    }

    public class DefaultDataWrp {
        @AuraEnabled
        public ExpertiseWrp expertise {get;set;}
        @AuraEnabled
        public SubExpertiseWrp subExpertise {get;set;}
        @AuraEnabled
        public ProcedureWrp procedure {get;set;}
        @AuraEnabled
        public List<String> arrangements {get;set;}
        @AuraEnabled
        public List<String> settlements {get;set;}

        public DefaultDataWrp(Case cas) {
            if (cas.Expertise__c != null) {
                this.expertise = new ExpertiseWrp(cas.Expertise__r);
            }
            if (cas.Sub_Expertise__c != null) {
                this.subExpertise = new SubExpertiseWrp(cas.Sub_Expertise__r);
            }
            if (cas.Medical_Procedure__c != null) {
                this.procedure = new ProcedureWrp(cas.Medical_Procedure__r);
            }

            this.arrangements = new List<String>();
            this.settlements = new List<String>();
        }
    }

    public class SearchDoctorsWrp {
        @AuraEnabled
        public List<DoctorWrp> doctors {get;set;}
        @AuraEnabled
        public FilterOptionWrp filterOptions {get;set;}

        public SearchDoctorsWrp(List<DoctorWrp> doctors) {
            this.doctors = doctors;
            this.filterOptions = new FilterOptionWrp();
        }
    }

    public class FilterOptionWrp {
        @AuraEnabled
        public List<Decimal> ranks {get;set;}
        @AuraEnabled
        public List<OptionWrp> sites {get;set;}
        @AuraEnabled
        public List<OptionWrp> genders {get;set;}
        @AuraEnabled
        public List<OptionWrp> degrees {get;set;}
        @AuraEnabled
        public List<OptionWrp> procedures {get;set;}
        @AuraEnabled
        public List<OptionWrp> quantities {get;set;}
        @AuraEnabled
        public List<OptionWrp> arrangements {get;set;}

        public FilterOptionWrp() {
            this.ranks = new List<Decimal>{1, 10};
            this.sites = new List<OptionWrp>();
            this.genders = new List<OptionWrp>{new OptionWrp(LC_DoctorScreenUtil.LBL_ALL, '')};
            this.degrees = new List<OptionWrp>{new OptionWrp(LC_DoctorScreenUtil.LBL_ALL, '')};
            this.procedures = new List<OptionWrp>();
            this.quantities = new List<OptionWrp>();
            this.arrangements = new List<OptionWrp>();
        }

        public List<OptionWrp> prepareOptions(Set<String> uniqueValues) {
            List<OptionWrp> options = new List<OptionWrp>();
            for (String value_i : uniqueValues) {
                options.add(new OptionWrp(value_i));
            }
            return options;
        }

        public List<OptionWrp> prepareOptions(Set<String> uniqueValues, List<PicklistUtil.PicklistValue> entries) {
            List<OptionWrp> options = new List<OptionWrp>();
            for (PicklistUtil.PicklistValue entry_i : entries) {
                if (uniqueValues.contains(entry_i.value)) {
                    options.add(new OptionWrp(entry_i));
                }
            }
            return options;
        }

        public List<OptionWrp> prepareOptions(List<SObject> records) {
            List<OptionWrp> options = new List<OptionWrp>();
            for (SObject record_i : records) {
                switch on String.valueOf(record_i.Id.getSobjectType()) {
                    when 'Medical_Procedure__c' {
                        Medical_Procedure__c procedure_i = (Medical_Procedure__c) record_i;
                        options.add(new OptionWrp(procedure_i.Marketing_Procedure_Name__c, procedure_i.Id));
                    }
                    when 'Doctor_arrangement__c' {
                        Doctor_arrangement__c docArrangement_i = (Doctor_arrangement__c) record_i;
                        options.add(new OptionWrp(docArrangement_i.Arrangement__r.Name, docArrangement_i.Arrangement__c));
                    }
                    when 'Doctor_in_site__c' {
                        Doctor_in_site__c docSite_i = (Doctor_in_site__c) record_i;
                        options.add(new OptionWrp(docSite_i.Site__r.Name, docSite_i.Site__c));
                    }
                }
            }
            return options;
        }
    }

    public class DoctorWrp implements Comparable {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String gender {get;set;}
        @AuraEnabled
        public String degree {get;set;}
        @AuraEnabled
        public String picture {get;set;}
        @AuraEnabled
        public Decimal rank {get;set;}
        @AuraEnabled
        public Integer quantity {get;set;}
        @AuraEnabled
        public Boolean isRecommended {get;set;}
        @AuraEnabled
        public Boolean isExcellent {get;set;}
        @AuraEnabled
        public Boolean isPromoted {get;set;}
        @AuraEnabled
        public Boolean isExpert {get;set;}
        @AuraEnabled
        public String alert {get;set;}
        @AuraEnabled
        public String expertiseETL1 {get;set;}
        @AuraEnabled
        public String expertiseETL2 {get;set;}
        @AuraEnabled
        public List<String> sites {get;set;}
        @AuraEnabled
        public List<String> procedures {get;set;}
        @AuraEnabled
        public String arrangement {get;set;}
        @AuraEnabled
        public List<OptionWrp> arrangements {get;set;}
        @AuraEnabled
        public String closestAvailableSlotInfo {get;set;}
        @AuraEnabled
        public Datetime closestAvailableSlotTime {get;set;}

        public DoctorWrp(Account doctor, Integer quantity, Boolean isRecommended, Datetime slotTime) {
            this.id = doctor.Id;
            this.name = doctor.Name;
            this.gender = doctor.Gender__c;
            this.degree = doctor.doctor_degree__c;
            this.picture = doctor.Picture_URL__c?.replace('amp;', '');
            this.expertiseETL1 = doctor.Expertise_1__r.Name;
            this.expertiseETL2 = doctor.Expertise_2__r.Name;

            this.rank = 1;
            this.quantity = quantity;

            this.isRecommended = isRecommended;
            this.isExcellent = !doctor.Calendars__r.isEmpty();
            this.isPromoted = doctor.Counting_Promoted_doctor_values__c > 0;
            this.isExpert = doctor.Experts_center__c;

            this.closestAvailableSlotTime = slotTime;
            this.closestAvailableSlotInfo = slotTime != null
                ? LC_DoctorScreenUtil.prettifyTime(slotTime)
                : '';

            this.alert = this.isExpert && this.isPromoted
                ? 'יתבצע ע"י המטופל לא שייך למרכז מומחים. הזימון'
                : '';

            this.sites = new List<String>();
            this.procedures = new List<String>();
            this.arrangements = new List<OptionWrp>();
        }

        public void setDefaultArrangement(List<String> arrangements) {
            if (arrangements?.size() == 1) {
                this.arrangement = arrangements.get(0);
            } else if (this.arrangements.size() == 1) {
                this.arrangement = this.arrangements.get(0).value;
            } else {
                for (OptionWrp arrangement_i : this.arrangements) {
                    if (arrangement_i.label.contains('מומחים')) {
                        this.arrangement = arrangement_i.value;
                        break;
                    }
                }
            }
        }

        public Integer compareTo(Object compareTo) {
            DoctorWrp that = (DoctorWrp) compareTo;
            if (this.closestAvailableSlotTime != null && that.closestAvailableSlotTime != null) {
                return this.closestAvailableSlotTime < that.closestAvailableSlotTime
                    ? -1
                    : 1;
            } else if (this.closestAvailableSlotTime != null) {
                return -1;
            } else if (that.closestAvailableSlotTime != null) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    public class ClinicWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String clinicId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String address {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String calendar {get;set;}
        @AuraEnabled
        public String workingHours {get;set;}
        @AuraEnabled
        public String pfNames {get;set;}
        @AuraEnabled
        public SiteWrp site {get;set;}

        public ClinicWrp(Calendar__c calendar) {
            this.id = calendar.Id;
            this.name = calendar.Name;
            this.clinicId = calendar.Id; // redirect to
            this.calendar = calendar.AppointmentSys__c;

            if (calendar.BranchName__c != null) {
                this.site = new SiteWrp(calendar.BranchName__r);
            }
        }

        public ClinicWrp(Doctor_in_Clinic__c docClinic) {
            this.id = docClinic.Id;
            this.clinicId = docClinic.Clinic__c;

            this.phone = docClinic.Phone__c;
            this.calendar = docClinic.Schedule_System__c;
            this.workingHours = docClinic.Working_Hours__c;

            this.name = docClinic.Clinic__r.Name;
            this.address = docClinic.Clinic__r.street_address__c != null
                ? docClinic.Clinic__r.street_address__c + ', ' + docClinic.Clinic__r.Address__c
                : docClinic.Clinic__r.Address__c;

            if (docClinic.Clinic__r.Site__c != null) {
                this.site = new SiteWrp(docClinic.Clinic__r.Site__r);
            }
        }

        public ClinicWrp(Doctor_in_Clinic__c docClinic, String pfNames) {
            this(docClinic);
            this.pfNames = pfNames;
        }
    }

    public class SelectedClinicWrp {
        @AuraEnabled
        public String action {get;set;} /** schedule, create */
        @AuraEnabled
        public SObjectWrapper appointment {get;set;}
        @AuraEnabled
        public ClinicWrp clinic {get;set;}

        public SelectedClinicWrp(Calendar__c calendar) {
            this.action = 'schedule';
            this.clinic = new ClinicWrp(calendar);
        }

        public SelectedClinicWrp(Doctor_in_Clinic__c docClinic) {
            this.action = 'schedule';
            this.clinic = new ClinicWrp(docClinic);
        }

        public SelectedClinicWrp(SObjectWrapper appointment) {
            this.action = 'create';
            this.appointment = appointment;
        }
    }

    public class OptionWrp {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public Boolean isSurgery {get;set;} // for Arrangements only

        public OptionWrp(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public OptionWrp(String value) {
            this(value, value);
        }

        public OptionWrp(PicklistUtil.PicklistValue entry) {
            this(entry.label, entry.value);
        }
    }

    /** SOBJECT WRAPPERS */
    public class ExpertiseWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}

        public ExpertiseWrp(Expertise__c expertise) {
            this.id = expertise.Id;
            this.name = expertise.Name;
        }
    }

    public class SubExpertiseWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public ExpertiseWrp expertise {get;set;}

        public SubExpertiseWrp(Sub_Expertise__c subExpertise) {
            this.id = subExpertise.Id;
            this.name = subExpertise.Name;
            this.expertise = new ExpertiseWrp(subExpertise.Expertise__r);
        }
    }

    public class ProcedureWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public SubExpertiseWrp subExpertise {get;set;}

        public ProcedureWrp(Medical_Procedure__c procedure) {
            this.id = procedure.Id;
            this.name = procedure.Marketing_Procedure_Name__c != null
                ? procedure.Marketing_Procedure_Name__c
                : procedure.Name;
            this.code = procedure.Procedure_Code__c;

            if (procedure.Sub_Expertise__c != null) {
                this.subExpertise = new SubExpertiseWrp(procedure.Sub_Expertise__r);
            }
        }
    }

    public class SiteWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String code {get;set;}

        public SiteWrp(Site__c site) {
            this.id = site.Id;
            this.name = site.Name;
            this.code = site.Site_Code__c;
        }
    }
}