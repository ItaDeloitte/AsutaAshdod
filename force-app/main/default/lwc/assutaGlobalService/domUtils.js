import { ClassSet } from './classUtils/ClassSet';

class DomUtils {
  ClassSet = ClassSet;
  focusEl(el) {
    if (el && typeof el.focus === 'function') {
      el.focus();
    }
  }
}

export const domUtils = new DomUtils();