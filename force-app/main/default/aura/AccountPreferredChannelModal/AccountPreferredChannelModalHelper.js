/**@type {import('AccountPreferredChannelModal').Helper} */
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
    this.fetchChannels(cmp);
  },
  modalParams: function(cmp, value) {
    return this.attribute(cmp, 'modalParams', value);
  },
  isReady: function(cmp, value) {
    return this.attribute(cmp, 'isReady', value);
  },
  errors: function(cmp, value) {
    return this.attribute(cmp, 'errors', value);
  },

  channelOptions: function(cmp, value) {
    return this.attribute(cmp, 'channelOptions', value);
  },

  selectedChannel: function(cmp, value) {
    return this.attribute(cmp, 'selectedChannel', value);
  },
  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  additionalInputs: function(cmp, value) {
    return this.attribute(cmp, 'additionalInputs', value);
  },
  additionalInputCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('additionalInput'));
  },

  getCustomLabels: function() {
    return {
      AccountPreferredChannel: $A.get('$Label.c.Preferred_Channel'),
      SelectPreferredChannel: $A.get('$Label.c.Preferred_Channel'),
      Cancel: $A.get('$Label.c.Cancel'),
      Back: $A.get('$Label.c.Back'),
      Next: $A.get('$Label.c.Next'),
      Submit: $A.get('$Label.c.Submit'),
      PreferredChannelUpdated: $A.get('$Label.c.Preferred_Channel_Updated'),
      ChooseAnotherChannelError:
        $A.get('$Label.Choose_another_preferred_channel') ||
        'Choose another preferred channel'
    };
  },
  checkModalData: function(cmp) {
    var that = this;
    var modalParams = that.modalParams(cmp);
    var modalData = modalParams.modalData;
    this.recordId(cmp, modalData.recordId);
  },
  configLabels: function(cmp) {
    var customLabels = this.getCustomLabels();
    this.labels(cmp, customLabels);
  },
  submitHandler: function(cmp) {
    var that = this;
    var labels = that.labels(cmp);

    var isValid = that.validate(cmp);
    if (!isValid) {
      return;
    }

    var globalServiceCmp = that.globalServiceCmp(cmp);
    var services = that.globalServices(cmp);
    var prefChannelService = services.accountPreferredChannelService;
    var errorsService = services.errorsService;
    var toastService = services.toastService;
    var recordId = that.recordId(cmp);
    var selectedChannel = that.selectedChannel(cmp);
    var additonalInputsValue = that.getAdditionalInputsValue(cmp);
    that.resetErrors(cmp);
    that.isLoading(cmp, true);
    prefChannelService
      .updatePreferredChannel(recordId, selectedChannel, additonalInputsValue)
      .then(
        $A.getCallback(function(data) {
          that.isLoading(cmp, false);
          globalServiceCmp.callWithLwcContext(function(lwc) {
            toastService.success(lwc, {
              message: labels.PreferredChannelUpdated
            });
          });
          that.emitCloseModal(cmp, true);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.errors(cmp, errorsService.buildServerErrorsArray(err));
        })
      );
  },

  cancelHandler: function(cmp) {
    this.emitCloseModal(cmp);
  },
  emitCloseModal: function(cmp, result) {
    var modalParams = this.modalParams(cmp);
    modalParams.resolvers.close(result);
    this.close(cmp);
  },
  resetErrors: function(cmp) {
    this.errors(cmp, []);
  },
  closeErrorsHandler: function(cmp) {
    this.resetErrors(cmp);
  },
  fetchChannels: function(cmp) {
    var that = this;
    var services = that.globalServices(cmp);
    var prefChannelService = services.accountPreferredChannelService;
    var errorsService = services.errorsService;
    var recordId = that.recordId(cmp);
    that.resetErrors(cmp);
    that.isLoading(cmp, true);
    prefChannelService
      .getPreferredChannels(recordId)
      .then(
        $A.getCallback(function(data) {
          that.isLoading(cmp, false);
          that.configChannels(cmp, data);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.errors(cmp, errorsService.buildServerErrorsArray(err));
        })
      );
  },
  configChannels: function(cmp, data) {
    var channelOptions = data.options.map(function(item) {
      return Object.assign({}, item, { disabled: !item.isSelectable });
    });
    var defaultOption = data.defaultOption;

    if (!defaultOption) {
      defaultOption = channelOptions[0];
    }
    var selectedChannel = defaultOption ? defaultOption.value : '';
    this.staticData(cmp, data);
    this.channelOptions(cmp, channelOptions);
    this.selectedChannel(cmp, selectedChannel);
    this.updateAdditionalInputs(cmp);
  },
  validate: function(cmp) {
    var that = this;
    var isValid = true;
    var labels = that.labels(cmp);

    var additionalInputCmps = that.additionalInputCmps(cmp);
    var channelOptions = that.channelOptions(cmp);
    var selectedChannel = that.selectedChannel(cmp);

    var option = channelOptions.find(function(item) {
      return item.value === selectedChannel;
    });

    if (option && !option.isSelectable) {
      isValid = false;
      that.errors(cmp, [labels.ChooseAnotherChannelError]);
    }

    additionalInputCmps.forEach(function(fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });

    return isValid;
  },
  channelChangedHandler: function(cmp) {
    this.updateAdditionalInputs(cmp);
  },
  updateAdditionalInputs: function(cmp) {
    var that = this;
    var selectedChannel = that.selectedChannel(cmp);
    var staticData = that.staticData(cmp);
    var channelAdditionalInputsMap = staticData.additionalInputs || {};
    var additionalObj = channelAdditionalInputsMap[selectedChannel];
    var additionalInputs = [];
    if (additionalObj) {
      var inputData = Object.assign({}, additionalObj, {
        type: 'text',
        required: true
      });
      additionalInputs.push(inputData);
    }

    that.additionalInputs(cmp, additionalInputs);
  },
  getAdditionalInputsValue: function(cmp) {
    var that = this;
    var value = '';
    var additionalInputs = that.additionalInputs(cmp);
    if (additionalInputs.length > 0) {
      value = additionalInputs[0].value;
    }
    return value;
  }
});