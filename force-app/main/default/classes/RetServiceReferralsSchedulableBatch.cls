// TEST: RetServiceReferralsSchedulableBatchTest
global class RetServiceReferralsSchedulableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    Map<Id, Map<String, File__c>> accountIdToFilesMap = new Map<Id, Map<String, File__c>>();
    List<AttachmentWrp> attachmentToInsertList = new List<AttachmentWrp>();

    public RetServiceReferralsSchedulableBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('RetServiceReferralsSchedulableBatch ... start');
        return Database.getQueryLocator([
            SELECT Id
                    , Case__c
                    , ID_Type__c                     
                    , Patient_Account__c
                    , IdNumberForMaccabi__c                     
                    , Medical_Procedure__c
                    , Medical_Procedure__r.Domain__r.MaccabiRefferal__c
            FROM Appointment__c
            WHERE Number_of_referral__c = null    
            AND IdNumberForMaccabi__c != null       
            AND ID_Type__c = 'תעודת זהות'
            AND Appointment_Date_Time__c = NEXT_N_DAYS:3
            AND Medical_Procedure__r.RellevantJobReferral__c = true
            AND PayerFactor__r.InsuranceCode__c IN ( '3', '43', '44', '89')
            AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed')
            AND (RecordType.DeveloperName = 'Institutes' OR RecordType.DeveloperName = 'Closedins')           
        ]);
    }    

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('RetServiceReferralsSchedulableBatch ... execute');   
        Set<Id> accountIdSet = new Set<Id>();
        List<File__c> fileToUpdateList = new List<File__c>();
        File__c file;

        for (Appointment__c appointment_i : scope) {
            accountIdSet.add(appointment_i.Patient_Account__c);
        }
        System.debug('accountIdSet: size: ' + accountIdSet.size() + ' value: ' + accountIdSet);
        
        for(File__c file_i : [SELECT Id
                                   , IsMaccabi__c
                                   , ReferralNumber__c
                                   , Account__c
                              FROM File__c 
                             WHERE Account__c IN :accountIdSet
                               AND ReferralNumber__c != null
                               AND CreatedDate > LAST_N_MONTHS:2]) {            
            if (!accountIdToFilesMap.containskey(file_i.Account__c)) {
                accountIdToFilesMap.put(file_i.Account__c, new Map<String, File__c>());
            }
            accountIdToFilesMap.get(file_i.Account__c).put(file_i.ReferralNumber__c, file_i);
        }
        System.debug('accountIdToFilesMap: size: ' + accountIdToFilesMap.size() + ' values: ' + accountIdToFilesMap);
    
        for (Appointment__c appointment_i : scope) {
            file = this.pulloutRetServiceReferrals(appointment_i);
            if (file != null) fileToUpdateList.add(file);
        }

        System.debug('fileToUpdateList: size: ' + fileToUpdateList.size() + ' value: ' + fileToUpdateList);
        AsyncUtil.doUpdate(fileToUpdateList);
        insertAttachments();

    }

    global void finish(Database.BatchableContext BC) {
        System.debug('RetServiceReferralsSchedulableBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new RetServiceReferralsSchedulableBatch(), 5);
    }

    public File__c pulloutRetServiceReferrals(Appointment__c appointment) {
        System.debug('RetServiceReferralsSchedulableBatch.pulloutRetServiceReferrals ...');
        ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap retrievingServiceReferralsSoap = new ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput retrievingServiceReferralsInput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput();
        RetrievingServiceReferralsInput.MemberID = appointment.IdNumberForMaccabi__c;
        RetrievingServiceReferralsInput.MemberIDCode = '0';//appointment.ID_Type__c == 'דרכון' ? '9' : '0';
        RetrievingServiceReferralsInput.ReferralType = appointment.Medical_Procedure__r.Domain__r.MaccabiRefferal__c;
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput result = retrievingServiceReferralsSoap.retrievingServiceReferrals(RetrievingServiceReferralsInput);
        
        File__c fileToReturn;

        try {
            System.debug('isServiceReturnsAnswers ErrorCode: ' + result.ErrorCode.trim());
            String errorCode = String.valueOf(Integer.valueOf(result.ErrorCode.Trim()));
            if (errorCode == '0' && result.Referrals.Referral.size() > 0 ) {                               
                String lastRefNum = MaccabiIntegration.getLastReferralNumber(result.Referrals.Referral);
               
                for (Integer i = 0; i < result.Referrals.Referral.size(); i++) {
                    String referralNum = result.Referrals.Referral[i].ReferralNumber.Trim();
                    if (!(accountIdToFilesMap.containskey(appointment.Patient_Account__c)
                          && accountIdToFilesMap.get(appointment.Patient_Account__c).containskey(referralNum))) {
                        Map<String, String> refDataMap = MaccabiIntegration.createRefData(result.Referrals.Referral[i]); 
                        
                        refDataMap.put('parentObjName', 'Account');
                        refDataMap.put('caseID', appointment.Case__c);
                        refDataMap.put('memberID', appointment.IdNumberForMaccabi__c);
                        refDataMap.put('accountID', appointment.Patient_Account__c);
                        refDataMap.put('referralExistErrCode', errorCode);
                        refDataMap.put('appId', lastRefNum != null && referralNum == lastRefNum ? appointment.Id : null);                                                                                                                                        
                        System.debug('isServiceReturnsAnswers refDataMap: ' + refDataMap);
                              
                        Blob attachBody = Test.isRunningTest() ? Blob.valueOf('sfaewgWRFS') : getDocument(appointment, referralNum);
                    
                        attachmentToInsertList.add(new AttachmentWrp(
                            refDataMap,
                              'הפניה',
                            attachBody,
                            appointment.IdNumberForMaccabi__c,
                            result.Referrals.Referral[i].Treatments
                        ));                    
                       
                    } else if ( accountIdToFilesMap.containskey(appointment.Patient_Account__c)
                             && accountIdToFilesMap.get(appointment.Patient_Account__c).containskey(lastRefNum) 
                             && accountIdToFilesMap.get(appointment.Patient_Account__c).containskey(referralNum) ) {    
                        fileToReturn = new File__c(Id = accountIdToFilesMap.get(appointment.Patient_Account__c).get(lastRefNum).Id, Appointment__c = appointment.Id);                        
                    }   
                }   
            }
        } catch(Exception e) {
            System.debug('Error: An exception has been encountered while calling out to RetrievingServiceReferrals: ' + e.getMessage());
        }

        System.debug('fileToReturn: ' + fileToReturn);
        return fileToReturn;
    }

    @TestVisible
    private Blob getDocument(Appointment__c appointment, String referralId) {
        System.debug('RetServiceReferralsSchedulableBatch.getDocument ...');
        Dom.Document document = new Dom.Document();
        document.load(MaccabiIntegration.isReceiveDocumentFromArc(appointment.IdNumberForMaccabi__c, appointment.ID_Type__c == 'דרכון' ? '9' : '0', referralId, false));

        String errorCode = document.getRootElement().getChildElement('ErrorCode', null).getText();
        System.debug('isReceiveDocumentFromArc Error Code: '+ errorCode);

        if (errorCode.trim() == '0') {
            return EncodingUtil.base64Decode(document.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
        }

        return null;
    }

    private void insertAttachments() {
        System.debug('attachmentToInsertList: size: ' + attachmentToInsertList.size() + ' value: ' + attachmentToInsertList);
        for (AttachmentWrp attachmantWrp_i : attachmentToInsertList) {
            MaccabiIntegration.insertAttachment(MaccabiIntegration.insertFileReferral(attachmantWrp_i.refDataMap, MaccabiIntegration.convertToArrayOfCodes(attachmantWrp_i.treatments), MaccabiIntegration.convertToArrayOfDescription(attachmantWrp_i.treatments))
                                              , attachmantWrp_i.fileName
                                              , attachmantWrp_i.attachBody
                                              , attachmantWrp_i.patientAccId);
        }
    }   

    private class AttachmentWrp {
        Map<String, String> refDataMap;
        String fileName;
        Blob attachBody;
        String patientAccId;
        ws_maccabiHitchayvuyotReferrals.Treatments[] treatments;

        public AttachmentWrp(Map<String, String> refDataMap, String fileName, Blob attachBody, String patientAccId, ws_maccabiHitchayvuyotReferrals.Treatments[] treatments) {
            this.refDataMap = refDataMap;
            this.attachBody = attachBody;
            this.fileName = fileName;
            this.patientAccId = patientAccId;
            this.treatments = treatments;
        }
    }
}