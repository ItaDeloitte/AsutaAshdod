// TEST: IsServiceRetAnswSchedulableBatchTest
global class IsServiceRetAnswSchedulableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    Map<Id, Boolean> apptIdToResend;
    List<AttachmentWrp> attachmentToInsertList = new List<AttachmentWrp>();

    public IsServiceRetAnswSchedulableBatch() {}

    public IsServiceRetAnswSchedulableBatch(Map<Id, Boolean> apptIdToResend) {
        this.apptIdToResend = apptIdToResend;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('IsServiceRetAnswSchedulableBatch ... start');
        if(this.apptIdToResend != null) {
            return Database.getQueryLocator([
                SELECT Id
                     , ID_Type__c
                     , GuidForMaccabi__c
                     , Classification__c
                     , Commitment_Status__c
                     , IdNumberForMaccabi__c
                     , Number_of_commitment__c
                     , Number_Batch_Maccabi__c
                     , LastUpdateMaccabiStatus__c
                  FROM Appointment__c
                 WHERE Id IN :apptIdToResend.keySet()
                   AND Appointment_Date_Time__c >= TODAY
                   AND Help_Parent_Code_in__c = '3'
                   AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed')
                   AND IdNumberForMaccabi__c != null
                   AND ((Classification__c = 'אדום' AND GuidForMaccabi__c != null) OR Classification__c != 'אדום')
                   AND (Commitment_Status__c = '6' OR Commitment_Status__c = '1b')
            ]);
        } else {
            return Database.getQueryLocator([
                SELECT Id
                     , ID_Type__c
                     , GuidForMaccabi__c
                     , Classification__c
                     , Commitment_Status__c
                     , IdNumberForMaccabi__c
                     , Number_of_commitment__c
                     , Number_Batch_Maccabi__c
                     , LastUpdateMaccabiStatus__c
                  FROM Appointment__c
                 WHERE Appointment_Date_Time__c >= TODAY
                   AND Help_Parent_Code_in__c = '3'
                   AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed')
                   AND IdNumberForMaccabi__c != null
                   AND ((Classification__c = 'אדום' AND GuidForMaccabi__c != null) OR Classification__c != 'אדום')
                   AND (Commitment_Status__c = '6' OR Commitment_Status__c = '1b')
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('IsServiceRetAnswSchedulableBatch ... execute');
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

        for (Appointment__c appointment_i : scope) {
            if((this.apptIdToResend == null || (this.apptIdToResend.containsKey(appointment_i.Id) && !this.apptIdToResend.get(appointment_i.Id))) && !isValidMaccabiStatus(appointment_i)) {
                continue;
            }

            appointment_i = this.pulloutIsServiceReturnsAnswers(appointment_i);
            if (appointment_i != null) appointmentToUpdateList.add(appointment_i);
        }

        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);
        AsyncUtil.doUpdate(appointmentToUpdateList);
        insertAttachments();
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('IsServiceRetAnswSchedulableBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new IsServiceRetAnswSchedulableBatch(this.apptIdToResend), 7);
    }

    public Appointment__c pulloutIsServiceReturnsAnswers(Appointment__c appointment) {
        System.debug('IsServiceRetAnswSchedulableBatch.pulloutIsServiceReturnsAnswers ...');
        ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap isServiceReturnsAnswersSoap = new ws_maccabiIsServiceRetAnsSOAP.IsServiceReturnsAnswersSoap();
        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput isServiceReturnsAnswersInput = new ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersInput();
        isServiceReturnsAnswersInput.PatientID = Integer.valueOf(appointment.IdNumberForMaccabi__c);
        isServiceReturnsAnswersInput.PatientIDCode = appointment.ID_Type__c == 'דרכון' ? 9 : 0;
        isServiceReturnsAnswersInput.Guid = appointment.Classification__c == 'אדום' ? appointment.GuidForMaccabi__c : appointment.IdNumberForMaccabi__c + appointment.Number_of_commitment__c;
        ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput result = isServiceReturnsAnswersSoap.isServiceReturnsAnswers(isServiceReturnsAnswersInput);
        Appointment__c appointmentToReturn;

        try {
            System.debug('isServiceReturnsAnswers ErrorCode: ' + result.ErrorCode.trim());

            switch on result.ErrorCode.trim() {
                when '1', '2' {
                    appointmentToReturn = new Appointment__c(
                        Id = appointment.Id,
                        Commitment_Status__c = '6',
                        macabi_failure_detail__c = MaccabiIntegration.convertToArrayOfComment(result.CommentReplys.CommentReply)
                    );
                }
                when '0' {
                    Map<String, String> comDataMap = new Map<String, String>{
                        'commitmentStatus' => result.ErrorCode.trim(),
                        'LiabilityID' => result.LiabilityID,
                        'Deductible' => String.valueOf(result.Deductible),
                        'AmountDoctor' => String.valueOf(result.AmountDoctor),
                        'AmountImplants' => result.AmountImplants,
                        'appId' => String.valueOf(appointment.Id),
                        'DateCreateLiability' => result.DateCreateLiability,
                        'DateSofLiability' => result.DateSofLiability,
                        'AmountAnesthesiologist' => result.AmountAnesthesiologist,
                        'DeductibleHospital' => result.DeductibleHospital
                    };
                    Blob attachBody = Test.isRunningTest() ? Blob.valueOf('sfaewgWRFS') : getDocument(appointment, result.LiabilityID);
                    
                    attachmentToInsertList.add(new AttachmentWrp(
                        comDataMap,
                        'התחייבות',
                        attachBody,
                        appointment.IdNumberForMaccabi__c,
                        result.CodesConversions.CodeConversion
                    ));
                    Decimal deductible = result.Deductible != 0 ? result.Deductible : result.DeductibleHospital != '0.0' ? Decimal.valueOf(result.DeductibleHospital) : result.Deductible;
                    appointmentToReturn = new Appointment__c(Id = appointment.Id, Commitment_Status__c = '0', Deductibles__c = deductible);
                }
                when '9' {
                    appointmentToReturn = new Appointment__c(Id = appointment.Id, Commitment_Status__c = '9b');
                }
            }

            if (appointmentToReturn != null) {
                appointmentToReturn.Number_Batch_Maccabi__c = appointment.Number_Batch_Maccabi__c == null || (this.apptIdToResend != null && this.apptIdToResend.containsKey(appointment.Id) && this.apptIdToResend.get(appointment.Id))? 1 : appointment.Number_Batch_Maccabi__c + 1;
                appointmentToReturn.LastUpdateMaccabiStatus__c = Datetime.now(); 
            }

        } catch(Exception e) {
            System.debug('Error: An exception has been encountered while calling out to IsServiceReturnsAnswers: ' + e.getMessage());
        }

        System.debug('appointmentToReturn: ' + appointmentToReturn);
        return appointmentToReturn;
    }

    @TestVisible
    private Blob getDocument(Appointment__c appointment, String liabilityId) {
        System.debug('IsServiceRetAnswSchedulableBatch.getDocument ...');
        Dom.Document document = new Dom.Document();
        document.load(MaccabiIntegration.isReceiveDocumentFromArc(appointment.IdNumberForMaccabi__c, appointment.ID_Type__c == 'דרכון' ? '9' : '0', liabilityId, false));

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
            MaccabiIntegration.insertAttachment(MaccabiIntegration.insertFileCommitment(attachmantWrp_i.comDataMap, MaccabiIntegration.convertToArrayOfCodes(attachmantWrp_i.CodeConversion))
                                              , attachmantWrp_i.fileName
                                              , attachmantWrp_i.attachBody
                                              , attachmantWrp_i.patientAccId);
        }
    }

    private Boolean isValidMaccabiStatus(Appointment__c appointment) {
        Datetime now = Datetime.now();
        return (appointment.Number_Batch_Maccabi__c >= 1 && appointment.Number_Batch_Maccabi__c <= 6 && appointment.LastUpdateMaccabiStatus__c < now.addMinutes(-20))
            || (appointment.Number_Batch_Maccabi__c >= 7 && appointment.Number_Batch_Maccabi__c <= 9 && appointment.LastUpdateMaccabiStatus__c < now.addHours(-1))
            || (appointment.Number_Batch_Maccabi__c >= 10 && appointment.Number_Batch_Maccabi__c <= 40 && appointment.LastUpdateMaccabiStatus__c < now.addHours(-4))
            || (appointment.Number_Batch_Maccabi__c >= 41 && appointment.Number_Batch_Maccabi__c <= 70 && appointment.LastUpdateMaccabiStatus__c < now.addHours(-12))
            || appointment.Number_Batch_Maccabi__c == null;
    }

    private class AttachmentWrp {
        Map<String, String> comDataMap;
        String fileName;
        Blob attachBody;
        String patientAccId;
        String[] CodeConversion;

        public AttachmentWrp(Map<String, String> comDataMap, String fileName, Blob attachBody, String patientAccId, String[] CodeConversion) {
            this.comDataMap = comDataMap;
            this.attachBody = attachBody;
            this.fileName = fileName;
            this.patientAccId = patientAccId;
            this.CodeConversion = CodeConversion;
        }
    }
}