/**@type {import("UpdateCaseDoctorArrangement").Helper} */
({
    init: function(cmp) {
      this.getDoctorArrangement(cmp);
    },
    CONSTANTS: {},
    controllers: {
      caseDoctorArrangement: 'LC_CaseDoctorArrangement'
    },
    destroy: function(cmp) {},
    render: function(cmp) {},
    serverError: function(cmp, value) {
      return this.attribute(cmp, 'serverError', value);
    },
    selectedDoctorArrangementId: function(cmp, value) {
      return this.attribute(cmp, 'selectedDoctorArrangementId', value);
    },
    formFieldCmp: function(cmp) {
      return cmp.find('formField');
    },
    searchDoctorArrangements: function(cmp, term) {
      var self = this;
      var recordId = this.recordId(cmp);
      var params = {
        recordId: recordId,
        actionName: 'obtainDoctorArrangements',
        doctorArrangementName: term
      };
      return self
        .executeApex(cmp, {
          controllerName: this.controllers.caseDoctorArrangement,
          params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            var doctorArrangements = res.map(function(item) {
              return Object.assign(item, { label: item.Arrangement__r.Name, value: item.Id });
            });
            return doctorArrangements;
          })
        )
        .catch(
          $A.getCallback(function(err) {
            console.log(err);
            return [];
          })
        );
    },
    submit: function(cmp) {
      var self = this;
      var isValid = this.validate(cmp);
      if (!isValid) {
        return;
      }
      var recordId = this.recordId(cmp);
      var doctorArrangementId = this.selectedDoctorArrangementId(cmp);
      var params = {
        recordId: recordId,
        doctorArrangementId: doctorArrangementId,
        actionName: 'setDoctorArrangement'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.caseDoctorArrangement,
        params: params
      })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            self.isLoading(cmp, false);
            self.showToast({
              title: 'Success',
              message: 'Doctor Arrangement updated',
              type: 'success'
            });
            self.refreshView();
          })
        )
        .catch(
          $A.getCallback(function(err) {
            console.log(err);
            self.isLoading(cmp, false);
            var errMessage = self.buildHtmlServerError(err);
            self.serverError(cmp, errMessage);
          })
        );
    },
    getDoctorArrangement: function(cmp) {
      var self = this;
      var isValid = this.validate(cmp);
      if (!isValid) {
        return;
      }
      var recordId = this.recordId(cmp);
  
      var params = {
        recordId: recordId,
        actionName: 'getDoctorArrangement'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.caseDoctorArrangement,
        params: params
      })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            self.isLoading(cmp, false);
            if (res.Id != null) {
              var option = {
                label: res.Arrangement__r.Name,
                value: res.Id
              };
              self.formFieldCmp(cmp).setOption(option);
            }
          })
        )
        .catch(
          $A.getCallback(function(err) {
            console.log(err);
            self.isLoading(cmp, false);
            var errMessage = self.buildHtmlServerError(err);
            self.serverError(cmp, errMessage);
          })
        );
    },
    validate: function(cmp) {
      var isValid = true;
      var formFieldCmp = this.formFieldCmp(cmp);
      if (formFieldCmp) {
        formFieldCmp.showHelpMessageIfInvalid();
        var validity = this.attribute(formFieldCmp, 'validity');
        isValid = validity.valid;
      }
      return isValid;
    }
  });