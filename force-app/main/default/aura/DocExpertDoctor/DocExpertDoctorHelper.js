/**@type {import("DocExpertDoctor").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  doctor: function(cmp, value) {
    return this.attribute(cmp, 'doctor', value);
  },
  isFallbackImageVisible: function(cmp, value) {
    return this.attribute(cmp, 'isFallbackImageVisible', value);
  },
  isSelected: function(cmp, value) {
    return this.attribute(cmp, 'isSelected', value);
  },
  isRecommended: function(cmp, value) {
    return this.attribute(cmp, 'isRecommended', value);
  },
  currentInfo: function(cmp, value) {
    return this.attribute(cmp, 'currentInfo', value);
  },
  isInfoLoading: function(cmp, value) {
    return this.attribute(cmp, 'isInfoLoading', value);
  },
  clinics: function(cmp, value) {
    return this.attribute(cmp, 'clinics', value);
  },
  config: function(cmp) {
    var doctor = this.doctor(cmp);
    if (!doctor) {
      return;
    }
    var recommendedDoctors = this.recommendedDoctors(cmp);
    var docIndex = recommendedDoctors.findIndex(function(item) {
      return item.doctorId === doctor.doctorId;
    });
    var isRecommended = docIndex >= 0;
    this.isRecommended(cmp, isRecommended);
  },
  pictureErrorHandler: function(cmp) {
    this.isFallbackImageVisible(cmp, true);
  },
  doctorActionHandler: function(cmp, actionName) {
    var doctor = this.doctor(cmp);
    /**@type {import('DocExpertBase').DoctorActionEventValue} */
    var actionValue = {
      action: actionName,
      doctor: doctor
    };
    this.emitAction(cmp, actionValue);
  },
  emitAction: function(cmp, value) {
    this.emitEvent(cmp, 'ondocaction', { value: value });
  },
  showClinicsInfo: function(cmp) {
    var that = this;
    var recordId = this.recordId(cmp);
    var doctor = this.doctor(cmp);
    var doctorId = doctor.doctorId;
    var clinics = this.clinics(cmp);
    if (clinics.length > 0) {
      return;
    }
    that.isInfoLoading(cmp, true);
    that
      .fetchDoctorClinics(cmp, doctorId, recordId)
      .then(
        $A.getCallback(function(clinics) {
          that.isInfoLoading(cmp, false);
          that.clinics(cmp, clinics);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isInfoLoading(cmp, false);
        })
      );
  },
  showInfo: function(cmp, infoType) {
    this.currentInfo(cmp, infoType);
    switch (infoType) {
      case 'clinics': {
        return this.showClinicsInfo(cmp);
      }
    }
  }
});