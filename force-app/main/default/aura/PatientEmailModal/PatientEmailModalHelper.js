/**@type {import("PatientEmailModal").Controller} */
({
    init: function(cmp) {
      this.configLabels(cmp);
    },
    destroy: function(cmp) {},
    render: function(cmp) {
      var isRendered = this.isRendered(cmp);
      if (isRendered) {
        return;
      }
      this.isRendered(cmp, true);
      this.checkModalData(cmp);
    },
    controllers: {
      LC_PatientEmail: 'LC_PatientEmailController'
    },
    CONSTANTS: {},
  
    modalParams: function(cmp, value) {
      return this.attribute(cmp, 'modalParams', value);
    },
    patientId: function(cmp, value) {
      return this.attribute(cmp, 'patientId', value);
    },
    idType: function(cmp, value) {
      return this.attribute(cmp, 'idType', value);
    },
    email: function(cmp, value) {
      return this.attribute(cmp, 'email', value);
    },
    serverError: function(cmp, value) {
      return this.attribute(cmp, 'serverError', value);
    },
    configLabels: function(cmp) {
      var customLabels = this.getCustomLabels();
      this.labels(cmp, customLabels);
    },
    getCustomLabels: function() {
      return {
        Cancel: $A.get('$Label.c.Cancel'),
        Submit: $A.get('$Label.c.Submit'),
        Email: $A.get('$Label.c.Email'),
        NoEmailForPatient: $A.get('$Label.c.No_Email_For_Patient'),
        CompleteThisField: $A.get('$Label.c.Complete_this_field'),
        FillPatientEmailTitle: $A.get('$Label.c.FillPatientEmail_Title')
      };
    },
    getEditFields: function (cmp) {
      return this.convertCmpsToArray(cmp.find('editField'));
    },
    checkModalData: function(cmp) {
      var that = this;
      var modalParams = that.modalParams(cmp);
      var modalData = modalParams.modalData;
      var patientId = modalData.patientId || '';
      var idType = modalData.idType || '';
      that.patientId(cmp, patientId);
      that.idType(cmp, idType);
    },
    cancelHandler: function(cmp) {
      this.emitCloseModal(cmp);
    },
    emitCloseModal: function(cmp, result) {
      var modalParams = this.modalParams(cmp);
      modalParams.resolvers.close(result);
      this.close(cmp);
    },
    submit: function(cmp) {
      var that = this;
      var patientId = that.patientId(cmp);
      var idType = that.idType(cmp);
      var email = that.email(cmp);

      var isValid = that.validate(cmp);
      if(!isValid) {
        return;
      }
      if(email != "") {
        var params = {
          actionName: 'setPatientEmail',
          patientId: patientId,
          idType: idType,
          email: email
        };
        that.serverError(cmp, '');
        that.isLoading(cmp, true);
        that.executeApex(cmp, {
          controllerName: that.controllers.LC_PatientEmail,
          params: params
          })
        .then(that.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
              console.log(params, res);
              that.isLoading(cmp, false);
              that.refreshView();
              that.emitCloseModal(cmp, true);
          })
        )
        .catch(
          $A.getCallback(function(err) {
              console.log(err);
              that.isLoading(cmp, false);
              that.serverError(cmp, that.buildHtmlServerError(err));
          })
        );
      } 
      that.emitCloseModal(cmp, true);
    },
    validate: function(cmp) {
      var that = this;
      var isValid = true;
      var formFields = that.getEditFields(cmp);
      formFields.forEach(function(fieldCmp) {
        fieldCmp.showHelpMessageIfInvalid();
        var validity = that.attribute(fieldCmp, 'validity');
        if (validity) {
          isValid = isValid && validity.valid;
        }
      });
      return isValid;
    },
})