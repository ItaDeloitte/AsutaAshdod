//@ts-check

class DomUtils {
  focusEl(el) {
    if (el && typeof el.focus === 'function') {
      el.focus();
    }
  }
}

export const domUtils = new DomUtils();