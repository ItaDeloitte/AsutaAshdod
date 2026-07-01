@IsTest
global class ws_maccabiRetrievingServiceRef_Mock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

        ws_maccabiHitchayvuyotReferrals.Treatments[] arrOftreatments= new ws_maccabiHitchayvuyotReferrals.Treatments[]{};
        ws_maccabiHitchayvuyotReferrals.Treatments treatments = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments.TreatmentCode = '70.5';
        treatments.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments1 = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments1.TreatmentCode = '67.2';
        treatments1.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments2 = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments2.TreatmentCode = '68.25';
        treatments2.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments3= new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments3.TreatmentCode = '10';
        treatments3.TreatmentDescription = 'shgafdhgf';
        arrOftreatments.add(treatments);
        arrOftreatments.add(treatments1);
        arrOftreatments.add(treatments2);
        arrOftreatments.add(treatments3);

        ws_maccabiHitchayvuyotReferrals.Referral ref = new ws_maccabiHitchayvuyotReferrals.Referral();
            ref.DoctorID = '999228083';
            ref.DoctorName = 'היעשי הירא';
            ref.DoctorPhoneNumber = 'str';
            ref.DoctorAddress = 'str';
            ref.DoctorSpecialization = 'str';
            ref.DoctorLicense = '0000111';
            ref.ReferralDate = '05052018';
            ref.ReferralNumber = '125487952';
            ref.ObligationNumber = '0';
            ref.ObligationBranch = 'str';
            ref.BranchPhone = 'str';
            ref.ServiceType = 'str';
            ref.AssutaDeptDescription = 'str';
            ref.TreatmentDate = '10102019';
            ref.TreatmentInstruction = 'str';
            ref.TypeReferral = 'Hospitalization	';
            ref.Urgency = 'str';
            ref.Moked = 'str';
            ref.Findings = 'str';
            ref.Complaints = 'str';
            ref.Treatments = arrOftreatments;
        ws_maccabiHitchayvuyotReferrals.Referral[] Referral = new ws_maccabiHitchayvuyotReferrals.Referral[]{};
            Referral.add(ref);
            Referral.add(ref);
        ws_maccabiHitchayvuyotReferrals.ArrayOfReferralReferral arrRef = new ws_maccabiHitchayvuyotReferrals.ArrayOfReferralReferral();
            arrRef.Referral = Referral;
        ws_maccabiHitchayvuyotLiabilityAuto.ResultMessage resMessage = new ws_maccabiHitchayvuyotLiabilityAuto.ResultMessage();
            resMessage.Message = '';
            resMessage.Description = '';
            resMessage.Code = 0;
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput RetOutput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput();
            RetOutput.ErrorCode = '000';
            RetOutput.Referrals = arrRef;
            RetOutput.ResultMessage = resMessage;
        ws_maccabiRetrievingServiceReferralsSOAP.retrievingServiceReferralsResponse_element response_x = new ws_maccabiRetrievingServiceReferralsSOAP.retrievingServiceReferralsResponse_element();
            response_x.RetrievingServiceReferralsOutput = RetOutput;
            
        response.put('response_x', response_x); 
   }
}