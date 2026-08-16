import { utils } from '../utils';

class ErrorsService {
  /**
   *
   * @param {*} err
   */
  buildServerErrorsArray(err) {
    var errors = [];
    if (Array.isArray(err)) {
      errors = err.map((item) => {
        return item.message || JSON.stringify(item);
      });
    } else if (typeof err === 'object') {
      if (err.responseObj) {
        if (typeof err.responseObj === 'string') {
          errors.push(err.responseObj);
        } else {
          errors = errors.concat(this.buildServerErrorsArray(err.responseObj));
        }
      } else if (err.message) {
        try {
          const parsedErr = JSON.parse(err.message);
          errors = errors.concat(this.buildServerErrorsArray(parsedErr));
        } catch (parseErr) {
          errors = [err.message];
          if (Array.isArray(err.details)) {
            errors = errors.concat(this.buildServerErrorsArray(err.details));
          }
        }
      } else if (err.body && err.body) {
        errors = this.buildServerErrorsArray(err.body);
      } else {
        errors = [JSON.stringify(err)];
      }
    } else {
      errors = [err];
    }
    errors = errors.filter((item) => !!item);
    return errors.length > 0 ? errors : null;
  }

  buildServerErrorsString(err) {
    return this.buildServerErrorsArray(err).join(', ');
  }
}

export const errorsService = new ErrorsService();