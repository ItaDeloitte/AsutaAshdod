import { api, track } from 'lwc';
import { modalService } from 'c/modalService';
import { loadDashboardStyles, doctorActions } from 'c/docExpertService';
import { utils } from 'c/utils';
import { LightningElementWithNavigation } from 'c/abstractComponents';
import { auraLwcBridgeService } from 'c/auraLwcBridgeService';
import { errorsService } from 'c/errorsService';
import { toastService } from 'c/toastService';
import { labels } from './labels';
import { formFieldNames, searchTypes, SORT_BY } from './constants';
import { dashboardService } from './service';
import {
  buildDefaultFilters,
  buildSearchResult,
  buildSerchTypeFields,
  searchFilterProcedures
} from './utils';
import { docSort } from './docSort';
import { docFilter } from './docFilter';
import Surgery_indicator from "@salesforce/resourceUrl/Surgery_indicator";

/**@typedef {DocExpertServiceTypes.Doctor} Doctor */
/**@typedef {DocExpertServiceTypes.DocActionDetails} DocActionDetails */

/**@typedef {DocExpertDashboardModalTypes.InitData} InitData */
/**@typedef {DocExpertDashboardModalTypes.Filters} Filters */
/**@typedef {DocExpertDashboardModalTypes.SearchResult} SearchResult */
/**@typedef {DocExpertDashboardModalTypes.FormValues} FormValues */

/** DocExpertDashboardModal */
export default class DocExpertDashboardModal extends LightningElementWithNavigation {
  @api modalParams;
  recordId = '';
  /**@type {Filters} */
  @track filters = buildDefaultFilters();
  /**@type {FormValues} */
  @track formValues = {
    expertise: null,
    subExpertise: null,
    procedure: null,
    settlements: [],
    arrangements: [],
    doctorName: ''
  };

  /**@type {InitData} */
  initData;

  lookupConfig = {
    minSearchTermLength: 0
  };

  /**@type {SearchResult} */
  searchResult = {
    doctors: [],
    filterOptions: {
      genders: [],
      arrangements: [],
      degrees: [],
      procedures: [],
      sites: []
    }
  };

  /**@type {Doctor[]} */
  filteredDoctors = [];
  /**@type {Doctor[]} */
  filteredAndSortedDoctors = [];
  /**@type {Object<string,string>} */
  recommendedMap = {};
  selectedDoctorId = '';
  isRecommendedChanged = false;

  selectedSearchType = searchTypes.byComingWeek;
  sortBy = '';
  isStylesLoaded = false;
  isLoading = false;
  isInitialSearch = true;
  errors = null;
  _slotAutoUpdateTimeoutId = null;
  _isConnected = false;

  connectedCallback() {
    this._isConnected = true;
    const { modalData } = this.modalParams;
    this.recordId = modalData.recordId;
    loadDashboardStyles(this)
      .then(() => {
        this.isStylesLoaded = true;
        this.fetchInitData();
      })
      .catch(() => {});
  }

  disconnectedCallback() {
    this._isConnected = false;
    this.stopClosestSlotAutoUpdate();
  }

  get labels() {
    return labels;
  }

  get isProcedureRequired() {
    if (this.isByDoctorNameSearchType) {
      return false;
    }
    return !this.formValues.subExpertise;
  }

  get isSubExpertiseRequired() {
    return !this.formValues.procedure;
  }

  get filterOptions() {
    return this.searchResult.filterOptions;
  }

  get doctorsViewList() {
    return this.filteredAndSortedDoctors;
  }

  get hasViewDoctors() {
    return this.doctorsViewList.length > 0;
  }

  get allDoctors() {
    return this.searchResult.doctors;
  }

  get isSendDocAdvDisabled() {
    return (
      this.isLoading || !(this.hasRecommendedIds && this.isRecommendedChanged)
    );
  }

  get isSaveDisabled() {
    return this.isLoading || !this.hasRecommendedIds;
  }

  get recommendedIds() {
    return this.getRecommendedIds(this.recommendedMap);
  }

  get hasRecommendedIds() {
    return this.recommendedIds.length > 0;
  }

  get searchTypeFields() {
    return buildSerchTypeFields(this.selectedSearchType);
  }

  get isByDoctorNameSearchType() {
    return this.selectedSearchType === searchTypes.byDoctorName;
  }

  get doctorsSearchStatusText() {
    if (this.isInitialSearch) {
      return '';
    }
    if (this.allDoctors.length === 0) {
      return labels.DoctorsNotFound;
    }

    return utils.formatTemplateText(labels.NumbersOfDoctorsFound, [
      this.filteredAndSortedDoctors.length
    ]);
  }

  get arrangementsCondition() {
    return this.sortBy === SORT_BY.arrangement
  }

  arrangementsOptions = []


  /**@returns {any[]} */
  getFormFields() {
    return [...this.template.querySelectorAll('[data-form-field]')];
  }

  /**@returns {HTMLElement} */
  getErrorsAlert() {
    return this.template.querySelector('c-errors-alert');
  }

  focusErrors() {
    utils.timeout().then(() => {
      const el = this.getErrorsAlert();
      if (el && el.focus) {
        el.focus();
      }
    });
  }

  /**@param {Object<string,string>} recommendedMap */
  getRecommendedIds(recommendedMap) {
    return Object.keys(recommendedMap);
  }

  fetchInitData() {
    this.isLoading = true;

    dashboardService
      .getInitData(this.recordId)
      .then((initData) => {
        this.isLoading = false;
        this.initConfig(initData);
      })
      .catch((err) => {
        this.isLoading = false;
        console.log(err);
        const errMessage = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errMessage });
        this.closeModal();
      });
  }
  /** @param {InitData} initData */
  initConfig(initData) {
    this.formValues = Object.assign({}, this.formValues, initData.defaultData);
    this.initData = initData;
    this.arrangementsOptions = this.initData.arrangements.map((option) => {
        return {...option, icon: option.isSurgery ? Surgery_indicator : '', style: option.isSurgery ? 'background-color: #FCE2BC;' : ''}
      })
    const { selectedDoctorId } = this.initData;
    if (selectedDoctorId) {
      return this.showClinicsModal(selectedDoctorId);
    }
    return this.searchDoctors();
  }

  searchDoctors() {
    this.resetErrors();
    if (!this.isInitialSearch) {
      const isValid = this.validateForm();
      if (!isValid) {
        return;
      }
    }

    this.isLoading = true;

    const {
      procedure,
      expertise,
      subExpertise,
      arrangements,
      settlements,
      doctorName
    } = this.formValues;

    const params = {
      recordId: this.recordId,
      searchType: this.selectedSearchType,
      onlyRecommended: this.isInitialSearch,
      procedureId: procedure ? procedure.id : undefined,
      arrangements,
      settlements: settlements.length === this.initData.settlements.length ? undefined : settlements,
      expertiseId: expertise ? expertise.id : undefined,
      subExpertiseId: subExpertise ? subExpertise.id : undefined,
      doctorName
    };

    dashboardService
      .searchDoctors(params)
      .then((res) => buildSearchResult(this, res))
      .then((result) => {
        this.isLoading = false;
        this.resetRecommendedMap();
        this.sortBy = '';
        const filters = buildDefaultFilters();
        // filters.onlyExperts = this.isInitialSearch;
        this.filters = filters;
        this.searchResult = result;
        this.filterDoctors();
        this.isRecommendedChanged = false;
        // this.sortDoctors();
        // this.logValues();
        this.runClosestSlotAutoUpdate(this.searchResult.doctors, params);
      })
      .catch((err) => {
        this.isLoading = false;
        this.errorsHandler(err);
      });
  }

  searchTypeChangeHandler(event) {
    const { value, name, checked } = event.target;
    const prevSearchType = this.selectedSearchType;
    this.selectedSearchType = value;

    if (this.selectedSearchType === searchTypes.byDoctorName) {
      this.formValues.expertise = null;
      this.formValues.subExpertise = null;
    } else {
      this.formValues.doctorName = '';
    }

    if (prevSearchType === searchTypes.byDoctorName) {
      this.procedureFieldChangeHandler();
    }
  }

  validateForm() {
    let isValid = true;

    const fields = this.getFormFields();
    fields.forEach((field) => {
      if (field.reportValidity && field.checkValidity) {
        // field.setCustomValidity('');
        field.reportValidity();
        isValid = isValid && field.checkValidity();
      }
    });

    return isValid;
  }

  /** @param {*} event */
  filterChangeHandler(event) {
    const { target } = event;
    let { name, checked, value, type } = target;
    this.filters[name] = type === 'checkbox' ? checked : name === 'arrangementsSortFilter' ? JSON.parse(JSON.stringify(event.detail.value)) : value;
    this.filterDoctors();
  }

  /**@param {*} event */
  sortChangeHandler(event) {
    const { value } = event.target;
    this.sortBy = value;
    this.sortDoctors();
  }

  /** @param {*} event */
  filterLookupChangeHandler(event) {
    const { target } = event;
    const name = target.name;
    const value = target.getSelection();

    this.filters[name] = value;

    this.filterDoctors();
  }

  /** @param {*} event */
  filterLookupSearchHandler(event) {
    const { detail, target } = event;
    const { name } = target;

    switch (name) {
      case 'procedures': {
        const { searchTerm, selectedIds } = detail;
        searchFilterProcedures(
          this.filterOptions.procedures,
          searchTerm,
          selectedIds
        )
          .then((options) => {
            target.setSearchResults(options);
          })
          .catch(() => {
            target.setSearchResults([]);
          });

        break;
      }

      default: {
        utils.timeout().then(() => {
          target.setSearchResults([]);
        });
      }
    }
  }

  /** @param {*} event */
  formFieldChangeHandler(event) {
    const { name, value } = event.target;

    this.formValues[name] = value;
    // this.logValues();
  }

  /** @param {*} event */
  formLookupChangeHandler(event) {
    const { target } = event;
    const name = target.name;
    const value = target.getSelection();

    this.formValues[name] = value;

    switch (name) {
      case formFieldNames.expertise: {
        this.expertiseChangeHandler();
        break;
      }
      case formFieldNames.subExpertise: {
        this.subExpertiseChangeHandler();
        break;
      }
      case formFieldNames.procedure: {
        this.procedureFieldChangeHandler();
        break;
      }
      default: {
        /*  */
      }
    }
  }

  expertiseChangeHandler() {
    this.formValues.subExpertise = null;
    this.formValues.procedure = null;
  }

  subExpertiseChangeHandler() {
    const { subExpertise } = this.formValues;
    this.formValues.procedure = null;

    if (!subExpertise) {
      return;
    }

    const { expertise } = subExpertise;
    if (expertise) {
      this.formValues.expertise = expertise;
    }
  }

  procedureFieldChangeHandler() {
    const { procedure } = this.formValues;
    if (!procedure) {
      return;
    }

    if (this.isByDoctorNameSearchType) {
      return;
    }

    const { subExpertise } = procedure;
    if (!subExpertise) {
      return;
    }
    this.formValues.subExpertise = subExpertise;
    this.formValues.expertise = subExpertise.expertise;
  }

  /** @param {*} event */
  formLookupSearchHandler(event) {
    const { detail, target } = event;
    const { name } = target;

    switch (name) {
      case formFieldNames.expertise: {
        this.searchExpertise(target, detail);
        break;
      }

      case formFieldNames.subExpertise: {
        this.searchSubExpertise(target, detail);
        break;
      }

      case formFieldNames.procedure: {
        this.searchProcedure(target, detail);
        break;
      }

      default: {
        utils.timeout().then(() => {
          target.setSearchResults([]);
        });
      }
    }
  }

  /**
   *
   * @param {*} lookup
   * @param {*} detail
   */
  searchExpertise(lookup, detail) {
    const { searchTerm } = detail;
    const { recordId } = this;

    dashboardService
      .searchExpertise({ recordId, searchTerm })
      .then((options) => {
        lookup.setSearchResults(options);
      })
      .catch(() => {
        lookup.setSearchResults([]);
      });
  }

  /**
   *
   * @param {*} lookup
   * @param {*} detail
   */
  searchSubExpertise(lookup, detail) {
    const { searchTerm } = detail;
    const { recordId } = this;
    const { expertise } = this.formValues;
    const expertiseId = expertise ? expertise.id : '';

    dashboardService
      .searchSubExpertise({ recordId, searchTerm, expertiseId })
      .then((options) => {
        lookup.setSearchResults(options);
      })
      .catch(() => {
        lookup.setSearchResults([]);
      });
  }

  /**
   *
   * @param {*} lookup
   * @param {*} detail
   */
  searchProcedure(lookup, detail) {
    const { searchTerm } = detail;
    const { subExpertise } = this.formValues;
    const subExpertiseId = subExpertise ? subExpertise.id : '';

    dashboardService
      .searchMedicalProcedure({
        recordId: this.recordId,
        searchTerm,
        subExpertiseId
      })
      .then((options) => {
        if (options.length) {
          lookup.setSearchResults(options);
        } else if (this.initData.alertProcedureCodes.find(code => code === searchTerm)) {
          lookup.setNoResultsLabel(this.initData.alertMessage)
          lookup.setSearchResults([]);
        } else {
          lookup.setNoResultsLabel()
          lookup.setSearchResults([]);
        }
      })
      .catch(() => {
        lookup.setSearchResults([]);
      });
  }

  filterDoctors() {
    const { allDoctors, filters, filterOptions } = this;

    // this.isLoading = true;

    utils
      .timeout()
      .then(() => {
        this.filteredDoctors = docFilter(allDoctors, filters, filterOptions);
        this.sortDoctors();
      })
      .then(() => {
        // this.isLoading = false;
      })
      .catch((err) => {
        console.error(err);
        // this.isLoading = false;
      });
  }

  sortDoctors() {
    const {filteredDoctors, sortBy, filters} = this;
    if (this.arrangementsCondition && filters?.arrangementsSortFilter) {
      this.filteredAndSortedDoctors = this.filteredAndSortedDoctors.slice().sort(this.arrangementSort2);
    } else {
      this.filteredAndSortedDoctors = docSort(filteredDoctors, sortBy);
    }
  }

  arrangementSort1 = (doctorA, doctorB) => { //TODO sort by selected more priority after this options
    const arrangementA = doctorA.arrangement || "";
    const arrangementB = doctorB.arrangement || "";
    const sortFilter = this.filters.arrangementsSortFilter;
    if (sortFilter.includes(arrangementA) && sortFilter.includes(arrangementB)) {
      return sortFilter.indexOf(arrangementA) - sortFilter.indexOf(arrangementB);
    } else if (sortFilter.includes(arrangementA)) {
      return -1;
    } else if (sortFilter.includes(arrangementB)) {
      return 1;
    } else {
      const arrangementsA = doctorA.arrangements.map(arr => arr.value);
      const arrangementsB = doctorB.arrangements.map(arr => arr.value);

      for (const value of sortFilter) {
        if (arrangementsA.includes(value) && arrangementsB.includes(value)) {
          return arrangementsA.indexOf(value) - arrangementsB.indexOf(value);
        } else if (arrangementsA.includes(value)) {
          return -1;
        } else if (arrangementsB.includes(value)) {
          return 1;
        }
      }

      return 0;
    }
  };

  arrangementSort2 = (doctorA, doctorB) => { //TODO sort by selected more priority + options
    const sortFilter = this.filters.arrangementsSortFilter;
    const priorityOrder = [...sortFilter];

    for (const value of priorityOrder) {
      if (doctorA.arrangement === value) {
        return -1;
      } else if (doctorB.arrangement === value) {
        return 1;
      } else {
        const arrangementsA = doctorA.arrangements.map(arr => arr.value);
        const arrangementsB = doctorB.arrangements.map(arr => arr.value);

        if (arrangementsA.includes(value)) {
          return -1;
        } else if (arrangementsB.includes(value)) {
          return 1;
        }
      }
    }
  }

  searchClickHandler() {
    if (this.isInitialSearch) {
      this.isInitialSearch = false;
    }
    this.searchDoctors();
  }

  /**@param {CustomEvent<DocActionDetails>} event */
  doctorActionHandler(event) {
    const { action, doctorId } = event.detail;
    switch (action) {
      case doctorActions.recommend: {
        this.recommendDoctorHandler(doctorId);
        break;
      }
      case doctorActions.select: {
        this.selectDoctorHandler(event.detail);
        break;
      }
      case doctorActions.arrangementChange: {
        this.changeDoctorArrangement(event.detail);
        break;
      }
      default: {
        /*  */
      }
    }
  }

  /**@param {string} doctorId */
  recommendDoctorHandler(doctorId) {
    let { recommendedMap, initData } = this;
    recommendedMap = Object.assign({}, recommendedMap);
    const ids = this.getRecommendedIds(recommendedMap);

    if (recommendedMap[doctorId]) {
      delete recommendedMap[doctorId];
    } else if (ids.length < initData.maxRecommendedDoctors) {
      recommendedMap[doctorId] = doctorId;
    }
    this.recommendedMap = recommendedMap;
    this.isRecommendedChanged = true;
  }

  /**@param {DocActionDetails} details */
  selectDoctorHandler(details) {
    // const { recommendedMap } = this;

    // if (!recommendedMap[doctorId]) {
    //   return;
    // }

    this.scheduleAppointment(details);
  }

  /**
   *
   * @param {DocActionDetails} details
   */
  changeDoctorArrangement(details) {
    const { doctorId, arrangementId } = details;

    const targetDoc = this.allDoctors.find((doc) => doc.id === doctorId);
    if (!targetDoc) {
      return;
    }

    targetDoc.arrangement = arrangementId;
    this.filteredAndSortedDoctors = this.filteredAndSortedDoctors.slice();
  }

  /** @param {DocActionDetails} details */
  scheduleAppointment(details) {
    if (this.isLoading) {
      return;
    }
    this.resetErrors();
    const { recordId, recommendedIds } = this;
    const { doctorId, arrangementId } = details;

    this.isLoading = true;

    dashboardService
      .schedule({
        recordId,
        doctorIds: recommendedIds,
        selectedDoctorId: doctorId,
        arrangementId
      })
      .then(() => {
        toastService.success(this, { message: labels.DoctorSelectedMessage });
        auraLwcBridgeService.refreshView();
        this.showClinicsModal(doctorId);
      })
      .catch((err) => {
        this.isLoading = false;
        this.errorsHandler(err);
      });
  }

  saveClickHandler() {
    this.resetErrors();
    const { recordId, recommendedIds } = this;

    this.isLoading = true;

    dashboardService
      .recommendDoctors({ recordId, doctorIds: recommendedIds })
      .then((message) => {
        toastService.success(this, { message });
        auraLwcBridgeService.refreshView();
        this.closeModal();
      })
      .catch((err) => {
        this.isLoading = false;
        this.errorsHandler(err);
      });
  }

  sendDocAdvClickHandler() {
    this.resetErrors();
    const { recordId, recommendedIds } = this;

    this.isLoading = true;

    dashboardService
      .sendDoctorAdvisor({ recordId, doctorIds: recommendedIds })
      .then((message) => {
        this.isLoading = false;
        this.isRecommendedChanged = false;
        toastService.success(this, { message });
        auraLwcBridgeService.refreshView();
        this.closeModal();
      })
      .catch((err) => {
        this.isLoading = false;
        this.errorsHandler(err);
      });
  }

  resetClickHandler() {
    const { initData } = this;
    this.formValues = Object.assign({}, this.formValues, initData.defaultData);
  }

  resetRecommendedMap() {
    this.recommendedMap = {};
  }

  resetSelectedDoctorId() {
    this.selectedDoctorId = '';
  }

  closeErrorsHandler() {
    this.resetErrors();
  }

  resetErrors() {
    this.errors = null;
  }

  /**@param {*} err */
  errorsHandler(err) {
    this.errors = errorsService.buildServerErrorsArray(err);
    this.focusErrors();
  }

  closeClickHandler() {
    this.closeModal();
  }

  /** @param {*} [result] */
  closeModal(result) {
    modalService.emitCloseModal(this, result);
  }

  logValues() {
    console.log(
      utils.unproxyData({
        filters: this.filters,
        formValues: this.formValues,
        allDoctors: this.allDoctors
      })
    );
  }

  /**@param {string} doctorId */
  showClinicsModal(doctorId) {
    const modalParams = modalService.buildAuraModalParams(
      'docExpertClinicsModalNew',
      {
        cssClass: 'slds-modal_medium clinics-modal',
        modalData: {
          recordId: this.recordId,
          doctorId
        },
        showCloseButton: true,
        useAuraModalDynamicLwc: true
      }
    );
    modalService
      .showModal(this, modalParams)
      .then(() => {})
      .catch(() => {});
    this.closeModal();
  }

  /**
   *
   * @param {Doctor[]} doctors
   * @param {DocExpertDashboardModalTypes.SearchDoctorsRequestParams} searchParams
   */
  runClosestSlotAutoUpdate(doctors, searchParams) {
    this.stopClosestSlotAutoUpdate();
    const delay = 2 * 60 * 1000; //2 min
    const { expertiseId, subExpertiseId } = searchParams;
    const doctorIds = doctors.map((item) => item.id);

    if (doctorIds.length < 1) {
      return;
    }

    const run = () => {
      if (!this._isConnected) {
        return;
      }

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this._slotAutoUpdateTimeoutId = setTimeout(() => {
        dashboardService
          .getClosestAvailableSlotInfo({
            recordId: this.recordId,
            doctorIds: doctorIds,
            expertiseId,
            subExpertiseId
          })
          .then((res) => {
            this.allDoctors.forEach((doc) => {
              const slotInfo = res[doc.id];
              if (slotInfo !== undefined) {
                doc.closestAvailableSlotInfo = slotInfo;
              }
            });

            this.filteredAndSortedDoctors =
              this.filteredAndSortedDoctors.slice();
          })
          .catch((err) => {
            const errMessage = errorsService.buildServerErrorsString(err);
            toastService.error(this, { message: errMessage });
          });
        run();
      }, delay);
    };

    run();
  }

  stopClosestSlotAutoUpdate() {
    if (this._slotAutoUpdateTimeoutId) {
      clearTimeout(this._slotAutoUpdateTimeoutId);
    }
  }
}