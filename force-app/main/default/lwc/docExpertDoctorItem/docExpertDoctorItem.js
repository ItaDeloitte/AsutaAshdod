import { LightningElement, api } from 'lwc';
import { labels } from './labels';
import {
  doctorImages,
  docExpertService,
  doctorActions
} from 'c/docExpertService';
import { ClassSet, utils } from 'c/utils';
import {
  detailsTypeToTitle,
  detailLinks,
  doctorDetailTypes
} from './constants';
import { errorsService } from 'c/errorsService';
import { toastService } from 'c/toastService';
import { LightningElementWithNavigation } from 'c/abstractComponents';
import {
  buildClinicDetailItem,
  buildSimpleDetailItem,
  buildDetailItems
} from './docUtils';
import Surgery_indicator from "@salesforce/resourceUrl/Surgery_indicator";

/**@typedef {DocExpertServiceTypes.Doctor} Doctor */

export default class DocExpertDoctorItem extends LightningElementWithNavigation {
  @api recordId = '';
  /**@type {Doctor} */
  @api doctor;
  /**@type {Object<string,string>} */
  @api recommendedMap = {};
  activeDetailsType = '';
  isLoading = false;
  details = {
    clinics: null,
    arrangements: null,
    agreements: null,
    procedures: null,
    sites: null
  };

  formattedTimeConfig = {
    hour12: false
  };

  connectedCallback() {}

  disconnectedCallback() {}

  get labels() {
    return labels;
  }

  get doctorImages() {
    return doctorImages;
  }

  get isDetailsPanelActive() {
    return !!this.activeDetailsType;
  }

  get detailsPanelClassName() {
    return new ClassSet('slds-is-relative details-panel')
      .add({
        'is-active': this.isDetailsPanelActive
      })
      .toString();
  }

  get detailsTitle() {
    return detailsTypeToTitle[this.activeDetailsType];
  }

  get detailsList() {
    return this.details[this.activeDetailsType] || [];
  }

  get detailLinks() {
    return detailLinks;
  }

  get genderLabel() {
    const { gender } = this.doctor;
    return gender ? gender.label : '';
  }

  get isRecommended() {
    return !!this.recommendedMap[this.doctor.id];
  }

  get cardClassName() {
    return new ClassSet(
      'slds-is-relative slds-grid slds-grid_vertical doctor-card'
    )
      .add({
        'is-recommended': this.isRecommended
      })
      .toString();
  }

  get arrangementOptions() {
    const options = JSON.parse(JSON.stringify(this.doctor.arrangements)).map(option => {
      option.selected = option.value === this.doctor.arrangement
      option.icon = option.isSurgery ? Surgery_indicator : ''
      option.style = option.isSurgery ? 'background-color: #FCE2BC;' : ''
      return option
    });
    return options;
  }

  get hasArrangementsOptions() {
    return this.arrangementOptions.length > 1;
  }

  stopEventHandler(event) {
    event.stopPropagation();
  }

  /**@param {*} event */
  showDetailsClickHandler(event) {
    event.preventDefault();
    const target = event.currentTarget;
    const detailsType = target.dataset.detailsType;
    this.activeDetailsType = detailsType;

    if (!this.details[detailsType]) {
      if (detailsType === doctorDetailTypes.clinics) {
        this.fetchClinics();
        return;
      }
      this.updateSimpleDetailItems(detailsType, this.doctor[detailsType]);
    }
  }

  closeDetailsClickHandler() {
    this.activeDetailsType = '';
  }

  fetchClinics() {
    this.isLoading = true;
    return docExpertService
      .getDoctorClinics({
        recordId: this.recordId,
        doctorId: this.doctor.id
      })
      .then((clinics) => buildDetailItems(this, clinics, buildClinicDetailItem))
      .then((items) => {
        this.isLoading = false;
        this.details = Object.assign({}, this.details, { clinics: items });
      })
      .catch((err) => {
        this.isLoading = false;
        const errMessage = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errMessage });
      });
  }

  /**
   *
   * @param {string} detailsKey
   * @param {any[]} dataList
   */
  async updateSimpleDetailItems(detailsKey, dataList = []) {
    const details = await buildDetailItems(
      this,
      dataList,
      buildSimpleDetailItem
    );
    this.details = Object.assign({}, this.details, { [detailsKey]: details });
  }

  recommendClickHandler() {
    this.emitDoctorAction(doctorActions.recommend);
  }

  /** @param {*} event */
  selectClickHandler(event) {
    const extraData = { arrangementId: this.doctor.arrangement };
    this.emitDoctorAction(doctorActions.select, extraData);
  }

  /** @param {*} event */
  arrangementChangeHandler(event) {
    const value = event.detail.value[0];
    const extraData = { arrangementId: value };
    this.emitDoctorAction(doctorActions.arrangementChange, extraData);
  }

  /**
   * @param {string} action
   * @param {any} extraData
   */
  emitDoctorAction(action, extraData) {
    this.dispatchEvent(
      new CustomEvent('doctoraction', {
        cancelable: true,
        composed: true,
        bubbles: true,
        detail: Object.assign(
          {
            action,
            doctorId: this.doctor.id
          },
          extraData
        )
      })
    );
  }
}