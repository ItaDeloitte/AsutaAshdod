//@ts-check
import { appointmentService } from './appointmentService';

class AccountPreferredChannelService {
  /**
   *
   * @param {string} recordId
   * @returns {Promise}
   */
  getPreferredChannels(recordId) {
    const params = {
      actionName: 'getPreferredChannels',
      recordId: recordId
    };
    return this.request(params);
  }

  /**
   *
   * @param {string} recordId
   * @param {string} preferredChannel
   * @param {string} [additionalInput]
   * @returns {Promise}
   */
  updatePreferredChannel(recordId, preferredChannel, additionalInput = '') {
    const params = {
      actionName: 'updatePreferredChannel',
      recordId: recordId,
      preferredChannel: preferredChannel,
      additionalInput: additionalInput
    };
    return this.request(params);
  }

  /**
   *
   * @param {*} params
   * @returns {Promise}
   */
  request(params) {
    return appointmentService.request(params);
  }
}

export const accountPreferredChannelService = new AccountPreferredChannelService();