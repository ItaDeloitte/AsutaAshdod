public with sharing class RedirectToAppointment {

    @InvocableMethod
    public static void redirect(List<ID> aptIds) {
        Appointment__c apt = new Appointment__c(Id = aptIds[0]);
        PageReference acctPage = new PageReference('/' + String.valueOf(apt.Id));
        acctPage.setRedirect(true);
    }
}