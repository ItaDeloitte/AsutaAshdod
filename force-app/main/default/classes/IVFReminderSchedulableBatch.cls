global class IVFReminderSchedulableBatch implements Database.Batchable<sObject>, Schedulable {
    
    Boolean runNextJob = false;
    DateTime today = date.today();
    DateTime todayMin7Days = today.adddays(-7).addHours(-2);
    DateTime todayMin6Days = today.adddays(-6).addHours(-2);
    DateTime todayMin13Days = today.addDays(-13).addHours(-2);
    DateTime todayMin12Days = today.addDays(-12).addHours(-2);
    String todayMin7Str = todayMin7Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String todayMin6Str = todayMin6Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String todayMin13Str = todayMin13Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String todayMin12Str = todayMin12Days.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

    Id TwentyThreeCouple = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TwentyThree_Days_Reminder_Couple'].Id;
    Id TwentyThreeMale = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TwentyThree_Days_Reminder_Male'].Id;
    Id TwentyThreeFemale = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TwentyThree_Days_Reminder_Female'].Id;
    Id TenCouple = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Ten_Days_Reminder_Couple'].Id;
    Id TenMale = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Ten_Days_Reminder_Male'].Id;
    Id TenFemale = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Ten_Days_Reminder_Female'].Id;
    Id tempContactId = [SELECT Id FROM Contact LIMIT 1].Id;
    Map<Id,OrgWideEmailAddress> owea = new Map<Id,OrgWideEmailAddress>([SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = 'ramat.info@assuta.co.il' OR Address = 'rishon.info@assuta.co.il']);
    Map<String,Id> emailMap = new Map<String,Id>();

    String query = 'SELECT Id'
                      + ', Female_Status__c'
                      + ', Partner_Status__c'
                      + ', Case_Route__c'
                      + ', Case_Status__c'
                      + ', email_from_patient__c '
                      + ', Partner_Name__r.PersonEmail'
        			  + ', Partner_Name__r.SMS_Phone_Number__c'
                      + ', Reminder_After_10_Days_Partner__c'
                      + ', Reminder_After_10_Days_FemalePatient__c'
                      + ', Kit_Sending_Date_Female_IVF__c'
                      + ', link_upload_files__c'
                      + ', Fax_Number_IVF__c'
                      + ', Site_Email__c'
                      + ', Case_site__c'
                      + ', Kit_Sending_Date_Partner_IVF__c'
                      + ', SMS_Phone_Number__c'
                      + ', AccountId'
                      + ', Account.SMS_Phone_number__c'
                      + ', Reminders_Needed__c'
                      + ', Expiration_Decision_Making_Male_IVF__c'
                      + ', Expiration_Decision_Making_Female_IVF__c'
                      + ', Male_First_Name__c'
                      + ', Female_First_Name__c'

                + ' FROM Case'
                + ' WHERE RecordType.DeveloperName = \'IVF_Freezing_Eggs\''
                + ' AND ((Kit_Sending_Date_Female_IVF__c >='+todayMin7Str+' AND Kit_Sending_Date_Female_IVF__c <='+todayMin6Str+')'
                + ' OR (Kit_Sending_Date_Partner_IVF__c >='+todayMin7Str+' AND Kit_Sending_Date_Partner_IVF__c <='+todayMin6Str+')'
                + ' OR (Kit_Sending_Date_Female_IVF__c >='+todayMin13Str+' AND Kit_Sending_Date_Female_IVF__c <='+todayMin12Str+')'
                + ' OR (Kit_Sending_Date_Partner_IVF__c >='+todayMin13Str+' AND Kit_Sending_Date_Partner_IVF__c <='+todayMin12Str+'))';

            
    global IVFReminderSchedulableBatch(){}

    global IVFReminderSchedulableBatch(Boolean runNextJob){
        this.runNextJob = runNextJob;
    }
    global IVFReminderSchedulableBatch(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Case '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> cases){
        System.debug('inside execute');
        Map<Case,String> validCases = new Map<Case,String>();
        Map<Id,String> idToCaseTypeMap = new Map<Id,String>();
        Map<Id,Case> validCasesIdMap = new Map<Id,Case>();
        Map<Id,String> validCasesRoute = new Map<Id,String>();
        Map<Id,Integer> validCasesReminder = new Map<Id,Integer>();
        List<String> validEmails = new List<String>();
        for(Id emailId : owea.keySet()){
            emailMap.put(owea.get(emailId).address,emailId);
        }

        for(Case case_i : cases){
            System.debug('checking case id: '+case_i.Id);
            if((case_i.Kit_Sending_Date_Female_IVF__c>=todayMin7Days && case_i.Kit_Sending_Date_Female_IVF__c <= todayMin6Days) ||
             (case_i.Kit_Sending_Date_Partner_IVF__c>=todayMin7Days && case_i.Kit_Sending_Date_Partner_IVF__c <= todayMin6Days))
            {
                System.debug('7 days');
                if(case_i.Case_Route__c=='Seperate_Route'  // both patient and partner need to be reminded today
                && case_i.email_from_patient__c!=null &&
                    !case_i.Reminder_After_10_Days_FemalePatient__c &&
                    case_i.Kit_Sending_Date_Female_IVF__c!=null && 
                    case_i.Partner_Name__r.PersonEmail!=null &&
                    !case_i.Reminder_After_10_Days_Partner__c &&
                    case_i.Female_Status__c=='Documents_Holds' &&
                    case_i.Partner_Status__c=='Documents_Holds' &&
                    (case_i.Kit_Sending_Date_Female_IVF__c>=todayMin7Days && case_i.Kit_Sending_Date_Female_IVF__c <= todayMin6Days) &&
                    (case_i.Kit_Sending_Date_Partner_IVF__c>=todayMin7Days && case_i.Kit_Sending_Date_Partner_IVF__c <= todayMin6Days)
                    ){
                        System.debug('seperate - both');
                        validCasesRoute.put(case_i.Id,'Seperate_Route');
                        validCasesReminder.put(case_i.Id,7);
                        validCases.put(case_i,'both');
                        idToCaseTypeMap.put(case_i.Id,'both');
                        validCasesIdMap.put(case_i.Id,case_i);
                }
                else if(case_i.Case_Route__c=='Seperate_Route' 
                && case_i.email_from_patient__c!=null &&
                    !case_i.Reminder_After_10_Days_FemalePatient__c &&
                    case_i.Kit_Sending_Date_Female_IVF__c!=null &&
                    case_i.Female_Status__c=='Documents_Holds' &&
                    (case_i.Kit_Sending_Date_Female_IVF__c >= todayMin7Days &&
                    case_i.Kit_Sending_Date_Female_IVF__c <=todayMin6Days)) { // case is valid for reminder after 7 days

                        System.debug('seperate - female');
                        validCasesReminder.put(case_i.Id,7);
                        validCases.put(case_i,'female');
                        idToCaseTypeMap.put(case_i.Id,'female');
                        validCasesRoute.put(case_i.Id,'Seperate_Route');
                        validCasesIdMap.put(case_i.Id,case_i);

                }else if(case_i.Case_Route__c=='Seperate_Route' &&
                        case_i.Partner_Name__r.PersonEmail!=null &&
                        !case_i.Reminder_After_10_Days_Partner__c &&
                        case_i.Partner_Status__c=='Documents_Holds' &&
                        (case_i.Kit_Sending_Date_Partner_IVF__c >= todayMin7Days &&
                        case_i.Kit_Sending_Date_Partner_IVF__c <=todayMin6Days))
                        {
                            System.debug('seperate - partner');
                            validCasesReminder.put(case_i.Id,7);
                            validCases.put(case_i,'partner');
                            idToCaseTypeMap.put(case_i.Id,'partner');
                            validCasesRoute.put(case_i.Id,'Seperate_Route');
                            validCasesIdMap.put(case_i.Id,case_i);
                }
                else if((!(case_i.Case_Route__c=='Seperate_Route') &&
                            !case_i.Reminder_After_10_Days_FemalePatient__c &&
                            case_i.email_from_patient__c!=null &&
                            case_i.Case_Status__c=='Documents_Holds' &&
                            (case_i.Kit_Sending_Date_Female_IVF__c >= todayMin7Days && case_i.Kit_Sending_Date_Female_IVF__c <=todayMin6Days) )){ // case is valid for reminder after 7 days

                                validCasesReminder.put(case_i.Id,7);
                                validCases.put(case_i,'female');
                                idToCaseTypeMap.put(case_i.Id,'female');
                                validCasesRoute.put(case_i.Id,'together');
                                validCasesIdMap.put(case_i.Id,case_i);
                                System.debug('inside if partner');
                }
            }
            else if(((case_i.Kit_Sending_Date_Female_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Female_IVF__c <= todayMin12Days) ||
                    (case_i.Kit_Sending_Date_Partner_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Partner_IVF__c <= todayMin12Days)) &&
                     case_i.Reminders_Needed__c)
                    {
                    System.debug('13 days');   
                    if(case_i.Case_Route__c=='Seperate_Route'  // both patient and partner need to be reminded today
                    && case_i.email_from_patient__c!=null &&
                        case_i.Partner_Name__r.PersonEmail!=null &&
                        case_i.Female_Status__c=='Documents_Holds'&&
                        case_i.Partner_Status__c=='Documents_Holds' &&
                        (case_i.Kit_Sending_Date_Female_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Female_IVF__c <= todayMin12Days) &&
                        (case_i.Kit_Sending_Date_Partner_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Partner_IVF__c <= todayMin12Days)
                        ){
                            System.debug('seperate - both');
                            validCasesRoute.put(case_i.Id,'Seperate_Route');
                            validCasesReminder.put(case_i.Id,13);
                            validCases.put(case_i,'both');
                            idToCaseTypeMap.put(case_i.Id,'both');
                            validCasesIdMap.put(case_i.Id,case_i);
                    }
                    else if(case_i.Case_Route__c=='Seperate_Route'){
                        System.debug('seperate route');
                        if(case_i.Reminder_After_10_Days_Partner__c &&
                            case_i.Partner_Status__c=='Documents_Holds' &&
                            (case_i.Kit_Sending_Date_Partner_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Partner_IVF__c <= todayMin12Days)){
                                System.debug('partner route');
                                validCasesReminder.put(case_i.Id,13);
                                validCases.put(case_i,'partner');
                                idToCaseTypeMap.put(case_i.Id,'partner');
                                validCasesIdMap.put(case_i.Id,case_i);
                                validCasesRoute.put(case_i.Id,'Seperate_Route');
                        }else if(case_i.Reminder_After_10_Days_FemalePatient__c &&
                                case_i.Female_Status__c=='Documents_Holds'&&
                                (case_i.Kit_Sending_Date_Female_IVF__c>=todayMin13Days && case_i.Kit_Sending_Date_Female_IVF__c <= todayMin12Days)){
                                    System.debug('female route');
                                    validCasesReminder.put(case_i.Id,13);
                                    validCases.put(case_i,'female');
                                    idToCaseTypeMap.put(case_i.Id,'female');
                                    validCasesIdMap.put(case_i.Id,case_i);
                                    validCasesRoute.put(case_i.Id,'Seperate_Route');
                        }
                    }else if ((!(case_i.Case_Route__c=='Seperate_Route')) && (case_i.Case_Route__c!=null) && case_i.Case_Status__c=='Documents_Holds'){
                        System.debug('female route not seperate');
                        	validCases.put(case_i,'female');
                        	idToCaseTypeMap.put(case_i.Id,'female');
                            validCasesReminder.put(case_i.Id,13);
                            validCasesIdMap.put(case_i.Id,case_i);
                            validCasesRoute.put(case_i.Id,'together');
                    }
                    
            }
            else{
                System.debug('non of conditions met');
            }
            System.debug('current case: '+validCases.get(case_i));
            System.debug('current route: '+validCasesRoute.get(case_i.Id));
        }
        if(validCases.size()>0){
            System.debug('sending mail and sms valid cases');
            sendMail(validCases,validCasesReminder,validCasesRoute,idToCaseTypeMap);
            sendSMS(validCases,validCasesIdMap,validCasesReminder,validCasesRoute,idToCaseTypeMap);
        }
    }

    

    private void sendMail(Map<Case,String> validCases,Map<Id,Integer> validCasesReminder,Map<Id,String> validCasesRoute,Map<Id,String> idToCaseTypeMap){
        //Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Ten_Days_Reminder'].Id;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> status = new List<String>();
        List<String> sentEmails = new List<String>();
        List<Id> sentEmailsIds = new List<Id>();
        List<String> sentIds = new List<String>();
        Set<Id> successEmails = new Set<Id>();
        Map<String,String> siteEmailMap = getSiteEmailMap();

        for (Case currCase : validCases.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(validCases.get(currCase)=='both'){
                sentEmails.add(currCase.email_from_patient__c);
                sentEmails.add(currCase.Partner_Name__r.PersonEmail);
                sentEmailsIds.add(currCase.Id);
                sentEmailsIds.add(currCase.Id);
                mail = initMail(mail, currCase,currCase.email_from_patient__c, tempContactId,siteEmailMap);
                mail = definePattern(mail, validCasesReminder, validCasesRoute,validCases, currCase,'female');
                //mail.setTemplateId(TenFemale);
                mails.add(mail);
                Messaging.SingleEmailMessage mailPartner = new Messaging.SingleEmailMessage();
                mailPartner = initMail(mailPartner, currCase,currCase.Partner_Name__r.PersonEmail, tempContactId,siteEmailMap);
                mailPartner = definePattern(mailPartner, validCasesReminder, validCasesRoute,validCases, currCase,'partner');
                //mailPartner.setTemplateId(TenMale);
                mails.add(mailPartner);
            }
            else{
                String emailAddress = validCases.get(currCase)=='female' ? currCase.email_from_patient__c : currCase.Partner_Name__r.PersonEmail;
                System.debug('sending email to: '+emailAddress);
                sentEmails.add(emailAddress);
                sentEmailsIds.add(currCase.Id);
                mail = initMail(mail, currCase,emailAddress, tempContactId,siteEmailMap);
                mail = definePattern(mail, validCasesReminder, validCasesRoute,validCases, currCase,null);
                mails.add(mail);
            }
           
        }
        System.debug('mails are: '+mails);
        System.debug('validCases for IVF reminder are: '+validCases);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
        Integer i = 0;
        for (Messaging.SendEmailResult result_i : results) {
            if (result_i.success) {
                status.add('success (' + sentEmails.get(i)+ ')');
                successEmails.add(sentEmailsIds.get(i));
            } else {
                status.add('fail (' + sentEmails.get(i)+ ') message: ' +  result_i.errors.get(0).message);
            }
            i++;
        }
        System.debug('status: size: ' + status.size() + ' values: ' + status);

        if(!successEmails.isEmpty()){
            updateCases(successEmails,validCases,validCasesReminder,validCasesRoute);   // commented just for testing in order to be able to test again
        }
    }

    private Messaging.SingleEmailMessage initMail(Messaging.SingleEmailMessage mail,Case currCase,String emailAddress,Id tempContactId,Map<String,String> siteEmailMap){
        System.debug('initMail...');
        mail.setToAddresses(new List<String>{emailAddress});
        mail.setTargetObjectId(tempContactId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setwhatId(currCase.Id);
        mail.setOrgWideEmailAddressId(emailMap.get(currCase.Case_site__c == 'Ramat_Hahayal' ? 'ramat.info@assuta.co.il' : 'rishon.info@assuta.co.il'));
        mail.setReplyTo(currCase.Case_site__c == 'Ramat_Hahayal' ? siteEmailMap.get('20') : siteEmailMap.get('85'));
        mail.setSaveAsActivity(false);
        return mail;
    }

    private Messaging.SingleEmailMessage definePattern(Messaging.SingleEmailMessage mail,Map<Id,Integer> validCasesReminder,Map<Id,String> validCasesRoute,Map<Case,String> validCases,Case currCase,String bothGender){
        System.debug('definePattern...');
        if (validCasesReminder.get(currCase.Id)==13){
            if(validCasesRoute.get(currCase.Id)=='together'){
                System.debug('sending mail 13 together');
                mail.setTemplateId(TwentyThreeCouple);
            }
            else if(validCases.get(currCase) == 'both'){
                if(bothGender=='female'){
                    mail.setTemplateId(TwentyThreeFemale);
                }else if(bothGender=='partner'){
                    mail.setTemplateId(TwentyThreeMale);
                }
            }
            else if(validCases.get(currCase) == 'partner'){
                System.debug('sending mail 13 partner');
                mail.setTemplateId(TwentyThreeMale);
            }
            else if (validCases.get(currCase) == 'female'){
                System.debug('sending mail 13 female');
                mail.setTemplateId(TwentyThreeFemale);
            }
        }
        else if(validCasesReminder.get(currCase.Id)==7){
            if (validCasesRoute.get(currCase.Id)=='together'){
                System.debug('sending mail 7 together');
                mail.setTemplateId(TenCouple);
            }else if((validCases.get(currCase) == 'female' || bothGender=='female') && (validCasesRoute.get(currCase.Id)=='Seperate_Route')){
                System.debug('sending mail 7 female');
                mail.setTemplateId(TenFemale);
            }else if((validCases.get(currCase) == 'partner' || bothGender=='partner') && (validCasesRoute.get(currCase.Id)=='Seperate_Route')){
                System.debug('sending mail 7 partner');
                mail.setTemplateId(TenMale);
            }
        }

        return mail;
    }

    private void sendSMS(Map<Case,String> validCases,Map<Id,Case> validCasesIdMap,Map<Id,Integer> validCasesReminder,Map<Id,String> validCasesRoute,Map<Id,String> idToCaseTypeMap){
        System.debug('IVFReminderSchedulableBatch.sendSMS...');
        List<SMS__c> smsList = new List<SMS__c>();
        Set<Id> smsIds = new Set<Id>();
        Set<String> errors = new Set<String>();
        Map<Id,Case> casesMap = new Map<Id,Case>();

        for (Case currCase :validCases.keySet()){
            String smsPhoneNumber;
            System.debug('checking case type for case id: '+currCase.Id);
            if(idToCaseTypeMap.get(currCase.Id)=='partner'){
                smsPhoneNumber = currCase.Partner_Name__r.SMS_Phone_Number__c;
            }else{
                smsPhoneNumber = currCase != null && currCase.SMS_Phone_Number__c != null
                ? currCase.SMS_Phone_Number__c
                : currCase.Account.SMS_Phone_number__c;
            }    
        System.debug('before sms init currCase is: '+idToCaseTypeMap.get(currCase.Id));
        String smsType = initSMSData(currCase, validCasesReminder, validCasesRoute);
        if(idToCaseTypeMap.get(currCase.Id)=='both'){
            System.debug('SMS for both');
            String templateTextMale = initSMSTemplate(currCase, smsType,validCasesRoute,validCases,'partner',idToCaseTypeMap);
            String templateTextFemale = initSMSTemplate(currCase, smsType,validCasesRoute,validCases,'female',idToCaseTypeMap);
            if(smsType!=null && templateTextMale!=null){
                smsList.add(createNewSMS(CurrCase, templateTextMale, currCase.Partner_Name__r.SMS_Phone_Number__c, smsType));
            }
            if(smsType!=null && templateTextFemale!=null){
                smsList.add(createNewSMS(CurrCase, templateTextFemale, smsPhoneNumber, smsType));
            }
        }
       else{
           String templateText = initSMSTemplate(currCase, smsType,validCasesRoute,validCases,null,idToCaseTypeMap);
           if(smsType!=null && templateText!=null){
               smsList.add(createNewSMS(CurrCase, templateText, smsPhoneNumber, smsType));
                System.debug('smsType '+smsType);
        		System.debug('smsType '+templateText);
           }
       }
        
        }

        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);
        for (Database.SaveResult result_i : Database.insert(smsList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        for (SMS__c sms_i : [SELECT Id, Case__c FROM SMS__c WHERE Id IN: smsIds]){ // if the case belongs to female than we want to update female flag
                                                                                   // otherwise update the partner flag
            Case currCase =  validCasesIdMap.get(sms_i.Case__c);
            if(idToCaseTypeMap.get(currCase.Id) == 'female'){ 
                if(casesMap.get(currCase.Id)==null){
                    casesMap.put(currCase.Id,new Case(Id=sms_i.Case__c,Reminder_After_10_Days_FemalePatient__c = true));
                }else{
                    Case mapCase= casesMap.get(currCase.Id);
                    mapCase.Reminder_After_10_Days_FemalePatient__c=true;
                    casesMap.put(mapCase.Id,mapCase);
                }
            }else{
                if(casesMap.get(currCase.Id)==null){
                    casesMap.put(currCase.Id,new Case(Id=sms_i.Case__c,Reminder_After_10_Days_Partner__c = true));
                }else{
                    Case mapCase= casesMap.get(currCase.Id);
                    mapCase.Reminder_After_10_Days_Partner__c=true;
                    casesMap.put(mapCase.Id,mapCase);
                }
            } 
        }

        System.debug('cases: size: ' + casesMap.size() + ' value: ' + casesMap.values());
        for (Database.SaveResult result_i : Database.update(casesMap.values(), false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    }
    
    private SMS__c createNewSMS(Case CurrCase,String templateText,String smsPhoneNumber,String smsType){
        return new SMS__c(
                status__c = '1',
                Case__c= currCase.Id ,
                Type__c = 'Outgoing',
                Template_Text__c  = templateText,
                Phone_Number__c = smsPhoneNumber,
                Event_Name__c = smsType
                );
    }



    private void updateCases(Set<Id> successEmails,Map<Case,String> validCases,Map<Id,Integer> validCasesReminder, Map<Id,String> validCasesRoute){
        System.debug('updateCases...');
        List<Case>  casesToUpdate = new List<Case>();
        for (Case currCase : validCases.keySet()){
            if(successEmails.contains(currCase.Id)){
                if(validCasesReminder.get(currCase.Id)==7){
                    if(validCases.get(currCase)=='female'){
                        currCase.Reminder_After_10_Days_FemalePatient__c = true;
                        currCase.First_Reminder_Sending_Date_Female__c =  DateTime.now();
                    }else if(validCases.get(currCase)=='partner'){
                        currCase.Reminder_After_10_Days_Partner__c = true;
                        currCase.First_Reminder_Sending_Date_Partner__c =  DateTime.now();
                    }else if(validCases.get(currCase)=='both'){
                        currCase.Reminder_After_10_Days_FemalePatient__c = true;
                        currCase.First_Reminder_Sending_Date_Partner__c =  DateTime.now();
                        currCase.First_Reminder_Sending_Date_Female__c =  DateTime.now();
                        currCase.Reminder_After_10_Days_Partner__c = true;
                    }
                }else if(validCasesReminder.get(currCase.Id)==13){
                    if(validCasesRoute.get(currCase.Id)=='together' || validCases.get(currCase)=='female'){
                        currCase.Second_Reminder_Sent_Female_Couple__c = true;
                    }else if(validCasesRoute.get(currCase.Id)=='Seperate_Route' && validCases.get(currCase)=='partner' ){
                        currCase.Second_Reminder_Sent_Partner__c = true;
                    }
                    else if(validCases.get(currCase)=='both'){
                        currCase.Second_Reminder_Sent_Female_Couple__c = true;
                        currCase.Second_Reminder_Sent_Partner__c = true;
                    }
                }
                casesToUpdate.add(currCase);
            }
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }

    private String initSMSData(Case currCase,Map<Id,Integer> validCasesReminder, Map<Id,String> validCasesRoute){
        System.debug('initSMSData...');
        if(validCasesRoute.get(currCase.Id)=='Seperate_Route'){
            if(currCase.Case_site__c=='Ramat_Hahayal'){
                return 'IVF_Reminder_Seperate_20';
            }
            else if(currCase.Case_site__c=='Rishon_Letzion'){
                return 'IVF_Reminder_Seperate_85';
            }
        }else if(validCasesRoute.get(currCase.Id)=='together'){
            if(currCase.Case_site__c=='Ramat_Hahayal'){
                return 'IVF_Reminder_Couple_20';
            }
            else if(currCase.Case_site__c=='Rishon_Letzion'){
                return 'IVF_Reminder_Couple_85';
            }
        }
        return null;
    }
    private String initSMSTemplate(Case currCase,String templateName,Map<Id,String> validCasesRoute,Map<Case,String> validCases,String togetherGender,Map<Id,String> idToCaseTypeMap){
        System.debug('initSMSTemplate...');
        String patientName=null;
        String kitSendigDate=null;
        String expirationDate=null;
		
        
        System.debug('sms route is: '+validCasesRoute.get(currCase.Id));
        System.debug('sms valid case is: '+idToCaseTypeMap.get(currCase.Id));
        System.debug('template name: '+templateName);
        
        if(validCasesRoute.get(currCase.Id)=='Seperate_Route' && (idToCaseTypeMap.get(currCase.Id)=='partner' || togetherGender=='partner')){
            System.debug('initSMSTemplate seperate partner...');
            patientName = currCase.Male_First_Name__c;
            kitSendigDate = String.valueOf(currCase.Kit_Sending_Date_Partner_IVF__c);
            expirationDate = String.valueOf(currCase.Expiration_Decision_Making_Male_IVF__c);
        }else if(validCasesRoute.get(currCase.Id)=='together' || idToCaseTypeMap.get(currCase.Id)=='female' || togetherGender=='female'){
            System.debug('initSMSTemplate together or female...');
            patientName = currCase.Female_First_Name__c;
            kitSendigDate = String.valueOf(currCase.Kit_Sending_Date_Female_IVF__c);
            expirationDate = String.valueOf(currCase.Expiration_Decision_Making_Female_IVF__c);
        }
        System.debug('name:'+patientName+' kitSendDate:'+kitSendigDate+' expirtationDate: '+expirationDate);
        if(templateName!=null && patientName!=null && kitSendigDate!=null && expirationDate!=null &&
         currCase.link_upload_files__c!=null && currCase.Fax_Number_IVF__c!=null  && currCase.Site_Email__c!=null){
            return templateName+','+patientName+','+kitSendigDate+','+expirationDate+','+currCase.link_upload_files__c+','+currCase.Fax_Number_IVF__c+','+currCase.Site_Email__c;
         }else{
             System.debug('SMS cannot be send with null values');
         }
       System.debug('initSMSTemplate returning null...');
       return null; 
    }

    private Map<String,String> getSiteEmailMap(){
        Map<String,String> siteEmailMap =  new Map<String,String>();
        for(Site_email_address__mdt metadata_i : [SELECT SiteCode__c,SiteEmail__c FROM Site_email_address__mdt]){
            siteEmailMap.put(metadata_i.SiteCode__c,metadata_i.SiteEmail__c);
        }
        return siteEmailMap;
    }


    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
         
        if (runNextJob) {
            Database.executeBatch(new IVFReminderSchedulableBatch(true), 25);
        }
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new IVFReminderSchedulableBatch(runNextJob), 25);
    }


}