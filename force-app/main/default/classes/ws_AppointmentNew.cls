global class ws_AppointmentNew {
 
    public class RescheduleAppointmentRequest {
        public String TargetSystem;
        public String SourceSystem;
        public String ProcessId;
        public String UserId;
        public ws_AppointmentNew.PatientDetails PatientDetails;
        public List<ws_AppointmentNew.SetAppointmentDetails> AppointmentDetails;
        public List<ws_AppointmentNew.Order> Order;
    }

    public class ExternalStudyCriteria {
        public String ProcedureCode;
        public String ProcedurePlanCode;
        public Integer ProcedurePlanSequenceId;
        public Integer study_key;
        public String Modality;
    }

    
    public class SetAppointmentResponse {
        public ws_AppointmentNew.Result MessageResult;
        public ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult AppointmentResult;
    }

    public class AppointmentSearchCriteria {
        public DateTime FromDate;
        public DateTime ToDate;
        public ws_AppointmentNew.ArrayOfDayDay Days;
    }

    
    public class ArrayOfOrderOrder {
        public ws_AppointmentNew.Order[] Order;
    }

    public class Ens_Messagebody {
    }

    public class Result {
        public DateTime DateSent;
        public String ErrorCode;
        public String ErrorDescription;
    }

    
    public class SetAppointmentDetails {
        public String ModalityCode;
        public String SlotId;
        public Long AppointmentKey;
        public DateTime ScheduledStartDate;
        public String Duration;
        public String SchedulingSystem;
        public String Guid;
        public String Anotes;
        public String ForceAppointmentCode;
        public Boolean IsProcessRecycable;
        public String ProcedurePlanCode;
        public String ProcedureCode;
        public String LateralityCode;
    }

    public class ArrayOfErrorError {
        public ws_AppointmentNew.Error[] Error;
    }

    
    public class Order {
        public Long InsurerId;
        public String HospitalName;
    }

    public class AppointmentSearchRequest {
        public Long TargetSystem;
        public String PatientId;
        public Long IDType;
        public String UserName;
        public ws_AppointmentNew.ArrayOfAppointmentSiteCriteriasAppointmentSiteCriterias AppointmentCriterias;
        public String Resource;
        public String InsurenceCode;
        public String DistrictId;
        public String MedicaField;
    }

    
    public class CancelAppointmentDetails {
        public String UserId;
        public String ProcessId;
        public String CancelationReasonCode;
        public String AppointmentDate;
        public String AppointmentDuration;
        public String ActivityCode;
        public String CalendarCode;
        public String Activity;
    }

    public class AppointmentSiteCriterias {
        public ws_AppointmentNew.ArrayOfExternalStudyCriteriaExternalStudyCriteria StudyCriterias;
        public ws_AppointmentNew.AppointmentSearchCriteria AppointmentSearchCriteria;
        public String SiteId;
    }

    
    public class PatientDetails {
        public String PatientId;
        public String IdType;
        public String Pnotes;
        public String FirstName;
        public String LastName;
        public String GenderCode;
        public DateTime BirthDate;
        public String HomelTel;
        public String MobilePhoneNumber;
        public String Email;
    }

    
    public class AppointmentResult {
        public String ProcessId;
        public String CrmAppointmentId;
        public ws_AppointmentNew.Result Result;
    }

    public class UnLockSlotRequest {
        public String TargetSystem;
        public String SlotLockId;
        public String ModalityCode;
        public String UserName;
    }

    public class ArrayOfExternalStudyCriteriaExternalStudyCriteria {
        public ws_AppointmentNew.ExternalStudyCriteria[] ExternalStudyCriteria;
    }

    public class Ens_Response {
    }

    public class LockSlotResponse {
        @AuraEnabled
        public String ExtCalendarId;
        @AuraEnabled
        public String SlotLockId;
        @AuraEnabled
        public Long LockDurationMinutes;
        @AuraEnabled
        public DateTime LockExpirationDate;
        public ws_AppointmentNew.Result LockSlotResult;
    }

    
    public class CancelAppointmentResponse {
        public ws_AppointmentNew.Result CancelAppointmentResult;
    }

    public class Agreement {
        public ws_AppointmentNew.ArrayOfDeclinedSitesItemString DeclinedSites;
        public ws_AppointmentNew.ArrayOfPricesInfoPricesInfo PricesInfoList;
        public Boolean IsAgreementExists;
        public ws_AppointmentNew.ArrayOfErrorError Errors;
    }

    public class AppointmentSearchResponse {
        public ws_AppointmentNew.ArrayOfCalenderSlotCalenderSlot CalenderSlots;
        public ws_AppointmentNew.Result AppointmentSearchResult;
        public ws_AppointmentNew.Agreement Agreements;
    }

    public class ArrayOfDayDay {
        public ws_AppointmentNew.Day[] Day;
    }

    
    public class CancelAppointmentRequest {
        public String TargetSystem;
        public ws_AppointmentNew.ArrayOfCancelAppointmentDetailsCancelAppointmentDetails CancelAppointmentDetails;
    }

    public class ArrayOfCalenderSlotCalenderSlot {
        public ws_AppointmentNew.CalenderSlot[] CalenderSlot;
    }

    
    public class RescheduleAppointmentResponse {
        public ws_AppointmentNew.Result MessageResult;
        public ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult AppointmentResult;
    }

    
    public class ArrayOfSetAppointmentDetailsSetAppointmentDetails {
        public ws_AppointmentNew.SetAppointmentDetails[] SetAppointmentDetails;
    }

    
    public class ArrayOfAppointmentResultAppointmentResult {
        public ws_AppointmentNew.AppointmentResult[] AppointmentResult;
    }

    public class PricesInfo {
        public Long Price;
        public String ClientNo;
        public String Site;
    }

    
    public class SetAppointmentRequest {
        public String TargetSystem;
        public String SourceSystem;
        public String UserId;
        public ws_AppointmentNew.PatientDetails PatientDetails;
        public List<ws_AppointmentNew.SetAppointmentDetails> AppointmentDetails;
        public ws_AppointmentNew.Order Order;
    }

    public class RefreshLockSlotResponse {
        public ws_AppointmentNew.Result RefreshLockSlotResult;
    }

    public class ArrayOfDeclinedSitesItemString {
        public String[] DeclinedSitesItem;
    }

    public class ArrayOfPricesInfoPricesInfo {
        public ws_AppointmentNew.PricesInfo[] PricesInfo;
    }

    public class Error {
        public String ErrorCode;
        public String ErrorMessage;
    }

    global class CalenderSlot implements Comparable {
        @AuraEnabled
        public Long SlotId;
        @AuraEnabled
        public DateTime StartTime;
        @AuraEnabled
        public DateTime EndTime;
        @AuraEnabled
        public Long Duration;
        @AuraEnabled
        public Long ModalityCode;
        @AuraEnabled
        public String AppointmentTypeId;
        @AuraEnabled
        public Long UnitCode;
        @AuraEnabled
        public Long CalendarId;
        @AuraEnabled
        public String uniqKey;
        @AuraEnabled
        public String siteCode;
        @AuraEnabled
        public String procedureCode;
        @AuraEnabled
        public String dayOfWeek;
        @AuraEnabled
        public Date targetDate;
        @AuraEnabled
        public String region;

        global Integer compareTo(Object compareTo) {
            CalenderSlot compareToSlot = (CalenderSlot) compareTo;

            Integer returnValue = 0;
            if (this.StartTime > compareToSlot.StartTime) {
                returnValue = 1;
            } else if (this.StartTime < compareToSlot.StartTime) {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    
    public class ArrayOfCancelAppointmentDetailsCancelAppointmentDetails {
        public ws_AppointmentNew.CancelAppointmentDetails[] CancelAppointmentDetails;
    }

    public class UnLockSlotResponse {
        public ws_AppointmentNew.Result UnlockSlotResult;
    }

    public class LockSlotRequest {
        public Long TargetSystem;
        public String UserName;
        public String ModalityCode;
        public Integer SlotId;
        public Integer LockDurationMinutes;
        public String AppointmentTypeId;
        public DateTime StartTime;
        public DateTime EndTime;
    }

    public class RefreshLockSlotRequest {
        public String TargetSystem;
        public String SlotLockId;
        public String ModalityCode;
        public String UserName;
        public Long ExtensionMinutes;
    }

    public class Ens_Request {
    }

    public class ArrayOfAppointmentSiteCriteriasAppointmentSiteCriterias {
        public ws_AppointmentNew.AppointmentSiteCriterias[] AppointmentSiteCriterias;
    }

    public class Day {
        public String DayOfweek;
        public DateTime StartTime;
        public DateTime EndTime;
    }
}
