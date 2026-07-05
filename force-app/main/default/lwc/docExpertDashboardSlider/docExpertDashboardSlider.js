import { LightningElement, api } from 'lwc';
import { swiperService } from 'c/swiperService';
import { ClassSet, utils } from 'c/utils';
import { errorsService } from 'c/errorsService';
import { toastService } from 'c/toastService';
// @ts-ignore
import DIR from '@salesforce/i18n/dir';

const isRtl = DIR === 'rtl';

const icons = {
  next: isRtl ? 'utility:chevronleft' : 'utility:chevronright',
  prev: isRtl ? 'utility:chevronright' : 'utility:chevronleft'
};
export default class DocExpertDashboardSlider extends LightningElement {
  @api recordId = '';
  @api recommendedMap = {};

  /**@type {DocExpertServiceTypes.Doctor[]} */
  _doctors = [];
  isSliderInited = false;

  @api
  get doctors() {
    return this._doctors;
  }

  set doctors(val) {
    const prevDoctors = this._doctors;

    const newDoctors = val.map((item, index) => {
      return Object.assign({}, item);
    });

    let isSameDoctors = prevDoctors.length === newDoctors.length;
    if (isSameDoctors) {
      isSameDoctors = newDoctors.every((doc, index) => {
        return doc.id === prevDoctors[index].id;
      });
    }

    this._doctors = newDoctors;

    if (this.swiper) {
      this.updateSwiper(!isSameDoctors);
    }
  }

  connectedCallback() {}

  disconnectedCallback() {
    this.destroySwiper();
  }

  renderedCallback() {
    if (this._isRendered) {
      return;
    }
    this._isRendered = true;
    this.loadSwiper();
  }

  get isRtl() {
    return isRtl;
  }

  get icons() {
    return icons;
  }

  get sliderWrapperClassNames() {
    return new ClassSet('slider-wrapper')
      .add({
        'is-inited': this.isSliderInited,
        'is-rtl': this.isRtl
      })
      .toString();
  }

  /**
   *
   * @returns {HTMLElement}
   */
  getSwiperContainerEl() {
    return this.template.querySelector('[data-swiper-container]');
  }
  /**
   *
   * @returns {HTMLElement}
   */
  getNextButtonEl() {
    return this.template.querySelector('[data-swiper-button-next]');
  }
  /**
   *
   * @returns {HTMLElement}
   */
  getPrevButtonEl() {
    return this.template.querySelector('[data-swiper-button-prev]');
  }

  loadSwiper() {
    this.isLoading = true;

    swiperService
      .getLib(this)
      .then(() => {
        this.isLoading = false;
      })
      .then(() => {
        this.initSwiper();
      })
      .catch((err) => {
        const errMessage = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errMessage });
      });
  }

  initSwiper() {
    // @ts-ignore
    const Swiper = window.Swiper;

    const containerEl = this.getSwiperContainerEl();
    const nextBtnEl = this.getNextButtonEl();
    const prevBtnEl = this.getPrevButtonEl();

    const swiperInitHandler = () => {
      this.isSliderInited = true;
    };

    const swiper = new Swiper(containerEl, {
      spaceBetween: 20,
      slidesPerView: 'auto',
      freeMode: true,
      freeModeSticky: false,
      // centeredSlides: false,
      cssMode: false,
      observer: false,
      autoplay: false,
      loop: false,
      autoHeight: false,
      mousewheel: false,
      // preventClicks: false,//
      // preventClicksPropagation: false,//
      navigation: {
        nextEl: nextBtnEl,
        prevEl: prevBtnEl
      },
      on: {
        init: swiperInitHandler
      }
    });
    this.swiper = swiper;
  }

  /**
   *
   * @param {boolean} slideToBegin
   */
  updateSwiper(slideToBegin) {
    utils.timeout().then(() => {
      if (this.swiper) {
        this.swiper.update();
        if (slideToBegin) {
          this.swiper.slideTo(0);
        }
      }
    });
  }

  destroySwiper() {
    if (this.swiper) {
      this.swiper.destroy();
      this.swiper = null;
    }
  }
}