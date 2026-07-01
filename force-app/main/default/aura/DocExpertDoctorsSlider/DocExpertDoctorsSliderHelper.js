/**@type {import("DocExpertDoctorsSlider").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {
    var swiper = this.swiper(cmp);
    if (swiper) {
      swiper.destroy(true, true);
      this.swiper(cmp, null);
    }
  },
  render: function(cmp) {},

  CONSTANTS: {
    counter: 0
  },
  controllers: {},

  swiperContainer: function(cmp) {
    var containerCmp = cmp.find('swiperContainer');
    // @ts-ignore
    return containerCmp.getElement();
  },
  swiperButtonsElements: function(cmp) {
    var buttonCmps = cmp.find('swiperButton') || [];
    return buttonCmps.map(function(item) {
      return item.getElement();
    });
  },
  doctors: function(cmp, value) {
    return this.attribute(cmp, 'doctors', value);
  },
  virtualData: function(cmp, value) {
    return this.attribute(cmp, 'virtualData', value);
  },

  swiper: function(cmp, value) {
    return this.property(cmp, 'swiper', value);
  },

  updateSwiperHeight: function(cmp) {
    var self = this;

    setTimeout(function() {
      var swiper = self.swiper(cmp);
      if (swiper) {
        swiper.updateAutoHeight(300);
      }
    });
  },

  config: function(cmp) {
    var that = this;
    var Swiper = window['Swiper'];
    var swiper = this.swiper(cmp);
    if (swiper) {
      swiper.destroy(true, true);
    }
    var container = that.swiperContainer(cmp);
    var buttonsElements = that.swiperButtonsElements(cmp);
    var doctors = that.doctors(cmp);
    /**@type {import("swiper").SwiperOptions} */
    var swiperOptions = {
      autoHeight: true,

      slidesPerView: 5,
      slidesPerGroup: 1,
      spaceBetween: 15,
      // observer: true,
      // observeParents: true,
      freeMode: false,
      navigation: {
        nextEl: buttonsElements[1],
        prevEl: buttonsElements[0]
      },
      virtual: {
        // cache: false,
        slides: doctors.slice(),
        addSlidesBefore: 10,
        addSlidesAfter: 10,
        renderExternal: $A.getCallback(function(data) {
          that.virtualData(cmp, data);
        })
      },
      // roundLengths: true,
      on: {
        transitionStart: $A.getCallback(function() {
          that.emitSlideMove(cmp);
        }),
        sliderMove: $A.getCallback(function() {
          that.emitSlideMove(cmp);
        }),
        slideChange: $A.getCallback(function() {}),
        reachEnd: $A.getCallback(function() {})
      },
      breakpoints: {
        1850: {
          slidesPerView: 4
          // slidesPerGroup: 3
        },
        1550: {
          slidesPerView: 3
          // slidesPerGroup: 2
        },
        1300: {
          slidesPerView: 2
          // slidesPerGroup: 2
        },
        980: {
          slidesPerView: 1
          // slidesPerGroup: 1
        }
      }
    };
    swiper = new Swiper(container, swiperOptions);
    that.swiper(cmp, swiper);
    that.updateSwiper(cmp);
  },
  emitSlideMove: function(cmp) {
    this.emitEvent(cmp, 'onSlideMove', {});
  },
  slideTo: function(cmp, index) {
    var swiper = this.swiper(cmp);
    if (swiper) {
      // swiper.slideTo(index);
      // this.updateSwiper(cmp);
    }
  },
  changeDoctorsHandler: function(cmp) {
    // var swiper = this.swiper(cmp);
    // if (!swiper) {
    //   return;
    // }
    // var doctors = this.doctors(cmp);
    // swiper.virtual.slides = doctors.slice();
    var virtualData = this.virtualData(cmp);
    virtualData = { slides: [] };
    this.virtualData(cmp, virtualData);
    this.config(cmp);
  },

  updateSwiper: function(cmp) {
    var that = this;
    setTimeout(function() {
      var swiper = that.swiper(cmp);
      if (!swiper) {
        return;
      }
      if (swiper.update) {
        swiper.update();
      }
      if (swiper.virtual) {
        swiper.virtual.update();
      }
    }, 10);
  }
});