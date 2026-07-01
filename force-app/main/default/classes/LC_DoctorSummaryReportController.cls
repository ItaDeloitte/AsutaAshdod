// Test: LC_DoctorSummaryReportTest
public class LC_DoctorSummaryReportController implements ILCController {

    public class LC_DoctorSummaryReportException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'reportButtonAvailable' {
                return this.reportButtonAvailable((String) params.get('doctorId'));
            }
            when 'sendReport' {
                return this.sendReport((String) params.get('doctorId'));
            }
            when else {
                throw new LC_DoctorSummaryReportException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response reportButtonAvailable(String doctorId) {
        Boolean buttonAvailable = false;

        List<Account> doctorList = [
            SELECT Id
              FROM Account
             WHERE RecordType.DeveloperName = 'Doctor_Account'
               AND Experts_Center__c = true
               AND Status__c = 'פ'
               AND Id =: doctorId];

        if (!doctorList.isEmpty()) {
            buttonAvailable = true;
        }

        return new Response(buttonAvailable);
    }

    private Response sendReport(String doctorId) {
        Account doctor = [SELECT Doctor_marketing_email__c FROM Account WHERE Id =: doctorId];

        if (doctor.Doctor_marketing_email__c == null) {
            throw new LC_DoctorSummaryReportException(System.Label.Empty_Email);
        }

        Database.executeBatch(new DoctorSummaryReportBatch(doctorId), 1);
        return new Response('success');
    }
}