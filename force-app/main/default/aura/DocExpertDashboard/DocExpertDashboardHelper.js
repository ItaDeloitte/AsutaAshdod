/**@type {import("DocExpertDashboard").Helper} */
({
  init: function(cmp) {
    this.fetchStaticData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  CONSTANTS: {
    maxRecommendedDoctors: 3,
    defaultRankValue: 1
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  filters: function(cmp, value) {
    return this.attribute(cmp, 'filters', value);
  },
  filterOptions: function(cmp, value) {
    return this.attribute(cmp, 'filterOptions', value);
  },
  sortBy: function(cmp, value) {
    return this.attribute(cmp, 'sortBy', value);
  },
  isRecommendChanged: function(cmp, value) {
    return this.attribute(cmp, 'isRecommendChanged', value);
  },

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  editFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('editField'));
  },
  findAutocompleteEditField: function(cmp, fieldName) {
    return this.findEditField(cmp, fieldName);
  },
  findMultiSelectEditField: function(cmp, fieldName) {
    return this.findEditField(cmp, fieldName);
  },
  findEditField: function(cmp, fieldName) {
    var that = this;
    var editFieldCmps = that.editFieldCmps(cmp);
    return editFieldCmps.find(function(item) {
      var name = that.attribute(item, 'name');
      return name === fieldName;
    });
  },
  subExpertiseFieldCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'subExpertise');
  },
  expertiseFieldCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'expertise');
  },
  procedureFieldCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'procedure');
  },
  agreementsFieldCmp: function(cmp) {
    return this.findMultiSelectEditField(cmp, 'agreements');
  },
  arrangmentsFieldCmp: function(cmp) {
    return this.findMultiSelectEditField(cmp, 'arrangments');
  },
  areaFieldCmp: function(cmp) {
    return this.findMultiSelectEditField(cmp, 'area');
  },

  sliderCmp: function(cmp) {
    return cmp.find('slider');
  },
  filteredDoctors: function(cmp, value) {
    return this.attribute(cmp, 'filteredDoctors', value);
  },
  filteredAndSortedDoctors: function(cmp, value) {
    return this.attribute(cmp, 'filteredAndSortedDoctors', value);
  },
  selectedEditAutocompleteRelation: function(cmp, value) {
    return this.attribute(cmp, 'selectedEditAutocompleteRelation', value);
  },

  isNotFoundMessageVisible: function(cmp, value) {
    return this.attribute(cmp, 'isNotFoundMessageVisible', value);
  },

  fetchStaticData: function(cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var params = {
      actionName: 'docExpertise',
      caseId: caseId
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('DocExpertBase').StaticDataRes} */ staticDataRes
        ) {
          console.log(params, staticDataRes);
          that.config(cmp, staticDataRes);
          that.isLoading(cmp, false);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.showToast({
            message: that.buildHtmlServerError(err),
            title: $A.get('$Label.c.Error'),
            type: 'error'
          });
          that.close(cmp);
        })
      );
  },
  config: function(cmp, staticDataRes) {
    var that = this;
    var editData = that.editData(cmp);
    var staticData = that.transformStaticDataRes(staticDataRes);
    var selectedDoctorId = staticData.selectedDoctorId;
    if (selectedDoctorId) {
      // that.emitCloseDocExpModal(cmp, staticData.selectedDoctorId);
      that.showClinicsModal(cmp, selectedDoctorId);
      return;
    }

    editData = Object.assign({}, editData);

    if (staticData.defaultPayerFactorValues) {
      editData.arrangments = staticData.defaultArrangementFactorValues.slice();
      editData.agreements = staticData.defaultAgreementFactorValues.slice();
    }
    if (staticData.defaultAreaValues) {
      editData.area = staticData.defaultAreaValues.slice();
    }
    that.editData(cmp, editData);
    that.staticData(cmp, staticData);
    if (staticData.defaultExpertise) {
      var expertiseFieldCmp = that.expertiseFieldCmp(cmp);
      expertiseFieldCmp.setOption(staticData.defaultExpertise);
    }
    if (staticData.defaultSubExpertise) {
      var subExpertiseFieldCmp = that.subExpertiseFieldCmp(cmp);
      subExpertiseFieldCmp.setOption(staticData.defaultSubExpertise);
    }
    if (staticData.defaultProcedure) {
      var procedureFieldCmp = that.procedureFieldCmp(cmp);
      procedureFieldCmp.setOption(staticData.defaultProcedure);
    }
    setTimeout(
      $A.getCallback(function() {
        that.searchDoctors(cmp, true);
      })
    );
    console.log({
      staticDataRes: staticDataRes,
      staticData: staticData
    });
  },
  resetSearchHandler: function(cmp) {
    var staticData = this.staticData(cmp);

    var procedureFieldCmp = this.procedureFieldCmp(cmp);
    var expertiseFieldCmp = this.expertiseFieldCmp(cmp);
    var subExpertiseFieldCmp = this.subExpertiseFieldCmp(cmp);
    var agreementsFieldCmp = this.agreementsFieldCmp(cmp);
    var arrangmentsFieldCmp = this.arrangmentsFieldCmp(cmp);
    var areaFieldCmp = this.areaFieldCmp(cmp);

    if (staticData.defaultProcedure) {
      procedureFieldCmp.setOption(staticData.defaultProcedure);
    } else {
      procedureFieldCmp.reset();
    }
    if (staticData.defaultExpertise) {
      expertiseFieldCmp.reset();
    } else {
      expertiseFieldCmp.setOption(staticData.defaultSubExpertise);
    }
    if (staticData.defaultSubExpertise) {
      subExpertiseFieldCmp.reset();
    } else {
      subExpertiseFieldCmp.setOption(staticData.defaultSubExpertise);
    }

    areaFieldCmp.setValue(
      staticData.areaOptions.map(function(item) {
        return item.value;
      })
    );
    agreementsFieldCmp.setValue(
      staticData.agreementFactorOptions.map(function(item) {
        return item.value;
      })
    );
    arrangmentsFieldCmp.setValue(
      staticData.arrangementFactorOptions.map(function(item) {
        return item.value;
      })
    );

    procedureFieldCmp.triggerSearch();
    expertiseFieldCmp.triggerSearch();
    subExpertiseFieldCmp.triggerSearch();
  },

  transformStaticDataRes: function(data) {
    /**@type {import('DocExpertBase').ProcedureOption} */
    var defaultProcedure = null;
    /**@type {import('DocExpertBase').ExpertiseOption} */
    var defaultExpertise = null;
    /**@type {import('DocExpertBase').SubExpertiseOption} */
    var defaultSubExpertise = null;
    var defaultPayerFactorValues = data.payerFactorValues.map(function(item) {
      return item.value;
    });
    var defaultAreaValues = data.defaultAreas.map(function(item) {
      return item.value;
    });
    var defaultAgreementFactorValues = data.defaultAgreementFactorValues.map(
      function(item) {
        return item.value;
      }
    );
    var defaultArrangementFactorValues = data.defaultArrangementFactorValues.map(
      function(item) {
        return item.value;
      }
    );
    if (data.defaultProcedure) {
      defaultProcedure = this.buildProceduresOption(data.defaultProcedure);
    }
    if (data.defaultExpertise) {
      var expertise = data.defaultExpertise;
      defaultExpertise = Object.assign({}, expertise, {
        label: expertise.Name,
        value: expertise.Id
      });
    }
    if (data.defaultSubExpertise) {
      var subExpertise = data.defaultSubExpertise;
      defaultSubExpertise = Object.assign({}, subExpertise, {
        label: subExpertise.Name,
        value: subExpertise.Id
      });
    }

    /**@type {import('DocExpertBase').Option[]} */
    //DocQuantity
    //DocRank
    var sortOptions = [
      { label: $A.get('{!$Label.c.DocQuantity}'), value: 'quantity' }
      // { label: $A.get('{!$Label.c.DocRank}'), value: 'rank' }
    ];
    /**@type {import('DocExpertBase').StaticData} */
    var staticData = {
      sortOptions: sortOptions,
      areaOptions: data.areaValues,
      payerFactorOptions: data.payerFactorValues,
      agreementFactorOptions: data.agreementFactorValues,
      arrangementFactorOptions: data.arrangementFactorValues,
      defaultPayerFactors: data.defaultPayerFactors,
      defaultProcedure: defaultProcedure,
      defaultAreas: data.defaultAreas,
      defaultExpertise: defaultExpertise,
      defaultSubExpertise: defaultSubExpertise,
      defaultAreaValues: defaultAreaValues,
      defaultPayerFactorValues: defaultPayerFactorValues,
      defaultAgreementFactorValues: defaultAgreementFactorValues,
      defaultArrangementFactorValues: defaultArrangementFactorValues,
      selectedDoctorId: data.selectedDoctorId
    };
    return staticData;
  },
  searchProcedure: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var params = {
      actionName: 'procedureSearch',
      procedureName: term,
      subExpertiseId: editData.subExpertise
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          console.log(params, data);
          var options = data.map(function(item) {
            return that.buildProceduresOption(item);
          });
          return options;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  searchExpertise: function(cmp, term) {
    var that = this;
    var params = {
      actionName: 'expertiseSearch',
      expertiseName: term
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          var options = that.buildExpertiseOptions(data);
          return options;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  searchSubExpertise: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var params = {
      actionName: 'subExpertiseSearch',
      expertiseId: editData.expertise,
      subExpertiseName: term
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          var options = that.buildExpertiseOptions(data);
          return options;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  searchDoctors: function(cmp, isConfig) {
    isConfig = !!isConfig;
    var that = this;
    if (!isConfig) {
      var isFormValid = that.validateEditForm(cmp, true);
      if (!isFormValid) {
        return;
      }
    }
    var caseId = this.recordId(cmp);
    var editData = that.editData(cmp);
    var params = {
      actionName: 'doctorSearch',
      caseId: caseId,
      onlyRecommended: isConfig,
      procedureId: editData.procedure,
      expertiseId: editData.expertise,
      subExpertiseId: editData.subExpertise,
      agreementPayerFactors: JSON.stringify(editData.agreements),
      arrangmentPayerFactors: JSON.stringify(editData.arrangments),
      areas: JSON.stringify(editData.area)
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that.isNotFoundMessageVisible(cmp, false);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('DocExpertBase').DoctorsRes} */ data
        ) {
          console.log(params, data);

          that.isLoading(cmp, false);
          var filterOptions = that.buildFilterOptions(data);
          that.filterOptions(cmp, filterOptions);
          var doctors = that.buildDoctors(cmp, data.doctors);
          that.doctors(cmp, doctors);
          var oldFilters = that.filters(cmp);
          var filters = that.buildFilters(cmp, oldFilters, doctors, isConfig);
          that.filters(cmp, filters);
          that.filterDoctors(cmp);
          that.sortDoctors(cmp);
          that.selectedDoctorId(cmp, null);
          var recommendedDoctors = doctors.filter(function(item) {
            return item.isRecommended;
          });
          that.recommendedDoctors(cmp, recommendedDoctors);
          that.isNotFoundMessageVisible(cmp, !isConfig && doctors.length === 0);
          that.isRecommendChanged(cmp, false);
          console.log({
            data: data,
            doctors: doctors,
            filterOptions: filterOptions
          });
          that.triggerLookupFilterSearch(cmp, '');
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  validateEditForm: function(cmp, showValidationMessages) {
    var isValid = true;
    var editFieldCmps = this.editFieldCmps(cmp);
    editFieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      if (showValidationMessages) {
        fieldCmp.showHelpMessageIfInvalid();
      }
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },
  filterDoctors: function(cmp) {
    var that = this;
    var doctors = that.doctors(cmp);
    var filters = that.filters(cmp);
    var filterOptions = that.filterOptions(cmp);
    var filteredDoctors = doctors
      .filter(filterByGender)
      .filter(filterByProcedure)
      .filter(filterByRank)
      .filter(filterByDegree)
      .filter(filterBySite)
      .filter(filterByArrangment)
      .filter(filterByAgreement)
      .filter(filterByExpert)
      .filter(filterByOperationsInLastMonths);
    that.filteredDoctors(cmp, filteredDoctors);

    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByGender(doc) {
      return filters.gender ? doc.gender === filters.gender : true;
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByRank(doc) {
      return doc.rank >= filters.rank;
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByDegree(doc) {
      return filters.degree ? doc.degree === filters.degree : true;
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByProcedure(doc) {
      var currentFilters = filters.procedures;
      if (
        currentFilters.length === 0 ||
        currentFilters.length === filterOptions.procedureOptions.length
      ) {
        return true;
      }
      return currentFilters.some(function(item) {
        return !!doc.proceduresMap[item];
      });
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterBySite(doc) {
      var currentFilters = filters.sites;
      if (
        currentFilters.length === 0 ||
        currentFilters.length === filterOptions.siteOptions.length
      ) {
        return true;
      }
      return currentFilters.some(function(item) {
        return !!doc.sitesMap[item];
      });
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByAgreement(doc) {
      var currentFilters = filters.agreements;
      if (
        currentFilters.length === 0 ||
        currentFilters.length === filterOptions.agreementOptions.length
      ) {
        return true;
      }
      return currentFilters.some(function(item) {
        return !!doc.agreementsMap[item];
      });
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByArrangment(doc) {
      var currentFilters = filters.arrangments;
      if (
        currentFilters.length === 0 ||
        currentFilters.length === filterOptions.arrangmentOptions.length
      ) {
        return true;
      }
      return currentFilters.some(function(item) {
        return !!doc.arrangmentsMap[item];
      });
    }
    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByExpert(doc) {
      
      if (filters.expert) { // changed by CRM request to change Experts logic
        return (doc.isExpert || doc.isPromoted);
      }
      return true;
    }

    /**@type {import('DocExpertDashboard').FilterDocFn} */
    function filterByOperationsInLastMonths(doc) {
      if (filters.operationsInLastMonths) {
        return doc.quantity >= 2;
      }
      return true;
    }
  },
  sortDoctors: function(cmp) {
    var sortBy = this.sortBy(cmp);
    var doctors = this.filteredDoctors(cmp).slice();
    /**@type {import('DocExpertDashboard').SortDocCompare} */
    var sortFn = null;
    if (sortBy === 'quantity') {
      sortFn = quantityCompare;
    } else if (sortBy === 'rank') {
      sortFn = rankCompare;
    }
    if (sortFn) {
      doctors.sort(sortFn);
    }
    /**@type {import('DocExpertDashboard').SortDocCompare} */
    function quantityCompare(doc1, doc2) {
      return doc2.quantity - doc1.quantity;
    }
    /**@type {import('DocExpertDashboard').SortDocCompare} */
    function rankCompare(doc1, doc2) {
      return doc2.rank - doc1.rank;
    }

    this.filteredAndSortedDoctors(cmp, doctors);
    // this.slideDoctorsToIndex(cmp, 0);
  },
  buildExpertiseOptions: function(data) {
    return data.map(function(item) {
      return Object.assign({}, item, { label: item.Name, value: item.Id });
    });
  },
  buildProceduresOption: function(data) {
    if (!data) {
      return null;
    }
    var label = data.Marketing_Procedure_Name__c || data.Name;
    return Object.assign({}, data, {
      label: label,
      value: data.Id,
      labelHtml: label + ' - ' + data.Procedure_Code__c
    });
  },
  buildFilterOptions: function(data) {
    /**@type {import('DocExpertBase').FilterOptions} */
    var filterOptions = {
      arrangmentOptions: data.arrangmentFactorValues,
      arrangmentOptionsMap: this.buildOptionsMap(data.arrangmentFactorValues),
      agreementOptions: data.agreementFactorValues,
      agreementOptionsMap: this.buildOptionsMap(data.agreementFactorValues),
      degreeOptions: data.degreeValues,
      degreeOptionsMap: this.buildOptionsMap(data.degreeValues),
      genderOptions: data.genderValues,
      genderOptionsMap: this.buildOptionsMap(data.genderValues),
      insuranceFactorOptions: data.insuranceFactorValues,
      insuranceFactorOptionsMap: this.buildOptionsMap(
        data.insuranceFactorValues
      ),
      procedureOptions: data.procedureValues,
      procedureOptionsMap: this.buildOptionsMap(data.procedureValues),
      minRank: data.rankValues[0],
      maxRank: data.rankValues[1],
      siteOptions: data.siteValues,
      siteOptionsMap: this.buildOptionsMap(data.siteValues)
    };
    return filterOptions;
  },
  buildDoctors: function(cmp, data) {
    var that = this;
    var filterOptions = that.filterOptions(cmp);
    var genderOptionsMap = filterOptions.genderOptionsMap;
    var degreeOptionsMap = filterOptions.degreeOptionsMap;
    var insuranceFactorOptionsMap = filterOptions.insuranceFactorOptionsMap;
    var procedureOptionsMap = filterOptions.procedureOptionsMap;
    var siteOptionsMap = filterOptions.siteOptionsMap;
    var agreementOptionsMap = filterOptions.agreementOptionsMap;
    var arrangmentOptionsMap = filterOptions.arrangmentOptionsMap;

    /**@type {import('DocExpertDashboard').BuildDoctorOptions} */
    function buildDoctorOptions(ids, optionsMap) {
      return ids
        .map(function(id) {
          var option = optionsMap[id];
          if (!option) {
            console.error(
              'Id: ' + id + ' is missed in optionsMap:',
              that.unProxyData(optionsMap)
            );
          }
          return option;
        })
        .filter(function(option) {
          return !!option;
        });
    }
    return data.map(function(doctor) {
      var img = that.parseDoctorPicture(doctor.picture);
      var degree = degreeOptionsMap[doctor.degree];
      var gender = genderOptionsMap[doctor.gender];

      var procedures = buildDoctorOptions(
        doctor.procedures,
        procedureOptionsMap
      );
      var proceduresMap = that.buildOptionsMap(procedures);

      var insurenceFactors = buildDoctorOptions(
        doctor.insuranceFactors,
        insuranceFactorOptionsMap
      );
      var insurenceFactorsMap = that.buildOptionsMap(insurenceFactors);

      var sites = buildDoctorOptions(doctor.sites, siteOptionsMap);
      var sitesMap = that.buildOptionsMap(sites);

      var arrangments = buildDoctorOptions(
        doctor.arrangmentInsuranceFactors,
        arrangmentOptionsMap
      );

      var arrangmentsMap = that.buildOptionsMap(arrangments);

      var agreements = buildDoctorOptions(
        doctor.agreementInsuranceFactors,
        agreementOptionsMap
      );
      var agreementsMap = that.buildOptionsMap(agreements);

      /**@type {import('DocExpertBase').DoctorExtraFields} */
      var docExtraFields = {
        img: img,
        degreeName: degree ? degree.label : '',
        genderName: gender ? gender.label : '',
        rank: doctor.rank || 1,
        procedures: procedures,
        proceduresMap: proceduresMap,
        proceduresLabel: '',
        insuranceFactors: insurenceFactors,
        insuranceFactorsMap: insurenceFactorsMap,
        sites: sites,
        sitesMap: sitesMap,
        agreements: agreements,
        agreementsMap: agreementsMap,
        arrangments: arrangments,
        arrangmentsMap: arrangmentsMap
      };
      /**@type {import('DocExpertBase').Doctor} */
      var buildedDoctor = Object.assign({}, doctor, docExtraFields);
      return buildedDoctor;
    });
  },
  parseDoctorPicture: function(str) {
    if (!str) {
      return null;
    }
    var matched = str.match(/src="(.+?)"/);
    if (matched) {
      return matched[1];
    }
    return str;
  },
  buildOptionsMap: function(data, key) {
    var that = this;
    key = key || 'value';
    return data.reduce(function(acc, item) {
      try {
        acc[item[key]] = item;
        return acc;
      } catch (err) {
        console.log(err);
        console.log(that.unProxyData(data), key);
        return acc;
      }
    }, {});
  },
  buildFilters: function(cmp, oldFilters, doctors, isConfig) {
    // console.log(arguments);
    var expert = isConfig ? false : true;
    // var expert = false;

    /**@type {import('DocExpertDashboard').Filters} */
    var filters = {
      degree: '',
      gender: '',
      procedures: [],
      procedureOptions: [],
      rank: this.CONSTANTS.defaultRankValue,
      sites: [],
      arrangments: [],
      agreements: [],
      expert: expert,
      operationsInLastMonths: false
    };
    return filters;
  },
  changeFilterHandler: function(cmp) {
    var that = this;
    that.isLoading(cmp, true);
    setTimeout(
      $A.getCallback(function() {
        that.filterDoctors(cmp);
        that.sortDoctors(cmp);
        that.selectedDoctorId(cmp, '');
        that.recommendedDoctors(cmp, []);
        that.slideDoctorsToIndex(cmp, 0);
        that.isLoading(cmp, false);
      }),
      100
    );
  },

  changeSortHandler: function(cmp) {
    var that = this;
    that.isLoading(cmp, true);
    setTimeout(
      $A.getCallback(function() {
        that.sortDoctors(cmp);
        that.isLoading(cmp, false);
      }),
      100
    );
  },
  changeProcedureHandler: function(cmp, option) {
    var subExpertiseFieldCmp = this.subExpertiseFieldCmp(cmp);
    var expertiseFieldCmp = this.expertiseFieldCmp(cmp);
    if (!option) {
      // subExpertiseFieldCmp.reset(false);
      // expertiseFieldCmp.reset(false);
      return;
    }
    var subExpertise = option.Sub_Expertise__r;
    if (!subExpertise) {
      return;
    }
    /**@type {import('DocExpertBase').SubExpertiseOption} */
    var subExpertiseOption = Object.assign(subExpertise, {
      label: subExpertise.Name,
      value: subExpertise.Id
    });
    var expertise = subExpertise.Expertise__r;
    /**@type {import('DocExpertBase').ExpertiseOption} */
    var expertiseOption = Object.assign(expertise, {
      label: expertise.Name,
      value: expertise.Id
    });
    expertiseFieldCmp.setOption(expertiseOption);
    subExpertiseFieldCmp.setOption(subExpertiseOption);
  },
  changeSubExpertiseHandler: function(cmp, option) {
    var procedureFieldCmp = this.procedureFieldCmp(cmp);
    procedureFieldCmp.reset();
    procedureFieldCmp.triggerSearch();

    if (!option) {
      return;
    }
    var expertise = option.Expertise__r;
    if (!expertise) {
      return;
    }
    var expertiseFieldCmp = this.expertiseFieldCmp(cmp);
    /**@type {import('DocExpertBase').ExpertiseOption} */
    var expertiseOption = Object.assign(expertise, {
      label: expertise.Name,
      value: expertise.Id
    });
    expertiseFieldCmp.setOption(expertiseOption);
  },
  changeExpertiseHandler: function(cmp, option) {
    var subExpertiseFieldCmp = this.subExpertiseFieldCmp(cmp);
    var procedureFieldCmp = this.procedureFieldCmp(cmp);
    subExpertiseFieldCmp.reset();
    procedureFieldCmp.reset();
    subExpertiseFieldCmp.triggerSearch();
    procedureFieldCmp.triggerSearch();
  },
  selectDoctor: function(cmp, doctor) {
    var recommendedDoctors = this.recommendedDoctors(cmp);
    var docIndex = recommendedDoctors.findIndex(function(item) {
      return item.doctorId === doctor.doctorId;
    });
    if (docIndex < 0) {
      return;
    }
    var doctorId = doctor.doctorId;
    this.scheduleAppointment(cmp, doctorId);
  },
  recommendDoctor: function(cmp, doctor) {
    var selectedDoctorId = this.selectedDoctorId(cmp);
    var recommendedDoctors = this.recommendedDoctors(cmp).slice();
    var docIndex = recommendedDoctors.findIndex(function(item) {
      return item.doctorId === doctor.doctorId;
    });
    if (docIndex < 0) {
      if (recommendedDoctors.length < this.CONSTANTS.maxRecommendedDoctors) {
        recommendedDoctors.push(doctor);
        this.isRecommendChanged(cmp, true);
      }
    } else {
      recommendedDoctors.splice(docIndex, 1);
      if (selectedDoctorId === doctor.doctorId) {
        this.selectedDoctorId(cmp, '');
      }
      this.isRecommendChanged(cmp, true);
    }
    this.recommendedDoctors(cmp, recommendedDoctors);
  },
  save: function(cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var recDocIds = that.buildRecommendedDoctorIds(cmp);
    var params = {
      actionName: 'saveCase',
      caseId: caseId,
      recDocIds: recDocIds
    };
    console.log(params);
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(message) {
          console.log(message);
          that.isLoading(cmp, false);
          that.refreshView();
          that.showToast({
            message: message,
            title: $A.get('$Label.c.Success'),
            type: 'success'
          });
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  scheduleAppointment: function(cmp, selectedDoctorId) {
    var that = this;
    var caseId = that.recordId(cmp);
    var recDocIds = that.buildRecommendedDoctorIds(cmp);
    var params = {
      actionName: 'scheduleAppointment',
      caseId: caseId,
      recDocIds: recDocIds,
      chosenDocId: selectedDoctorId
    };
    console.log(params);
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Doctor_selected')
          });
          that.refreshView();
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  sendDocAdv: function(cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var recDocIds = that.buildRecommendedDoctorIds(cmp);

    var params = {
      actionName: 'sendDocAdvisor',
      caseId: caseId,
      recDocIds: recDocIds
    };
    console.log(params);
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(message) {
          console.log(message);
          that.isLoading(cmp, false);
          that.refreshView();
          that.showToast({
            message: message,
            title: $A.get('$Label.c.Success'),
            type: 'success'
          });
          that.isRecommendChanged(cmp, false);
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  buildRecommendedDoctorIds: function(cmp) {
    var recommendedDoctors = this.recommendedDoctors(cmp);
    var recDocIds = recommendedDoctors.map(function(item) {
      return item.doctorId;
    });
    return recDocIds;
  },
  emitCloseDocExpModal: function(cmp, selectedDoctorId) {
    /**@type {import('DocExpertBase').CloseModalEventParams} */
    var params = {
      modalName: 'dashboard',
      data: selectedDoctorId
    };
    this.emitEvent(cmp, 'onCloseModal', { value: params });
    this.close(cmp);
  },
  slideDoctorsToIndex: function(cmp, index) {
    var that = this;
    setTimeout(
      $A.getCallback(function() {
        var sliderCmp = that.sliderCmp(cmp);
        if (sliderCmp) {
          sliderCmp.slideTo(index);
        }
      })
    );
  },
  filterCheckboxChangeHandler: function(cmp, name, value) {
    var filters = this.filters(cmp);
    filters[name] = value;
    this.filters(cmp, filters);
  },
  searchLookupFilterHandler: function(cmp, lookupCmp, params) {
    var customKey = lookupCmp.getkey();
    var searchTerm = params.searchTerm;
    var selectedIds = params.selectedIds || [];
    switch (customKey) {
      case 'procedure': {
        this.searchFilterProcedures(cmp, lookupCmp, searchTerm, selectedIds);
        break;
      }
    }
  },
  searchFilterProcedures: function(cmp, lookupCmp, term, selectedIds) {
    var that = this;
    setTimeout(
      $A.getCallback(function() {
        var filterOptions = that.filterOptions(cmp);
        var procedureOptions = filterOptions.procedureOptions || [];
        var searchResults = procedureOptions
          .filter(function(item) {
            var value = item.value;
            var label = item.label;
            var isSelected = selectedIds.indexOf(value) >= 0;
            return (
              !isSelected &&
              label.toLowerCase().indexOf(term.toLowerCase()) >= 0
            );
          })
          .map(function(option) {
            return { title: option.label, id: option.value };
          });
        lookupCmp.setSearchResults(searchResults);
      }),
      50
    );
  },
  changeLookupFilterHandler: function(cmp, lookupCmp) {
    var customKey = lookupCmp.getkey();
    var selectedOptions = lookupCmp.getSelection();
    var selectedIds = selectedOptions.map(function(item) {
      return item.id;
    });
    var filters = this.filters(cmp);
    filters.procedureOptions = selectedOptions;
    filters.procedures = selectedIds;
    // filters[customKey] = selectedIds;
    this.filters(cmp, filters);
    this.changeFilterHandler(cmp);
  },
  triggerLookupFilterSearch: function(cmp, lookupKey) {
    var lookup = cmp.find('lookupFilter');
    if (lookup) {
      // @ts-ignore
      lookup.triggerSearch();
    }
  },
  showClinicsModal: function(cmp, doctorId) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var caseId = that.recordId(cmp);
    var cmpName = 'DocExpertClinicsModal';
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: caseId,
        doctorId: doctorId
      },
      function(preparedCmp, status, message) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' clinics-modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(function(modalRef) {
              that.isLoading(cmp, false);
              that.close(cmp);
            });
        } else {
          console.log(status, message);
          that.isLoading(cmp, false);
          that.close(cmp);
        }
      }
    );
  }
});