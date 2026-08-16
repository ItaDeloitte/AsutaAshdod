/*
    * @author         Yulia Liberman   <yliberman@deloitte.co.il>
    * @modifiedBy     
    * @version        1.0
    * @created        01-07-2019
    * @modified       DD-MM-YYYY
    * @see            
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
    * @changes
    * vX.X            mail@mail.com
    * YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
    *                 each line should be indented till left aligned with the previous description text.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class MaccabiIntegration {
    private static final String comStatus_1b = '1b';
    private static final String comStatus_9b = '9b';
    private static final String errorCode_9 = '9';

    public static Id jobId = null;
    public static DateTime startTime = System.now();
    public static DateTime startTimePlusFive = MaccabiIntegration.startTime.addDays(5);
    public static List<Log__c> logs = new List<Log__c>();

    public MaccabiIntegration() {}

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals by button click from appointment
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appId       ID of Appointment__c
        * @param    memberID    Patient ID number (passport number)
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)
    public static void retrievingServiceReferrals (String appId, String memberID, String memberIDCode, String payerFactor, String patientAcc, String servProviderID, String doctorLicense, String medicalProcedure) {
        MaccabiIntegration.retrievingServiceReferralsHandler (memberID, memberIDCode, appId, payerFactor, patientAcc, servProviderID, doctorLicense, medicalProcedure);
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service by click on button יצירת הפניה ידנית מול מכבי in File__c layout
        * LWComponent 'CommitmentsMaccabiManual'
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    fileID                  ID of File__c
        * @param    memberID                Patient ID number (passport number)
        * @param    codeConversionArr       array of Medical_Procedure__c codes
        * @param    doctorId                File__c.Doctor_ID__c
        * @param    referralNumber          File__c.ReferralNumber__c
        * @param    dateTreatment           Today + 5 days
        * @return   ErrorCode               Service return resultCode.ErrorCode (0-7/9)
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)
    public static String isReqLiabilityAuto(String appId, String fileID, String memberID, String memberIDCode, String [] codeConversionArr, String doctorId, String referralNumber, String dateTreatment, String servProviderID) {
        try{/*Callout isRequestLiabilityAuto*/ 
            ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput resultCode = MaccabiIntegration.isRequestLiabilityAuto(memberID, memberIDCode, codeConversionArr, doctorId, referralNumber, dateTreatment, servProviderID);
            if (resultCode.ErrorCode != null) {                
                update new File__c (Id = Id.valueOf(fileID)
                                    , CommitmentStatus__c = resultCode.ErrorCode
                                    , ObligationNumber__c = resultCode.LiabilityID
                                    , Commitment_Reason__c = resultCode.DescriptionRemark
                                    , ReferralRequestNumber__c = resultCode.LiabilityID
                                   );
                update new Appointment__c (Id = Id.valueOf(appId)
                                           , Commitment_Status__c = resultCode.ErrorCode
                                           , Number_of_commitment__c = resultCode.LiabilityID
                                           , Deductibles__c = resultCode.Deductible != '000000000000.00' ? Decimal.valueOf(resultCode.Deductible.Trim()) : null);
                System.debug('update CommitmentStatus in File to : '+resultCode.ErrorCode);
            }
            return resultCode.ErrorCode;
        } catch(Exception ex) {
            System.debug('isReqLiabilityAuto fail: '+ ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'isReqLiabilityAuto', ex, appId + ' ' + memberID));  
            insert logs;
            return null;
        }
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service by click on button שליחת קובץ הפניה למכבי in File__c layout
        * LWComponent 'CommitmentsMaccabiManual' for classification == RED
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appId                   ID of Appointment__c
        * @param    fileID                  ID of File__c
        * @param    memberID                Patient ID number (passport number)
        * @param    codeConversionArr       array of Medical_Procedure__c codes
        * @param    doctorId                File__c.Doctor_ID__c
        * @param    doctorName              File__c.DoctorName__r.Name
        * @param    servProviderID          Site.Maccabi_Code__c
        * @param    guid                    Guid of Appointment for Maccabi
        * @return   ErrorCode               Service return resultCode.ErrorCode (0-7/9)
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)
    public static String isLiabilityManagement(String appId, String fileID, String memberID, String memberIDCode, String [] codeConversionArr, String doctorId, String doctorName, String servProviderID, String guid) {
        try{
            ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput resIsLiabManagement = MaccabiIntegration.isLiabilitiesManagement(memberID, memberIDCode, doctorId, doctorName, codeConversionArr, servProviderID, '0', guid);
            System.debug('###isLiabilitiesManagement### ErrorCode result: '+resIsLiabManagement.ErrorCode.Trim());
            String errorCode = resIsLiabManagement.ErrorCode.Trim() == '1' ? comStatus_1b : resIsLiabManagement.ErrorCode.Trim();
            update new File__c(Id = Id.valueOf(fileID), CommitmentStatus__c = errorCode, ObligationNumber__c = resIsLiabManagement.LiabilityID, ReferralRequestNumber__c = resIsLiabManagement.LiabilityID);
            update new Appointment__c(Id = Id.valueOf(appId), Commitment_Status__c = errorCode, Number_of_commitment__c = resIsLiabManagement.LiabilityID);
            System.debug('update CommitmentStatus in File to : '+resIsLiabManagement.ErrorCode);
            return resIsLiabManagement.ErrorCode;
        } catch(Exception ex) {
            System.debug('isLiabilityManagement fail: '+ ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'isLiabilityManagement', ex, appId + ' ' + memberID));  
            insert logs;
            return null;
        } 
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service by click on button שליחת קובץ הפניה למכבי in File__c layout
        * Will work only if file of referral was attached to file (layout) 
        * LWComponent 'CommitmentsMaccabiManual'
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    contentDocumentId       ContentDocumentLink.ContentDocumentId
        * @param    memberID                Patient ID number (passport number)
        * @param    appId                   File__c.Appointment__c
        * @param    referralNumber          File__c.ReferralNumber__c
        * @param    appDate                 File__c.Date_Time_of_the_appointment__c
        * @return   Code                    Number of Code (0/1/2)
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)    
    public static String insertDocumentToArchive(Id contentDocumentId, String memberID, String memberIDCode, String referralNumber, Id appId, Date appDate, String fileID, String docType) {
        try{
            if(referralNumber == '' || referralNumber == null){
                referralNumber = '0';
            }
            ws_MaccabiInsertDocumentToArchiveSOAP.InsertDocumentToArchiveSoap req = new  ws_MaccabiInsertDocumentToArchiveSOAP.InsertDocumentToArchiveSoap();
            Blob content = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId=:contentDocumentId limit 1].VersionData;
            String contentBase = EncodingUtil.base64Encode(content);
            String InputXMLString = 
                    '<PRDOCUMENT>'+ contentBase +'</PRDOCUMENT>'+
                    '<PTZ>'+ memberID +'</PTZ>'+
                    '<PKTZ>'+ memberIDCode +'</PKTZ>'+
                    '<PHIT>'+ referralNumber +'</PHIT>'+
                    '<PRTEURDOC>'+ docType +'</PRTEURDOC>'+
                    '<PRTYPEDOC>pdf</PRTYPEDOC>';       
            String result = req.insertDocumentToArchive(InputXMLString);
            System.debug('insertDocumentToArchive: '+result);
            Dom.Document doc = new Dom.Document();
            doc.load(result);
            String resultCode = doc.getRootElement().getChildElement('ResultMessage', null) != null ? doc.getRootElement().getChildElement('ResultMessage', null).getChildElement('Code', null).getText() : '';
            // if(resultCode == '0') {
            //     ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput isRetAns = MaccabiIntegration.isServiceReturnsAnswers(memberID, referralNumber, appId, appDate);
            //     System.debug('IsServiceReturnsAnswers: '+isRetAns);
            // }
            if(resultCode == '0' || resultCode == '1' || resultCode == '2'){
                update new File__c(Id = Id.valueOf(fileID), Status_sent_file_to_maccabi__c = resultCode);
                System.debug('update CommitmentStatusSendFile in File to : '+resultCode);
            }
            return resultCode;
        } catch(Exception ex) {
            System.debug('insertDocumentToArchive fail: '+ ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'insertDocumentToArchive', ex, appId + ' ' + memberID));  
            return null;
        } 
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals in account page (all referrals will display in account page)
        * calls on page loading - for only one account in transaction
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    memberID    Patient ID number (passport number)
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future(callout=true) @AuraEnabled(cacheable=false)
    public static void retrievingReferralsFromAccount (String memberID, String memberIDCode, Id accId, String domainCode, String caseId, Id appId) {
        ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap req = new ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput RetrievingServiceReferralsInput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput result = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput();

        RetrievingServiceReferralsInput.MemberID = memberID;
        RetrievingServiceReferralsInput.MemberIDCode = memberIDCode;
        RetrievingServiceReferralsInput.ReferralType = domainCode != null ? domainCode : '';
        String referralErrorCode = errorCode_9;
        String referralExistErrCode = errorCode_9;
        Blob attachContent = Blob.valueOf('');
        Boolean isRecivedFile = false;
        Map<String, String> refData = new Map<String, String>();
        Map<String, String[]> refDataCodeConversion = new Map<String, String[]>();
        Map<String, Blob> attContent = new Map<String, Blob>();
        Map<String, Map<String, String>> refDataMap = new Map<String, Map<String, String>>();
        Set<String> existreferrals = new Set<String>();
        for(File__c file : [SELECT Id, IsMaccabi__c, ReferralNumber__c, Account__c FROM File__c WHERE Account__c =:accId AND ReferralNumber__c != null]){
            existreferrals.add(file.ReferralNumber__c);
        }
        try{/*Callout RetServiceReferrals*/
            result = req.retrievingServiceReferrals(RetrievingServiceReferralsInput);
            referralExistErrCode = String.valueOf(Integer.valueOf(result.ErrorCode.Trim()));
            System.debug('RetServiceReferrals result: '+result);
            if(Integer.valueOf(result.ErrorCode.Trim()) == 0 && result.Referrals.Referral.size()>0) {//if refferal exist => create file object -InsertFileReferral()
                for (Integer i=0; i<result.Referrals.Referral.size(); i++) {
                    refData = MaccabiIntegration.createRefData(result.Referrals.Referral[i]);     
                    if(!existreferrals.contains(refData.get('referralNumber'))){
                        refData.put('memberID', memberID);
                        refData.put('referralExistErrCode', referralExistErrCode);
                        refData.put('accountID', accId);
                        refData.put('parentObjName', 'Account');
                        refData.put('caseID', caseId);
                        refData.put('commitmentStatus', null);
                        refData.put('appId', appId);

                        refDataCodeConversion.put(refData.get('referralNumber') + 'TreatmentsCodes', convertToArrayOfCodes(result.Referrals.Referral[i].Treatments));
                        refDataCodeConversion.put(refData.get('referralNumber') + 'TreatmentsDesc', convertToArrayOfDescription(result.Referrals.Referral[i].Treatments));

                        try{/*Callout isReceiveDocumentFromArc*/ //REFERRAL
                            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, refData.get('referralNumber'), false); 
                            Dom.Document doc = new Dom.Document();
                            doc.load(resultIsReceiveDocFromArc);
                            referralErrorCode = doc.getRootElement().getChildElement('ErrorCode', null).getText();
                            System.debug('isReceiveDocumentFromArc referralErrorCode: '+referralErrorCode); 
                            attachContent = EncodingUtil.base64Decode(doc.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                            attContent.put(refData.get('referralNumber'), attachContent);
                            if(referralErrorCode.Trim() == '0') {
                                isRecivedFile = true;
                            }
                        } catch (Exception ex) {
                            System.debug('retrievingReferralsFromAccount - isReceiveDocumentFromArc  fail: '+ ex);
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingReferralsFromAccount - isReceiveDocumentFromArc', ex, appId + ' ' + memberID));  
                        }

                        refDataMap.put(result.Referrals.Referral[i].ReferralNumber, refData);
                    }
                }

                for (String key : refDataMap.keySet()) {
                    if(!existreferrals.contains(key)){
                        refData= refDataMap.get(key);
                        Id fileId = MaccabiIntegration.insertFileReferral(refData, refDataCodeConversion.get(refData.get('referralNumber') + 'TreatmentsCodes'), refDataCodeConversion.get(refData.get('referralNumber') + 'TreatmentsDesc'));
                        if(fileId != null && isRecivedFile) {
                            MaccabiIntegration.insertAttachment(fileId, 'הפניה', attContent.get(refData.get('referralNumber')), String.valueOf(accId));
                        } 
                    }               
                }
            }            
        } catch(Exception ex) {
            System.debug('retrievingReferralsFromAccount  fail: '+ ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingReferralsFromAccount', ex, appId + ' ' + memberID));  
        }
        insert logs;
    }

     /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals triggered by AfterInsert Appointment__c. For appointments scheduled in 
        * the source system, Record Type - Institutes ,Payer Factor - maccabi and Maccabi Domain  
        * Code not null.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future(callout=true)
    public static void retrievingReferralsFromInstitutesApp (String memberID, String memberIDCode, Id accId, String domainCode, String caseId, Id appId) {
        ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap req = new ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput RetrievingServiceReferralsInput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput result = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput();

        RetrievingServiceReferralsInput.MemberID = memberID;
        RetrievingServiceReferralsInput.MemberIDCode = memberIDCode;
        RetrievingServiceReferralsInput.ReferralType = domainCode != null ? domainCode : '';
        String referralErrorCode = errorCode_9;
        String referralExistErrCode = errorCode_9;
        Blob attachContent = Blob.valueOf('');
        Boolean isRecivedFile = false;
        Map<String, String> refData = new Map<String, String>();
        Map<String, String[]> refDataCodeConversion = new Map<String, String[]>();
        Map<String, Blob> attContent = new Map<String, Blob>();
        Map<String, Map<String, String>> refDataMap = new Map<String, Map<String, String>>();
        Map<String, File__c> existreferrals = new Map<String, File__c>();
        for(File__c file : [SELECT Id, IsMaccabi__c, ReferralNumber__c, Account__c, Appointment__c FROM File__c WHERE Account__c =:accId AND ReferralNumber__c != null]){
            existreferrals.put(file.ReferralNumber__c, file);
        }
        try{/*Callout RetServiceReferrals*/
            result = req.retrievingServiceReferrals(RetrievingServiceReferralsInput);
            referralExistErrCode = String.valueOf(Integer.valueOf(result.ErrorCode.Trim()));
            System.debug('RetServiceReferrals result: '+result);
            if(Integer.valueOf(result.ErrorCode.Trim()) == 0 && result.Referrals.Referral.size()>0) {//if refferal exist => create file object -InsertFileReferral()
                String refNumber = MaccabiIntegration.getLastReferralNumber(result.Referrals.Referral);
                System.debug('**refNumber ' + refNumber);
                File__c fileUpdate;                          
                for (Integer i = 0; i< result.Referrals.Referral.size(); i++) {
                    refData = MaccabiIntegration.createRefData(result.Referrals.Referral[i]);                               
                    if (!existreferrals.containsKey(refData.get('referralNumber'))){
                        if(refNumber != null && refData.get('referralNumber') == refNumber) {    
                            refData.put('appId', appId);
                        }
                        refData.put('memberID', memberID);
                        refData.put('referralExistErrCode', referralExistErrCode);
                        refData.put('accountID', accId);
                        refData.put('parentObjName', 'Account');
                        refData.put('caseID', caseId);
                        refData.put('commitmentStatus', null);
                        
                        refDataCodeConversion.put(refData.get('referralNumber') + 'TreatmentsCodes', convertToArrayOfCodes(result.Referrals.Referral[i].Treatments));
                        refDataCodeConversion.put(refData.get('referralNumber') + 'TreatmentsDesc', convertToArrayOfDescription(result.Referrals.Referral[i].Treatments));

                        try{/*Callout isReceiveDocumentFromArc*/ //REFERRAL
                            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, refData.get('referralNumber'), false); 
                            Dom.Document doc = new Dom.Document();
                            doc.load(resultIsReceiveDocFromArc);
                            referralErrorCode = doc.getRootElement().getChildElement('ErrorCode', null).getText();
                            System.debug('isReceiveDocumentFromArc referralErrorCode: '+referralErrorCode); 
                            attachContent = EncodingUtil.base64Decode(doc.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                            attContent.put(refData.get('referralNumber'), attachContent);
                            if(referralErrorCode.Trim() == '0') {
                                isRecivedFile = true;
                            }
                        } catch (Exception ex) {
                            System.debug('retrievingReferralsFromAccount - isReceiveDocumentFromArc  fail: '+ ex);
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingReferralsFromAccount - isReceiveDocumentFromArc', ex, appId + ' ' + memberID));  
                        }

                        refDataMap.put(result.Referrals.Referral[i].ReferralNumber, refData);
                    } else if(refNumber != null && refData.get('referralNumber') == refNumber ) {    
                        fileUpdate = new File__c(Id = existreferrals.get(refData.get('referralNumber')).Id, Appointment__c = appId);                        
                    }                     
                }

                for (String key : refDataMap.keySet()) {
                    if(!existreferrals.containsKey(key)){
                        refData= refDataMap.get(key);
                        Id fileId = MaccabiIntegration.insertFileReferral(refData, refDataCodeConversion.get(refData.get('referralNumber') + 'TreatmentsCodes'), refDataCodeConversion.get(refData.get('referralNumber') + 'TreatmentsDesc'));
                        if(fileId != null && isRecivedFile) {
                            MaccabiIntegration.insertAttachment(fileId, 'הפניה', attContent.get(refData.get('referralNumber')), String.valueOf(accId));
                        } 
                    }               
                }
                if(fileUpdate != null) {
                    update fileUpdate;
                }
            }            
        } catch(Exception ex) {
            System.debug('retrievingReferralsFromAccount  fail: '+ ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingReferralsFromAccount', ex, appId + ' ' + memberID));  
        }
        insert logs;
    }


    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive commitment by button click from appointment
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appId       ID of Appointment__c
        * @param    memberID    Patient ID number (passport number)
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)
    public static void retrieveServiceRefRED (String patAccount, String memberID, String memberIDCode, String doctorId, String doctorName, String appId, String medProId, String servProviderID, String guid) {
        MaccabiIntegration.retServiceReferralsRedHandler (patAccount, memberID, memberIDCode, doctorId, doctorName, appId, medProId, servProviderID, guid);
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals triggered by AfterInsert Appointment__c when classification == RED
        * From button in Appointment layout, when something went wrong in trigger 
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appMap        The Map of Appointment__c with data of Appointment
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void retServiceReferralsRed (Map<Id, Map<String, String>> appMap) {        
         for (Id key_i : appMap.keySet()) {
             MaccabiIntegration.retServiceReferralsRedHandler (appMap.get(key_i).get('Patient_Account__c'), appMap.get(key_i).get('memberID'), appMap.get(key_i).get('memberIDCode'), appMap.get(key_i).get('doctorId'), appMap.get(key_i).get('doctorName'), String.valueOf(key_i), appMap.get(key_i).get('medicalProcedure'), appMap.get(key_i).get('Site'), null);
         }
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals feature method called from retServiceReferralsRed 
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    doctorId                Appointment__c.Doctor_Account__r.Id_Number__c
        * @param    memberID                Appointment__c.IDNumber__c
        * @param    appId                   Appointment__c
        * @param    referralNumber          '123456'
        * @param    dateTreatment           Appointment__c.Date_of_appointment__c
        * @param    medProId                Medical Procedure Id
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future(callout=true)
    public static void retServiceReferralsRedHandler (String patAccount, String memberID, String memberIDCode, String doctorId, String doctorName, String appId, String medProId, String servProviderID, String guid) {
        Map<String, String> comData = new Map<String, String>();
        String [] codeConversionArr = new List<String>();
        String medProcedure = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c WHERE Id=:medProId limit 1].Procedure_Code__c;
        Blob attachContentCom = Blob.valueOf('');
        Boolean isRecivedCommitmentFile = false;
        String referralErrorCode = errorCode_9;

        codeConversionArr.add(medProcedure);
        try{
            ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput resIsLiabManagement = MaccabiIntegration.isLiabilitiesManagement(memberID, memberIDCode, doctorId, doctorName, codeConversionArr, servProviderID, '0', guid);

            System.debug('###RED### ErrorCode result: '+resIsLiabManagement.ErrorCode.Trim());
            if(resIsLiabManagement.ErrorCode.Trim() == '0') {
                comData = MaccabiIntegration.createComData(resIsLiabManagement);
                comData.put('refType', null);
                comData.put('accountID', patAccount);
                comData.put('appId', appId);
                comData.put('LiabilityID', resIsLiabManagement.LiabilityID);

                String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, resIsLiabManagement.LiabilityID, false); 
                Dom.Document docCom = new Dom.Document();
                docCom.load(resultIsReceiveDocFromArc);
                referralErrorCode = docCom.getRootElement().getChildElement('ErrorCode', null).getText();
                attachContentCom = EncodingUtil.base64Decode(docCom.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                comData.put('referralErrorCode', referralErrorCode);//the same field for referral and commitment

                isRecivedCommitmentFile = referralErrorCode.Trim() == '0' ? true : false;
                System.debug('###RED### isReceiveDocumentFromArc ErrorCode: '+referralErrorCode);
                update new Appointment__c(Id = appId, Commitment_Status__c = '0', Number_of_commitment__c = comData.get('LiabilityID'));
                Id fileId = MaccabiIntegration.insertFileCommitment(comData, codeConversionArr);
                if(fileId != null && isRecivedCommitmentFile) {
                    MaccabiIntegration.insertAttachment(fileId, comData.get('LiabilityID')+' - התחייבות', attachContentCom, memberID);
                }                 
            } else if(resIsLiabManagement.ErrorCode.Trim() == '1'){
                update new Appointment__c(Id = appId, Commitment_Status__c = comStatus_1b, Number_of_commitment__c = resIsLiabManagement.LiabilityID);
            }
            else{                
                update new Appointment__c(Id = appId, Commitment_Status__c = resIsLiabManagement.ErrorCode.Trim(), Number_of_commitment__c = resIsLiabManagement.LiabilityID);
            }
        } catch (Exception ex) {
            System.debug('###RED### retServiceReferralsRedHandler fail: '+ ex); 
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retServiceReferralsRedHandler', ex, appId + ' ' + memberID));  
            insert logs;     
            update new Appointment__c(Id = appId, Commitment_Status__c = comStatus_9b); 
        }  
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals triggered by AfterInsert Appointment__c
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appMap        The Map of Appointment__c with Id and IDNumber__c
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void retServiceReferrals (Map<Id, Map<String, String>> appMap) {
        for (Id key_i : appMap.keySet()) {
            MaccabiIntegration.retrievingServiceReferralsHandler (appMap.get(key_i).get('IDNumber__c'), appMap.get(key_i).get('IDType__c'), key_i, appMap.get(key_i).get('PayerFactor__c'), 
            appMap.get(key_i).get('Patient_Account__c'), appMap.get(key_i).get('Site'), appMap.get(key_i).get('DoctorLicense'), appMap.get(key_i).get('MedicalProcedure'));
        }     
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Retrive servise refferals feauture method called from :
        * retServiceReferrals - Appointment After Insert trigger
        * retrievingServiceReferrals - Retrive servise refferals by button click from appointment
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appId       ID of Appointment__c
        * @param    memberID    Patient ID number (passport number)
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */   
    @future(callout=true)
    public static void retrievingServiceReferralsHandler (String memberID, String memberIDCode, String appId, String payerFactor, String patientAcc, String servProviderID, String doctorLicense, String medicalProcedure) {
        ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap req = new  ws_maccabiRetrievingServiceReferralsSOAP.RetrievingServiceReferralsSoap();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput RetrievingServiceReferralsInput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsInput();
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput result = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput();

        ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput resIsReqLiabilityAuto = new ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput();
        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput respIsLiabManagement = new  ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput();

        RetrievingServiceReferralsInput.MemberID = memberID;
        RetrievingServiceReferralsInput.MemberIDCode = memberIDCode;
        String referralErrorCode = errorCode_9;
        String referralExistErrCode = errorCode_9;
        String commitmentStatus = null;
        Blob attachContentRef = Blob.valueOf('');
        Blob attachContentCom = Blob.valueOf('');
        Boolean isReqLAuto = false;
        Boolean isLiabManagement = false;
        Boolean isRecivedCommitmentFile = false;
        Boolean isRecivedReferralFile = false;
        Map<String, String> refData = new Map<String, String>();
        Map<String, String> comData = new Map<String, String>();
        String[] codeConversionArr = new List<String>();
        String[] descConversionArr = new List<String>();

        try{/*Callout RetServiceReferrals*/
            result = req.retrievingServiceReferrals(RetrievingServiceReferralsInput);
            referralExistErrCode = String.valueOf(Integer.valueOf(result.ErrorCode.Trim()));
            System.debug('RetServiceReferrals ErrCode: '+referralExistErrCode);
            if(Integer.valueOf(result.ErrorCode.Trim())==0 && result.Referrals.Referral.size()>0) {//if refferal exist => create file object -InsertFileReferral()
                Integer ii = MaccabiIntegration.getReferralSorted(result, doctorLicense, medicalProcedure);
                System.debug('**ii' + ii);
                if(ii!=null) {                    
                    refData = MaccabiIntegration.createRefData(result.Referrals.Referral[ii]);
                    refData.put('referralExistErrCode', referralExistErrCode);                
                    refData.put('appId', appId);
                    refData.put('PayerFactor', payerFactor);
                    refData.put('accountID', patientAcc);
                    codeConversionArr = convertToArrayOfCodes(result.Referrals.Referral[ii].Treatments);
                    descConversionArr = convertToArrayOfDescription(result.Referrals.Referral[ii].Treatments);
                    if(refData.get('refType') != null && (refData.get('refType').contains('ביצוע פעולה') || refData.get('refType').toLowerCase().contains('hospitalization'))) {/*Callout IsRequestLiabilityAuto*/
                        try{
                            System.debug('**resIsReqLiabilityAuto');
                            resIsReqLiabilityAuto = MaccabiIntegration.IsRequestLiabilityAuto (memberID, memberIDCode, codeConversionArr, refData.get('doctorIdNum'), refData.get('referralNumber'), refData.get('dateTreatmen'), servProviderID);
                            isReqLAuto = resIsReqLiabilityAuto.ErrorCode.Trim() == '0' ? true : false; 
                            commitmentStatus = resIsReqLiabilityAuto.ErrorCode.Trim();
                            comData = MaccabiIntegration.createComData(resIsReqLiabilityAuto);
                            comData.put('commitmentStatus', commitmentStatus);          
                            comData.put('appId', appId);
                            comData.put('DescriptionRemark', resIsReqLiabilityAuto.DescriptionRemark);
                            refData.put('LiabilityID', resIsReqLiabilityAuto.LiabilityID.Trim());
                            System.debug('IsRequestLiabilityAuto ErrorCode: '+resIsReqLiabilityAuto.ErrorCode);
                        } catch (Exception ex) {
                            commitmentStatus = '10';
                            System.debug('IsRequestLiabilityAuto fail: '+ex); 
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingServiceReferralsHandler - IsRequestLiabilityAuto', ex, appId + ' ' + memberID));    
                        }
                        try{/*Callout isReceiveDocumentFromArc - REFERRAL*/
                            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, refData.get('referralNumber'), false); 
                            Dom.Document docRef = new Dom.Document();
                            docRef.load(resultIsReceiveDocFromArc);
                            referralErrorCode = docRef.getRootElement().getChildElement('ErrorCode', null).getText();
                            System.debug('isReceiveDocumentFromArc Error Code: '+referralErrorCode);
                            isRecivedReferralFile = referralErrorCode.Trim() == '0' ? true : false;
                            attachContentRef = EncodingUtil.base64Decode(docRef.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                        } catch (Exception ex) {
                            System.debug('isReceiveDocumentFromArc fail: '+ex);
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingServiceReferralsHandler - isReceiveDocumentFromArc', ex, appId + ' ' + memberID));    
                        }
                    } else if(refData.get('refType').contains('חיוב ישיר')) {/*Callout IsLiabilitiesManagement*/
                        try{
                            respIsLiabManagement = MaccabiIntegration.IsLiabilitiesManagement(memberID, memberIDCode, refData.get('doctorIdNum'), refData.get('doctorName'), codeConversionArr, servProviderID, '2', null);
                            isLiabManagement = respIsLiabManagement.ErrorCode.Trim() == '0' ? true : false;
                            commitmentStatus = respIsLiabManagement.ErrorCode.Trim();
                            comData = MaccabiIntegration.createComData(respIsLiabManagement);
                            comData.put('commitmentStatus', commitmentStatus);          
                            comData.put('appId', appId);
                            System.debug('IsLiabilitiesManagement ErrorCode: '+respIsLiabManagement.ErrorCode);
                        } catch (Exception ex) {
                            commitmentStatus = '10';
                            System.debug('IsLiabilitiesManagement fail: '+ex);
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingServiceReferralsHandler - IsLiabilitiesManagement', ex, appId + ' ' + memberID));          
                        }
                    }
                    refData.put('referralErrorCode', referralErrorCode);
                    comData.put('refType', refData.get('refType'));
                    comData.put('PayerFactor', payerFactor);
                    comData.put('accountID', patientAcc);                        

                    if(isReqLAuto || isLiabManagement) {//If recived meta data of commitment will try to recive file pdf
                        try{/*Callout isReceiveDocumentFromArc - COMMITMENT*/
                            String commitmentNum = refData.get('refType').contains('חיוב ישיר') ? refData.get('ObligationNumber') : comData.get('LiabilityID');
                            String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, commitmentNum, false); 
                            Dom.Document docCom = new Dom.Document();
                            docCom.load(resultIsReceiveDocFromArc);
                            referralErrorCode = docCom.getRootElement().getChildElement('ErrorCode', null).getText();
                            attachContentCom = EncodingUtil.base64Decode(docCom.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                            isRecivedCommitmentFile = referralErrorCode.Trim() == '0' ? true : false;
                            System.debug('isRecivedCommitmentFile ErrorCode : '+referralErrorCode);
                        } catch (Exception ex) {
                            System.debug('isReceiveDocumentFromArc fail: '+ex); 
                            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingServiceReferralsHandler - isReceiveDocumentFromArc', ex, appId + ' ' + memberID));    
                        }                    
                        comData.put('referralErrorCode', referralErrorCode);//the same field for referral and commitment
                    }
                    refData.put('commitmentStatus', commitmentStatus);
                    comData.put('ErrorCode', commitmentStatus);

                    if(!refData.get('refType').contains('חיוב ישיר')){
                        Id fileId = MaccabiIntegration.insertFileReferral(refData, codeConversionArr, descConversionArr);
                        if(fileId != null && isRecivedReferralFile) {
                            MaccabiIntegration.insertAttachment(fileId, refData.get('referralNumber')+' - הפניה', attachContentRef, patientAcc);
                        }
                    }             
                } else {
                    referralExistErrCode = '1';//If it is no refferals of SURGERY return status 'No refferals' - 1
                }
            }
        } catch(Exception ex) {
            System.debug('RetServiceReferrals fail: '+ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'retrievingServiceReferralsHandler - RetServiceReferrals', ex, appId + ' '+ memberID));    
        }

        if(isReqLAuto || isLiabManagement) {
            Id fileId = MaccabiIntegration.insertFileCommitment(comData, codeConversionArr);
            if(fileId != null && isRecivedCommitmentFile) {
                MaccabiIntegration.insertAttachment(fileId, comData.get('LiabilityID')+' - התחייבות', attachContentCom, patientAcc);
            }
        }
        
        update new Appointment__c(Id = Id.valueOf(appId), Referral_Status_Maccabi__c = referralExistErrCode, Commitment_Status__c = commitmentStatus, Number_of_commitment__c = comData.containsKey('LiabilityID') ? comData.get('LiabilityID') : '');
        System.debug('***UpdateUppointment***'); 
        insert logs;
    }


    @future(callout=true) @AuraEnabled(cacheable=false)
    public static void getCommitmentGreenWay(String patientAccID, String refType, String memberID, String memberIDCode, String appID, String payerFactor, String[] codeConversionArr, String doctorIdNum, String doctorName, String referralNumber, String dateTreatmen, String servProviderID){

        Boolean isReqLAuto = false;
        String commitmentStatus = null;
        Boolean isLiabManagement = false;
        Boolean isRecivedCommitmentFile = false;
        Blob attachContentCom = Blob.valueOf('');
        String referralErrorCode;
        Map<String, String> comData = new Map<String, String>();
        ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput resIsReqLiabilityAuto = new ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput();
        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput respIsLiabManagement = new  ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput();

        if(refType != null && (refType.contains('ביצוע פעולה') || refType.toLowerCase().contains('hospitalization'))) {/*Callout IsRequestLiabilityAuto*/
            try{
                resIsReqLiabilityAuto = MaccabiIntegration.IsRequestLiabilityAuto (memberID, memberIDCode, codeConversionArr, doctorIdNum, referralNumber, dateTreatmen, servProviderID);
                isReqLAuto = resIsReqLiabilityAuto.ErrorCode.Trim() == '0' ? true : false; 
                commitmentStatus = resIsReqLiabilityAuto.ErrorCode.Trim();
                comData = MaccabiIntegration.createComData(resIsReqLiabilityAuto);
                comData.put('commitmentStatus', commitmentStatus);          
                comData.put('appId', appID);
                System.debug('IsRequestLiabilityAuto ErrorCode: '+resIsReqLiabilityAuto.ErrorCode);
            } catch (Exception ex) {
                commitmentStatus = '10';
                System.debug('IsRequestLiabilityAuto fail: '+ex); 
            }
        } else if(refType.contains('חיוב ישיר')) {/*Callout IsLiabilitiesManagement*/
            try{
                respIsLiabManagement = MaccabiIntegration.IsLiabilitiesManagement(memberID, memberIDCode, doctorIdNum, doctorName, codeConversionArr, servProviderID, '2', null);
                isLiabManagement = respIsLiabManagement.ErrorCode.Trim() == '0' ? true : false;
                commitmentStatus = respIsLiabManagement.ErrorCode.Trim();
                comData = MaccabiIntegration.createComData(respIsLiabManagement);
                comData.put('commitmentStatus', commitmentStatus);          
                comData.put('appId', appID);
                System.debug('IsLiabilitiesManagement ErrorCode: '+respIsLiabManagement.ErrorCode);
            } catch (Exception ex) {
                commitmentStatus = '10';
                System.debug('IsLiabilitiesManagement fail: '+ex);
                
            }
        }
        comData.put('PayerFactor', payerFactor);
        comData.put('accountID', patientAccID);                        
        comData.put('ErrorCode', commitmentStatus);

        if(isReqLAuto || isLiabManagement) {//If recived meta data of commitment will try to recive file pdf
            try{/*Callout isReceiveDocumentFromArc - COMMITMENT*/
                String commitmentNum = refType.contains('חיוב ישיר') ? referralNumber : comData.get('LiabilityID');
                String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, commitmentNum, false); 
                Dom.Document docCom = new Dom.Document();
                docCom.load(resultIsReceiveDocFromArc);
                referralErrorCode = docCom.getRootElement().getChildElement('ErrorCode', null).getText();
                attachContentCom = EncodingUtil.base64Decode(docCom.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
                isRecivedCommitmentFile = referralErrorCode.Trim() == '0' ? true : false;
                System.debug('isRecivedCommitmentFile ErrorCode : '+referralErrorCode);
                comData.put('referralErrorCode', referralErrorCode);//the same field for referral and commitment
                Id fileId = MaccabiIntegration.insertFileCommitment(comData, codeConversionArr);
                if(fileId != null) {
                    MaccabiIntegration.insertAttachment(fileId, comData.get('LiabilityID')+' - התחייבות', attachContentCom, patientAccID);
                }

            } catch (Exception ex) {
                System.debug('isReceiveDocumentFromArc fail: '+ex); 
            }
        }  
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service by click on button יצירת הפניה ידנית מול מכבי in File__c layout
        * LWComponent 'CommitmentsMaccabiManual'
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    memberID                Patient ID number (passport number)
        * @param    referralNumber          File__c.ReferralNumber__c
        * @return   result                  Result of type String from Maccabi service ,
        *                                   method 'IsReceiveDocumentFromArchives'
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String isReceiveDocumentFromArc(String memberID, String memberIDCode, String referralNumber, Boolean isAmbulatory)  { // קבלת ושמירת קובץ הפנייה
        ws_maccabiIsReceiveDocFromArcSOAP.IsReceiveDocumentFromArchivesSoap req = new  ws_maccabiIsReceiveDocFromArcSOAP.IsReceiveDocumentFromArchivesSoap();
        String xmlString =  
            '<ChannelID>A</ChannelID>'+
            '<PatientID>'+ memberID +'</PatientID>'+
            '<PatientIDCode>'+ memberIDCode +'</PatientIDCode>'+
            '<ReferenceID>'+ referralNumber +'</ReferenceID>'+            
            '<CodeSubSystem></CodeSubSystem>'+                       
            '<NameDocument></NameDocument>'+
            '<StyleReceive>2</StyleReceive>'+
            '<NameDocLast></NameDocLast>';
        if(isAmbulatory) {
            xmlString += '<CodeSystem>'+ 'h' +'</CodeSystem>'+
            '<CodeTypeDocument>'+ '41' +'</CodeTypeDocument>';
        } else {
            xmlString += '<CodeSystem></CodeSystem>'+
            '<CodeTypeDocument>'+ '000' +'</CodeTypeDocument>';
        }
        String result = req.isReceiveDocumentFromArchives(xmlString); 
        return result;                
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service to recive commitment meta data
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    memberID                Patient ID number (passport number)
        * @param    memberIDCode            Patient ID type
        * @param    codeConversionArr       array of Medical_Procedure__c codes
        * @param    doctorId                File__c.Doctor_ID__c
        * @param    referralNumber          File__c.ReferralNumber__c
        * @param    dateTreatment           Today + 5 days
        * @return   result                  Result of from Maccabi service ,
        *                                   method IsRequestLiabilityAutoSoap.isRequestLiabilityAuto
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput isRequestLiabilityAuto(String memberID, String memberIDCode, String [] codeConversionArr, String doctorId, String referralNumber, String dateTreatment, String servProviderID) {
        ws_maccabiRequestLiabilityAutoSOAP.IsRequestLiabilityAutoSoap req = new  ws_maccabiRequestLiabilityAutoSOAP.IsRequestLiabilityAutoSoap();
        ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoInput IsRequestLiabilityAutoInput = new ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoInput();
        ws_maccabiRequestLiabilityAuto.ArrayOfCodeConversionString CodeConversions = new ws_maccabiRequestLiabilityAuto.ArrayOfCodeConversionString();
        CodeConversions.CodeConversion = codeConversionArr;
        IsRequestLiabilityAutoInput.PatientID = Integer.valueOf(memberID);
        IsRequestLiabilityAutoInput.PatientIDCode = Integer.valueOf(memberIDCode);
        IsRequestLiabilityAutoInput.DoctorID = Integer.valueOf(doctorId);
        IsRequestLiabilityAutoInput.ReferenceNumber = Integer.valueOf(referralNumber);
        IsRequestLiabilityAutoInput.ServiceProviderID = Integer.valueOf(servProviderID);
        IsRequestLiabilityAutoInput.CodeConversions = CodeConversions;
        IsRequestLiabilityAutoInput.DateTreatment = Integer.valueOf(dateTreatment);//ddmmyyyy
        
        ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput result = req.isRequestLiabilityAuto(IsRequestLiabilityAutoInput);
        return result;
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service to recive commitment meta data
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    memberID                Patient ID number (passport number)
        * @param    codeConversionArr       array of Medical_Procedure__c codes
        * @param    doctorId                File__c.Doctor_ID__c
        * @param    doctorName              DoctorName field from recived referral
        * @param    dateTreatment           Today + 5 days
        * @return   result                  Result of from Maccabi service (0/1/2),
        *                                   method IsLiabilitiesManagementSoap.isLiabilitiesManagement
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput isLiabilitiesManagement(String memberID, String memberIDCode, String doctorId, String doctorName, String [] codeConversionArr, String servProviderID, String typeAction, String guid){
        ws_maccabiIsLiabilitiesManagSOAP.IsLiabilitiesManagementSoap req = new  ws_maccabiIsLiabilitiesManagSOAP.IsLiabilitiesManagementSoap();
        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementInput IsLiabilitiesManagementInput = new ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementInput();   
        ws_maccabiIsLiabilitiesManag.ArrayOfCodeAnalysisAssutaString Codes = new ws_maccabiIsLiabilitiesManag.ArrayOfCodeAnalysisAssutaString();
        Codes.CodeAnalysisAssuta = codeConversionArr;
        IsLiabilitiesManagementInput.TypeAction = typeAction;
        IsLiabilitiesManagementInput.PatientID = Integer.valueOf(memberID);
        IsLiabilitiesManagementInput.PatientIDCode = memberIDCode;
        IsLiabilitiesManagementInput.DoctorID = doctorId;
        IsLiabilitiesManagementInput.NameDoctor = doctorName;
        IsLiabilitiesManagementInput.DateAnalysis = 0;
        IsLiabilitiesManagementInput.Guid = guid;
        IsLiabilitiesManagementInput.ExplanationNote = '';
        IsLiabilitiesManagementInput.ServiceProviderID = Integer.valueOf(servProviderID);
        IsLiabilitiesManagementInput.Codes = Codes; 
            
        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput result = req.isLiabilitiesManagement(IsLiabilitiesManagementInput);
        return result;
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Call maccabi service to check that referral recived by Maccabi
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    memberID                Patient ID number (passport number)
        * @param    referralNum             File__c.ReferralNumber__c
        * @param    app_id                  Id of Appointment__c
        * @param    appDate                 File__c.Date_Time_of_the_appointment__c
        * @return   result                  Metadata of commitment
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput isServiceReturnsAnswers(String memberID, String memberIDCode, String referralNum, Id app_id, Date appDate) {

        ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap isServiceReturnsAns = new ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap();
        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput IsServiceReturnsAnswersInput = new ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput();
        IsServiceReturnsAnswersInput.PatientID = Integer.valueOf(memberID);
        IsServiceReturnsAnswersInput.PatientIDCode = Integer.valueOf(memberIDCode);
        IsServiceReturnsAnswersInput.Guid = memberID + referralNum;

        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput result = isServiceReturnsAns.isServiceReturnsAnswers(IsServiceReturnsAnswersInput);

        Map<String, String> comData = new Map<String, String>();
        System.debug('isServiceReturnsAnswers ErrorCode: '+result.ErrorCode.Trim());
        if(result.ErrorCode.Trim() == '1') {
            update new Appointment__c(Id = app_id, Commitment_Status__c = '6', Number_of_commitment__c = result.LiabilityID);
        } else if(result.ErrorCode.Trim() == '0') {
            comData.put('commitmentStatus', result.ErrorCode.Trim());          
            comData.put('LiabilityID', result.LiabilityID);
            comData.put('Deductible', String.valueOf(result.Deductible));
            comData.put('AmountDoctor', String.valueOf(result.AmountDoctor));
            comData.put('AmountImplants', result.AmountImplants);
            comData.put('appId', String.valueOf(app_id));
            comData.put('DateCreateLiability', result.DateCreateLiability);
            comData.put('DateSofLiability', result.DateSofLiability);
            comData.put('AmountAnesthesiologist', result.AmountAnesthesiologist);
            comData.put('DeductibleHospital', result.DeductibleHospital); 
            comData.put('CommentReplys', convertToArrayOfComment(result.CommentReplys.CommentReply));       
            String[] codeConversionArr = convertToArrayOfCodes(result.CodesConversions.CodeConversion);

            MaccabiIntegration.insertFileCommitment(comData, codeConversionArr);
            update new Appointment__c(Id = app_id, Commitment_Status__c = '0', Number_of_commitment__c = comData.get('LiabilityID'));
        } else if(result.ErrorCode.Trim() == errorCode_9) {
            update new Appointment__c(Id = app_id, Commitment_Status__c = comStatus_9b, Number_of_commitment__c = result.LiabilityID);
        }

        return result;
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Insert Attachment to SF Object 
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    fileId              ParentId of Attachment
        * @param    fileName            the name of attachment
        * @param    attachBody          Content of attachment - type Blob
        * @return   ---                  
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible  
    public static void insertAttachment (Id fileId, String fileName, Blob attachBody, String patientAccId) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = attachBody;
        cv.PathOnClient = fileName+'.pdf';
        cv.Title = fileName;
        cv.IsMaccabiFile__c = true;
        try{
            Database.SaveResult saveResult = Database.insert(cv, false);
            if(saveResult.isSuccess()){
                System.debug('Succsess Insert ContentVersion');
                Id cvId = saveResult.getId();
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvId].ContentDocumentId;
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = fileId;                
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';
                try{
                    Database.SaveResult saveResultcDocLink = Database.insert(cDocLink, false);
                    if(saveResultcDocLink.isSuccess()){
                        System.debug('Succsess Insert ContentDocumentLink ');
                    }else {
                        System.debug('Fail to insert ContentDocumentLink ');
                    }            
                } catch(Exception ex){
                    System.debug('Error - can`t insert ContentDocumentLink: ' + ex);
                } 
            }else {
                System.debug('Fail to insert ContentVersion');
                for(Database.Error err : saveResult.getErrors()) {
                    System.debug('The following error has occurred:');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }            
        } catch(Exception ex){
            System.debug('Error - can`t insert ContentVersion: ' + ex);
            logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'insertAttachment', ex, fileId));    
        }
    }
    @TestVisible    
    public static Id insertFileReferral(Map<String, String> refData, String[] codeConversionArr, String[] descConversionArr) {
        System.debug('insertFileReferral Start: ');  
        Map<String, Schema.RecordTypeInfo> accountRTMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Id reqTypeDoctor = accountRTMap.get('Doctor_Account').getRecordTypeId();
        List<File__c> existFile = [SELECT Id FROM File__c WHERE ReferralNumber__c=:refData.get('referralNumber') AND Account__c=:refData.get('accountID')];
        if(existFile.size() == 0) {
            Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();
            List<Account> doctorId = [SELECT Id FROM Account WHERE DocIDNum__c=:refData.get('doctorIdNum') AND RecordTypeId =:reqTypeDoctor];
            Boolean isIVF = false;
            File__c newFile = new File__c();
                Date refDate = refData.get('refDate') != null ? MaccabiIntegration.dateFormat(refData.get('refDate')) : null;
                newFile.ReferralRequestNumber__c = refData.containsKey ('LiabilityID') && refData.get('LiabilityID') != null ?  refData.get('LiabilityID'): null;
                newFile.ReferralDate__c = refDate;
                newFile.ReferralsExistErrorCode__c = refData.get('referralExistErrCode');
                newFile.ReferralErrorCode__c  = refData.get('referralErrorCode');
                newFile.ReferralNumber__c = refData.get('referralNumber');
                newFile.Referral_Type__c = refData.get('refType');
                newFile.ObligationNumber__c = refData.get('commitmentNum');
                newFile.CommitmentStatus__c = refData.get('commitmentStatus');
                newFile.Appointment__c = refData.get('appId') != null ? Id.valueOf(refData.get('appId')) : null;             
                newFile.file_type__c = '14';
                newFile.Account__c = refData.get('accountID') != null ? refData.get('accountID') : null;
                newFile.Case__c = refData.get('caseID') != null ? refData.get('caseID') : null;
                newFile.Name = refData.get('referralNumber');
                newFile.PayerFactor__c = refData.get('PayerFactor') != null ? Id.valueOf(refData.get('PayerFactor')) : null;
                newFile.DoctorPhoneNumber__c = refData.get('doctorPhoneNumber');
                newFile.DoctorAddress__c = refData.get('doctorAddress');
                newFile.DoctorSpecialization__c = refData.get('doctorSpecialization');
                newFile.ObligationBranch__c = refData.get('ObligationBranch');
                newFile.BranchPhone__c = refData.get('branchPhone');
                newFile.ServiceType__c = refData.get('serviceType');
                newFile.AssutaDeptDescription__c = refData.get('assutaDeptDescription');
                newFile.TreatmentDate__c = refData.get('dateTreatmen');
                newFile.TreatmentInstruction__c = refData.get('treatmentInstruction');
                newFile.Urgency__c = refData.get('urgency');
                newFile.Moked__c = refData.get('moked');
                newFile.Findings__c = refData.get('findings');
                newFile.Complaints__c = refData.get('complaints');
                
                for(Integer i = 0; i < descConversionArr.size();){
                    String fieldValue = descConversionArr[i];
                    i++;
                    String fieldName = 'TreatmentDescription'+ i +'__c';
                    newFile.put(fieldName, fieldValue);
                }
        
                Integer i = 1;
                for(Medical_Procedure__c mp : [SELECT Id, Domain__r.DomainCode__c FROM Medical_Procedure__c WHERE Procedure_Code__c In :codeConversionArr]){
                    if(mp.Domain__r.DomainCode__c == 120){
                        isIVF = true;
                    }
                    String fieldName = 'Medical_Procedure'+ (String.valueOf(i)=='1' ? '' : String.valueOf(i))+'__c';
                    newFile.put(fieldName, mp.Id);
                    i= i+1;
                }
                if(doctorId.size() >0) {
                    newFile.DoctorName__c = doctorId[0].Id;
                } 
                //newFile.DoctorName__c = null;
                newFile.Maccabi_Doctor_License__c = refData.get('doctorLicense');
                newFile.Maccabi_Doctor_Name__c = refData.get('doctorName');
                newFile.Maccabi_Doctor_code__c = refData.get('doctorIdNum');
                          
                if(refData.get('refType').toLowerCase().contains('hospitalization') && refData.get('doctorIdNum').contains('000000000') && !isIVF){
                    newFile.RecordTypeId = fileRTMap.get('Committee_approval').getRecordTypeId();//אישור ועדה 
                }else{
                    newFile.RecordTypeId = fileRTMap.get('Referral').getRecordTypeId();
                }
            try{
                Database.SaveResult saveResult = Database.insert(newFile, false);
                if(saveResult.isSuccess()){
                    Id fileId = saveResult.getId();
                    System.debug('insert file Referral: ' + newFile);                    
                    return fileId;
                }else {
                    for(Database.Error err : saveResult.getErrors()) {
                        System.debug('Fail to insert file Referral:');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Appointment fields that affected this error: ' + err.getFields());
                    }
                } 
            } catch(Exception ex){
                System.debug('Error - can`t insert file Referral: ' + ex); 
                logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'insertFileReferral', ex, refData.get('referralNumber')));     
            }
            return null;
        } else {
            existFile[0].ReferralRequestNumber__c = refData.containsKey ('LiabilityID') && refData.get('LiabilityID') != null ?  refData.get('LiabilityID'): null;
            if(refData.get('parentObjName') == 'Case'){
                existFile[0].Case__c = Id.valueOf(refData.get('caseID'));
            } else if(refData.get('parentObjName') == 'Account') {
                existFile[0].Account__c = Id.valueOf(refData.get('accountID'));
            } else {
                existFile[0].Appointment__c = Id.valueOf(refData.get('appId'));
            }            
            update existFile[0];
            System.debug('Update file Referral: ' + existFile[0]);
            return null;
        }
    }

    public static Id insertFileCommitment(Map<String, String> comData, String[] codeConversionArr) {
        System.debug('insertFileCommitment Start: ');
        Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();
        if([SELECT count() FROM File__c WHERE Appointment__c=:comData.get('appId') AND Number_of_commitment__c=:comData.get('LiabilityID')] == 0) {
            File__c newFile = new File__c();
                newFile.file_type__c = '5';//Commmitment form
                newFile.Referral_Type__c = comData.get('refType');
                newFile.Number_of_commitment__c = comData.get('LiabilityID');
                newFile.Deductibles__c = comData.containsKey('Deductible') && comData.get('Deductible') != null ? Integer.valueOf(comData.get('Deductible')) : null;
                newFile.Refund_for_Doctor__c = comData.containsKey('AmountDoctor') && comData.get('AmountDoctor') != null ? Integer.valueOf(comData.get('AmountDoctor')) : null;
                newFile.Refund_for_Implants__c = comData.containsKey('AmountImplants') && comData.get('AmountImplants') != null ? Integer.valueOf(comData.get('AmountImplants')) : null;
                newFile.Appointment__c = comData.get('appId') != null ? Id.valueOf(comData.get('appId')) : null;
                newFile.ReferralErrorCode__c  = comData.get('referralErrorCode');
                if(comData.containsKey('DateCreateLiability') && comData.get('DateCreateLiability') != null && comData.get('DateCreateLiability').Trim() != '') {
                    Date dateOfComm = MaccabiIntegration.dateFormat(comData.get('DateCreateLiability'));
                    newFile.Date_of_commitment__c = dateOfComm;
                }
                if(comData.containsKey('DateSofLiability') && comData.get('DateSofLiability') != null && comData.get('DateSofLiability').Trim() != '') {
                    Date endDate = MaccabiIntegration.dateFormat(comData.get('DateSofLiability'));
                    newFile.End_Date_Commitment__c = endDate;
                }            
                newFile.CommitmentStatus__c = comData.get('ErrorCode');
                newFile.Commitment_Reason__c = comData.get('DescriptionRemark');
                newFile.Referral_File__c = comData.containsKey('AttachLink') && comData.get('AttachLink') != null ? comData.get('AttachLink'): null;
                newFile.Approved_Amount_Anesthetist__c = comData.containsKey('AmountAnesthesiologist') && comData.get('AmountAnesthesiologist') != null ? Integer.valueOf(comData.get('AmountAnesthesiologist')) : null;
                newFile.Deductibles_Hospitalization__c = comData.containsKey('DeductibleHospital') && comData.get('DeductibleHospital') != null ? Integer.valueOf(comData.get('DeductibleHospital')) : null;
                newFile.Name = comData.get('LiabilityID');
                newFile.PayerFactor__c = comData.containsKey('PayerFactor') && comData.get('PayerFactor') != null ? Id.valueOf(comData.get('PayerFactor')) : null;
                newFile.Account__c = comData.get('accountID') != null ? Id.valueOf(comData.get('accountID')) : null;
                newFile.macabi_failure_detail__c = comData.containsKey('CommentReplys') && comData.get('CommentReplys') != null ? comData.get('CommentReplys') : null;
                Integer i = 1;
                for(Medical_Procedure__c mp : [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c In :codeConversionArr]){
                    String fieldName = 'Medical_Procedure'+ (String.valueOf(i)=='1' ? '' : String.valueOf(i))+'__c';
                    newFile.put(fieldName, mp.Id);
                    i= i+1;
                } 
                newFile.RecordTypeId = fileRTMap.get('Commitment').getRecordTypeId();
            try{
                Database.SaveResult saveResult = Database.insert(newFile, false);
                if(saveResult.isSuccess()){
                    Id fileId = saveResult.getId();
                    System.debug('insert file Commitment: ' + newFile);                    
                    return fileId;
                }else {
                    for(Database.Error err : saveResult.getErrors()) {
                        System.debug('Fail to insert file Commitment:');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Appointment fields that affected this error: ' + err.getFields());
                    }
                    return null;
                }               
            } catch(Exception ex){
                System.debug('Error - can`t insert file Commitment form: ' + ex);
                logs.addAll(LogSettingService.getInstance().prepareLog('MaccabiIntegration', 'insertFileCommitment', ex, comData.get('LiabilityID')));    
                return null;                
            }
        } else{
            System.debug('Insert file Commitment - FILE EXIST');
            return null;
        }
    }

    private static Integer dateSort(String d1, String d2) {
        Date date1 = MaccabiIntegration.dateFormat(d1);
        Date date2 = MaccabiIntegration.dateFormat(d2);
        if (date1 > date2)
            return 1;
        if (date1 == date2)
            return 0;
        return -1;
    }

    public static Map<String, String> createRefData(ws_maccabiHitchayvuyotReferrals.Referral referral) {
        Map<String, String> refData = new Map<String, String>();
                            if(referral.TypeReferral != null && referral.TypeReferral.contains('חיוב ישיר')){
                                refData.put('referralNumber', referral.ObligationNumber.Trim());
                            } else {
                                refData.put('referralNumber', referral.ReferralNumber.Trim());
                            }
                            refData.put('ObligationNumber', referral.ObligationNumber.Trim());
                            refData.put('doctorIdNum', (referral.DoctorID.Trim()));
                            refData.put('refDate', referral.ReferralDate);
                            refData.put('refType', referral.TypeReferral.Trim());                       
                            refData.put('doctorLicense', referral.DoctorLicense.Trim());
                            refData.put('doctorName', referral.DoctorName.reverse());
                            refData.put('dateTreatmen', referral.TreatmentDate);
                            refData.put('commitmentNum', referral.ObligationNumber.Trim());
                            refData.put('doctorPhoneNumber', referral.DoctorPhoneNumber.Trim());
                            refData.put('doctorAddress', referral.DoctorAddress.Trim());
                            refData.put('doctorSpecialization', referral.DoctorSpecialization.Trim());
                            refData.put('ObligationBranch', referral.ObligationBranch.Trim());
                            refData.put('branchPhone', referral.BranchPhone.Trim());
                            refData.put('serviceType', referral.ServiceType.Trim());
                            refData.put('assutaDeptDescription', referral.AssutaDeptDescription.Trim());
                            refData.put('treatmentInstruction', referral.TreatmentInstruction.Trim());
                            refData.put('urgency', referral.Urgency);
                            refData.put('moked', referral.Moked);
                            refData.put('findings', referral.Findings.Trim());
                            refData.put('complaints', referral.Complaints.Trim());
        return refData;
    }
    @TestVisible
    private static Map<String, String> createComData(ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput commitment){
        Map<String, String> comData = new Map<String, String>();
                            comData.put('LiabilityID', commitment.LiabilityID.Trim());
                            comData.put('Deductible', commitment.Deductible);
                            comData.put('AmountDoctor', commitment.AmountDoctor.Trim());
                            comData.put('AmountImplants', commitment.AmountImplants.Trim());
                            comData.put('AttachLink', commitment.AttachLink);
                            comData.put('DateCreateLiability', commitment.DateCreateLiability);
                            comData.put('DateSofLiability', commitment.DateSofLiability);  
                            comData.put('DeductibleHospital', commitment.DeductibleHospital);                          
        return comData;
    }
    @TestVisible
    private static Map<String, String> createComData(ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput commitment){
        Map<String, String> comData = new Map<String, String>();
                            comData.put('commitmentStatus', commitment.ErrorCode.Trim());
                            comData.put('LiabilityID', commitment.LiabilityID);
                            comData.put('Deductible', commitment.Deductible);
                            comData.put('AmountDoctor', commitment.AmountDoctor);
                            comData.put('AmountImplants', commitment.AmountImplants);
                            comData.put('DateCreateLiability', commitment.DateCreateLiability);
                            comData.put('DateSofLiability', commitment.DateSofLiability);
        return comData;
    }

    private static Date dateFormat(String dateStr) { //Format from string mmddyyyy to dd/mm/yyyy
        return date.parse(dateStr.left(2) + '/' + dateStr.mid(2,2) + '/' + dateStr.right(4));
    }

    public static String getLastReferralNumber(List<ws_maccabiHitchayvuyotReferrals.Referral> referrals) {
        ws_maccabiHitchayvuyotReferrals.Referral lastReferral = referrals.get(0);

        for (ws_maccabiHitchayvuyotReferrals.Referral referral_i : referrals) {
            if (MaccabiIntegration.dateSort(lastReferral.ReferralDate, referral_i.ReferralDate) < 0) {
                lastReferral = referral_i;
            }
        }
        System.debug('lastReferral: ' + lastReferral.ReferralNumber.trim());

        return lastReferral.ReferralNumber.trim();
    }

    @TestVisible
    private static Integer getReferralSorted(ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput result, String doctorLicense, String medicalProcedure){
        Integer ii = null;
        Set<String> domainCodes = new Set<String>();
        Map<String, String> domainCodeMap = new Map<String, String>();
        Map<String, String> treatmentsOfRefMap = new  Map<String, String>();
        Map<String, Integer> refTypeMap = new  Map<String, Integer>();
        List<ws_maccabiHitchayvuyotReferrals.Referral> refTypeArr = new List<ws_maccabiHitchayvuyotReferrals.Referral>();
        List<ws_maccabiHitchayvuyotReferrals.Referral> refMatchArr = new List<ws_maccabiHitchayvuyotReferrals.Referral>();
        Map<String, Integer> refMatchMap = new  Map<String, Integer>();

        if(result.Referrals.Referral.size()>=1) {
            for (Integer i=0; i<result.Referrals.Referral.size(); i++) {
                if(MaccabiIntegration.checkRefType(result.Referrals.Referral[i].TypeReferral)){
                    String Treatment = convertToArrayOfCodes(result.Referrals.Referral[i].Treatments).get(0);                    
                    treatmentsOfRefMap.put(result.Referrals.Referral[i].ReferralNumber.Trim(), Treatment);
                    domainCodes.add(Treatment);
                    refTypeArr.add(result.Referrals.Referral[i]);
                    refTypeMap.put(result.Referrals.Referral[i].ReferralNumber.Trim(), i);
                }
            }

            if(refTypeArr.Size()> 0){
                System.debug('refTypeMap: size: ' + refTypeMap.size() + ' values: ' + refTypeMap);
            
                for(Medical_Procedure__c domainCode : [SELECT Id, Domain__r.DomainCode__c, Procedure_Code__c FROM Medical_Procedure__c WHERE Procedure_Code__c IN: domainCodes]){
                    domainCodeMap.put(domainCode.Procedure_Code__c, String.valueOf(domainCode.Domain__r.DomainCode__c));
                }
                System.debug('domainCodeMap ' + domainCodeMap);
                
                for (Integer i=0; i<refTypeArr.size(); i++) {
                    String refDoctorLicense = refTypeArr[i].DoctorLicense.Trim();
                    String docLicense = (refDoctorLicense.length() < 7) ? refDoctorLicense.leftPad(7 ,'0') : refDoctorLicense;
                    if((domainCodeMap.get(treatmentsOfRefMap.get(refTypeArr[i].ReferralNumber.Trim())) == medicalProcedure) && (docLicense == doctorLicense)){
                        System.debug('Have a match');
                        refMatchArr.add(refTypeArr[i]);
                        refMatchMap.put(refTypeArr[i].ReferralNumber.Trim(), refTypeMap.get(refTypeArr[i].ReferralNumber.Trim()));
                    }
                }

                System.debug('refMatchMap: size: ' + refMatchMap.size() + ' values: ' + refMatchMap);
                if (!refMatchArr.isEmpty()) {
                    ii = refMatchMap.get(MaccabiIntegration.getLastReferralNumber(refMatchArr));
                    System.debug('ii ' + ii);
                    return ii;
                }
            }
        }  
        return null;
    }

    private static Boolean checkRefType(String refType) {
        if(refType.toLowerCase().contains('ביצוע פעולה') || refType.toLowerCase().contains('hospitalization') || refType.toLowerCase().contains('חיוב ישיר')){
            System.debug('**checkRefType positive ...');
            return true;
        }
        return false;
    }

    public static String[] convertToArrayOfCodes(ws_maccabiHitchayvuyotReferrals.Treatments[] obj){
        List<String> arrTreatment = new List<String>{};
        for (Integer i = 0; i<obj.size(); i++) {
            if(obj[i].TreatmentCode != null){
                arrTreatment.add(obj[i].TreatmentCode.trim());
            }
        }
        return arrTreatment;
    }

    public static String[] convertToArrayOfCodes(ws_maccabiRequestLiabilityAuto.Treatment[] obj){
        List<String> arrTreatment = new List<String>{};
        for (Integer i = 0; i<obj.size(); i++) {
            if(obj[i].TreatmentCodeCPT != null){
                arrTreatment.add(obj[i].TreatmentCodeCPT.trim());
            }
        }
        return arrTreatment;
    }

    public static String[] convertToArrayOfCodes(String[] CodeConversion){
        List<String> arrTreatment = new List<String>{};
        for (Integer i = 0; i<CodeConversion.size(); i++) {
            if(CodeConversion[i] != null){
                arrTreatment.add(CodeConversion[i].trim());
            }
        }
        return arrTreatment;
    }

    public static String convertToArrayOfComment(String[] CommentReplys){
        String Comment;
        for (Integer i = 0; i< CommentReplys.size(); i++) {
            if(CommentReplys[i] != null){
                if(Comment == null){
                    Comment = CommentReplys[i].trim();
                }else{
                    Comment += '\n,' + CommentReplys[i].trim();
                }
            }
        }
        return Comment;
    }

    public static String[] convertToArrayOfDescription(ws_maccabiHitchayvuyotReferrals.Treatments[] obj){
        List<String> arrTreatmentDes = new List<String>{};
        for (Integer i = 0; i<obj.size(); i++) {
            if(obj[i].TreatmentDescription != null){
                arrTreatmentDes.add(obj[i].TreatmentDescription.trim());
            }
        }
        return arrTreatmentDes;
    }
}