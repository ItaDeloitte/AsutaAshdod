@isTest
private class DemographyExtendedTest {
    
    @isTest
    static void DemographyExtendedTest() {
        DemographyExtended.InfoSorceSystem sorceSystem = new DemographyExtended.InfoSorceSystem();
        sorceSystem.SorceSysCode = 'sys code';
        sorceSystem.QueryStatus = 'query status';
        sorceSystem.ErrorMessage = 'error message';
        sorceSystem.ErrorCode = 'error code';
        
        DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem arraySorceSystem = new DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem();
        arraySorceSystem.InfoSorceSystem = new List<DemographyExtended.InfoSorceSystem>{sorceSystem};
            
            DemographyExtended.AddressExtended address = new DemographyExtended.AddressExtended();
        address.StateName = 'StateName';
        address.Street = 'Street';
        address.HouseNumber = 'HouseNumber';
        address.Apartment = 'Apartment';
        address.CityCode = 'CityCode';
        address.City = 'City';
        address.ZipCode = 'ZipCode';
        
        DemographyExtended.Disabilities disabilities = new DemographyExtended.Disabilities();
        
        DemographyExtended.MemberInsuranceExtended insurer = new DemographyExtended.MemberInsuranceExtended();
        insurer.IsInsuranceExist = 'IsInsuranceExist';
        insurer.StartDate = Date.today();
        insurer.EndDate = Date.today();
        insurer.Code = 'Code';
        insurer.SickFundDesc = 'SickFundDesc';
        
        DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended arrayInsurer = new DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended();
        arrayInsurer.MemberInsuranceExtended = new List<DemographyExtended.MemberInsuranceExtended>{insurer};
            
            DemographyExtended.ArrayOfAdditionalHealthServiceItemLong healthService = new DemographyExtended.ArrayOfAdditionalHealthServiceItemLong();
        healthService.AdditionalHealthServiceItem = new List<Long>{1};
            
            DemographyExtended.ResultMessge resultMessge = new DemographyExtended.ResultMessge();
        resultMessge.Status = 'Status';
        resultMessge.ErrorDescription = 'ErrorDescription';
        resultMessge.ErrorCode = 1;
        
        DemographyExtended.PatientDemographicExtended patient = new DemographyExtended.PatientDemographicExtended();
        patient.IsDemographyExist = 1;
        patient.PatientID = 'PatientID';
        patient.FirstName = 'FirstName';
        patient.LastName = 'LastName';
        patient.PrimaryLanguage = 'PrimaryLanguage';
        patient.IdType = 1;
        patient.CellNumber = 'CellNumber';
        patient.HomeNumber = 'HomeNumber';
        patient.WorkNumber = 'WorkNumber';
        patient.Fax = 'Fax';
        patient.Email = 'Email';
        patient.HMOCode = 1;
        patient.BirthDate = 'BirthDate';
        patient.Gender = 'Gender';
        patient.Address = address;
        patient.Disabilities = disabilities;
        patient.InfoSorceSystems = arraySorceSystem;
        patient.MemberInsurances = arrayInsurer;
        patient.ResultMessage = resultMessge;
        patient.IdentificationCode = 'IdentificationCode';
        patient.UserSecurityAreaLevel = 'UserSecurityAreaLevel';
        patient.AdditionalHealthService = healthService;
        patient.BeginMembership = Date.today();
        patient.IsEligble = true;
        
        DemographyExtended.GetCombinedDemographyResponse_element response = new DemographyExtended.GetCombinedDemographyResponse_element();
        response.GetCombinedDemographyResult = patient;
        
        DemographyExtended.Patient_Disability disability = new DemographyExtended.Patient_Disability();
        disability.Dis_Code = 'test';
        disability.Dis_Desc = 'test';
        disability.Date_Of_Disability = 'test';
        disability.Side_Code = 'test';
        disability.Side_Desc = 'test';
        disability.Permanence = 'test';
        disability.Disability_Remark = 'test';
        
        DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability arrayDisability = new DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability();
        arrayDisability.Patient_Disability = new List<DemographyExtended.Patient_Disability>{disability};
        
        DemographyExtended.Patient_Assist assist = new DemographyExtended.Patient_Assist();
        assist.Assist_Code = 'test';
        assist.Assist_Desc = 'test';
        assist.Date_Of_Assist = 'test';
        assist.Assist_Remark = 'test';
        
        DemographyExtended.ArrayOfPatient_AssistPatient_Assist arrayAssist = new DemographyExtended.ArrayOfPatient_AssistPatient_Assist();
        arrayAssist.Patient_Assist = new List<DemographyExtended.Patient_Assist>{assist};
            
        DemographyExtended.PatientDemographicRequest patientRequest = new DemographyExtended.PatientDemographicRequest(); {
        	patientRequest.PatientID = 'test';
            patientRequest.IdType = 1;
            patientRequest.HMOCode = 1;
            patientRequest.BirthDate = 'test';
            patientRequest.SourceSysNo = 1;
            patientRequest.GetADdata = true;
        }
    }
    
    @isTest
    static void ws_DemographyExtendedTest() {
        ws_DemographyExtended.InfoSorceSystem sorceSystem1 = new ws_DemographyExtended.InfoSorceSystem();
        sorceSystem1.SorceSysCode = 'sys code';
        sorceSystem1.QueryStatus = 'query status';
        sorceSystem1.ErrorMessage = 'error message';
        sorceSystem1.ErrorCode = 'error code';
        
        DemographyExtended.InfoSorceSystem sorceSystem = new DemographyExtended.InfoSorceSystem();
        sorceSystem.SorceSysCode = 'sys code';
        sorceSystem.QueryStatus = 'query status';
        sorceSystem.ErrorMessage = 'error message';
        sorceSystem.ErrorCode = 'error code';
        
        ws_DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem arraySorceSystem = new ws_DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem();
        arraySorceSystem.InfoSorceSystem = new List<DemographyExtended.InfoSorceSystem>{sorceSystem};
            
            ws_DemographyExtended.AddressExtended address = new ws_DemographyExtended.AddressExtended();
        address.StateName = 'StateName';
        address.Street = 'Street';
        address.HouseNumber = 'HouseNumber';
        address.Apartment = 'Apartment';
        address.CityCode = 'CityCode';
        address.City = 'City';
        address.ZipCode = 'ZipCode';
        
        ws_DemographyExtended.Disabilities disabilities = new ws_DemographyExtended.Disabilities();
        
        ws_DemographyExtended.MemberInsuranceExtended insurer = new ws_DemographyExtended.MemberInsuranceExtended();
        insurer.IsInsuranceExist = 'IsInsuranceExist';
        insurer.StartDate = Date.today();
        insurer.EndDate = Date.today();
        insurer.Code = 'Code';
        insurer.SickFundDesc = 'SickFundDesc';
        
        ws_DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended arrayInsurer = new ws_DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended();
        arrayInsurer.MemberInsuranceExtended = new List<ws_DemographyExtended.MemberInsuranceExtended>{insurer};
            
            ws_DemographyExtended.ArrayOfAdditionalHealthServiceItemLong healthService = new ws_DemographyExtended.ArrayOfAdditionalHealthServiceItemLong();
        healthService.AdditionalHealthServiceItem = new List<Long>{1};
            
            ws_DemographyExtended.ResultMessge resultMessge = new ws_DemographyExtended.ResultMessge();
        resultMessge.Status = 'Status';
        resultMessge.ErrorDescription = 'ErrorDescription';
        resultMessge.ErrorCode = 1;
        
        ws_DemographyExtended.PatientDemographicExtended patient = new ws_DemographyExtended.PatientDemographicExtended();
        patient.IsDemographyExist = 1;
        patient.PatientID = 'PatientID';
        patient.FirstName = 'FirstName';
        patient.LastName = 'LastName';
        patient.PrimaryLanguage = 'PrimaryLanguage';
        patient.IdType = 1;
        patient.CellNumber = 'CellNumber';
        patient.HomeNumber = 'HomeNumber';
        patient.WorkNumber = 'WorkNumber';
        patient.Fax = 'Fax';
        patient.Email = 'Email';
        patient.HMOCode = 1;
        patient.BirthDate = 'BirthDate';
        patient.Gender = 'Gender';
        patient.Address = address;
        patient.Disabilities = disabilities;
        patient.InfoSorceSystems = arraySorceSystem;
        patient.MemberInsurances = arrayInsurer;
        patient.ResultMessage = resultMessge;
        patient.IdentificationCode = 'IdentificationCode';
        patient.UserSecurityAreaLevel = 'UserSecurityAreaLevel';
        patient.AdditionalHealthService = healthService;
        patient.BeginMembership = String.valueOf(Date.today());
        patient.IsEligble = true;
        
        ws_DemographyExtended.GetCombinedDemographyResponse_element response = new ws_DemographyExtended.GetCombinedDemographyResponse_element();
        response.GetCombinedDemographyResult = patient;
        
        ws_DemographyExtended.Patient_Disability disability = new ws_DemographyExtended.Patient_Disability();
        disability.Dis_Code = 'test';
        disability.Dis_Desc = 'test';
        disability.Date_Of_Disability = 'test';
        disability.Side_Code = 'test';
        disability.Side_Desc = 'test';
        disability.Permanence = 'test';
        disability.Disability_Remark = 'test';
        
        ws_DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability arrayDisability = new ws_DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability();
        arrayDisability.Patient_Disability = new List<ws_DemographyExtended.Patient_Disability>{disability};
        
        ws_DemographyExtended.Patient_Assist assist = new ws_DemographyExtended.Patient_Assist();
        assist.Assist_Code = 'test';
        assist.Assist_Desc = 'test';
        assist.Date_Of_Assist = 'test';
        assist.Assist_Remark = 'test';
        
        ws_DemographyExtended.ArrayOfPatient_AssistPatient_Assist arrayAssist = new ws_DemographyExtended.ArrayOfPatient_AssistPatient_Assist();
        arrayAssist.Patient_Assist = new List<ws_DemographyExtended.Patient_Assist>{assist};
            
        ws_DemographyExtended.PatientDemographicRequest patientRequest = new ws_DemographyExtended.PatientDemographicRequest(); {
        	patientRequest.PatientID = 'test';
            patientRequest.IdType = 1;
            patientRequest.HMOCode = 1;
            patientRequest.BirthDate = 'test';
            patientRequest.SourceSysNo = 1;
            patientRequest.GetADdata = true;
        }
        
        ws_DemographyExtended.GetCombinedDemography_element getDemography = new ws_DemographyExtended.GetCombinedDemography_element();
        getDemography.pRequest = patientRequest;
    }
    
    @isTest
    static void ws_DemographyReqTest() {
        ws_DemographyReq.InfoSorceSystem sorceSystem = new ws_DemographyReq.InfoSorceSystem();
        sorceSystem.SorceSysCode = 'sys code';
        sorceSystem.QueryStatus = 'query status';
        sorceSystem.ErrorMessage = 'error message';
        sorceSystem.ErrorCode = 'error code';
        
        ws_DemographyReq.ArrayOfInfoSorceSystemInfoSorceSystem arraySorceSystem = new ws_DemographyReq.ArrayOfInfoSorceSystemInfoSorceSystem();
        arraySorceSystem.InfoSorceSystem = new List<ws_DemographyReq.InfoSorceSystem>{sorceSystem};
            
            ws_DemographyReq.Address address = new ws_DemographyReq.Address();
        address.Street = 'Street';
        address.HouseNumber = 'HouseNumber';
        address.Apartment = 'Apartment';
        address.CityCode = 'CityCode';
        address.City = 'City';
        address.ZipCode = 'ZipCode';
        
        ws_DemographyReq.Disabilities disabilities = new ws_DemographyReq.Disabilities();
        
        ws_DemographyReq.MemberInsurance insurer = new ws_DemographyReq.MemberInsurance();
        insurer.IsInsuranceExist = 1;
        insurer.StartDate = Date.today();
        insurer.EndDate = Date.today();
        insurer.Code = 1;
        
        ws_DemographyReq.ArrayOfMemberInsuranceMemberInsurance arrayInsurer = new ws_DemographyReq.ArrayOfMemberInsuranceMemberInsurance();
        arrayInsurer.MemberInsurance = new List<ws_DemographyReq.MemberInsurance>{insurer};
            
            ws_DemographyReq.ResultMessge resultMessge = new ws_DemographyReq.ResultMessge();
        resultMessge.Status = 'Status';
        resultMessge.ErrorDescription = 'ErrorDescription';
        resultMessge.ErrorCode = 1;
        
        ws_DemographyReq.PatientDemographicResponse patient = new ws_DemographyReq.PatientDemographicResponse();
        patient.IsDemographyExist = 1;
        patient.PatientID = 'PatientID';
        patient.FirstName = 'FirstName';
        patient.LastName = 'LastName';
        patient.IdType = 1;
        patient.MobileNum = 'CellNumber';
        patient.OtherPhoneNum = 'HomeNumber';
        patient.Email = 'Email';
        patient.HMOCode = 1;
        patient.BirthDate = 'BirthDate';
        patient.Gender = 'Gender';
        patient.Address = address;
        patient.Disabilities = disabilities;
        patient.InfoSorceSystems = arraySorceSystem;
        patient.MemberInsurances = arrayInsurer;
        patient.ResultMessage = resultMessge;
        patient.IdentificationCode = 'IdentificationCode';
        patient.UserSecurityAreaLevel = 'UserSecurityAreaLevel';
        
        ws_DemographyReq.GetCombinedDemographyResponse_element response = new ws_DemographyReq.GetCombinedDemographyResponse_element();
        response.GetCombinedDemographyResult = patient;
        
        ws_DemographyReq.Patient_Disability disability = new ws_DemographyReq.Patient_Disability();
        disability.Dis_Code = 'test';
        disability.Dis_Desc = 'test';
        disability.Date_Of_Disability = 'test';
        disability.Side_Code = 'test';
        disability.Side_Desc = 'test';
        disability.Permanence = 'test';
        disability.Disability_Remark = 'test';
        
        ws_DemographyReq.ArrayOfPatient_DisabilityPatient_Disability arrayDisability = new ws_DemographyReq.ArrayOfPatient_DisabilityPatient_Disability();
        arrayDisability.Patient_Disability = new List<ws_DemographyReq.Patient_Disability>{disability};
        
        ws_DemographyReq.Patient_Assist assist = new ws_DemographyReq.Patient_Assist();
        assist.Assist_Code = 'test';
        assist.Assist_Desc = 'test';
        assist.Date_Of_Assist = 'test';
        assist.Assist_Remark = 'test';
        
        ws_DemographyReq.ArrayOfPatient_AssistPatient_Assist arrayAssist = new ws_DemographyReq.ArrayOfPatient_AssistPatient_Assist();
        arrayAssist.Patient_Assist = new List<ws_DemographyReq.Patient_Assist>{assist};
            
        ws_DemographyReq.PatientDemographicRequest patientRequest = new ws_DemographyReq.PatientDemographicRequest(); {
        	patientRequest.PatientID = 'test';
            patientRequest.IdType = 1;
            patientRequest.HMOCode = 1;
            patientRequest.BirthDate = 'test';
            patientRequest.SourceSysNo = 1;
            patientRequest.GetADdata = true;
        }
        
        ws_DemographyReq.GetCombinedDemography_element getDemography = new ws_DemographyReq.GetCombinedDemography_element();
        getDemography.pRequest = patientRequest;
    }
}