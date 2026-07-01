/**@type {import("AppointmentsDatesSlider").Helper} */
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
    var self = this;
    var Swiper = window['Swiper'];
    var container = this.swiperContainer(cmp);
    var buttonsElements = this.swiperButtonsElements(cmp);
    /**@type {import("swiper").SwiperOptions} */
    var swiperOptions = {
      autoHeight: true,
      observer: true,
      slidesPerView: 5,
      spaceBetween: 15,
      navigation: {
        nextEl: buttonsElements[1],
        prevEl: buttonsElements[0]
      },
      roundLengths: true,
      on: {
        transitionStart: $A.getCallback(function() {
          self.emitSlideMove(cmp);
        }),
        sliderMove: $A.getCallback(function() {
          self.emitSlideMove(cmp);
        })
      },
      breakpoints: {
        1800: {
          slidesPerView: 4
        },
        1500: {
          slidesPerView: 3
        },
        1300: {
          slidesPerView: 2
        },
        1199: {
          slidesPerView: 3
        },
        1020: {
          slidesPerView: 2
        },
        600: {
          slidesPerView: 1
        }
      }
    };
    var swiper = new Swiper(container, swiperOptions);
    this.swiper(cmp, swiper);
  },
  emitSlideMove: function(cmp) {
    this.emitEvent(cmp, 'onSlideMove', {});
  }
});