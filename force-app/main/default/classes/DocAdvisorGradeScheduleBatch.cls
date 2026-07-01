/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Advisor Grade Calculation Schedule Batch Apex class to recalculate doctors' grades based on Survey Taker records
 *
 * Test                 DocAdvisorGradeScheduleBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             24-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class DocAdvisorGradeScheduleBatch implements Database.Batchable<sObject>, Schedulable {

    List<String> questionTypes = new List<String>{'Courtesy', 'Availability', 'Professionalism', 'General_impression'};

    String query = 'SELECT Doctor__c'
                  + ' FROM SurveyTaker__c'
                 + ' WHERE LastModifiedDate = YESTERDAY'
                   + ' AND Doctor__c != null'
                   + ' AND Taken__c = \'true\''
                   + ' AND Survey__r.SurveyCode__c = \'DocAdvisor\''
                   + ' AND RecordType.DeveloperName = \'Doc_Advisor\''
              + ' ORDER BY Doctor__c';

    global DocAdvisorGradeScheduleBatch() {}

    global DocAdvisorGradeScheduleBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DocAdvisorGradeScheduleBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SurveyTaker__c> scope) {
        System.debug('DocAdvisorGradeScheduleBatch ... execute');
        List<Account> doctorsToUpdate = new List<Account>();
        Map<Id, Account> doctorMap = new Map<Id, Account>();
        Map<Id, Grades> gradesMap = new Map<Id, Grades>();
        Set<Id> doctorIds = new Set<Id>();

        for (SurveyTaker__c surveyTaker_i : scope) {
            doctorIds.add(surveyTaker_i.Doctor__c);
        }
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        List<SurveyTaker__c> surveyTakers = obtainSurveyTakers(doctorIds);
        System.debug('surveyTakers: size: ' + surveyTakers.size() + ' value: ' + surveyTakers);

        for (SurveyTaker__c surveyTaker_i : surveyTakers) {
            Account doctor_i = surveyTaker_i.Doctor__r;

            if (!doctorMap.containsKey(doctor_i.Id)) {
                doctorMap.put(doctor_i.Id, doctor_i);
                gradesMap.put(doctor_i.Id, new Grades());
            }
            gradesMap.get(doctor_i.Id).processSurvey(surveyTaker_i);
        }
        System.debug('doctorMap: size: ' + doctorMap.size() + ' value: ' + doctorMap);
        System.debug('gradesMap: size: ' + gradesMap.size() + ' value: ' + gradesMap);

        for (Account doctor_i : doctorMap.values()) {
            Grades grades_i = gradesMap.get(doctor_i.Id);

            if (grades_i.isDifferent(doctor_i)) {
                doctorsToUpdate.add(grades_i.overrideDoctor(doctor_i));
            }
        }
        System.debug('doctorsToUpdate: size: ' + doctorsToUpdate.size() + ' value: ' + doctorsToUpdate);

        if (!doctorsToUpdate.isEmpty()) {
            for (Database.SaveResult dr_i : Database.update(doctorsToUpdate, false)) {
                if (!dr_i.isSuccess()) {
                    System.debug('The following errors have occurred while trying to update Account (' + dr_i.getId() + '):');
                    for (Database.Error err_i : dr_i.getErrors()) {
                        System.debug(' - ' + err_i.getStatusCode() + ': ' + err_i.getMessage());
                    }
                }
            }
            System.debug('DocAdvisorGradeScheduleBatch ... executed');
        }
    }

    private List<SurveyTaker__c> obtainSurveyTakers(Set<Id> doctorIds) {
        return [SELECT Survey_score__c
                     , Doctor__r.Poor_poll_amount__c
                     , Doctor__r.not_good_poll_amount__c
                     , Doctor__r.good_poll_amount__c
                     , Doctor__r.excellent_pool_amount__c
                     , Doctor__r.Courtesy_avg__c
                     , Doctor__r.Availability_avg__c
                     , Doctor__r.Professional_avg__c
                     , Doctor__r.General_Impression_avg__c
                     , Doctor__r.Surveys_Amount__c
                     , (SELECT rate__c
                             , Survey_Question__r.Name
                          FROM Survey_Question_Answers__r
                         WHERE rate__c != null
                           AND Survey_Question__r.Name IN :questionTypes)
                  FROM SurveyTaker__c
                 WHERE Id IN (SELECT SurveyTaker__c
                                FROM SurveyQuestionResponse__c
                               WHERE rate__c != null
                                 AND Survey_Question__r.Name IN :questionTypes)
                   AND Doctor__c IN :doctorIds
                   AND Taken__c = 'true'
                   AND Status__c  = 'active'
                   AND Survey__r.SurveyCode__c = 'DocAdvisor'
                   AND RecordType.DeveloperName = 'Doc_Advisor'
              ORDER BY Doctor__c];
    }

    private class Grades {
        private Integer surveysAmount {get;set;}

        private Integer excellentAmount {get;set;}
        private Integer goodAmount {get;set;}
        private Integer notGoodAmount {get;set;}
        private Integer poorAmount {get;set;}

        private Integer courtesyAmount {get;set;}
        private Decimal courtesySum {get;set;}
        private Decimal courtesyAvg {get;set;}
        private Integer availabilityAmount {get;set;}
        private Decimal availabilitySum {get;set;}
        private Decimal availabilityAvg {get;set;}
        private Integer professionalismAmount {get;set;}
        private Decimal professionalismSum {get;set;}
        private Decimal professionalismAvg {get;set;}
        private Integer generalImpressionAmount {get;set;}
        private Decimal generalImpressionSum {get;set;}
        private Decimal generalImpressionAvg {get;set;}

        private Grades() {
            this.surveysAmount = 0;

            this.excellentAmount = 0;
            this.goodAmount = 0;
            this.notGoodAmount = 0;
            this.poorAmount = 0;

            this.courtesyAmount = 0;
            this.courtesySum = 0;
            this.availabilityAmount = 0;
            this.availabilitySum = 0;
            this.professionalismAmount = 0;
            this.professionalismSum = 0;
            this.generalImpressionAmount = 0;
            this.generalImpressionSum = 0;
        }

        private void processSurvey(SurveyTaker__c surveyTaker) {
            this.countScore(surveyTaker.Survey_score__c);
            this.countAvg(surveyTaker.Survey_Question_Answers__r);
        }

        private void countScore(Decimal score) {
            this.surveysAmount++;

            if (score >= 8.1) {
                this.excellentAmount++;
            } else if (score >= 6.1) {
                this.goodAmount++;
            } else if (score >= 4.1) {
                this.notGoodAmount++;
            } else if (score != null) {
                this.poorAmount++;
            }
        }

        private void countAvg(List<SurveyQuestionResponse__c> grades) {
            for (SurveyQuestionResponse__c grade_i : grades) {
                switch on grade_i.Survey_Question__r.Name {
                    when 'Courtesy' {
                        this.courtesyAmount++;
                        this.courtesySum += grade_i.rate__c;
                        this.courtesyAvg = this.courtesySum.divide(this.courtesyAmount, 1);
                    }
                    when 'Availability' {
                        this.availabilityAmount++;
                        this.availabilitySum += grade_i.rate__c;
                        this.availabilityAvg = this.availabilitySum.divide(this.availabilityAmount, 1);
                    }
                    when 'Professionalism' {
                        this.professionalismAmount++;
                        this.professionalismSum += grade_i.rate__c;
                        this.professionalismAvg = this.professionalismSum.divide(this.professionalismAmount, 1);
                    }
                    when 'General_impression' {
                        this.generalImpressionAmount++;
                        this.generalImpressionSum += grade_i.rate__c;
                        this.generalImpressionAvg = this.generalImpressionSum.divide(this.generalImpressionAmount, 1);
                    }
                }
            }
        }

        private Boolean isDifferent(Account doctor) {
            Boolean isDifferent = false;
            if (doctor.Surveys_Amount__c != this.surveysAmount ||
                    doctor.excellent_pool_amount__c != this.excellentAmount ||
                    doctor.good_poll_amount__c != this.goodAmount ||
                    doctor.not_good_poll_amount__c != this.notGoodAmount ||
                    doctor.Poor_poll_amount__c != this.poorAmount ||
                    doctor.Courtesy_avg__c != this.courtesyAvg ||
                    doctor.Availability_avg__c != this.availabilityAvg ||
                    doctor.Professional_avg__c != this.professionalismAvg ||
                    doctor.General_Impression_avg__c != this.generalImpressionAvg) {
                isDifferent = true;
            }
            return isDifferent;
        }

        private Account overrideDoctor(Account doctor) {
            doctor.Surveys_Amount__c = this.surveysAmount;

            doctor.excellent_pool_amount__c = this.excellentAmount;
            doctor.good_poll_amount__c = this.goodAmount;
            doctor.not_good_poll_amount__c = this.notGoodAmount;
            doctor.Poor_poll_amount__c = this.poorAmount;

            doctor.Courtesy_avg__c = this.courtesyAvg;
            doctor.Availability_avg__c = this.availabilityAvg;
            doctor.Professional_avg__c = this.professionalismAvg;
            doctor.General_Impression_avg__c = this.generalImpressionAvg;

            return doctor;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('DocAdvisorGradeScheduleBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DocAdvisorGradeScheduleBatch(), 10);
    }
}