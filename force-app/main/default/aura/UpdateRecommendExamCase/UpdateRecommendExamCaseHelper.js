/**@type {import("UpdateRecommendExamCase").Helper} */
({
  init: function(cmp) {
    this.fetchCase(cmp);
  },
  CONSTANTS: {},
  destroy: function(cmp) {},
  render: function(cmp) {},
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  selectedCaseId: function(cmp, value) {
    return this.attribute(cmp, 'selectedCaseId', value);
  },
  formFieldCmp: function(cmp) {
    return cmp.find('formField');
  },
  searchCases: function(cmp, term) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      recordId: recordId,
      actionName: 'obtainCases',
      keyWord: term
    };
    return that
      .recommendExamCaseRequest(cmp, params)
      .then(
        $A.getCallback(function(data) {
          var cases = data.map(function(item) {
            return Object.assign(item, {
              label: item.CaseNumber,
              value: item.Id
            });
          });
          return cases;
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
    var that = this;
    var isValid = that.validate(cmp);
    if (!isValid) {
      return;
    }
    var recordId = that.recordId(cmp);
    var caseId = that.selectedCaseId(cmp);
    var params = {
      recordId: recordId,
      caseId: caseId,
      actionName: 'setCase'
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .recommendExamCaseRequest(cmp, params)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          that.showToast({
            title: 'Success',
            message: 'Recommend Exam updated',
            type: 'success'
          });
          that.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          var errMessage = that.buildHtmlServerError(err);
          that.serverError(cmp, errMessage);
        })
      );
  },
  fetchCase: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);

    var params = {
      recordId: recordId,
      actionName: 'getCase'
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .recommendExamCaseRequest(cmp, params)
      .then(
        $A.getCallback(function(data) {
          that.isLoading(cmp, false);
          if (data && data.Id) {
            var option = {
              label: data.CaseNumber,
              value: data.Id
            };
            that.formFieldCmp(cmp).setOption(option);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          var errMessage = that.buildHtmlServerError(err);
          that.serverError(cmp, errMessage);
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
  },
  recommendExamCaseRequest: function(cmp, params) {
    var controllerName = 'LC_RecommendExamCase';
    var requestParams = {
      controllerName: controllerName,
      params: params
    };
    console.log(requestParams);
    return this.executeApex(cmp, requestParams)
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        console.log(requestParams, res);
        return res;
      })
      .catch(function(err) {
        console.log(requestParams, err);
        throw err;
      });
  }
});