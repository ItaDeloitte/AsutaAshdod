@isTest
public class TestDataFactory {

    public static final String ACCOUNT_ID_TYPE = '1';

    // CHECKED METHODS
    public static final String ACCT_D_RT_NAME = 'Doctor_Account';
    public static final String ACCT_P_RT_NAME = 'PersonAccount';
    public static final String APPT_I_RT_NAME = 'Institutes';
    public static final String APPT_S_RT_NAME = 'Surgeries';
    public static final String APPT_E_RT_NAME = 'Experts';
    public static final String APPT_ALL_RT = 'All';

    public static final String D_ID_NUMBER = '000000224';
    public static final String D_ID_NUMBER_1 = '999657950';
    public static final String P_ID_NUMBER = '852986371';
    public static final String P_ID_NUMBER_1 = '999088396';

    public static final String ID_NUMBER = '311049191';
    public static final String ID_TYPE = '1';
    public static final Integer TEST_INT = 504;

    public static final String PROCEDURE_CODE = '760902';
    public static final String NEW_DOCTOR_PROCEDURE_CODE = '99400';
    public static final String MAMMOGRAPHY_PROCEDURE_CODE = '760902';
    public static final String BREAST_ULTRASOUND_MAMMOGRAPHY_PROCEDURE_CODE = '760904';

    public static final String CALENDAR_CODE = '504';
    public static final String DOMAIN_CODE = '120';
    public static final String PFACTOR_CODE = '3';
    public static final String PFACTOR_CHILD_CODE = '8';
    public static final String SITE_CODE = '20';
    public static final String SITE_CODEASHDOD = '33';
    public static final String CLINIC_SCHEDULED_SYSTEM = 'QFlow';

    public static final String JSONED_SLOTS = getJSONSlots(PROCEDURE_CODE);
    public static final String KEYWORD = 'test';

    public static Integer uCounter = 1;

    @IsTest
    public static void test() {}

    public static CommonData insertCommonData() {
        return insertCommonData(null);
    }

    public static CommonData insertCommonData(String apptRecordType) {
        DataBuilder dBuilder =  buildCommonData();
        dBuilder.initCommonData();

        if (apptRecordType != null) {
            if (apptRecordType == APPT_ALL_RT || apptRecordType == APPT_S_RT_NAME) {
                
                Case caseS = dBuilder.createCase('Surgery', 'Surgery');
                caseS.AccountId = dBuilder.patient.Id;
                dBuilder.addProcedure('99000', '99000');
                dBuilder.addAppoitment(APPT_S_RT_NAME,'99000', 'Surgery');
               
            }
            if (apptRecordType == APPT_ALL_RT || apptRecordType == APPT_I_RT_NAME) {
                dBuilder.addCase('Appointments', 'Appointments');
                dBuilder.addProcedure(MAMMOGRAPHY_PROCEDURE_CODE, MAMMOGRAPHY_PROCEDURE_CODE);
                dBuilder.addAppoitment(APPT_I_RT_NAME, MAMMOGRAPHY_PROCEDURE_CODE, 'Appointments');
            }
            if (apptRecordType == APPT_ALL_RT || apptRecordType == APPT_E_RT_NAME) {
                dBuilder.addCase('DOC_expert', 'DOC_expert');
                dBuilder.addProcedure(NEW_DOCTOR_PROCEDURE_CODE, NEW_DOCTOR_PROCEDURE_CODE);
                dBuilder.addAppoitment(APPT_E_RT_NAME, NEW_DOCTOR_PROCEDURE_CODE, 'DOC_expert');
            }
        }
        return dBuilder.insertCommonData();
    }

    public static DataBuilder buildCommonData() {
        return new DataBuilder();
    }

    /*
    * ──────────────────────────────────────────────────────────────────────────────────────────────┐
    * Builder helps create/insert records for test. Builder class has 'pre inserted records' 
    * like doctor accout, patient account, docotr contract etc. 'Pre inserted records' inserted with
    * some filed fields. Use methods like add/create to add additional records to test data like case, 
    * medical procedure etc. Additional records uses lookup ids from 'pre inserted records'. 
    * Example test clases LC_DocExpertiseControllerTest and LC_CaseAppointmentButtonsTest.
    * ───────────────────────────────────────────────────────────────────────────────────────────────
    * @created         20-04-2021           <sergey.duiev@synebo.io>
    * ──────────────────────────────────────────────────────────────────────────────────────────────┘
    */

    public class DataBuilder {    

        public Account doctor {public get; private set;}
        public Account patient {public get; private set;}
        public Contact con {public get; private set;}
        public Payer_Factor__c pFactor {public get; private set;}
        public Payer_Factor__c ppFactor {public get; private set;}
        public Agreement__c agreement {public get; private set;}
        public Arrangements__c arrangement {public get; private set;}
        public Doctor_Arrangement__c docArrangement {public get; private set;}
        public Expertise__c expertise {public get; private set;}
        public Sub_Expertise__c subExpertise {public get; private set;}
        public Domain__c domain {public get; private set;}
        public Calendar__c calendar {public get; private set;}
        public Opportunity oppt {public get; private set;}
        public Procedure_Plan__c procedurePlan {public get; private set;}
        public Settlement__c settlement {public get; private set;}
        public Clinic__c clinic {public get; private set;}
        public Doctor_in_Clinic__c docClinic {public get; private set;}
        public Doctor_Rank__c docRank {public get; private set;}
        public Site__c site {public get; private set;}
        public Nursery__c nursery {public get; private set;}
        public Lead lead1 {public get; private set;}

        private Map<String, Account> accountsMap = new Map<String, Account>();

        private List<Case> cases = new List<Case>();
        private Map<String, Case> casesMap = new Map<String, Case>();
        
        private List<Medical_Procedure__c> procedures = new List<Medical_Procedure__c>();
        private Map<String, Medical_Procedure__c> proceduresMap = new Map<String, Medical_Procedure__c>();

        private List<Appointment> appointments = new List<Appointment>();

        private List<DoctorsStatistics> doctorsStatistics = new List<DoctorsStatistics>();

        private List<DoctorMedicalProcedure> doctorMedicalProcedures = new List<DoctorMedicalProcedure>();

        private List<Doctor_in_site__c> docInSites = new List<Doctor_in_site__c>();

        private List<CaseRecommendedDoctor> caseRecomendedDocs = new List<CaseRecommendedDoctor>();

        private List<ProcedureSite> procedureSites = new List<ProcedureSite>();

        private List<CalendarProcedure> calendarProcedures = new List<CalendarProcedure>();

        private List<Sequence> sequences = new List<Sequence>();

        private List<SchedulerParameters> schedulerParameters = new List<SchedulerParameters>();

        private Map<String, Group> groups = new Map<String, Group>();

        private List<SiteDomain> siteDomains = new List<SiteDomain>();

        private List<SurveyTaker> surveyTakers = new List<SurveyTaker>();

        private Map<String, Survey__c> surveyMap = new Map<String, Survey__c>();

        private List<SurveyQuestion> surveyQuestions = new List<SurveyQuestion>();

        private List<DocToAction> docToActions = new List<DocToAction>();

        private Map<String, Guidelines__c> guidelinesMap = new Map<String, Guidelines__c>();

        private List<GuidanceScenario> guidanceScenaries = new List<GuidanceScenario>();

        private List<ImplantsToMedProd> implantsToMedProds = new List<ImplantsToMedProd>();

        private List<Calendar1__c> calendars1 = new List<Calendar1__c>();

        public DataBuilder() {
            this.doctor = TestDataFactory.getAccount(ACCT_D_RT_NAME);
            this.patient = TestDataFactory.getAccount(ACCT_P_RT_NAME);
            this.con = TestDataFactory.getContact(null);
            this.ppFactor = TestDataFactory.getPFactor(PFACTOR_CODE);
            this.ppFactor.Insurance_Company__c = true;
            this.pFactor = TestDataFactory.getPFactor(PFACTOR_CHILD_CODE);
            this.pFactor.Insurance_Company__c = true;
            this.agreement = TestDataFactory.getAgreement(null, null);
            this.arrangement = TestDataFactory.getArrangements(null);
            this.docArrangement = TestDataFactory.getDocArrangement(null, null);
            this.expertise = TestDataFactory.getExpertise();
            this.subExpertise = TestDataFactory.getSubExpertise(null);
            this.domain = TestDataFactory.getDomain(DOMAIN_CODE);
            this.calendar = TestDataFactory.getCalendar();
            this.oppt = TestDataFactory.getOpportunity();
            this.procedurePlan = TestDataFactory.getProcedurePlan();
            this.settlement = TestDataFactory.getSettlement();
            this.clinic = TestDataFactory.getClinic();
            this.docClinic = TestDataFactory.getDocClinic(null, null);
            this.docRank = TestDataFactory.getDocRank(null);
            this.site = TestDataFactory.getSite();
            this.nursery = TestDataFactory.getNursery();
            this.lead1 = TestDataFactory.getLead();
        }

        /*
        * ──────────────────────────────────────────────────────────────────────────────────────────────┐
        * Inserts 'predetermined records'. Modify records fields or add new before calling this method.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @created         20-04-2021           <sergey.duiev@synebo.io>
        * ──────────────────────────────────────────────────────────────────────────────────────────────┘
        */

        public DataBuilder initCommonData() {
            insert TestDataFactory.getENV();
            List<Account> accounts = new List<Account>();
            
            accounts.add(this.doctor);
            accounts.add(this.patient);
            insert accounts;

            this.con.AccountId = this.doctor.Id;
            insert this.con;

            insert this.ppFactor;
            this.pFactor.Name_of_parent__c = this.ppFactor.Id;
            insert this.pFactor;
            
            this.agreement.Doctor_Account__c = this.doctor.Id;
            this.agreement.PayerFactor__c = this.pFactor.Id;
            insert this.agreement;

            this.arrangement.PayerFactor__c = this.pFactor.Id;
            insert this.arrangement;

            this.docArrangement.Arrangement__c = this.arrangement.Id;
            this.docArrangement.Doctor__c = this.doctor.Id;
            insert this.docArrangement;

            insert this.expertise;

            this.subExpertise.Expertise__c = this.expertise.Id;
            insert this.subExpertise;

            insert this.domain;
            insert this.calendar;
            this.oppt.AccountId = this.patient.Id;
            insert this.oppt;
            insert this.procedurePlan;
            insert this.settlement;
            insert this.clinic;

            this.docClinic.Doctors__c = this.doctor.Id;
            this.docClinic.Clinic__c = this.clinic.Id;
            insert this.docClinic;

            this.docRank.Doctor__c = this.doctor.Id;
            insert this.docRank;

            insert this.site;
            insert this.nursery;
            insert this.lead1;
            return this;
        }


        public DataBuilder addAccountDoctor(String key, String idNumber) {
            return buildAccountDoctor(key)
                .setField('ID_Number__c', idNumber)
                .build();
        }

        public DataBuilder addAccountPerson(String key, String idNumber) {
            return buildAccountPerson(key)
                .setField('ID_Number__c', idNumber)
                .build();
        }  
        
        public AccountBuilder buildAccountDoctor(String key) {
            Account acct = TestDataFactory.getAccount(ACCT_D_RT_NAME);
            AccountBuilder accountBuilder = new AccountBuilder(this, acct);

            accountsMap.put(key, acct);
            return accountBuilder;
        }

        public AccountBuilder buildAccountPerson(String key) {
            Account acct = TestDataFactory.getAccount(ACCT_P_RT_NAME);
            AccountBuilder accountBuilder = new AccountBuilder(this, acct);

            accountsMap.put(key, acct);
            return accountBuilder;
        }

        public DataBuilder addCase(String recordType) {
            return addCase(null, recordType);
        }

        public DataBuilder addCase(String key, String recordType) {
            createCase(key, recordType);
            return this;
        }

        public Case createCase(String recordType) {
            return createCase(null, recordType);
        }

        public Case createCase(String key, String recordType) {
            Case cas = TestDataFactory.getCase(recordType, doctor.Id, patient.Id, con.Id, pFactor.Id);

            if (key == null) {
                cases.add(cas);
            } else {
                casesMap.put(key, cas);
            }
            return cas;
        }

        public DataBuilder addProcedure(String code) {
            return buildProcedure(null, code).build();
        }

        public DataBuilder addProcedure(String key, String code) {
            return buildProcedure(key, code).build();
        }

        public Medical_Procedure__c createProcedure(String key, String code) {
            Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, code);

            if (key == null) {
                procedures.add(procedure);
            } else {
                proceduresMap.put(key, procedure);
            }
            return procedure;
        }

        public SObjectBuilder buildProcedure(String code) {
            return buildProcedure(null, code);
        }

        public SObjectBuilder buildProcedure(String key, String code) {
            Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, code);
            SObjectBuilder sBuilder = new SObjectBuilder(this, procedure);

            if (key == null) {
                procedures.add(procedure);
            } else {
                proceduresMap.put(key, procedure);
            }
            return sBuilder;
        }

        public DataBuilder addAppoitment(String recordType, String procedure, String cas) {
            return addAppoitment(null, recordType, procedure, cas);
        }

        public DataBuilder addAppoitment(String key, String recordType, String procedure, String cas) {
            createAppoitment(key, recordType, procedure, cas);
            return this;
        }

        public Appointment__c createAppoitment(String recordType, String procedure, String cas) {
            return createAppoitment(null, recordType, procedure, cas);
        }

        public Appointment__c createAppoitment(String key, String recordType, String procedure, String cas) {
            Appointment__c appt = TestDataFactory.getAppointment(recordType, null, patient.Id, calendar.Id, null);
            Appointment apptWrapper = new Appointment(key, appt, cas, procedure);
            
            appointments.add(apptWrapper);
            return appt;
        }

        public DataBuilder addDoctorsStatistics(String procedure) {
            createDoctorsStatistics(procedure);
            return this;
        }

        public Doctors_Statistics__c createDoctorsStatistics(String procedure) {
            Doctors_Statistics__c docStat = getDocStatistics(this.doctor.Id, null);

            doctorsStatistics.add(new DoctorsStatistics(docStat, procedure));
            return docStat;
        }

        public DataBuilder addDoctorMedicalProcedure(String procedureKey) {
            return buildDoctorMedicalProcedure(procedureKey).build();
        }

        public Doctor_Medical_Procedure__c createDoctorMedicalProcedure(String procedureKey) {
            Doctor_Medical_Procedure__c docMedProc = getDocProcedure(this.doctor.Id, null);

            doctorMedicalProcedures.add(new DoctorMedicalProcedure(docMedProc, procedureKey));
            return docMedProc;
        }

        public SObjectBuilder buildDoctorMedicalProcedure(String procedureKey) {
            Doctor_Medical_Procedure__c docMedProc = getDocProcedure(this.doctor.Id, null);
            SObjectBuilder sBuilder = new SObjectBuilder(this, docMedProc);

            doctorMedicalProcedures.add(new DoctorMedicalProcedure(docMedProc, procedureKey));

            return sBuilder;
        }

        public DataBuilder addDocSite() {
            createDocSite();
            return this;
        }

        public Doctor_in_site__c createDocSite() {
            Doctor_in_site__c docSite =  getDocSite(this.doctor.Id, this.site.Id);

            docInSites.add(docSite);
            return docSite;
        }

        public DataBuilder addCaseRecDoc(String cas) {
            createCaseRecDoc(cas);
            return this;
        }

        public Case_Recommended_Doctor__c createCaseRecDoc(String cas) {
            Case_Recommended_Doctor__c caseRecDoc = getCaseRecDoc(this.doctor.Id, null);

            caseRecomendedDocs.add(new CaseRecommendedDoctor(caseRecDoc, cas));
            return caseRecDoc;
        }

        public DataBuilder addProcedureSite(String procedure) {
            createProcedureSite(procedure);
            return this;
        }

        public Medical_Procedure_in_Sites__c createProcedureSite(String procedure) {
            Medical_Procedure_in_Sites__c procedureSite = getProcedureSite(null, this.site.Id);

            procedureSites.add(new ProcedureSite(procedureSite, procedure));
            return procedureSite;
        }

        public DataBuilder addCalendarProcedure(String procedure) {
            createCalendarProcedure(procedure);
            return this;
        }

        public calendar_medp__c createCalendarProcedure(String procedure) {
            calendar_medp__c calendar = getCalendarProcedure(this.calendar.Id, null);

            calendarProcedures.add(new CalendarProcedure(calendar, procedure));
            return calendar;
        }
        
        public DataBuilder addSequence(String procedure1, String procedure2) {
            createSequence(procedure1, procedure2);
            return this;
        }

        public Sequence__c createSequence(String procedure1, String procedure2) {
            Sequence__c sequence = getSequence(null, null);
            
            sequences.add(new Sequence(sequence, procedure1, procedure2));
            return sequence;
        }

        public DataBuilder addCalendar1() {
            createCalendar1(null, null);
            return this;
        } 

        public DataBuilder addCalendar1(Integer numberOfDays) {
            createCalendar1(null, numberOfDays);
            return this;
        } 

        public DataBuilder addCalendar1(Integer numberOfDaysBack, Integer numberOfDays) {
            createCalendar1(numberOfDaysBack, numberOfDays);
            return this;
        } 

        public List<Calendar1__c> createCalendar1() {
            return createCalendar1(null, null);
        }

        public List<Calendar1__c> createCalendar1(Integer numberOfDays) {
            return createCalendar1(null, numberOfDays);
        }

        public List<Calendar1__c> createCalendar1(Integer numberOfDaysBack, Integer numberOfDays) {
            if (numberOfDaysBack == null && numberOfDays == null) {
                calendars1.add(getCalendar1());
            } else if (numberOfDaysBack == null && numberOfDays != null) {
                calendars1.addAll(getCalendars1(numberOfDays));
            } else if (numberOfDaysBack != null && numberOfDays != null) {
                calendars1.addAll(getCalendars1_days(numberOfDaysBack, numberOfDays));
            }
            return calendars1;
        }

        public DataBuilder addSchedulerParameters(String procedureKey) {
            createSchedulerParameters(procedureKey);
            return this;
        }

        public Scheduler_Parameters__c createSchedulerParameters(String procedureKey) {
            Scheduler_Parameters__c param = getSchParameter(null, this.domain.Id);

            schedulerParameters.add(new SchedulerParameters(param, procedureKey));
            return param;
        } 

        public DataBuilder addGroup(String key, String type) {
            createGroup(key, type);
            return this;
        }

        public Group createGroup(String key, String type) {
            Group grp = getGroup(type);

            groups.put(key, grp);
            return grp;
        }

        public DataBuilder addSiteDomain(String queueKey) {
            buildSiteDomain(queueKey).build();
            return this;
        }

        public SObjectBuilder buildSiteDomain(String queueKey) {
            Site_Domain__c siteDomain = getSiteDomain(this.site.Id, this.domain.Id, null);
            SObjectBuilder sBuilder = new SObjectBuilder(this, siteDomain);

            siteDomains.add(new SiteDomain(siteDomain, queueKey));
            return sBuilder;
        }

        public DataBuilder addSurvey(String key) {
            return buildSurvey(key).build();
        }

        public SObjectBuilder buildSurvey(String key) {
            Survey__c survey = getSurvey();
            SObjectBuilder sBuilder = new SObjectBuilder(this, survey);

            surveyMap.put(key, survey);
            return sBuilder;
        }

        public DataBuilder addSurveyQuestion(String surveyKey) {
            return buildSurveyQuestion(surveyKey).build();  
        }        

        public SObjectBuilder buildSurveyQuestion(String surveyKey) {
            SurveyQuestion surveyQuestion = new SurveyQuestion(getSurveyQuestion(null), surveyKey);
            SObjectBuilder sBuilder = new SObjectBuilder(this, surveyQuestion.serveyQuestion);

            surveyQuestions.add(surveyQuestion);
            return sBuilder;
        }

        public DataBuilder addDocToAction(String surveyKey) {
            return buildDocToAction(surveykey).build();
        }

        public SObjectBuilder buildDocToAction(String surveyKey) {
            DocToAction docToAction = new DocToAction(getDocToAction(null), surveyKey);
            SObjectBuilder sBuilder = new SObjectBuilder(this, docToAction.docToAction);

            docToActions.add(docToAction);
            return sBuilder;
        }

        public DataBuilder addSurveyTaker(String surveyKey, String caseKey, String acctKey) {
            return buildSurveyTaker(surveyKey, caseKey, acctKey).build();
        }

        public SObjectBuilder buildSurveyTaker(String surveyKey, String caseKey, String acctKey) {
            SurveyTaker surveyTaker = new SurveyTaker(TestDataFactory.getSurveyTaker(null, null, null), surveyKey, caseKey, acctKey);
            SObjectBuilder sBuilder = new SObjectBuilder(this, surveyTaker.SurveyTaker);

            surveyTakers.add(surveyTaker);
            return sBuilder;
        }

        public DataBuilder addGuidelines(String key) {
            return buildGuidelines(key).build();
        }

        public SObjectBuilder buildGuidelines(String key) {
            Guidelines__c guildlines = getGuidelines();
            SObjectBuilder sBuilder = new SObjectBuilder(this, guildlines);

            guidelinesMap.put(key, guildlines);
            return sBuilder;
        }

        public DataBuilder addGuidanceScenario(String procedureKey, String guidelineKey) {
            return buidGuidanceScenario(procedureKey, guidelineKey).build();
        }

        public SObjectBuilder buidGuidanceScenario(String procedureKey, String guidelineKey) {
            GuidanceScenario guidanceScenario = new GuidanceScenario(TestDataFactory.getGuidlineScenario(null, null, site.Id), procedureKey, guidelineKey, null);
            SObjectBuilder sBuilder = new SObjectBuilder(this, guidanceScenario.guidanceScenario);

            guidanceScenaries.add(guidanceScenario);
            return sBuilder;
        }

        public DataBuilder addImplantsToMedProd(String procedureKey) {
            return buildImplantsToMedProd(procedureKey).build();
        }

        public SObjectBuilder buildImplantsToMedProd(String procedureKey) {
            ImplantsToMedProd implantsToMedProd = new ImplantsToMedProd(TestDataFactory.getImplantsToMedProd(nursery.Id, null), null, procedureKey);
            SObjectBuilder sBuilder = new SObjectBuilder(this, implantsToMedProd.implantsToMedProd);

            implantsToMedProds.add(implantsToMedProd);
            return sBuilder;
        }
        /*
        * ──────────────────────────────────────────────────────────────────────────────────────────────┐
        * Inserts additional records with that was added/created after initCommonData.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @created         20-04-2021           <sergey.duiev@synebo.io>
        * ──────────────────────────────────────────────────────────────────────────────────────────────┘
        */

        public CommonData insertCommonData() {
            CommonData cData = new CommonData();

            cData.doctor = this.doctor;
            cData.patient = this.patient;
            cData.con = this.con;
            cData.pFactor = this.pFactor;
            cData.ppFactor = this.ppFactor;
            cData.agreement = this.agreement;
            cData.arrangement = this.arrangement;
            cData.docArrangement = this.docArrangement;
            cData.expertise = this.expertise;
            cData.subExpertise = this.subExpertise;
            cData.domain = this.domain;
            cData.calendar = this.calendar;
            cData.oppt = this.oppt;
            cData.procedurePlan = this.procedurePlan;
            cData.settlement = this.settlement;
            cData.clinic = this.clinic;
            cData.docClinic = this.docClinic;
            cData.docRank = this.docRank;
            cData.site = this.site;
            cData.nursery = this.nursery;
            cData.lead1 = this.lead1;
            
            List<Account> acctountsToInsert = new List<Account>();
            acctountsToInsert.addAll(accountsMap.values());
            if (!acctountsToInsert.isEmpty()) {
                insert acctountsToInsert;
            }

            List<Case> casesToInsert = new List<Case>();

            casesToInsert.addAll(cases);
            casesToInsert.addAll(casesMap.values());

            if (!casesToInsert.isEmpty()) {
                insert casesToInsert;
            }
            cData.cases = casesMap;

            Test.startTest();
            if (!proceduresMap.isEmpty()) {
                insert proceduresMap.values();
            }
            cData.procedures = proceduresMap;

            List<Appointment__c> apptsToInsert = new List<Appointment__c>();

            for (Appointment appt_i : appointments) {
                appt_i.appt.Case__c = casesMap.get(appt_i.caseKey).Id;
                appt_i.appt.Medical_Procedure__c = proceduresMap.get(appt_i.procedureKey)?.Id;
                apptsToInsert.add(appt_i.appt);
                if (appt_i.apptKey != null)  {
                    cData.appointments.put(appt_i.apptKey, appt_i.appt);
                }
            }
            if (!apptsToInsert.isEmpty()) {
                insert apptsToInsert;
            }

            Test.stopTest();

            List<Doctors_Statistics__c> docStatsForInsert = new List<Doctors_Statistics__c>();

            for (DoctorsStatistics docStat_i : doctorsStatistics) {
                docStat_i.docStat.Medical_Procedure__c = proceduresMap.get(docStat_i.procedureKey)?.Id;
                docStatsForInsert.add(docStat_i.docStat);
            }
            if (!docStatsForInsert.isEmpty()) {
                insert docStatsForInsert;
            }
          
            List<Doctor_Medical_Procedure__c> docMedProcsToInsert = new List<Doctor_Medical_Procedure__c>();

            for (DoctorMedicalProcedure docMedProc_i : doctorMedicalProcedures) {
                docMedProc_i.docSMedProc.Medical_Procedure__c = proceduresMap.get(docMedProc_i.procedureKey)?.Id;
                docMedProcsToInsert.add(docMedProc_i.docSMedProc);
            }
            if (!docMedProcsToInsert.isEmpty()) {
                insert docMedProcsToInsert;
            }
            
            if (!docInSites.isEmpty()) {
                insert docInSites;
            }
            
            List<Case_Recommended_Doctor__c> caseRecDocsToInsert = new List<Case_Recommended_Doctor__c>();
        
            for (CaseRecommendedDoctor caseRecDoc_i : caseRecomendedDocs) {
                caseRecDoc_i.recomendedDoc.Case__c = casesMap.get(caseRecDoc_i.caseKey)?.Id;
                caseRecDocsToInsert.add(caseRecDoc_i.recomendedDoc);
            }
            if (!caseRecDocsToInsert.isEmpty()) {
                insert caseRecDocsToInsert;
            }
            
            List<Medical_Procedure_in_Sites__c> procedureSitesToInsert = new List<Medical_Procedure_in_Sites__c>();

            for (ProcedureSite procSite_i : procedureSites) {
                procSite_i.procedureSite.Medical_Procedure__c = proceduresMap.get(procSite_i.procedureKey)?.Id;
                procedureSitesToInsert.add(procSite_i.procedureSite);
            }
            if (!procedureSitesToInsert.isEmpty()) {
                insert procedureSitesToInsert;
            }

            List<calendar_medp__c> calendarProcedureToInsert = new List<calendar_medp__c>();

            for (CalendarProcedure calendarProc_i : calendarProcedures) {
                calendarProc_i.calendarProcedure.Medical_Procedure__c = proceduresMap.get(calendarProc_i.procedureKey)?.Id;
                calendarProcedureToInsert.add(calendarProc_i.calendarProcedure);
            }
            if (!calendarProcedureToInsert.isEmpty()) {
                insert calendarProcedureToInsert;
            }

            List<Sequence__c> sequencesToInsert = new List<Sequence__c>();

            for (Sequence seq_i : sequences) {
                seq_i.sequence.first_medical_procedure__c = proceduresMap.get(seq_i.procedure1Key)?.Id;
                seq_i.sequence.second_medical_procedure__c = proceduresMap.get(seq_i.procedure2Key)?.Id;
                sequencesToInsert.add(seq_i.sequence);
            }
            if (!sequencesToInsert.isEmpty()) {
                insert sequencesToInsert;
            }

            List<Scheduler_Parameters__c> schedulerParametersToInsert = new List<Scheduler_Parameters__c>();

            for (schedulerParameters param_i : schedulerParameters) {
                param_i.param.Medical_Procedure__c = proceduresMap.get(param_i.procedureKey)?.Id;
                schedulerParametersToInsert.add(param_i.param);
            }
            if (!schedulerParametersToInsert.isEmpty()) {
                insert schedulerParametersToInsert;
            }

            List<Group> groupsToInsert = new List<Group>();

            for (Group grp_i : groups.values()) {
                groupsToInsert.add(grp_i);
            }
            if (!groupsToInsert.isEmpty()) {
                insert groupsToInsert;
            }

            List<Site_Domain__c> siteDomainsToInsert = new List<Site_Domain__c>();

            for (SiteDomain siteD_i : siteDomains) {
                siteD_i.siteDomain.Queue__c = groups.get(siteD_i.queueKey)?.Id;
                siteDomainsToInsert.add(siteD_i.siteDomain);
            }
            if (!siteDomainsToInsert.isEmpty()) {
                insert siteDomainsToInsert;
            }

            List<Survey__c> surveyToInsert = new List<Survey__c>();
            surveyToInsert.addAll(surveyMap.values());

            if (!surveyToInsert.isEmpty()) {
                insert surveyToInsert;
            }

            List<Survey_Question__c> surveyQuestionsToInsert = new List<Survey_Question__c>();
            for (SurveyQuestion surveyQuestion_i : surveyQuestions) {
                surveyQuestion_i.serveyQuestion.Survey__c = surveyMap.get(surveyQuestion_i.surveyKey)?.Id;
                surveyQuestionsToInsert.add(surveyQuestion_i.serveyQuestion);
            }
            if (!surveyQuestionsToInsert.isEmpty()) {
                insert surveyQuestionsToInsert;
            }

            List<Doc_to_action__c> docToActionsToInsert = new List<Doc_to_action__c>();
            for (DocToAction docToAction_i : docToActions) {
                docToAction_i.docToAction.Survey__c = surveyMap.get(docToAction_i.surveyKey)?.Id;
                docToActionsToInsert.add(docToAction_i.docToAction);
            }
            if (!docToActionsToInsert.isEmpty()) {
                insert docToActionsToInsert;
            }

            List<SurveyTaker__c> surveyTakersToInsert = new List<SurveyTaker__c>();
            for (SurveyTaker serveyTaker_i : surveyTakers) {
                serveyTaker_i.surveyTaker.Survey__c = surveyMap.get(serveyTaker_i.surveyKey)?.Id;
                serveyTaker_i.surveyTaker.Case__c = casesMap.get(serveyTaker_i.caseKey)?.Id;
                serveyTaker_i.surveyTaker.Account__c = accountsMap.get(serveyTaker_i.acctKey)?.Id;
                surveyTakersToInsert.add(serveyTaker_i.surveyTaker);
            }
           
            if (!surveyTakersToInsert.isEmpty()) {
                insert surveyTakersToInsert;
            }

            List<Guidelines__c> guidelinesToInsert = new List<Guidelines__c>();
            guidelinesToInsert.addAll(guidelinesMap.values());
            if (!guidelinesToInsert.isEmpty()) {
                insert guidelinesToInsert;
            }

            List<Guidance_Scenario__c> guidanceScenariesToInsert = new List<Guidance_Scenario__c>();
            for (GuidanceScenario guidanceScenario_i : guidanceScenaries) {
                guidanceScenario_i.guidanceScenario.Medical_Procedure__c = proceduresMap.get(guidanceScenario_i.procedureKey)?.Id;
                guidanceScenario_i.guidanceScenario.Guideline1__c = guidelinesMap.get(guidanceScenario_i.guidelineKey)?.Id;
                guidanceScenariesToInsert.add(guidanceScenario_i.guidanceScenario);
            }
            if (!guidanceScenariesToInsert.isEmpty()) {
                insert guidanceScenariesToInsert;
            }

            List<Implants_to_med_prod__c> implantsToMedProdToInsert = new List<Implants_to_med_prod__c>();
            for (ImplantsToMedProd implant_i : implantsToMedProds) {
                implant_i.implantsToMedProd.Medical_Procedure__c = proceduresMap.get(implant_i.procedureKey)?.Id;
                implantsToMedProdToInsert.add(implant_i.implantsToMedProd);
            }
            if (!implantsToMedProdToInsert.isEmpty()) {
                insert implantsToMedProdToInsert;
            }
            
            if (!calendars1.isEmpty()) {
                insert calendars1;
            }
            return cData;
        }
    }

    public class CommonData {
        public Account doctor {public get; private set;}
        public Account patient {public get; private set;}
        public Contact con {public get; private set;}
        public Payer_Factor__c pFactor {public get; private set;}
        public Payer_Factor__c ppFactor {public get; private set;}
        public Agreement__c agreement {public get; private set;}
        public Arrangements__c arrangement {public get; private set;}
        public Doctor_Arrangement__c docArrangement {public get; private set;}
        public Expertise__c expertise {public get; private set;}
        public Sub_Expertise__c subExpertise {public get; private set;}
        public Domain__c domain {public get; private set;}
        public Calendar__c calendar {public get; private set;}
        public Opportunity oppt {public get; private set;}
        public Procedure_Plan__c procedurePlan {public get; private set;}
        public Settlement__c settlement {public get; private set;}
        public Clinic__c clinic {public get; private set;}
        public Doctor_in_Clinic__c docClinic {public get; private set;}
        public Doctor_Rank__c docRank {public get; private set;}
        public Site__c site {public get; private set;}
        public Nursery__c nursery {public get; private set;}
        public Lead lead1 {public get; private set;}
        public Map<String, Appointment__c> appointments {public get; private set;}
        public Map<String, Medical_Procedure__c> procedures {public get; private set;}
        public Map<String, Case> cases {public get; private set;}

        public CommonData() {
            this.appointments = new Map<String, Appointment__c>();
            this.procedures = new Map<String, Medical_Procedure__c>();
            this.cases = new Map<String, Case>();
        }
    }

    public class AccountBuilder extends SObjectBuilder {

        public AccountBuilder(DataBuilder dBuilder, Account acct) {
            super(dBuilder, acct);
        }

        private AccountBuilder setField1(String fieldName, Object value) {
            return (AccountBuilder) this.setField(fieldName, value);
        }

        public AccountBuilder setPicture(String str) {
            return this.setField1('Picture__c', str);
        }

        public AccountBuilder setPictureURL(String url) {
            return this.setField1('Picture_URL__c', url);
        }

        public AccountBuilder setDoctorCode(String code) {
            return this.setField1('Doctor_Code__c', code);
        }

        public AccountBuilder setExpertsCenter(Boolean flag) {
            return this.setField1('Experts_center__c', flag);
        }
    }

    public virtual class SObjectBuilder {

        private DataBuilder dBuilder; 
        private SObject sObj;

        public SObjectBuilder(DataBuilder dBuilder, SObject sObj) {
            this.dBuilder = dBuilder;
            this.sObj = sObj;
        }

        public SObjectBuilder setField(String fieldName, Object value) {
            sObj.put(fieldName, value);
            return this;
        }

        public DataBuilder build() {
            return this.dBuilder;
        }
    }

    class Appointment {
        private String apptKey;
        private Appointment__c appt;
        private String caseKey;
        private String procedureKey;

        public Appointment(String apptKey, Appointment__c appt, String caseKey, String procedureKey) {
            this.apptKey = apptKey;
            this.appt = appt;
            this.caseKey = caseKey;
            this.procedureKey = procedureKey;
        }
    }

    class DoctorsStatistics {
        private Doctors_Statistics__c docStat;
        private String procedureKey;

        public DoctorsStatistics(Doctors_Statistics__c docStat, String procedureKey) {
            this.docStat = docStat;
            this.procedureKey = procedureKey;
        }
    }

    class DoctorMedicalProcedure {
        private Doctor_Medical_Procedure__c docSMedProc;
        private String procedureKey;

        public DoctorMedicalProcedure(Doctor_Medical_Procedure__c docSMedProc, String procedureKey) {
            this.docSMedProc = docSMedProc;
            this.procedureKey = procedureKey;
        }
    }

    class CaseRecommendedDoctor {
        private Case_Recommended_Doctor__c recomendedDoc;
        private String caseKey;

        public CaseRecommendedDoctor(Case_Recommended_Doctor__c recomendedDoc, String caseKey) {
            this.recomendedDoc = recomendedDoc;
            this.caseKey = caseKey;
        }
    }

    class ProcedureSite {
        private Medical_Procedure_in_Sites__c procedureSite;
        private String procedureKey;

        public ProcedureSite(Medical_Procedure_in_Sites__c procedureSite, String procedureKey) {
            this.procedureSite = procedureSite;
            this.procedureKey = procedureKey;
        }
    }

    class CalendarProcedure {
        private calendar_medp__c calendarProcedure;
        private String procedureKey;

        public CalendarProcedure(calendar_medp__c calendarProcedure, String procedureKey) {
            this.calendarProcedure = calendarProcedure;
            this.procedureKey = procedureKey;
        }
    }
  
    class Sequence {
        private Sequence__c sequence;
        private String procedure1Key;
        private String procedure2Key;

        public Sequence(Sequence__c sequence, String procedure1Key, String procedure2Key) {
            this.sequence = sequence;
            this.procedure1Key = procedure1Key;
            this.procedure2Key = procedure2Key;
        }
    }

    class SchedulerParameters {
        private Scheduler_Parameters__c  param;
        private String procedureKey;

        public SchedulerParameters(Scheduler_Parameters__c param, String procedureKey) {
            this.param = param;
            this.procedureKey = procedureKey;
        }
    }

    class SiteDomain {
        private Site_Domain__c siteDomain;
        private String queueKey;

        public SiteDomain(Site_Domain__c siteDomain, String queueKey) {
            this.siteDomain = siteDomain;
            this.queueKey = queueKey;
        }
    }

    class SurveyQuestion {
        private Survey_Question__c serveyQuestion;
        private String surveyKey;

        public SurveyQuestion(Survey_Question__c serveyQuestion, String surveyKey) {
            this.serveyQuestion = serveyQuestion;
            this.surveyKey = surveyKey;
        }
    }

    class SurveyTaker {
        private SurveyTaker__c surveyTaker;
        private String surveyKey;
        private String caseKey;
        private String acctKey;

        public SurveyTaker(SurveyTaker__c surveyTaker, String surveyKey, String caseKey, String acctKey) {
            this.surveyTaker = surveyTaker;
            this.surveyKey = surveyKey;
            this.caseKey = caseKey;
            this.acctKey = acctKey;
        }
    }

    class DocToAction {
        private Doc_to_action__c docToAction;
        private String surveyKey;

        public DocToAction(Doc_to_action__c docToAction, String surveyKey) {
            this.docToAction = docToAction;
            this.surveyKey = surveyKey;
        }
    }

    class GuidanceScenario {
        private Guidance_Scenario__c guidanceScenario;
        private String procedureKey;
        private String guidelineKey;
        private String siteKey;

        public GuidanceScenario(Guidance_Scenario__c guidanceScenario, String procedureKey, String guidelineKey, String siteKey) {
            this.guidanceScenario = guidanceScenario;
            this.procedureKey = procedureKey;
            this.guidelineKey = guidelineKey;
            this.siteKey = siteKey;
        }
    }

    class ImplantsToMedProd {
        private Implants_to_med_prod__c implantsToMedProd;
        private String implansKey;
        private String procedureKey;

        public ImplantsToMedProd(Implants_to_med_prod__c implantsToMedProd, String implansKey, String procedureKey) {
            this.implantsToMedProd = implantsToMedProd;
            this.implansKey = implansKey;
            this.procedureKey = procedureKey;
        }
    }
    
    public static User getUser(String profileName) {
        profileName = profileName == null ? 'test Profile' : profileName;
        Profile p = [SELECT Id, UserType FROM Profile WHERE Name =: profileName];

        String UName = String.valueOf(System.now().format('yyyyMMdd_hhmmss')) + String.valueOf(uCounter) + '@assuta.co.il.dev';
        System.debug(LoggingLevel.Info, '#UName=' + UName);
        uCounter++;

        return new User(
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = Uname.substring(0, 7),
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LastName = 'Testing',
            User_AD__c = 'asyag',
            ProfileId = p.Id,
            UserName = UName,
            IsActive = true,
            Email = Uname,
            Title = 'נציג'
        );
    }

    public static String getJSONSlots(String procedureCode) {
        List<ws_AppointmentNew.CalenderSlot> slots = new List<ws_AppointmentNew.CalenderSlot>();
        ws_AppointmentNew.CalenderSlot slot = new ws_AppointmentNew.CalenderSlot();
        slot.StartTime = DateTime.newInstance(2021, 6, 7, 3, 1, 5);
        slot.EndTime = DateTime.newInstance(2021, 7, 7, 3, 1, 5);
        slot.procedureCode = procedureCode;
        slot.AppointmentTypeId = '504';
        slot.ModalityCode = TEST_INT;
        slot.CalendarId = TEST_INT;
        slot.siteCode = SITE_CODE;
        slot.UnitCode = TEST_INT;
        slot.SlotId = TEST_INT;
        slot.Duration = 2;
        slots.add(slot);
        return JSON.serialize(slots);
    }

    public static ENV__c getENV() {
        EnsembleSystem__mdt metadata = [SELECT Id, Env_value__c FROM EnsembleSystem__mdt LIMIT 1];
        return new ENV__c(Env_value__c = metadata.Env_value__c);
    }

    public static String getRTId(String developerName, String sObjectType) {
        // return [SELECT Id FROM RecordType WHERE DeveloperName =: developerName AND SObjectType =: sObjectType].Id;
        return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }

    public static Account getAccountPerson() {
        return getAccount(ACCT_P_RT_NAME);
    }

    public static Account getAccountDoctor() {
        return getAccount(ACCT_D_RT_NAME);
    }

    public static Account getAccount(String developerName) {
        Account acct = new Account(
            RecordTypeId = getRTId(developerName, 'Account'),
            Mailing_approval__c = 'מאשר דיוור - הכל',
            SMS_Phone_Number__c = '0999845467',
            Preferred_Channel__c = 'Phone',
            Insurer_factor__c = '2',
            ID_Type__c = ID_TYPE,
            Gender__c = 'נ'
        );
        if (developerName == ACCT_D_RT_NAME) {
            acct.sched_sys_doc_clinics__c = 'test sched sys doc clinic';
            acct.doctor_degree__c = KEYWORD + 'degree';
            acct.DisableValidation__c = true;
            acct.ID_Number__c = D_ID_NUMBER;
            acct.Name = KEYWORD + 'doctor';
            acct.Doctor_Code__c = '111';
            acct.Phone = '0546354188';
            acct.RoleCode__c = 15;
        } else if (developerName == ACCT_P_RT_NAME) {
            acct.PersonMailingCountry = 'Israel';
            acct.PersonMailingCity = 'Jerusalem';
            acct.PersonBirthdate = Date.today();
            acct.ID_Number__c = P_ID_NUMBER;
            acct.OTP_EMAIL_HIDDEN__c = null;
            acct.SMS_Phone_Number__c = '0527987458';
            acct.Phone = '+10546354188';
            acct.FirstName = KEYWORD;
            acct.LastName = 'patient';
            acct.Status__c = 'ח';
        }
        return acct;
    }

    public static Contact getContact(Id doctorId) {
        return new Contact(
            LastName = KEYWORD + 'contact',
            ID_Number__c = ID_NUMBER,
            ID_Type__c = ID_TYPE,
            AccountId = doctorId
        );
    }

    public static Payer_Factor__c getPFactor() {
        return getPFactor(PFACTOR_CODE);
    }

    public static Payer_Factor__c getPFactor(String pFactorCode) {
        return new Payer_Factor__c(
            PresentOnSchdeuleScreen__c = true,
            InsuranceCode__c = pFactorCode,
            Name = KEYWORD + 'pFactor'
        );
    }

    public static Case getCase(String recordType, Id doctorId, Id patientId, Id contactId, Id pFactorId) {
        Case cas =  new Case(
            sub_case_subject__c = 'שינוי תור קיים',
            Case_subject__c = 'עדכון תור קיים',
            PayerFactor__c = pFactorId,
            Patient__c = patientId,
            ContactId = contactId,
            AccountId = doctorId
            //RefferenceSource__c = 'אסותא מרכזים',
            //ActivityType__c = '	אשפוז' 
        );
        if (recordType != null) {
            cas.RecordTypeId = getRTId(recordType, 'Case');
        }   
        return cas;
    }

    public static Case getCase(Id doctorId, Id patientId, Id contactId, Id pFactorId) {
        return getCase(null, doctorId, patientId, contactId, pFactorId);
    }

    public static Case_Recommended_Doctor__c getCaseRecDoc(Id doctorId, Id caseId) {
        return new Case_Recommended_Doctor__c(
            doctor__c = doctorId,
            Case__c = caseId
        );
    }

    public static Expertise__c getExpertise() {
        return new Expertise__c(
            Name = KEYWORD + 'expertise'
        );
    }

    public static Sub_Expertise__c getSubExpertise(Id expertiseId) {
        return new Sub_Expertise__c(
            Name = KEYWORD + 'sub expertise',
            Expertise__c = expertiseId
        );
    }

    public static Domain__c getDomain() {
        return getDomain(DOMAIN_CODE);
    }

    public static Domain__c getDomain(String domainCode) {
        return new Domain__c(
            DomainCode__c = Decimal.valueOf(domainCode),
            Name = KEYWORD + 'domain'
        );
    }

    public static Medical_Procedure__c getProcedure(Id domainId, Id subExpertiseId) {
        return getProcedure(domainId, subExpertiseId, '99400');
    }

    public static Medical_Procedure__c getProcedure(Id domainId, Id subExpertiseId, String procedureCode) {
        return new Medical_Procedure__c(
            Marketing_Procedure_Name__c = KEYWORD + 'marketing procedure',
            Hide_From_Appointment_Screen__c = false,
            Procedure_Code__c = procedureCode,
            Sub_Expertise__c = subExpertiseId,
            Confidentiality__c = false,
            Name = KEYWORD + 'procedure',
            Domain__c = domainId,
            Protocols__c = 'p1',
            Status__c = '1'
        );
    }

    public static Procedure_Plan__c getProcedurePlan() {
        return new Procedure_Plan__c(
            ProcedurePlanCode__c = KEYWORD + 'procedure plan'
        );
    }

    public static Calendar__c getCalendar() {
        return getCalendar(CALENDAR_CODE);
    }
    
    public static Calendar__c getCalendar(String calendarCode) {
        return new Calendar__c(
            ServiceId__c = calendarCode
        );
    }

    public static Appointment__c getAppointment(String developerName, Id procedureId, Id patientId, Id calendarId, Id caseId, Id afterApptId, Boolean IsHidden) {
        return new Appointment__c(
            RecordTypeId = getRTId(developerName, 'Appointment__c'),
            Medical_Procedure_Text__c = KEYWORD + 'med procedure text',
            Appointment_Date_Time__c = Date.today().addDays(31),
            Calendar_Text__c = KEYWORD + 'calendar text',
            Medical_Procedure__c = procedureId,
            Site_Text__c = KEYWORD + 'site text',
            Patient_Account__c = patientId,
            Name = KEYWORD + 'appointment',
            Calendar__c = calendarId,
            Case__c = caseId,
            After_Appointment__c = afterApptId,
            Is_Hidden_Appointment__c = IsHidden
        );
    }

    public static Appointment__c getAppointment(String developerName, Id procedureId, Id patientId, Id calendarId, Id caseId) {
        return getAppointment(developerName, procedureId, patientId, calendarId, caseId, null, false);
    }

    public static Appointment__c getAppointmentSurgery(Id procedureId, Id patientId, Id calendarId, Id caseId) {
        return getAppointment(APPT_S_RT_NAME, procedureId, patientId, calendarId, caseId, null, false);
    }

    public static Appointment__c getAppointmentExperts(Id procedureId, Id patientId, Id calendarId, Id caseId) {
        return getAppointment(APPT_E_RT_NAME, procedureId, patientId, calendarId, caseId, null, false);
    }

    public static Appointment__c getAppointmentInstitutes(Id procedureId, Id patientId, Id calendarId, Id caseId) {
        return getAppointment(APPT_I_RT_NAME, procedureId, patientId, calendarId, caseId, null, false);
    }

    public static Doctor_Medical_Procedure__c getDocProcedure(Id doctorId, Id procedureId) {
        return new Doctor_Medical_Procedure__c(
            days_before_surgery_to_pre_s__c = 2,
            Medical_Procedure__c = procedureId,
            Pre_surgery__c = true,
            Doctor__c = doctorId
        );
    }

    public static Doctors_Statistics__c getDocStatistics(Id doctorId, Id procedureId) {
        return new Doctors_Statistics__c(
            Medical_Procedure__c = procedureId,
            Doctor_Account__c = doctorId,
            Total__c = 5);
    }

    public static Doctor_in_site__c getDocSite(Id doctorId, Id siteId) {
        return new Doctor_in_site__c(
            Account__c = doctorId,
            Site__c = siteId
        );
    }

    public static settlement__c getSettlement() {
        return new settlement__c(
            Area__c = 'אילת'
        );
    }

    public static Medical_Procedure_in_Sites__c getProcedureSite(Id procedureId, Id siteId) {
        return new Medical_Procedure_in_Sites__c(
            Medical_Procedure__c = procedureId,
            Site__c = siteId
        );
    }

    public static Sequence__c getSequence(Id procedureId1, Id procedureId2) {
        return new Sequence__c(
            first_medical_procedure__c = procedureId1,
            second_medical_procedure__c = procedureId2
        );
    }

    public static Sequence__c getSequence(Id procedureId1, Id procedureId2, Id procedureId3) {
        Sequence__c sequence = getSequence(procedureId1, procedureId2);
        sequence.third_medical_procedure__c = procedureId3;
        return sequence;
    }

    public static calendar_medp__c getCalendarProcedure(Id calendarId, Id procedureId) {
        return new calendar_medp__c(
            Medical_Procedure__c = procedureId,
            Calendar__c = calendarId
        );
    }

    public static Agreement__c getAgreement(Id doctorId, Id pFactorId) {
        return new Agreement__c(
            Name = KEYWORD + 'agreement',
            Doctor_Account__c = doctorId,
            PayerFactor__c = pFactorId
        );
    }

    public static Arrangements__c getArrangements(Id pFactorId) {
        return new Arrangements__c(
            PayerFactor__c = pFactorId,
            Name = KEYWORD + 'arrangement'
        );
    }

    public static Doctor_Arrangement__c getDocArrangement(Id doctorId, Id arrangementId) {
        return new Doctor_Arrangement__c(
            Arrangement__c = arrangementId,
            Doctor__c = doctorId
        );
    }

    public static Clinic__c getClinic() {
        return getClinic(CLINIC_SCHEDULED_SYSTEM);
    }

    public static Clinic__c getClinic(String scheduledSystem) {
        return new Clinic__c(
            Clinic_Email__c = 'main@clinic.com',
            CalendarClinic__c = scheduledSystem,
            Name = KEYWORD + 'clinic'
        );
    }

    public static Doctor_in_Clinic__c getDocClinic(Id doctorId, Id clinicId) {
        return new Doctor_in_Clinic__c(
            Doctors__c = doctorId,
            Clinic__c = clinicId
        );
    }

    public static Doctor_Rank__c getDocRank(Id doctorId) {
        return new Doctor_Rank__c(
            Doctor__c = doctorId,
            Rank_type__c = 'כללי',
            Rank_Value__c = 5
        );
    }

    public static Recommendations_after_exam__c getRecommendations(Id apptId) {
        return new Recommendations_after_exam__c(
            Related_Appointment__c = apptId
        );
    }

    public static Recommendations_after_exam__c getRecommendations(Id patientId, Id caseId) {
        return new Recommendations_after_exam__c(
            Patient__c = patientId,
            Case360__c = caseId
        );
    }

    public static RecommendationsTypeAfterExam__c getRecommendationsType() {
        return new RecommendationsTypeAfterExam__c();
    }

    public static ContentVersion getContentVersion() {
        return new ContentVersion(
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'),
            PathOnClient = 'test.jpg',
            Title = 'test',
            Origin = 'H'
        );
    }

    public static ContentDocumentLink getContentDocLink(Id linkedEntityId) {
        return new ContentDocumentLink(
            LinkedEntityId = linkedEntityId,
            ShareType = 'V'
        );
    }

    public static Site__c getSite() {
        return getSite(TestDataFactory.SITE_CODE);
    }

    public static Site__c getSite(String siteCode) {
        return new Site__c(
            AppScreen_SiteName__c = KEYWORD + 'screen name',
            Maccabi_Code__c = siteCode,
            Site_Code__c = siteCode,
            Name = KEYWORD + 'site'
        );
    }

    public static Site__c getSite(String siteCode, Id calendarId) {
        Site__c site = getSite(siteCode);
        site.US_Calendar__c = calendarId;
        return site;
    }

    public static File__c getFile() {
        return new File__c(
            Name = KEYWORD + 'file'
        );
    }

    public static File__c getFile(Case cas, Id procedureId) {
        File__c file = getFile();
        file.Medical_Procedure__c = procedureId;
        file.Account__c = cas.Patient__c;
        file.Case__c = cas.Id;
        return file;
    }

    public static Reminder__c getReminder(Id apptId) {
        return new Reminder__c(
            Reminder_Status__c = '1',
            Appointment__c = apptId
        );
    }

    public static Calendar1__c getCalendar1() {
        return new Calendar1__c(
            Gregorian_Date__c = Date.today(),
            business_day__c = false,
            Start_Time__c = Time.newInstance(1, 2, 3, 4),
            End_time__c =  Time.newInstance(1, 2, 3, 4),
            week_num__c = 1,
            Day__c = 'Sunday'
        );
    }

    public static List<Calendar1__c> getCalendars1(Integer numberOfDays) {
        List<Calendar1__c> calendars = new List<Calendar1__c>();
        for (Integer i = 0; i < numberOfDays; i++) {
            calendars.add(
                new Calendar1__c(
                    Gregorian_Date__c = Date.today().addDays(i),
                    business_day__c = true,
                    Start_Time__c = Time.newInstance(1, 2, 3, 4),
                    End_time__c =  Time.newInstance(1, 2, 3, 4),
                    week_num__c = 1,
                    Day__c = 'Sunday'
                )
            );
        }
        return calendars;
    }

    public static List<Calendar1__c> getCalendars1_days(Integer numberOfDaysBack, Integer numberOfDays) {
        List<Calendar1__c> calendars = new List<Calendar1__c>();
        Boolean businessDay = false;
        for (Integer i = 1; i < numberOfDaysBack; i++) {
            calendars.add(
                new Calendar1__c(
                    Gregorian_Date__c = Date.today().addDays(-i),
                    business_day__c = businessDay,
                    Start_Time__c = Time.newInstance(1, 2, 3, 4),
                    End_time__c =  Time.newInstance(1, 2, 3, 4),
                    week_num__c = 1,
                    Day__c = 'Sunday'
                )
            );
            businessDay = !businessDay;
        }
        for (Integer i = 0; i < numberOfDays; i++) {
            calendars.add(
                new Calendar1__c(
                    Gregorian_Date__c = Date.today().addDays(i),
                    business_day__c = businessDay,
                    Start_Time__c = Time.newInstance(1, 2, 3, 4),
                    End_time__c =  Time.newInstance(1, 2, 3, 4),
                    week_num__c = 1,
                    Day__c = 'Sunday'
                )
            );
            businessDay = !businessDay;
        }
        return calendars;
    }

    public static LiveChatTranscript getLiveChatTranscript() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        return new LiveChatTranscript(
            Pre_chat_RT__c = getRTId('DOC_expert', 'Case'), // 0128E0000007M4vQAE
            LiveChatVisitorid = lcv.Id
        );
    }

    public static Task getLogACall(Id userId, Boolean isCallback, String UUI, String OriginalCallObjectId) {
        return new Task(
            CallObject = OriginalCallObjectId,
            ActivityDate = Date.today(),
            CALLBACK__c = isCallback,
            Caller__c = '0546689654',
            Status = 'In Progress',
            AgentID__c = '13902',
            CallType= 'Inbound',
            Priority = 'Normal',
            Called__c = '17733',
            CallId__c = '6157',
            Subject = 'Call',
            OwnerId = userId,
            Type = 'Call',
            UUI__c = UUI
        );
    }

    public static Disabilities__c getDisability(Id acctId, String typeOfAssist) {
        return new Disabilities__c(
            Date_of_request__c = Date.today(),
            Type_of_Assist__c = typeOfAssist,
            Date_of_start__c = Date.today(),
            Assistance_notes__c = 'הערות עזר',
            Type_of_disability__c = '80',
            Patient_Account__c = acctId,
            Permanency__c = 'T',
            Side__c = 'RIGHT',
            Notes__c = 'הערות'
        );
    }

    public static Agent_survey__c getAgentSurvey(Id patientId, Id caseId, Id surveyId) {
        return new Agent_survey__c(
            Account_Survived__c = patientId,
            Survey__c = surveyId,
            Case__c = caseId
        );
    }

    public static waiting_list__c getWaitingList(Id appId1, Id appId2) {
        return new waiting_list__c(
            Appointment__c = appId1,
            potential_appointment__c = appId2
        );
    }

    public static Nursery__c getNursery() {
        return new Nursery__c(
            Name = 'Test'
        );
    }

    public static Implants_to_med_prod__c getImplantsToMedProd(Id implantsId, Id medicalProcedureId) {
        return new Implants_to_med_prod__c(
            Implants__c = implantsId,
            Medical_Procedure__c = medicalProcedureId,
            min_price__c = 20,
            max_price__c = 100,
            notes__c = 'Test notes'
        );
    }
    
    public static Lead getLead() {
        return new Lead( 
            FirstName = 'Test', 
            LastName = '123',
            Gender__c = 'נ',
            Email = 'test@assuta.co.il',
            Status = 'waiting', 
            Phone = '0527987458',
            CallBack__c = System.now().addDays(1)
        );
    }
    
    public static Opportunity getOpportunity() {
        return new Opportunity(
            StageName = 'Closed Won', 
            StageStatus__c = 'expert', 
            Name = 'OpportunityTest', 
            CloseDate = Date.today()
        );
    }

    public static Scheduler_Parameters__c getSchParameter(Id procedureId, Id domainId){
        Scheduler_Parameters__c schParameter = new Scheduler_Parameters__c (
            Status__c = 'פעיל',
            Medical_Procedure__c = procedureId,
            Domain__c = domainId,
            Payer_Factor__c = '4',
            Action_Type__c = 'הודעת אזהרה',
            Preview_Text__c = 'לא ניתן לזמן תור'
        );
        return schParameter;
    }

    public static Related_document__c getRelatedDoc(Id procedureId, String siteName){
        Related_document__c relatedDoc = new Related_document__c (
            Active__c = true,
            Medical_Procedure__c = procedureId,
            Language__c = '1;2;3;4;5',
            AppointmentRecordType__c = 'Institutes;Experts;Surgeries',
            Site__c = siteName
        );
        return relatedDoc;
    }
    
    public static Assuta_Employee__c getAssutaEmployee() {
        return new Assuta_Employee__c(
            First_Name__c = 'test',
            Last_Name__c = 'test'     
        );
    }

    public static Group getGroup(String type) {
        return new Group(
            Type = 'Queue', 
            Name = 'Test ' + type
        );
    }

    public static Site_Domain__c getSiteDomain(Id siteId, Id domainId, Id queueId) {
        return new Site_Domain__c(
            Site__c = siteId, 
            Domain__c = domainId, 
            Queue__c = queueId
        );
    }

    public static Implants_mp_apt__c getImplantMpApt(Id appointmentId) {
        return new Implants_mp_apt__c(
            Appointment__c = appointmentId,
            status__c = 'פעיל',
            min_price__c = 20,
            max_price__c = 50
        );
    }

    public static Survey__c getSurvey() {
        return new Survey__c();
    }

    public static Survey_Question__c getSurveyQuestion(Id serveyId) {
        return new Survey_Question__c(
            OrderNumber__c = 2,
            Question__c = 'Can you please stop answering this survey for god sake?',
            Type__c = 'RadioButton',
            Survey__c = serveyId
        );
    }

    public static Doc_to_action__c getDocToAction(Id serveyId) {
        return new Doc_to_action__c(
            activity_code__c = '76700',
            status__c = true,
            survey__c = serveyId
        );
    }

    public static SurveyTaker__c getSurveyTaker(Id surveyId, Id casId, Id acctId) {
        return new SurveyTaker__c(
            Survey__c = surveyId,
            Case__c = casId,
            Account__c = acctId
        );
    }

    public static Guidelines__c getGuidelines() {
        return new Guidelines__c(
            Status__c = 'active',
            Guideline_Type__c = 'A'
        );
    }

    public static Guidance_Scenario__c getGuidlineScenario(Id procedureId, Id guidelineId, Id siteId) {
        return new Guidance_Scenario__c(
            Medical_Procedure__c = procedureId,
            Guideline1__c = guidelineId,
            Site__c = siteId
        );
    }

    public static Survey_To_Site__c getSurveyToSite(Id siteId, Id surveyId) {
        return new Survey_To_Site__c(
            Site__c = siteId,
            Survey__c = surveyId
        );
    }

    public static SmsTemplate__c getSmsTemplate() {
        return new SmsTemplate__c(
            developerName__c = 'new_appointment', 
            Sms_content__c = 'שלום רב, נקבע לך תור לבדיקה שתתקיים ב{0}. בתאריך {1}. יש להצטייד בת.ז. ', 
            apiNames__c = 'site__r.Name,day_date_hour__c', 
            ObjectName__c = 'Appointment__c',
            FromPhone__c = 'Assuta'
        );
    } 
    
    public static SmsTemplate__c getSmsTemplate(String  developerName, String apiNames, String smsContent) {
        return new SmsTemplate__c(
            developerName__c = developerName, 
            Sms_content__c = smsContent, 
            apiNames__c = apiNames, 
            ObjectName__c = 'Appointment__c',
            FromPhone__c = 'Assuta' 
        );
    } 
    
    public static SMSReminder__c getSMSReminder(Id procedureId, Id smsTemplateId) {
        return new SMSReminder__c(
            SiteType__c = 'ALL',
            RecordType__c = 'Institutes',
            MedicalProcedure__c = procedureId,
            SmsTemplate__c = smsTemplateId   
        );
    }
    
     public static ConsentForm__c getConsentForm() {        
        return new ConsentForm__c(
        	HeadingHebrew__c = 'טופס הסכמה להרדמה'
        );
    }
    
    public static ConsentFormToSite__c getConsentFormToSite(Id siteId, Id consentFormId) {
        return new ConsentFormToSite__c(
            Site__c = siteId,
            ConsentForm__c = consentFormId
        );
    }

    public static Appointment_Manager__c getAppointmentManager(Id siteId, Id calendarId, Id procedureId) {
        return new Appointment_Manager__c(
            Status__c = 'Active',
            Action_Type__c = 'PreventMessaging',
            Site__c = siteId,
            Calendar__c = calendarId,
            Medical_Procedure__c = procedureId,
            Exclude_Messages_From__c = Date.today(),
            Exclude_Messages_Until__c = Date.today().addDays(3),
            RecordTypeId = getRTId('PreventMessaging', 'Appointment_Manager__c')
        );
    }
}