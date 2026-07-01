public class LC_ButtonsController implements ILCController {

    public class LC_ButtonsControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getAppointmentApproval' {
                return this.getAppointmentApproval((String) params.get('appointmentId'));
            }
            when 'sendDocAdvisor' {
                return this.sendDocAdvisor((String) params.get('caseId'));
            }
            when 'sendPreAppointmentForm' {
                return this.sendPreAppointmentForm((String) params.get('appointmentId'));
            }
            when 'retriveSubExpertises' {
                return this.retriveSubExpertises((String) params.get('accountId'), (String) params.get('expertiseName'));
            }
            when 'setSubExpertise' {
                return this.setSubExpertise((String) params.get('accountId'), (String) params.get('subExpertiseId'));
            }
            when 'transferToManager'{
                return this.transferToManager((String) params.get('caseId'));
            }
            when 'sendOTP'{
                return this.sendOTP((String) params.get('recordId'));
            }
            when 'uploadFilesToClinic'{
                return this.uploadFilesToClinic((String) params.get('caseId'));
            }
            when 'hasFutureAppointments' {
                return this.hasFutureAppointments(
                    (String) params.get('recordId')
                );
            }
            when 'createCase' {
                return this.createCase(
                    (String) params.get('recordId'),
                    (String) params.get('action')
                );
            }
            when else {
                throw new LC_ButtonsControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getAppointmentApproval(String appointmentId) {
        System.debug('LC_ButtonsController.getAppointmentApproval...\nappointmentId: ' + appointmentId);
        Appointment__c appointment = [SELECT Id, need_approval__c FROM Appointment__c WHERE Id = :appointmentId];
        appointment.need_approval__c = true;
        if(!Test.isRunningTest()) {
            update appointment;
        }

        System.debug('success\nappointment' + appointment);
        return new Response(appointment);
    }

    private Response sendDocAdvisor(String caseId) {
        System.debug('LC_ButtonsController.sendDocAdvisor...\ncaseId: ' + caseId);
        Case cas = [SELECT Id, Send_DocAdvisor__c FROM Case WHERE Id = :caseId];
        cas.Send_DocAdvisor__c = true;
        update cas;

        System.debug('success\ncas' + cas);
        return new Response(cas);
    }

    private Response sendPreAppointmentForm(String appointmentId) {
        System.debug('LC_ButtonsController.sendPreAppointmentForm...\nappointmentId: ' + appointmentId);
        Appointment__c appointment = [SELECT Id, Send_pre_appointement_form__c FROM Appointment__c WHERE Id = :appointmentId];
        appointment.Send_pre_appointement_form__c = true;
        update appointment;

        System.debug('success\nappointment' + appointment);
        return new Response(appointment);
    }

    private Response retriveSubExpertises(String accountId, String expertiseName) {
        System.debug('LC_ButtonsController.retriveSubExpertises...\naccountId: ' + accountId);
        Account acct = [SELECT Id, Expertise_1__c, Expertise_2__c FROM Account WHERE Id = :accountId];
        String exp1 = acct.Expertise_1__c;
        String exp2 = acct.Expertise_2__c;
        String queryStr = 'SELECT Id, Name, Expertise__c, Description__c, Expertise__r.Name FROM Sub_Expertise__c WHERE (Expertise__c = :exp1 OR Expertise__c = :exp2)';
        if (String.isNotBlank(expertiseName)) {
            expertiseName = '%' + expertiseName + '%';
            queryStr += ' AND Name LIKE :expertiseName';
        }
        List<Sub_Expertise__c> subExpertises = Database.query(queryStr);

        System.debug('success\nsubExpertises' + subExpertises);
        return new Response(subExpertises);
    }

    private Response setSubExpertise(String accountId, String subExpertiseId) {
        System.debug('LC_ButtonsController.setSubExpertise...\naccountId: ' + accountId + ' subExpertiseId: ' + subExpertiseId);
        Account acct = [SELECT Id, DisableValidation__c, Sub_Expertise__c FROM Account WHERE Id = :accountId];
        acct.DisableValidation__c = !acct.DisableValidation__c;
        acct.Sub_Expertise__c = subExpertiseId;
        update acct;

        System.debug('success\nacct' + acct);
        return new Response(acct);
    }

    private Response transferToManager(String caseId) {
        System.debug('LC_ButtonsController.transferToManager...\ncaseId: ' + caseId);        
        EmailTemplate template = [SELECT Id, DeveloperName, Subject, HtmlValue, Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = 'CaseForward'];
        Case currentCase = [SELECT Id, Status, OwnerId FROM Case WHERE Id = :caseId];
        if (currentCase.Status == 'In_Progress') { //In_Progress = 'בטיפול'
            Id managerId = [SELECT Id, ManagerId FROM User WHERE Id = :currentCase.OwnerId].ManagerId;
            if(managerId != null){              
               currentCase.Status = 'Escalated';
               currentCase.OwnerId = managerId;
               currentCase.help_transfer_to_manager__c = true;
               update currentCase;
               User manager = [SELECT Id, Email FROM User WHERE Id = :managerId]; 
               createEmailMessages(currentCase, manager.Email, template);
            } else{
                throw new LC_ButtonsControllerException(Label.agent_doesnt_have_a_manager);
            }
        }   else {
            throw new LC_ButtonsControllerException(Label.status_has_to_be_in_progress);
        }
        return new Response(currentCase);
    }

    private static void createEmailMessages(Case cas, String toAddress, EmailTemplate template) {                               
        EmailMessage em = new EmailMessage();
        em.ExpectedSendingDateTime__c = Datetime.now();
        em.EmailTemplateId = template.Id;            
        em.EmailTemplateDeveloperName__c = template.DeveloperName;            
        em.FromAddress = 'nonreply@assuta.co.il';
        em.ParentId = cas.Id;
        em.ToAddress = toAddress;
        em.Automation_name__c = 'transferToManagerButton';
        System.debug('em: ' + em);
        insert em;
    }    

    private Response sendOTP(String recordId) {
        System.debug('LC_ButtonsController.sendOTP...\nrecordId: ' + recordId);
        if (Id.valueOf(recordId).getSobjectType() == Case.getSObjectType()) { 
            Case currentCase = [SELECT Id, send_OTP__c FROM Case WHERE Id = :recordId];
            currentCase.send_OTP__c = true;
            update currentCase;
        } else if (Id.valueOf(recordId).getSobjectType() == Opportunity.getSObjectType()) {
            Opportunity currentOpp = [SELECT Id, SendOTP__c FROM Opportunity WHERE Id = :recordId];
            currentOpp.SendOTP__c = true;
            update currentOpp;
        }
        return new Response('success');
    }

    private Response uploadFilesToClinic(String caseId) {
        System.debug('LC_ButtonsController.uploadFilesToClinic...\ncaseId: ' + caseId);
        Case currentCase = [SELECT Id, Send_Link_Clinic__c, Upload_Files_Link_Clinic_Sent__c FROM Case WHERE Id = :caseId];
        currentCase.Upload_Files_Link_Clinic_Sent__c = true;
        currentCase.Send_Link_Clinic__c = true;
        update currentCase;
        return new Response('success');
    }

    private Response hasFutureAppointments(String pRecordId) {
        System.debug('LC_ButtonsController.hasFutureAppointments ...');
        Boolean hasFutureAppointments = false;
        String accountId = pRecordId;

        if (Id.valueOf(pRecordId).getSobjectType() == Opportunity.getSObjectType()) {
            accountId = [SELECT AccountId FROM Opportunity WHERE Id = :pRecordId LIMIT 1].AccountId;
        }

        List<Appointment__c> futureAppointments = [
            SELECT Id
              FROM Appointment__c
             WHERE Patient_Account__c = :accountId
               AND Appointment_Date_Time__c > :System.now()
               AND RecordType.DeveloperName = 'Experts'
               AND Appointment_Status__c NOT IN ('Canceled', 'CanceledFailed')
             LIMIT 1];
        System.debug('futureAppointments [' + futureAppointments.size() + ']: ' + futureAppointments);

        if (!futureAppointments.isEmpty()) {
            hasFutureAppointments = true;
        }
        System.debug('hasFutureAppointments: ' + hasFutureAppointments);

        return new Response(hasFutureAppointments);
    }

    private Response createCase(String pRecordId, String pAction) {
        System.debug('LC_ButtonsController.createCase ...');
        Id docExpertRTId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DOC_expert').getRecordTypeId();
        String accountId = pRecordId;

        Boolean isOpportunity = Id.valueOf(pRecordId).getSobjectType() == Opportunity.getSObjectType();

        if (isOpportunity) {
            accountId = [SELECT AccountId FROM Opportunity WHERE Id = :pRecordId LIMIT 1].AccountId;
        }

        // search a valid Case
        List<Case> cases = [
            SELECT Opportunity__c
                 , (SELECT Id FROM Appointments_makor__r)
              FROM Case
             WHERE RecordTypeId = :docExpertRTId
               AND AccountId = :accountId
               AND IsClosed = false
          ORDER BY CreatedDate DESC];
        System.debug('cases [' + cases.size() + ']: ' + cases);

        for (Case case_i : cases) {
            if (case_i.Appointments_makor__r.isEmpty()) {
                if (isOpportunity && case_i.Opportunity__c != pRecordId) {
                    case_i.Opportunity__c = pRecordId;
                    System.debug('case_i: ' + case_i);
                    update case_i;
                }

                return new Response(case_i.Id);
            }
        }

        // if no Case is found, create a new one
        Case cas = new Case(RecordTypeId = docExpertRTId, AccountId = accountId, Channel__c = 'פרטי');

        switch on pAction {
            when 'create' {
                cas.Case_subject__c = 'זימון רופא מומחה';
                cas.sub_case_subject__c = 'המלצה על רופא מומחה';
            }
            when 'update' {
                cas.Case_subject__c = 'עדכון תור לרופא';
                cas.sub_case_subject__c = 'שינוי מועד התור';
            }
        }

        if (isOpportunity) {
            cas.Opportunity__c = pRecordId;
        }
        System.debug('cas: ' + cas);

        insert cas;

        return new Response(cas.Id);
    }
}