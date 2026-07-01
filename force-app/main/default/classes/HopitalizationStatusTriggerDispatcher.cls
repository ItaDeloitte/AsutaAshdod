/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        21-07-2019
* @modified       15-12-2019
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class responsible for updating the appointments with the hospitalization statuses sent by
* events from Ensemble (received from Tafnit).
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes Added Tafnit case number field update.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class HopitalizationStatusTriggerDispatcher {

    public static void updateStatus(List<Hospitalization_Status__e> statuses) {
        Map<ID, Hospitalization_Status__e> aptIdsToEvents = new Map<ID, Hospitalization_Status__e>();
        List<Appointment__c> aptsToUpdate = new List<Appointment__c>();

        for (Hospitalization_Status__e status : statuses) {
            aptIdsToEvents.put(Id.valueOf(status.Appointment_ID__c), status);
        }
        
        aptsToUpdate = [SELECT Id, Patient_Hospitalization_Status__c FROM Appointment__c WHERE Id IN :aptIdsToEvents.keySet()];
        System.debug('Got Here!!!');
        for (Appointment__c apt : aptsToUpdate) {
            switch on aptIdsToEvents.get(apt.Id).Status_Code__c {
                when '1' { //Admission to hospital
                    apt.Patient_Hospitalization_Status__c = '1';
                    apt.Admission_Date__c = aptIdsToEvents.get(apt.Id).Status_Date_Time__c;                   
                }
                when '2' { //Cancellation of the case in Tafnit
                    apt.Patient_Hospitalization_Status__c = '2';
                }
                when '3' { //Patient release 
                    apt.Patient_Hospitalization_Status__c = '3';
                    apt.Release_Date__c = aptIdsToEvents.get(apt.Id).Status_Date_Time__c;
                }
                when '4' { //Cancellation of the cancellation of the case in Tafnit
                    apt.Patient_Hospitalization_Status__c = '4';
                }
                when '5' { //Cancellation of patient release
                    apt.Patient_Hospitalization_Status__c = '5';
                    apt.Release_Date__c = null;
                }
            }

            if (aptIdsToEvents.get(apt.Id).Tafnit_Case_Number__c != null) {
                apt.Tafnit_Case_Number__c = aptIdsToEvents.get(apt.Id).Tafnit_Case_Number__c;
            }
        }

        update aptsToUpdate;
    }
}