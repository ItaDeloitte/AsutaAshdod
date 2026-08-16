/**@type {import("DocExpertBase").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},
  controllers: {
    LC_DocExpertise: 'LC_DocExpertiseController'
  },
  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  doctors: function(cmp, value) {
    return this.attribute(cmp, 'doctors', value);
  },
  selectedDoctorId: function(cmp, value) {
    return this.attribute(cmp, 'selectedDoctorId', value);
  },
  recommendedDoctors: function(cmp, value) {
    return this.attribute(cmp, 'recommendedDoctors', value);
  },
  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },
  fetchDoctorClinics: function(cmp, doctorId, recordId) {
    var that = this;
    var params = {
      actionName: 'getClinics',
      caseId: recordId,
      doctorId: doctorId
    };
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.LC_DocExpertise,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(function(data) {
        var clinics = (data || []).map(function(item) {
          /*  Clinic__r.street_address__c + " ," + Clinic__r.Address__c */
          // var payerFactor = item.Payer_Factor__r;
          var payerFactorName = item.PayerFactorMulti__c || '';
          var clinicRef = item.Clinic__r;
          var address = [clinicRef.street_address__c, clinicRef.Address__c]
            .filter(function(item) {
              return !!item;
            })
            .join(', ');
          return Object.assign(item, {
            Address: address,
            payerFactorName: payerFactorName
          });
        });
        console.log(params, clinics);
        return clinics;
      });
  }
});