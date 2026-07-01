@IsTest
global class ws_maccabiIsServiceRetAns_Mock implements WebServiceMock {
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

            ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput RetOutput = new ws_maccabiIsServiceRetAnsOut.IsServiceReturnsAnswersOutput();
            ws_maccabiIsServiceRetAnswer.ResultMessage resMsg = new ws_maccabiIsServiceRetAnswer.ResultMessage();
            resMsg.Message = '';
            resMsg.Description = '';
            resMsg.Code = 1;
            
            String [] CodesConversionsArr = new List<String>();
            CodesConversionsArr.add('28.6');
            CodesConversionsArr.add('28.2');

            String [] CommentReplysArr = new List<String>();
            CommentReplysArr.add('tewst');
            CommentReplysArr.add('test 2');

            ws_maccabiIsServiceRetAnsOut.ArrayOfCommentReplyString CommentReplys = new ws_maccabiIsServiceRetAnsOut.ArrayOfCommentReplyString();
            CommentReplys.CommentReply = CommentReplysArr;
            ws_maccabiIsServiceRetAnsOut.ArrayOfCodeConversionString CodesConversions = new ws_maccabiIsServiceRetAnsOut.ArrayOfCodeConversionString();
            CodesConversions.CodeConversion = CodesConversionsArr;
            ws_maccabiIsServiceRetAnsOut.ArrayOfDescriptionCodeAnalysisString Descriptions = new ws_maccabiIsServiceRetAnsOut.ArrayOfDescriptionCodeAnalysisString();
            Descriptions.DescriptionCodeAnalysis = CommentReplysArr;

            RetOutput.CommentReplys = CommentReplys;
            RetOutput.CodesConversions = CodesConversions;
            RetOutput.Descriptions = Descriptions;
            RetOutput.DeductibleHospital = '20';
            RetOutput.AmountAnesthesiologist = '500';
            RetOutput.DoctorID = 123456789;
            RetOutput.DateAnalysis = 10102019;
            RetOutput.Remark = 'gsgh';
            RetOutput.LiabilityID = '2143556';
            RetOutput.Deductible = 1510;
            RetOutput.AmountDoctor = 300;
            RetOutput.AmountImplants = '10';
            RetOutput.DateCreateLiability = '10102019';
            RetOutput.DateSofLiability = '10102019';
            RetOutput.ErrorCode = '0';

            ws_maccabiIsServiceRetAnsSOAP.isServiceReturnsAnswersResponse_element response_x = new ws_maccabiIsServiceRetAnsSOAP.isServiceReturnsAnswersResponse_element();
            response_x.isServiceReturnsAnswersResult = RetOutput;
            response.put('response_x', (Object)response_x);
    }
}