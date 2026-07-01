global class DocAdvisorGradeSchedulableBatch implements Database.Batchable<sObject>, Schedulable,Database.Stateful {
    public static Map<String, Schema.RecordTypeInfo> SurveyTakerRTMap = Schema.SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName();
    Id docAdvisorRTId = SurveyTakerRTMap.get('Doc_Advisor').getRecordTypeId();
    List<String> questionTypes = new List<String>{'Courtesy','Availability','Professionalism','General_impression'};
    List<Survey_Question__c> sqList = [SELECT Id,Name FROM Survey_Question__c WHERE Name IN : questionTypes];
    Map<Id,Integer> docSurveyCountMap = new Map<Id,Integer>();
    Map<Id,Integer> oldSurveyCountMap = new Map<Id,Integer>();
	Map<Id,Account> finalAccountMap = new Map<Id,Account>();
    Map<Id,Map<Id,List<Integer>>> accountSumMap = new Map<Id,Map<Id,List<Integer>>>();
    Map<Id,Map<String,Integer>> accountGenImpCountMap = new  Map<Id,Map<String,Integer>>();
    Map<Id,Account> oldAccounts = new Map<Id,Account>();
    Map<Id,Map<String,Object>> accountDefaultValuesMap = new Map<Id,Map<String,Object>>();
    Set<Id> processedBatchAccounts = new Set<Id>();
    Boolean runNextJob = false;
    Id CourtesyId;
    Id AvailabilityId;
    Id ProfessionalismId;
    Id GeneralImpressionId;
    Decimal excellent=8.1;
    Decimal good=6.1;
    Decimal notGood=4.1;

    String query = 'SELECT Id'
                        + ', Doctor__c'
        				+ ', Survey_score__c'
                        + ', Doctor__r.Poor_poll_amount__c'
                        + ', Doctor__r.not_good_poll_amount__c'
                        + ', Doctor__r.good_poll_amount__c'
                        + ', Doctor__r.excellent_pool_amount__c'
                        + ', Doctor__r.Courtesy_avg__c'
                        + ', Doctor__r.Availability_avg__c'
                        + ', Doctor__r.Professional_avg__c'
                        + ', Doctor__r.General_Impression_avg__c'
                        + ', Doctor__r.Surveys_Amount__c'
                        + ',(SELECT Survey_Question__r.Name,rate__c FROM Survey_Question_Answers__r)'
                + ' FROM SurveyTaker__c'
                + ' WHERE Status__c  = \'active\''
                + ' AND Taken__c = \'true\''
                + ' AND IsProcessed__c = false'
         		+ ' AND Survey__r.SurveyCode__c = \'DocAdvisor\''
                + ' AND RecordType.DeveloperName = \'Doc_Advisor\''
        		+ ' ORDER BY Doctor__c LIMIT 10000';

    global DocAdvisorGradeSchedulableBatch() {}
    global DocAdvisorGradeSchedulableBatch(Boolean runNextJob){
        this.runNextJob = runNextJob;
    }
    global DocAdvisorGradeSchedulableBatch(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('SurveyTaker__c'));
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<SObject> surveyTakers){
        Map<Id,Id> surveyTakerAccountMap = new Map<Id,Id>();
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        Map<Id,Set<Id>> accountSTMap = new Map<Id,Set<Id>>();
        Map<Id,Map<String,Integer>> accountSTScoreMap = new Map<Id,Map<String,Integer>>();

        for(Survey_Question__c sq : sqList){ // init question Ids
            switch on sq.Name {
                when 'Courtesy' {
                    CourtesyId = sq.Id;
                }
                when 'Availability' {
                    AvailabilityId = sq.Id;
                }
                when 'Professionalism' {
                    ProfessionalismId = sq.Id;
                }
                when 'General_impression' {
                    GeneralImpressionId = sq.Id;
                }
                when else {
                    System.debug('no questions found');
                }
            }
        }

        for (SObject stObj : surveyTakers){
            Map<String, Object> fieldValues = stObj.getPopulatedFieldsAsMap();
            
            Account acc = (Account)fieldValues.get('Doctor__r');
            initAccountDefaultValuesMap(acc); // init account values to be able to calculate and sum values from different batches with the old values
            System.debug('the acc is: '+acc);
            System.debug('values are: '+fieldValues);
            processedBatchAccounts.add((Id)fieldValues.get('Doctor__c'));
            surveyTakerAccountMap.put((Id)fieldValues.get('Id'),(Id)fieldValues.get('Doctor__c'));
            if(accountSumMap.get((Id)fieldValues.get('Doctor__c'))==null){
                Map<Id,List<Integer>> subjectGradeMap = new Map<Id,List<Integer>>(); // init first grade map for each account Map<QuestionId,Rating>
                subjectGradeMap.put(CourtesyId,new List<Integer>());
                subjectGradeMap.put(AvailabilityId,new List<Integer>());
                subjectGradeMap.put(ProfessionalismId,new List<Integer>());
                subjectGradeMap.put(GeneralImpressionId,new List<Integer>());
                accountSumMap.put((Id)fieldValues.get('Doctor__c'),subjectGradeMap);
            }
            if(accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c'))==null){
                Map<String,Integer> countMap = new Map<String,Integer>();
                countMap.put('excellent',0);
                countMap.put('good',0);
                countMap.put('notGood',0);
                countMap.put('poor',0);
                accountGenImpCountMap.put((Id)fieldValues.get('Doctor__c'),countMap);
            }
            if(accountSTScoreMap.get((Id)fieldValues.get('Doctor__c'))==null){
                Map<String,Integer> scoreMap = new Map<String,Integer>();
                scoreMap.put('excellent',0);
                scoreMap.put('good',0);
                scoreMap.put('notGood',0);
                scoreMap.put('poor',0);
                accountSTScoreMap.put((Id)fieldValues.get('Doctor__c'),scoreMap);
            }
            Double currentScore = (Double)fieldValues.get('Survey_score__c');
            Map<String,Integer> scoreMap =accountSTScoreMap.get((Id)fieldValues.get('Doctor__c'));
            if(currentScore< notGood){
                //System.debug('adding score: '+currentScore + ' for account: '+(Id)fieldValues.get('Doctor__c')+ ' with survey Id: '+(Id)fieldValues.get('Id'));
                scoreMap.put('poor',scoreMap.get('poor')+1);
                accountSTScoreMap.put((Id)fieldValues.get('Doctor__c'),scoreMap);
            }else if(currentScore < good && currentScore >= notGood){
                //System.debug('adding score: '+currentScore + ' for account: '+(Id)fieldValues.get('Doctor__c')+ ' with survey Id: '+(Id)fieldValues.get('Id'));
                scoreMap.put('notGood',scoreMap.get('notGood')+1);
                accountSTScoreMap.put((Id)fieldValues.get('Doctor__c'),scoreMap);
            }else if(currentScore < excellent && currentScore >= good){
                //System.debug('adding score: '+currentScore + ' for account: '+(Id)fieldValues.get('Doctor__c')+ ' with survey Id: '+(Id)fieldValues.get('Id'));
                scoreMap.put('good',scoreMap.get('good')+1);
                accountSTScoreMap.put((Id)fieldValues.get('Doctor__c'),scoreMap);
            }else if(currentScore >= excellent){
                //System.debug('adding score: '+currentScore + ' for account: '+(Id)fieldValues.get('Doctor__c')+ ' with survey Id: '+(Id)fieldValues.get('Id'));
                scoreMap.put('excellent',scoreMap.get('excellent')+1);
                accountSTScoreMap.put((Id)fieldValues.get('Doctor__c'),scoreMap);
            }
            if(accountSTMap.get((Id)fieldValues.get('Doctor__c'))==null){ // init accountSTMap
                accountSTMap.put((Id)fieldValues.get('Doctor__c'),new Set<Id>());
            }
            accountSTMap.get((Id)fieldValues.get('Doctor__c')).add((Id)fieldValues.get('Id')); // add current SurveyTaker to sum all ST for each accoun
            system.debug('adding surbey taker:'+fieldValues.get('Id')+' for account: '+fieldValues.get('Doctor__c'));
            for (String fieldName : fieldValues.keySet()){
                if (fieldValues.get(fieldName) instanceof List<sObject>) {
                    List<sObject> myCollection = (List<sObject>) fieldValues.get(fieldName);
                    for (Sobject childObject : myCollection) {
                        if (childObject instanceof SurveyQuestionResponse__c){ // collect each question response into account map
                            SurveyQuestionResponse__c sqr = (SurveyQuestionResponse__c) childObject;
                            if(sqr.Survey_Question__c==CourtesyId && sqr.Rate__c != null){
                                accountSumMap.get((Id)fieldValues.get('Doctor__c')).get(CourtesyId).add(Integer.ValueOf(sqr.Rate__c));
                            }else if(sqr.Survey_Question__c==AvailabilityId && sqr.Rate__c != null){
                                accountSumMap.get((Id)fieldValues.get('Doctor__c')).get(AvailabilityId).add(Integer.ValueOf(sqr.Rate__c));
                            }else if(sqr.Survey_Question__c==ProfessionalismId && sqr.Rate__c != null){
                                accountSumMap.get((Id)fieldValues.get('Doctor__c')).get(ProfessionalismId).add(Integer.ValueOf(sqr.Rate__c));
                            }else if(sqr.Survey_Question__c==GeneralImpressionId && sqr.Rate__c != null){
                                accountSumMap.get((Id)fieldValues.get('Doctor__c')).get(GeneralImpressionId).add(Integer.ValueOf(sqr.Rate__c));
                            }
                                // for each general Impression question , count amount of reviews added
                                Map<String,Integer> currMap  = accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c'));
                                if(sqr.Rate__c < notGood){ 
                                    currMap.put('poor',accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('poor') +1);
                                    accountGenImpCountMap.put((Id)fieldValues.get('Doctor__c'),currMap);
                                }else if(sqr.Rate__c < good && sqr.Rate__c > notGood){
                                    currMap.put('notGood',accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('notGood') +1);
                                    accountGenImpCountMap.put((Id)fieldValues.get('Doctor__c'),currMap);
                                }else if(sqr.Rate__c < excellent && sqr.Rate__c >= good){
                                    //System.debug('adding account :'+(Id)fieldValues.get('Doctor__c'));
                                    //System.debug('adding good 1 '+'to '+accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('good'));
                                    currMap.put('good',accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('good') +1);
                                    accountGenImpCountMap.put((Id)fieldValues.get('Doctor__c'),currMap);
                                }else if(sqr.Rate__c >= excellent){
                                    //System.debug('adding account :'+(Id)fieldValues.get('Doctor__c'));
                                    //System.debug('adding excellent 1 '+'to '+accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('excellent'));
                                    currMap.put('excellent',accountGenImpCountMap.get((Id)fieldValues.get('Doctor__c')).get('excellent') +1);
                                    accountGenImpCountMap.put((Id)fieldValues.get('Doctor__c'),currMap);
                                }
                            
                        } 
                    }
                }
            }
        }
        // Populate map from SOQL query
        for(Id accId : processedBatchAccounts){ // for each account , check if each rating list is not empty , and if its not update
            Account acc = new Account();
            acc.Id=accId;
            //System.debug('accountSumMap' +accountSumMap);
            System.debug('acc is' +accId);
            if(accountSumMap.get(accId).get(CourtesyId).size() > 0){
                //System.debug('account ratings before sum courtesy: '+accountSumMap.get(accId).get(CourtesyId));
                acc.Courtesy_avg__c = sumRatingList(accountSumMap.get(accId).get(CourtesyId),accId,'Courtesy_avg__c');
                accountDefaultValuesMap.get(acc.Id).put('Courtesy_avg__c', acc.Courtesy_avg__c);
            }
            if(accountSumMap.get(accId).get(AvailabilityId).size() > 0){
                 //System.debug('account ratings before sum Availability: '+accountSumMap.get(accId).get(AvailabilityId));
                acc.Availability_avg__c = sumRatingList(accountSumMap.get(accId).get(AvailabilityId),accId,'Availability_avg__c');
                accountDefaultValuesMap.get(acc.Id).put('Availability_avg__c', acc.Availability_avg__c);
            }
            if(accountSumMap.get(accId).get(ProfessionalismId).size() > 0){
                //System.debug('account ratings before sum Professionalism: '+accountSumMap.get(accId).get(ProfessionalismId));
                acc.Professional_avg__c = sumRatingList(accountSumMap.get(accId).get(ProfessionalismId),accId,'Professional_avg__c');
                accountDefaultValuesMap.get(acc.Id).put('Professional_avg__c', acc.Professional_avg__c);
            }
            if(accountSumMap.get(accId).get(GeneralImpressionId).size() > 0){
                //System.debug('account ratings before sum GeneralImpression: '+accountSumMap.get(accId).get(GeneralImpressionId));
                acc.General_Impression_avg__c = sumRatingList(accountSumMap.get(accId).get(GeneralImpressionId),accId,'General_Impression_avg__c');
                accountDefaultValuesMap.get(acc.Id).put('General_Impression_avg__c', acc.General_Impression_avg__c);
            }
            if(acc.Courtesy_avg__c != null || acc.Availability_avg__c != null || acc.Professional_avg__c != null || acc.General_Impression_avg__c != null){
                accountsMap.put(accId,acc);
            }
        }
        for (Id accId : processedBatchAccounts){
            Account acc = new Account(Id=accId);
            if(accountsMap.get(accId)!=null){
                acc = accountsMap.get(accId);
            }
            // update general impression amount of survies rating
            if(accountSTScoreMap.get(accId).get('poor')!=null){
                Integer poor = accountSTScoreMap.get(accId).get('poor') + Integer.ValueOf(accountDefaultValuesMap.get(accId).get('Poor_poll_amount__c'));
                acc.Poor_poll_amount__c = poor;
                accountDefaultValuesMap.get(accId).put('Poor_poll_amount__c',poor);
            } 
            if(accountSTScoreMap.get(accId).get('notGood')!=null){
                Integer notGood  =accountSTScoreMap.get(accId).get('notGood') + Integer.ValueOf(accountDefaultValuesMap.get(accId).get('not_good_poll_amount__c'));
                acc.not_good_poll_amount__c = notGood;
                accountDefaultValuesMap.get(accId).put('not_good_poll_amount__c',notGood);
            }
            if(accountSTScoreMap.get(accId).get('good')!=null){
                Integer good = accountSTScoreMap.get(accId).get('good') + Integer.ValueOf(accountDefaultValuesMap.get(accId).get('good_poll_amount__c'));
                //System.debug('adding account: '+accId);
                //System.debug('adding account: '+accountSTScoreMap.get(accId));
                //System.debug('adding good+good amount '+accountSTScoreMap.get(accId).get('good')+'+ '+Integer.ValueOf(accountDefaultValuesMap.get(accId).get('good_poll_amount__c'))+' total='+good);
                acc.good_poll_amount__c = good;
                accountDefaultValuesMap.get(accId).put('good_poll_amount__c',good);
            }
            if(accountSTScoreMap.get(accId).get('excellent')!=null){
                Integer excellent = accountSTScoreMap.get(accId).get('excellent') +Integer.ValueOf(accountDefaultValuesMap.get(accId).get('excellent_pool_amount__c'));
                //System.debug('adding account: '+accId);
                //System.debug('adding account: '+accountSTScoreMap.get(accId));
                //System.debug('adding excellent+excellent amount '+accountSTScoreMap.get(accId).get('excellent')+'+ '+Integer.ValueOf(accountDefaultValuesMap.get(accId).get('excellent_pool_amount__c'))+' total='+excellent);
                acc.excellent_pool_amount__c = excellent;
                accountDefaultValuesMap.get(accId).put('excellent_pool_amount__c',excellent);
            }
            
               accountsMap.put(accId,acc);
            }
        	processedBatchAccounts.clear();

        for (Id accId : accountSTMap.keySet()){ // sum all surveyTakers for each account
            Account acc = new Account(Id=accId);
            if(accountsMap.get(accId)!=null){
                acc = accountsMap.get(accId);
            }
            if(docSurveyCountMap.get(accId)==null){
                docSurveyCountMap.put(accId,Integer.valueOf(accountDefaultValuesMap.get(acc.Id).get('Surveys_Amount__c')));
            }
            acc.Surveys_Amount__c = Integer.valueOf(accountDefaultValuesMap.get(acc.Id).get('Surveys_Amount__c')) + accountSTMap.get(accId).size();
            accountDefaultValuesMap.get(acc.Id).put('Surveys_Amount__c', acc.Surveys_Amount__c);
            system.debug('acc id is: '+acc.id);
            system.debug('acc surveys amount is: '+accountSTMap.get(accId).size());
            accountsMap.put(accId,acc);
        }

        if(accountsMap.size() > 0){
			try{
                List<String> errorsAccount = new List<String>();
                List<String> errorsSurvey = new List<String>();
                List<SurveyTaker__c> processedSurveyTakers = new List<SurveyTaker__c>();
           		for (Database.SaveResult result_i : Database.update(accountsMap.values(), false)) {
                    if (!result_i.isSuccess()) {
                     	errorsAccount.add(result_i.getId() + ': ' + result_i.getErrors());
                    }
           		}
           		System.debug('errorsAccount: ' + JSON.serialize(errorsAccount));
                
                for (Id surveyId : surveyTakerAccountMap.keySet()){
                    processedSurveyTakers.add(new SurveyTaker__c(Id=surveyId,IsProcessed__c=true));
                }
                for(Database.SaveResult result_i : Database.update(processedSurveyTakers,false)){
                	if(!result_i.isSuccess()){
                    errorsSurvey.add(result_i.getId() + ': ' + result_i.getErrors());  
                   }
                }
            System.debug('errorsSurvey: ' + JSON.serialize(errorsSurvey));
    		}catch(Exception e){
			System.debug('error occured on attempt to update records');            
        	}              
        }
    }

    private Double  sumRatingList(List<Integer> currRatingList,Id accId,String avgType){
        Decimal currRating = 0;
        for(Integer rating : currRatingList){
            currRating = currRating + rating;
        }
        Integer totalSurveys = Integer.ValueOf(accountDefaultValuesMap.get(accId).get('Surveys_Amount__c')); 
        Double totalAvarage = Double.valueOf(accountDefaultValuesMap.get(accId).get(avgType));
        //System.debug('calculating final avrage for accId: '+accId);
        //System.debug('currRating: '+currRating);
        //System.debug('totalAvarage: '+totalAvarage);
        //System.debug('totalSurveys: '+totalSurveys);
        //System.debug('currRatingList.size(): '+currRatingList.size());
        //System.debug('totalSurveys: '+totalSurveys);
        return (currRating+totalAvarage*totalSurveys).divide((currRatingList.size()+totalSurveys),1); // calculate avarage with old avarage
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
        
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DocAdvisorGradeSchedulableBatch(), 15);
    }

    global void initAccountDefaultValuesMap(Account acc){
        if(accountDefaultValuesMap.get(acc.Id)==null){
            accountDefaultValuesMap.put(acc.Id,new Map<String,Object>());
            accountDefaultValuesMap.get(acc.Id).put('Poor_poll_amount__c',acc.Poor_poll_amount__c);
            accountDefaultValuesMap.get(acc.Id).put('not_good_poll_amount__c',acc.not_good_poll_amount__c);
            accountDefaultValuesMap.get(acc.Id).put('good_poll_amount__c',acc.good_poll_amount__c);
            accountDefaultValuesMap.get(acc.Id).put('excellent_pool_amount__c',acc.excellent_pool_amount__c);
            accountDefaultValuesMap.get(acc.Id).put('Courtesy_avg__c',acc.Courtesy_avg__c);
            accountDefaultValuesMap.get(acc.Id).put('Availability_avg__c',acc.Availability_avg__c);
            accountDefaultValuesMap.get(acc.Id).put('Professional_avg__c',acc.Professional_avg__c);
            accountDefaultValuesMap.get(acc.Id).put('General_Impression_avg__c',acc.General_Impression_avg__c);
            accountDefaultValuesMap.get(acc.Id).put('Surveys_Amount__c',acc.Surveys_Amount__c);
        }
    }

}