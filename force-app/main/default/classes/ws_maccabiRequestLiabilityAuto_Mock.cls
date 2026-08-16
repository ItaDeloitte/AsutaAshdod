@IsTest
global class ws_maccabiRequestLiabilityAuto_Mock implements WebServiceMock {
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



            ws_maccabiRequestLiabilityAuto.Treatment[] arrOftreatments= new ws_maccabiRequestLiabilityAuto.Treatment[]{};
            ws_maccabiRequestLiabilityAuto.ArrayOfTreatmentTreatment treatmentsArr= new ws_maccabiRequestLiabilityAuto.ArrayOfTreatmentTreatment();


            ws_maccabiRequestLiabilityAuto.Treatment treatments = new ws_maccabiRequestLiabilityAuto.Treatment();
            treatments.TreatmentCodeCPT = '70.5';
            treatments.DescriptionTreatment = 'shgafdhgf';
            ws_maccabiRequestLiabilityAuto.Treatment treatments1 = new ws_maccabiRequestLiabilityAuto.Treatment();
            treatments1.TreatmentCodeCPT = '67.2';
            treatments1.DescriptionTreatment = 'shgafdhgf';
            ws_maccabiRequestLiabilityAuto.Treatment treatments2 = new ws_maccabiRequestLiabilityAuto.Treatment();
            treatments2.TreatmentCodeCPT = '68.25';
            treatments2.DescriptionTreatment = 'shgafdhgf';
            ws_maccabiRequestLiabilityAuto.Treatment treatments3= new ws_maccabiRequestLiabilityAuto.Treatment();
            treatments3.TreatmentCodeCPT = '10';
            treatments3.DescriptionTreatment = 'shgafdhgf';
            arrOftreatments.add(treatments);
            arrOftreatments.add(treatments1);
            arrOftreatments.add(treatments2);
            arrOftreatments.add(treatments3);

            treatmentsArr.Treatment = arrOftreatments;         
            
            ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput RetOutput = new ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput();
            RetOutput.LiabilityID = '2143556';
            RetOutput.Treatments = treatmentsArr;
            RetOutput.Deductible = 'str';
            RetOutput.AmountDoctor = '500';
            RetOutput.AmountImplants = '10';
            RetOutput.DateSend = 10102019;
            RetOutput.AttachLink = 'str';
            RetOutput.DateCreateLiability = '10102019';
            RetOutput.DateSofLiability = '10102019';
            RetOutput.AmountAnesthesiologist = '1000';
            RetOutput.DeductibleHospital = '1701';
            RetOutput.DescriptionRemark = 'sgdfhhgsfd';
            RetOutput.ErrorCode = '0';

            ws_maccabiRequestLiabilityAutoSOAP.isRequestLiabilityAutoResponse_element response_x = new ws_maccabiRequestLiabilityAutoSOAP.isRequestLiabilityAutoResponse_element();
            response_x.IsRequestLiabilityAutoOutput = RetOutput;
            response.put('response_x', response_x);
           }
}