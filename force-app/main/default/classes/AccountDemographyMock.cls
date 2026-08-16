@isTest
global class AccountDemographyMock implements WebServiceMock {
    
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        System.debug('REQUEST INSTANCE '+ request);
        if (request instanceof ws_CreatePatient.CreateAssutaPatientResponse_element || request instanceof ws_CreatePatient.CreateAssutaPatient_element) {
            System.debug('request instanceof ws_CreatePatient.CreateAssutaPatientResponse_element || request instanceof ws_CreatePatient.CreateAssutaPatient_element');
            ws_CreatePatient.InfoSorceSystem infoSystem = new ws_CreatePatient.InfoSorceSystem();
            infoSystem.SysCode = 'SysCode';
            infoSystem.Success = true;
            infoSystem.ErrorMessage = 'ErrorMessage';

            ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem arrauInfoSys = new ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem();
            arrauInfoSys.InfoSorceSystem = new List<ws_CreatePatient.InfoSorceSystem>{infoSystem};
                
            ws_CreatePatient.CreatePatientResponse assutePatientResult = new ws_CreatePatient.CreatePatientResponse();
            assutePatientResult.SMSSendSuccess = false;
            assutePatientResult.SMSSendErrorDescription = 'test failed MOCK ws_CreatePatient';
            assutePatientResult.PasswordText = 'test';
            assutePatientResult.InfoSorceSystems = arrauInfoSys;
            
            ws_CreatePatient.CreateAssutaPatientResponse_element response_x = new ws_CreatePatient.CreateAssutaPatientResponse_element();
            response_x.CreateAssutaPatientResult = assutePatientResult;
            response.put('response_x', response_x);
        } else if (request instanceof ws_DemographyExtended.GetCombinedDemographyResponse_element || request instanceof ws_DemographyExtended.GetCombinedDemography_element) {
            System.debug('request instanceof ws_DemographyExtended.GetCombinedDemographyResponse_element || request instanceof ws_DemographyExtended.GetCombinedDemography_element');
            ws_DemographyExtended.AddressExtended address = new ws_DemographyExtended.AddressExtended();
            address.ZipCode = '123456';
            address.StateName = 'Israel';
            address.City = 'test';
            address.Street = 'test st.';
            address.HouseNumber = '10';
            address.Apartment = '2';
            
            /*ws_DemographyExtended.Patient_Disability disability = new ws_DemographyExtended.Patient_Disability();
            disability.Dis_Code = '10';
            disability.Dis_Desc = 'test';
            disability.Date_Of_Disability = '2019-01-01';
            disability.Permanence = 'P';
            disability.Disability_Remark = 'test';
            disability.Side_Code = 'RIGHT';
            ws_DemographyExtended.Patient_Assist assistance = new ws_DemographyExtended.Patient_Assist();
            assistance.Assist_Code = '10';
            assistance.Assist_Desc = 'test';
            assistance.Date_Of_Assist = '2019-01-01';
            assistance.Assist_Remark = 'test';*/
            
            /*ws_DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability disabilityDisability = new ws_DemographyExtended.ArrayOfPatient_DisabilityPatient_Disability();
            disabilityDisability.Patient_Disability = new List<ws_DemographyExtended.Patient_Disability>{disability};
            ws_DemographyExtended.ArrayOfPatient_AssistPatient_Assist disabilityAssistance = new ws_DemographyExtended.ArrayOfPatient_AssistPatient_Assist();
            disabilityAssistance.Patient_Assist = new List<ws_DemographyExtended.Patient_Assist>{assistance};
                
            ws_DemographyExtended.Disabilities disabilities = new ws_DemographyExtended.Disabilities();
            disabilities.Patient_Assistance = disabilityAssistance;
            disabilities.Patient_Disabilities = disabilityDisability;*/
            
            DemographyExtended.InfoSorceSystem infoSystem = new DemographyExtended.InfoSorceSystem();
            infoSystem.SorceSysCode = 'SorceSysCode';
            infoSystem.QueryStatus = 'QueryStatus';
            infoSystem.ErrorMessage = 'ErrorMessage';
            infoSystem.ErrorCode = 'ErrorCode';
            
            ws_DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem infoSystemsArray = new ws_DemographyExtended.ArrayOfInfoSorceSystemInfoSorceSystem();
            infoSystemsArray.InfoSorceSystem = new List<DemographyExtended.InfoSorceSystem>{infoSystem};

            //*    
            ws_DemographyExtended.MemberInsuranceExtended insurance = new ws_DemographyExtended.MemberInsuranceExtended();   
            insurance.IsInsuranceExist = '1';
            insurance.StartDate = Date.valueOf('2019-05-05');
            insurance.EndDate = Date.valueOf('2019-12-05');
            insurance.Code = '2';
            insurance.SickFundDesc = 'sfd';
            
            ws_DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended memberInsurancesArray = new ws_DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended();
            memberInsurancesArray.MemberInsuranceExtended = new List<ws_DemographyExtended.MemberInsuranceExtended>{insurance};    

            //*
            ws_DemographyExtended.ResultMessge result = new ws_DemographyExtended.ResultMessge();
            result.Status = '1';
            result.ErrorDescription = 'test failed ws_DemographyExtended';
            result.ErrorCode = 1;
            //*

            ws_DemographyExtended.ArrayOfAdditionalHealthServiceItemLong healthServiceItemLongArray = new ws_DemographyExtended.ArrayOfAdditionalHealthServiceItemLong();
            healthServiceItemLongArray.AdditionalHealthServiceItem = new List<Long>{1};
            //healthServiceItemLongArray.AdditionalHealthServiceItem = new List<ArrayOfAdditionalHealthServiceItemLong.AdditionalHealthServiceItem>();
            
            ws_DemographyExtended.PatientDemographicExtended patientDemography = new ws_DemographyExtended.PatientDemographicExtended();
            patientDemography.IsDemographyExist = Long.valueOf('1');
            patientDemography.PatientID = '999089717';
            patientDemography.FirstName = 'firstName';
            patientDemography.LastName = 'lastName';
            patientDemography.PrimaryLanguage = 'אנגלית';
            patientDemography.IdType = Long.valueOf('1');
            patientDemography.CellNumber = '0';
            patientDemography.HomeNumber = '50-142574';
            patientDemography.WorkNumber = '50-142574';
            patientDemography.Fax = '50-142574';
            patientDemography.Email = 'test@te.st';
            patientDemography.HMOCode = Long.valueOf('2');
            patientDemography.BirthDate = '1998-01-01';
            patientDemography.Gender = 'ז';
            patientDemography.Address = address;
            //patientDemography.Disabilities = disabilities;
            patientDemography.InfoSorceSystems = infoSystemsArray;
            //public ws_DemographyExtended.ArrayOfMemberInsuranceExtendedMemberInsuranceExtended MemberInsurances;
            patientDemography.MemberInsurances = memberInsurancesArray;
            //public ws_DemographyExtended.ResultMessge ResultMessage;
            patientDemography.ResultMessage = result;
            patientDemography.IdentificationCode = '1';
            patientDemography.UserSecurityAreaLevel = '1';
            //public ws_DemographyExtended.ArrayOfAdditionalHealthServiceItemLong AdditionalHealthService;
            patientDemography.AdditionalHealthService = healthServiceItemLongArray;
            patientDemography.BeginMembership = 'test';
            patientDemography.IsEligble = true;

            ws_DemographyExtended.GetCombinedDemographyResponse_element response_x = new ws_DemographyExtended.GetCombinedDemographyResponse_element();
            response_x.GetCombinedDemographyResult = patientDemography;
            response.put('response_x', response_x); 
        } 
        // ws_AppointmentNew
        else if (request instanceof ws_AppointmentNew.CancelAppointmentResponse_element || request instanceof ws_AppointmentNew.CancelAppointment_element) {
        	System.debug('request instanceof ws_AppointmentNew.CancelAppointmentResponse_element');
           /* ws_AppointmentNew.CancelAppointmentDetails appDetails = new ws_AppointmentNew.CancelAppointmentDetails();
            appDetails.ProcessId = '001';
            appDetails.UserId = '0001';
            appDetails.CancelationReasonCode = '0';*/
            
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = Date.today();
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';
            
            ws_AppointmentNew.CancelAppointmentResponse resp = new ws_AppointmentNew.CancelAppointmentResponse();
            resp.CancelAppointmentResult = result;

            ws_AppointmentNew.CancelAppointmentResponse_element response_x = new ws_AppointmentNew.CancelAppointmentResponse_element();
            response_x.CancelAppointmentResult = resp;
            response.put('response_x', response_x);

        } else if (request instanceof ws_AppointmentNew.AppointmentSearch_element) {
            System.debug('request instanceof ws_Appointment.AppointmentSearch_element');

            // for AppointmentSearchResponse
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = Date.today();
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';

            ws_AppointmentNew.CalenderSlot calendar = new ws_AppointmentNew.CalenderSlot();
            calendar.SlotId = 1;
            calendar.StartTime = DateTime.newInstance(2019, 6, 7, 3,1,5);
            calendar.EndTime = DateTime.newInstance(2019, 7, 7, 3,1,5);
            calendar.Duration = 2;
            calendar.ModalityCode = 1;
            calendar.AppointmentTypeId = '1';
            calendar.UnitCode = 1;
            calendar.CalendarId = 1;            
            ws_AppointmentNew.ArrayOfCalenderSlotCalenderSlot calendarArr = new ws_AppointmentNew.ArrayOfCalenderSlotCalenderSlot();
            calendarArr.CalenderSlot = new List<ws_AppointmentNew.CalenderSlot>{calendar};
                
            ws_AppointmentNew.ArrayOfDeclinedSitesItemString declinedSites = new ws_AppointmentNew.ArrayOfDeclinedSitesItemString();
            declinedSites.DeclinedSitesItem = new List<String>{'20'};
            
            ws_AppointmentNew.Agreement agreement = new ws_AppointmentNew.Agreement();
            agreement.IsAgreementExists = true;
            agreement.DeclinedSites = declinedSites;

            ws_AppointmentNew.AppointmentSearchResponse resp = new ws_AppointmentNew.AppointmentSearchResponse();
            resp.AppointmentSearchResult = result;
            resp.CalenderSlots = calendarArr;
            resp.Agreements = agreement;

            ws_AppointmentNew.AppointmentSearchResponse_element response_x = new  ws_AppointmentNew.AppointmentSearchResponse_element();
            response_x.AppointmentSearchResult = resp;
            response.put('response_x', response_x);
        }  else if (request instanceof ws_AppointmentNew.LockSlotResponse_element || request instanceof ws_AppointmentNew.LockSlot_element) {  
            System.debug('request instanceof ws_AppointmentNew.LockSlotResponse_element || request instanceof ws_AppointmentNew.LockSlot_element');         
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = result.DateSent = DateTime.newInstance(2019, 6, 7, 3,1,5);
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';

            ws_AppointmentNew.LockSlotResponse resp = new ws_AppointmentNew.LockSlotResponse();
            resp.ExtCalendarId = '1';
            resp.SlotLockId = '1';
            resp.LockDurationMinutes = 1;
            resp.LockExpirationDate = result.DateSent = DateTime.newInstance(2019, 7, 7, 3,1,5);
            resp.LockSlotResult = result;

            ws_AppointmentNew.LockSlotResponse_element response_x = new ws_AppointmentNew.LockSlotResponse_element();
            response_x.LockSlotResult = resp;
            response.put('response_x', response_x);
        } else if(request instanceof ws_AppointmentNew.UnLockSlot_element || request instanceof ws_AppointmentNew.UnLockSlotResponse_element) {
            System.debug('request instanceof ws_AppointmentNew.UnLockSlot_element || request instanceof ws_AppointmentNew.ws_AppointmentNew.UnLockSlotResponse_element');

            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = DateTime.newInstance(2019, 7, 7, 3,1,5);
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';

            ws_AppointmentNew.UnLockSlotResponse resp = new ws_AppointmentNew.UnLockSlotResponse();
            resp.UnlockSlotResult = result;

            ws_AppointmentNew.UnLockSlotResponse_element response_x = new ws_AppointmentNew.UnLockSlotResponse_element();
            response_x.UnLockSlotResult = resp;
            response.put('response_x', response_x);
        } else if(request instanceof ws_AppointmentNew.SetAppointmentNew_element || request instanceof ws_AppointmentNew.SetAppointmentNewResponse_element) {
            System.debug('request instanceof ws_AppointmentNew.SetAppointmentNew_element || request instanceof ws_AppointmentNew.SetAppointmentNewResponse_element');

            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = result.DateSent = DateTime.newInstance(2019, 6, 7, 3,1,5);
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed with MOCK ws_AppointmentNew';
            
            ws_AppointmentNew.AppointmentResult appResult = new ws_AppointmentNew.AppointmentResult();
            appResult.ProcessId = '1';
            appResult.CrmAppointmentId = '1';
            appResult.Result = result;
            ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult arrOfAppointmentresult = new ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult();
            arrOfAppointmentresult.AppointmentResult = new List<ws_AppointmentNew.AppointmentResult>{appResult};
            
            ws_AppointmentNew.SetAppointmentResponse resp = new ws_AppointmentNew.SetAppointmentResponse();
            resp.AppointmentResult = arrOfAppointmentresult;
            resp.MessageResult = result;

            ws_AppointmentNew.SetAppointmentNewResponse_element response_x = new ws_AppointmentNew.SetAppointmentNewResponse_element();
            response_x.SetAppointmentNewResult = resp;
            response.put('response_x', response_x);
        } else if(request instanceof ws_AppointmentNew.RescheduleAppointmentNew_element || request  instanceof ws_AppointmentNew.RescheduleAppointmentResponse_element) {
            System.debug('request instanceof ws_AppointmentNew.RescheduleAppointmentNew_element || request  instanceof ws_AppointmentNew.RescheduleAppointmentResponse_element');

            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = result.DateSent = DateTime.newInstance(2019, 6, 7, 3,1,5);
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';

            ws_AppointmentNew.AppointmentResult appResult = new ws_AppointmentNew.AppointmentResult();
            appResult.ProcessId = '1';
            appResult.CrmAppointmentId = '1';
            appResult.Result = result;
            ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult arrOfAppointmentresult = new ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult();
            arrOfAppointmentresult.AppointmentResult = new List<ws_AppointmentNew.AppointmentResult>{appResult};

            ws_AppointmentNew.RescheduleAppointmentResponse resp = new ws_AppointmentNew.RescheduleAppointmentResponse();
            resp.AppointmentResult = arrOfAppointmentresult;
            resp.MessageResult = result;

            ws_AppointmentNew.RescheduleAppointmentNewResponse_element response_x = new ws_AppointmentNew.RescheduleAppointmentNewResponse_element();
            response_x.RescheduleAppointmentNewResult = resp;
            response.put('response_x', response_x);
        } else if (request instanceof ws_AppointmentNew.RefreshLockSlot_element) {
            ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
            result.DateSent = result.DateSent = DateTime.newInstance(2019, 6, 7, 3,1,5);
            result.ErrorCode = '0';
            result.ErrorDescription = 'test failed MOCK ws_AppointmentNew';

            ws_AppointmentNew.RefreshLockSlotResponse resp = new ws_AppointmentNew.RefreshLockSlotResponse();
            resp.RefreshLockSlotResult = result;

            ws_AppointmentNew.RefreshLockSlotResponse_element response_x = new ws_AppointmentNew.RefreshLockSlotResponse_element();
            response_x.RefreshLockSlotResult = resp;
            response.put('response_x', response_x);
            
        }
        else if (request instanceof WS_OutboundSMS.SendSMSResponse_element || request instanceof WS_OutboundSMS.SendSMS_element) {
            System.debug('request instanceof WS_OutboundSMS.SendSMSResponse_element || request instanceof WS_OutboundSMS.SendSMS_element');
            WS_OutboundSMS.SendText smsResult = new WS_OutboundSMS.SendText();
            smsResult.Success = true;
        	smsResult.ErrorMessage = 'test';
            
            WS_OutboundSMS.SendSMSResponse_element response_x = new WS_OutboundSMS.SendSMSResponse_element();
            response_x.SendSMSResult = smsResult;
            response.put('response_x', response_x);
        }
    }
}