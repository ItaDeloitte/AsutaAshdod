//ws_IsServiceRetAnsw_Invocable_TEST
global class ws_IsServiceRetAnsw_Batchable implements Database.Batchable<sObject>, Database.AllowsCallouts{


    private List<Appointment__c> appointmentList;

    public ws_IsServiceRetAnsw_Batchable(List<Appointment__c> appList) {
        appointmentList = appList;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<ID> appsId = new Set<ID>();
        for (Appointment__c app : appointmentList){
            appsId.add(app.Id);
        } 
        return DataBase.getQueryLocator([SELECT Id, ID_Type__c, IdNumberForMaccabi__c, Number_of_commitment__c, Commitment_Status__c, Number_Batch_Maccabi__c, GuidForMaccabi__c, Classification__c FROM Appointment__c WHERE Id IN:appsId]);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        system.debug('==========BatchIsRetAns START');
        for (Appointment__c app : scope){ 
            if (app.Commitment_Status__c == '6' || app.Commitment_Status__c == '1b'){
                String idType = app.ID_Type__c == 'דרכון' ? '9' : '0';
                if(app.Number_Batch_Maccabi__c != null){
                    isRetAns(app.IdNumberForMaccabi__c, idType, app.Number_of_commitment__c, app.id, app.Number_Batch_Maccabi__c, app.GuidForMaccabi__c, app.Classification__c);
                }else{
                    isRetAns(app.IdNumberForMaccabi__c, idType, app.Number_of_commitment__c, app.id, 0, app.GuidForMaccabi__c, app.Classification__c);
                }
                
            }            
        } 
    }   

    global void finish(Database.BatchableContext BC) {
        system.debug('==========BatchIsRetAns FINISH');
        // List<Appointment__c> appointmentList = [SELECT Id, IDNumber__c, Number_of_referral__c, Commitment_Status__c, Number_Batch_Maccabi__c FROM Appointment__c WHERE Id IN:appointmentList];
        // List<Appointment__c> appointmentsToVerify = new List<Appointment__c>();
        // Integer waitingMinutes = 10;
        // for (Appointment__c app : appointmentList){
        //     if (app.Commitment_Status__c == '6' || app.Commitment_Status__c == '1b'){
        //         appointmentsToVerify.add(app);
        //         if(app.Number_Batch_Maccabi__c > 6 && app.Number_Batch_Maccabi__c <= 9){
        //             waitingMinutes = 20;
        //         }else if(app.Number_Batch_Maccabi__c > 9 && app.Number_Batch_Maccabi__c <= 12){
        //             waitingMinutes = 60;
        //         }else if(app.Number_Batch_Maccabi__c > 12 && app.Number_Batch_Maccabi__c <= 42){
        //             waitingMinutes = 240;
        //         } else if(app.Number_Batch_Maccabi__c > 42 && app.Number_Batch_Maccabi__c <= 72){
        //             waitingMinutes = 720;
        //         } else if(app.Number_Batch_Maccabi__c > 72){
        //             waitingMinutes = 0;
        //         }
        //     }
        // }


        // if(!appointmentsToVerify.isEmpty() && waitingMinutes != 0){
        //     System.debug('START schedule class ');
        //     ws_IsServiceRetAnsw_Schedule isRetAns = new ws_IsServiceRetAnsw_Schedule(appointmentsToVerify);
        //     DateTime myDateTime = System.now().addMinutes(waitingMinutes);
        //     Integer second = myDateTime.second();
        //     Integer minute = myDateTime.minute();
        //     Integer hour = myDateTime.hour();
        //     Integer day = myDateTime.day();
        //     Integer month = myDateTime.month();
        //     Integer year = myDateTime.year();
        //     String sch = second+' '+minute+' '+hour+' '+day+' '+month+' ? '+year;

        //     System.debug('START schedule class ws_IsServiceRetAnsw_Schedule: '+sch);
        //     String jobID = system.schedule('IsRetAns from batch'+myDateTime, sch, isRetAns);
        //     System.debug('START schedule class ws_IsServiceRetAnsw_Schedule jobID: '+jobID); 
        // }

    }


    public void isRetAns(String memberID, String memberIDCode, String referralNum, Id app_id, Decimal numOfBatch, String guid, String classification){
        ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap isServiceReturnsAns = new ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap();
        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput IsServiceReturnsAnswersInput = new ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput();
        IsServiceReturnsAnswersInput.PatientID = Integer.valueOf(memberID);
        IsServiceReturnsAnswersInput.PatientIDCode = Integer.valueOf(memberIDCode);
        IsServiceReturnsAnswersInput.Guid = classification == 'אדום' ? guid: memberID + referralNum;

        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput result = isServiceReturnsAns.isServiceReturnsAnswers(IsServiceReturnsAnswersInput);

        Map<String, String> comData = new Map<String, String>();
        try{
            System.debug('isServiceReturnsAnswers ErrorCode: '+result.ErrorCode.Trim());
            if(result.ErrorCode.Trim() == '1' || result.ErrorCode.Trim() == '2') {
                update new Appointment__c(Id = app_id, Commitment_Status__c = '6', Number_Batch_Maccabi__c = numOfBatch+1, macabi_failure_detail__c = MaccabiIntegration.convertToArrayOfComment(result.CommentReplys.CommentReply));

            } else if(result.ErrorCode.Trim() == '0') {    
                Blob attachContent = !Test.isRunningTest() ? getDocument(memberID, memberIDCode, result.LiabilityID) : Blob.valueOf('sfaewgWRFS');    
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
                String[] codeConversionArr = MaccabiIntegration.convertToArrayOfCodes(result.CodesConversions.CodeConversion);
    
                Id fileId = MaccabiIntegration.insertFileCommitment(comData, codeConversionArr);
                MaccabiIntegration.insertAttachment(fileId, 'התחייבות', attachContent, memberID);
                update new Appointment__c(Id = app_id, Commitment_Status__c = '0');
            } else if(result.ErrorCode.Trim() == '9') {
                update new Appointment__c(Id = app_id, Commitment_Status__c = '9b');
            }
        }catch(exception e){
            System.debug('Error: An exception has been encountered while calling out to IsServiceReturnsAnswers:  ' + e.getMessage());
        }
    }

    @TestVisible
    private static Blob getDocument(String memberID, String memberIDCode, String LiabilityID){
        Blob attachContent = Blob.valueOf('');
        String resultIsReceiveDocFromArc = MaccabiIntegration.isReceiveDocumentFromArc (memberID, memberIDCode, LiabilityID, false);            
        Dom.Document doc = new Dom.Document();
        doc.load(resultIsReceiveDocFromArc);
        String errorCode = doc.getRootElement().getChildElement('ErrorCode', null).getText();
        System.debug('isReceiveDocumentFromArc From Batch: '+ errorCode);
        if(errorCode.Trim() == '0'){
            return attachContent = EncodingUtil.base64Decode(doc.getRootElement().getChildElement('RepresentationOfTheFile', null).getText());
        }
        return null;
    }
}