({
    init: function(cmp) {
        this.checkCreationOptions(cmp);
    }, 
    createAppointment:  function(cmp) {
        this.openPrepopulatedModal(cmp);
    }, 
    handleToast: function(cmp, event){
        this.checkJunction(cmp, event);
    },
    isAvailable: function(cmp, value) {
        return this.attribute(cmp, 'isAvailable', value);
    },
    caseRTDeveloperName: function(cmp, value) {
        return this.attribute(cmp, 'caseRTDeveloperName', value);
    },
    appointmentRTDeveloperName: function(cmp, value) {
        return this.attribute(cmp, 'appointmentRTDeveloperName', value);
    },
    checkCreationOptions: function(cmp){
        var self = this;
        var caseId = this.recordId(cmp);
        var caseRT = this.caseRTDeveloperName(cmp);
        var params = {
            actionName: 'isAvailable',
            caseId: caseId, 
            caseRtDevName: caseRT
        };
        return this.executeApex(cmp, {
            controllerName: this.controllers.LC_SurgeriesAppointment,
            params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
            $A.getCallback(function(res) {
                console.log('isAvailable', res);
                self.isAvailable(cmp, res);
            })
        )
        .catch(
            $A.getCallback(function(err) {
                console.log(err);
            })
        );
    }, 
    openPrepopulatedModal : function(cmp){
        var self = this;
        var caseId = this.recordId(cmp);
        var createAppointmentEvent = $A.get(this.BASE_CONSTANTS.forceEventTypes.createRecord);
        var appointmentRTDeveloperName = this.appointmentRTDeveloperName(cmp);
        var params = {
            actionName: 'prepopulateField',
            caseId: caseId, 
            appointmentRtDevName : appointmentRTDeveloperName
        };
        this.executeApex(cmp, {
            controllerName: this.controllers.LC_SurgeriesAppointment,
            params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
            $A.getCallback(function(res) {
                self.emitApppointmentCreationForm(
                    createAppointmentEvent,
                    res
                );
            })
        )
        .catch(
            $A.getCallback(function(err) {
                console.log(err);
            })
        );
    },
    emitApppointmentCreationForm: function(event, data) {
        var params = {
          entityApiName: 'Appointment__c',
          recordTypeId: data.RecordTypeId,
          defaultFieldValues: data
        };
        event.setParams(params);
        event.fire();
      }, 
      checkJunction: function(cmp, event){
        var self = this;
        var caseId = this.recordId(cmp);
        var isAvaliable = this.isAvailable(cmp);
        if (!isAvaliable){
            return;
        }
        var params = {
            actionName: 'checkJunction',
            caseId: caseId
        };
        self.executeApex(cmp, {
            controllerName: this.controllers.LC_SurgeriesAppointment,
            params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then($A.getCallback(function(res) {
                console.log('res '+res);
            })
        )
        .catch(
            $A.getCallback(function(err) {
                console.log(err);
            })

        );
        
      }
})