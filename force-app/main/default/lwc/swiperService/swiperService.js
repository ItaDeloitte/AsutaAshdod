//@ts-check
import { LibLoader } from 'c/abstractComponents';
import SWIPER_RESOURCES from '@salesforce/resourceUrl/swiper';

class SwiperService extends LibLoader {
  scripts = [`${SWIPER_RESOURCES}/5.4.5/swiper.js`];
  styles = [`${SWIPER_RESOURCES}/5.4.5/swiper.min.css`];
  libKey = 'Swiper';
}

export const swiperService = new SwiperService();