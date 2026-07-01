/**@type {import("AppointmentsFileForm").Helper} */
({
  init: function(cmp) {
    this.fetchFormData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  caseId: function(cmp, value) {
    return this.attribute(cmp, 'caseId', value);
  },
  procedureCode: function(cmp, value) {
    return this.attribute(cmp, 'procedureCode', value);
  },
  formData: function(cmp, value) {
    return this.attribute(cmp, 'formData', value);
  },
  formFields: function(cmp, value) {
    return this.attribute(cmp, 'formFields', value);
  },
  isFormLoaded: function(cmp, value) {
    return this.attribute(cmp, 'isFormLoaded', value);
  },

  recordFormCmp: function(cmp) {
    return cmp.find('recordForm');
  },

  cancel: function(cmp) {
    this.close(cmp);
  },
  emitCreate: function(cmp, value) {
    this.emitEvent(cmp, 'oncreate', { value: value });
  },
  formSuccessHandler: function(cmp, fileData) {
    this.emitCreate(cmp, fileData);
    this.close(cmp);
  },
  fetchFormData: function(cmp) {
    var that = this;
    var caseId = that.caseId(cmp);
    var procedureCode = that.procedureCode(cmp);
    var params = {
      actionName: 'getFilePrepopulatedData',
      caseId: caseId,
      procedureCode: procedureCode
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(params, res);
          // that.isLoading(cmp, false);
          var recordTypeId = res.RecordTypeId;

          delete res.RecordTypeId;
          var formData = {
            RecordTypeId: recordTypeId,
            defaultFields: res
          };
          that.formData(cmp, formData);
          console.log(that.recordFormCmp(cmp));
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
        })
      );
  },
  formLoadHandler: function(cmp, recordInfo) {
    console.log('formLoadHandler');
    var isFormLoaded = this.isFormLoaded(cmp);
    if (isFormLoaded) {
      return;
    }
    this.isFormLoaded(cmp, true);
    var formData = this.formData(cmp);
    var defaultFields = formData.defaultFields;
    var labelsStructure = [
      'File Code',
      'Record Type',
      'שם מטופל',
      'האם פתח את הקישור?',
      'סוג מסמך',
      'קראתי ומאשר',
      'תת-סוג מסמך',
      'Contact',
      'מסלול',
      'קישור למסמך',
      'מועד שליחת קובץ',
      'Appointment',
      'קובץ הפניה',
      'פנייה',
      'הערות',
      'הפניה קשורה לתהליך'
    ];
    var fieldApiNames = [
      //   'Name',
      //   'RecordType',
      'Account__c',
      'isread__c',
      'file_type__c',
      'Read_and_Approve__c',
      'role__c',
      'Contact__c',
      'Channel__c',
      'URL__c',
      'Send_File_Date__c',
      'Appointment__c',
      'Medical_Procedure__c',
      'Referral_File__c',
      'Case__c',
      'Remarks__c',
      'Related_Process__c'
    ];
    var fieldsMapByName = recordInfo.objectInfo.fields;
    var recordFields = recordInfo.record.fields;
    var fields = Object.keys(fieldsMapByName).map(function(key) {
      return fieldsMapByName[key];
    });
    var fieldsMapByLabel = fields.reduce(function(acc, field) {
      acc[field.label] = field;
      return acc;
    }, {});
    var targetFields = labelsStructure
      .map(function(label) {
        return fieldsMapByLabel[label];
      })
      .filter(function(field) {
        return !!field;
      });
    var formFields2 = fieldApiNames.map(function(name) {
      return {
        name: name,
        value: defaultFields[name]
      };
    });
    console.log({
      recordInfo: this.unProxyData(recordInfo),
      formData: this.unProxyData(formData),
      fieldsMapByName: this.unProxyData(fieldsMapByName),
      fields: this.unProxyData(fields),
      fieldsCount: fields.length,
      fieldsMapByLabel: this.unProxyData(fieldsMapByLabel),
      fieldByLabelCount: Object.keys(fieldsMapByLabel).length,
      targetFields: this.unProxyData(targetFields),
      formFields2: this.unProxyData(formFields2)
    });
    this.formFields(cmp, formFields2);
    this.isLoading(cmp, false);
  },
  submitForm: function(cmp) {
    var recordFormCmp = this.recordFormCmp(cmp);
    recordFormCmp.submit();
    this.isLoading(cmp, true);
  }
});