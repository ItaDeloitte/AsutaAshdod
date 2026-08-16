//@ts-check
({
  init: function (cmp) {
    this.configLabels(cmp);
  },
  destroy: function (cmp) { },
  render: function (cmp) {
    var isRendered = this.isRendered(cmp);
    if(isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.checkModalData(cmp);
    this.fetchFormConfig(cmp);
  },
  CONSTANTS: {},

  modalParams: function (cmp, value) {
    return this.attribute(cmp, 'modalParams', value);
  },
  formConfig: function (cmp, value) {
    return this.attribute(cmp, 'formConfig', value);
  },
  editData: function (cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  serverError: function (cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  isReady: function (cmp, value) {
    return this.attribute(cmp, 'isReady', value);
  },
  configLabels: function (cmp) {
    var customLabels = this.getCustomLabels();
    this.labels(cmp, customLabels);
  },
  getCustomLabels: function () {
    return {
      Cancel: $A.get('$Label.c.Cancel'),
      Submit: $A.get('$Label.c.Submit'),
      Gender: $A.get('$Label.c.Gender'),
      CompleteThisField: $A.get('$Label.c.Complete_this_field'),
      FillAccountTitle: $A.get('$Label.c.FillAccount_Title'),//Fill fields in Account',
      FirstName: $A.get('$Label.c.FillAccount_FirstName'),//'FirstName',
      LastName: $A.get('$Label.c.FillAccount_LastName'),//'LastName',
      IdNumber: $A.get('$Label.c.FillAccount_IdNumber'),//'ID Number',
      IdType: $A.get('$Label.c.FillAccount_IdType'),//'ID Type',
      Phone: $A.get('$Label.c.FillAccount_Phone'),//'Phone',
      BirthDay: $A.get('$Label.c.FillAccount_BirthDay'),//'BirthDay',
      MailingApproval: $A.get('$Label.c.FillAccount_MailingApproval'),//'Mailing Approval',
      InsurerFactor: $A.get('$Label.c.FillAccount_InsurerFactor'), //'Insurer Factor'
      OtherHealthServices: $A.get('$Label.c.FillAccount_OtherHealthServices') //'Other Health Services'
    };
  },

  getEditFields: function (cmp) {
    return this.convertCmpsToArray(cmp.find('editField'));
  },

  checkModalData: function (cmp) {
    var that = this;
    var modalParams = that.modalParams(cmp);
    var modalData = modalParams.modalData || {};
    this.recordId(cmp, modalData.recordId);
  },

  fetchFormConfig: function (cmp) {
    var that = this;
    var services = that.globalServices(cmp);
    var fillAccountService = services.fillAccountService;
    var errorsService = services.errorsService;
    var recordId = that.recordId(cmp);

    that.serverError(cmp, '');
    that.isLoading(cmp, true);

    return fillAccountService.getFormConfig(recordId)
      .then(
        $A.getCallback(function (
          config
        ) {
          that.isLoading(cmp, false);
          that.config(cmp, config);
        })
      )
      .catch(
        $A.getCallback(function (err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, errorsService.buildServerErrorsString(err));
        })
      );
  },
  config: function (cmp, config) {
    var that = this;
    var editData = Object.assign({}, config.defaultEditData);
    that.editData(cmp, editData);

    that.formConfig(cmp, config);
    that.updateHealthServicesOptions(cmp);
    that.isReady(cmp, true);
  },

  editFieldChangeHandler: function (cmp, event) {
    var target = event.getSource();
    var name = this.attribute(target, 'name');
    var editData = this.editData(cmp);

    switch(name) {
      case 'insurerFactor': {
        editData.otherHealthServices = '';
        this.editData(cmp, editData);
        this.updateHealthServicesOptions(cmp);
        break;
      }
      default: {
        /*  */
      }
    }


  },

  updateHealthServicesOptions: function (cmp) {
    var editData = this.editData(cmp);
    var formConfig = this.formConfig(cmp);
    var otherHealthServicesDependences = formConfig.otherHealthServicesDependences || {};
    var options = otherHealthServicesDependences[editData.insurerFactor] || [];
    formConfig.otherHealthServicesOptions = options;
    this.formConfig(cmp, formConfig);
  },


  submit: function (cmp) {
    var that = this;
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var services = that.globalServices(cmp);
    var fillAccountService = services.fillAccountService;
    var errorsService = services.errorsService;
    var toastService = services.toastService;

    var recordId = that.recordId(cmp);
    var accountData = that.editData(cmp);

    that.serverError(cmp, '');

    var isValid = that.validate(cmp);
    if(!isValid) {
      return;
    }

    that.isLoading(cmp, true);
    fillAccountService.setAccount(recordId, accountData)
      .then(
        $A.getCallback(function (res) {
          that.isLoading(cmp, false);
          globalServiceCmp.callWithLwcContext(function (lwc) {
            toastService.success(lwc, {
              message: ' '
            });
          });
          that.refreshView();
          that.emitCloseModal(cmp, true);
        })
      )
      .catch(
        $A.getCallback(function (err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, errorsService.buildServerErrorsString(err));
        })
      );
  },


  validate: function (cmp) {
    var that = this;
    var isValid = true;

    var formFields = that.getEditFields(cmp);

    formFields.forEach(function (fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if(validity) {
        isValid = isValid && validity.valid;
      }
    });

    return isValid;
  },

  cancel: function (cmp) {
    this.emitCloseModal(cmp);
  },
  emitCloseModal: function (cmp, result) {
    var modalParams = this.modalParams(cmp);
    modalParams.resolvers.close(result);
    this.close(cmp);
  }
})