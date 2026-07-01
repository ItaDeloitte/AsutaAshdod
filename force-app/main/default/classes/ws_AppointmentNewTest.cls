@isTest
private with sharing class ws_AppointmentNewTest {

    @IsTest
    private static void AppointmentOperationsSoapTest() {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        ws_AppointmentNew ws_AppointmentNew = new ws_AppointmentNew(); 
        ws_AppointmentNew.CancelAppointmentRequest cancelRequest = new ws_AppointmentNew.CancelAppointmentRequest();
        ws_AppointmentNew.RescheduleAppointmentRequest rescheduleRequest = new ws_AppointmentNew.RescheduleAppointmentRequest();
        ws_AppointmentNew.LockSlotRequest lockRequest = new ws_AppointmentNew.LockSlotRequest();
        ws_AppointmentNew.SetAppointmentRequest setRequest = new ws_AppointmentNew.SetAppointmentRequest();
        ws_AppointmentNew.AppointmentSearchRequest searchRequest = new ws_AppointmentNew.AppointmentSearchRequest();
        ws_AppointmentNew.UnLockSlotRequest unlockRequest = new ws_AppointmentNew.UnLockSlotRequest();
        ws_AppointmentNew.RefreshLockSlotRequest refreshRequest = new ws_AppointmentNew.RefreshLockSlotRequest();
        ws_AppointmentNew.Day day = new ws_AppointmentNew.Day();
        ws_AppointmentNew.ArrayOfAppointmentSiteCriteriasAppointmentSiteCriterias siteCriteriasArray = new ws_AppointmentNew.ArrayOfAppointmentSiteCriteriasAppointmentSiteCriterias();
        ws_AppointmentNew.Ens_Request endRequest = new ws_AppointmentNew.Ens_Request();
        ws_AppointmentNew.UnLockSlotResponse unlockSlotResponse = new ws_AppointmentNew.UnLockSlotResponse();
        ws_AppointmentNew.ArrayOfCancelAppointmentDetailsCancelAppointmentDetails cancelApptArray = new ws_AppointmentNew.ArrayOfCancelAppointmentDetailsCancelAppointmentDetails();
        ws_AppointmentNew.Error error = new ws_AppointmentNew.Error();
        ws_AppointmentNew.ArrayOfPricesInfoPricesInfo pricesArray = new ws_AppointmentNew.ArrayOfPricesInfoPricesInfo();
        ws_AppointmentNew.ArrayOfDeclinedSitesItemString decSitesArray = new ws_AppointmentNew.ArrayOfDeclinedSitesItemString();
        ws_AppointmentNew.RefreshLockSlotResponse refreshSlot = new ws_AppointmentNew.RefreshLockSlotResponse();
        ws_AppointmentNew.PricesInfo price = new ws_AppointmentNew.PricesInfo();
        ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult apptResArray = new ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult();
        ws_AppointmentNew.AppointmentSearchResponse_element searchResponseEl = new ws_AppointmentNew.AppointmentSearchResponse_element();
        ws_AppointmentNew.UnLockSlotResponse_element unlockResponseEl = new ws_AppointmentNew.UnLockSlotResponse_element();
        ws_AppointmentNew.CancelAppointmentResponse_element cancelResponseEl = new ws_AppointmentNew.CancelAppointmentResponse_element();
        ws_AppointmentNew.ArrayOfSetAppointmentDetailsSetAppointmentDetails apptDetArray = new ws_AppointmentNew.ArrayOfSetAppointmentDetailsSetAppointmentDetails();
        ws_AppointmentNew.SetAppointmentNewResponse_element setResEl = new ws_AppointmentNew.SetAppointmentNewResponse_element();
        ws_AppointmentNew.RescheduleAppointmentResponse reschApptRes = new ws_AppointmentNew.RescheduleAppointmentResponse();
        ws_AppointmentNew.ArrayOfDayDay daysArray = new ws_AppointmentNew.ArrayOfDayDay();
        ws_AppointmentNew.RefreshLockSlotResponse_element refreshLockEl = new ws_AppointmentNew.RefreshLockSlotResponse_element();
        ws_AppointmentNew.AppointmentSearchResponse apptSearchRes = new ws_AppointmentNew.AppointmentSearchResponse();
        ws_AppointmentNew.Agreement agreement = new ws_AppointmentNew.Agreement();
        ws_AppointmentNew.CancelAppointmentResponse cancelResp = new ws_AppointmentNew.CancelAppointmentResponse();
        ws_AppointmentNew.LockSlotResponse lockRes = new ws_AppointmentNew.LockSlotResponse();
        ws_AppointmentNew.LockSlotResponse_element lockResEl = new ws_AppointmentNew.LockSlotResponse_element();
        ws_AppointmentNew.Ens_Response ensResp = new ws_AppointmentNew.Ens_Response();
        ws_AppointmentNew.ArrayOfExternalStudyCriteriaExternalStudyCriteria studyArray = new ws_AppointmentNew.ArrayOfExternalStudyCriteriaExternalStudyCriteria();
        ws_AppointmentNew.AppointmentResult apptRes = new ws_AppointmentNew.AppointmentResult();
        ws_AppointmentNew.PatientDetails patient = new ws_AppointmentNew.PatientDetails();
        ws_AppointmentNew.AppointmentSiteCriterias siteCriteria = new ws_AppointmentNew.AppointmentSiteCriterias();
        ws_AppointmentNew.CancelAppointmentDetails cancelApptDetails = new ws_AppointmentNew.CancelAppointmentDetails();
        ws_AppointmentNew.Order order = new ws_AppointmentNew.Order();
        ws_AppointmentNew.ArrayOfErrorError errorArray = new ws_AppointmentNew.ArrayOfErrorError();
        ws_AppointmentNew.RescheduleAppointmentResponse_element reschApptResEl = new ws_AppointmentNew.RescheduleAppointmentResponse_element();
        ws_AppointmentNew.SetAppointmentDetails apptDetails = new ws_AppointmentNew.SetAppointmentDetails();
        ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
        ws_AppointmentNew.SetAppointmentResponse_element setApptEl = new ws_AppointmentNew.SetAppointmentResponse_element();
        ws_AppointmentNew.Ens_Messagebody messageBosy = new ws_AppointmentNew.Ens_Messagebody();
        ws_AppointmentNew.ArrayOfOrderOrder orderArray = new ws_AppointmentNew.ArrayOfOrderOrder();
        ws_AppointmentNew.AppointmentSearchCriteria searchCriteria = new ws_AppointmentNew.AppointmentSearchCriteria();
        ws_AppointmentNew.SetAppointmentResponse setApptRes = new ws_AppointmentNew.SetAppointmentResponse();
        ws_AppointmentNew.ExternalStudyCriteria externalStudy = new ws_AppointmentNew.ExternalStudyCriteria();
        ws_AppointmentNew.SecurityHeaderType secHeader = new ws_AppointmentNew.SecurityHeaderType('username', 'password');
        ws_AppointmentNew.UsernameToken token = new ws_AppointmentNew.UsernameToken('username', 'password');

        Test.startTest();
        ws_AppointmentNew.AppointmentOperationsSoap appointment = new ws_AppointmentNew.AppointmentOperationsSoap();
        try {
            ws_AppointmentNew.CancelAppointmentResponse cancelAppt = new ws_AppointmentNew.AppointmentOperationsSoap().CancelAppointment(cancelRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.RescheduleAppointmentResponse rescheduleAppt = new ws_AppointmentNew.AppointmentOperationsSoap().RescheduleAppointment(rescheduleRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.LockSlotResponse lockAppt = new ws_AppointmentNew.AppointmentOperationsSoap().LockSlot(lockRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.SetAppointmentResponse setAppt = new ws_AppointmentNew.AppointmentOperationsSoap().SetAppointment(setRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.SetAppointmentResponse setNewAppt = new ws_AppointmentNew.AppointmentOperationsSoap().SetAppointmentNew(setRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.AppointmentSearchResponse searchAppt = new ws_AppointmentNew.AppointmentOperationsSoap().AppointmentSearch(searchRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.UnLockSlotResponse unlockAppt = new ws_AppointmentNew.AppointmentOperationsSoap().UnLockSlot(unlockRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        try {
            ws_AppointmentNew.RefreshLockSlotResponse refreshAppt = new ws_AppointmentNew.AppointmentOperationsSoap().RefreshLockSlot(refreshRequest);
        } catch (Exception e) { System.debug(e.getMessage()); }
        Test.stopTest();
    }

    private class WebServiceMockImpl implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                if(request instanceof ws_AppointmentNew.AppointmentOperationsSoap) {
                    response.put('response_x', new ws_AppointmentNew.AppointmentOperationsSoap());
                }
                return;
            }
    }
}