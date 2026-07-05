//@ts-check
import { internalApiEventService } from 'c/internalApiEventService';
import { utils } from 'c/utils';

class WorkspaceService {
  /**
   * @private
   * @type {Promise<boolean>} */
  _isConsoleNavigationPromise;

  /**
   * Adds a browser tab title to a list of titles, which rotates every few seconds
   * @param {Object} params
   * @param {string} params.title Title that needs to be added to the browser title queue
   * @returns Returns a Promise. Success resolves to true. The Promise will be rejected on error.
   */
  addToBrowserTitleQueue(params) {
    return this.invokeApi('addToBrowserTitleQueue', params);
  }

  /**
   * Closes a workspace tab or subtab.
   * @param {Object} params
   * @param {string} params.tabId ID of the workspace tab or subtab to close.
   * @returns Returns a Promise. Success resolves to true. The Promise will be rejected on error.
   */
  closeTab(params) {
    return this.invokeApi('closeTab', params);
  }

  /**
   * Disables or enables close capabilities of the specified tab.
   * @param {Object} params
   * @param {string} params.tabId The ID of the tab for which to disable or enable close capabilities.
   * @param {boolean} params.disabled Specifies whether the tab should have close capabilities disabled or enabled.
   * @returns Returns a Promise. Success resolves to a tabInfo object of the modified tab. The Promise will be rejected on error.
   */
  disableTabClose(params) {
    return this.invokeApi('disableTabClose', params);
  }

  /**
   * Focuses a workspace tab or subtab.
   * @param {Object} params
   * @param {string} params.tabId The ID of the workspace tab or subtab on which to focus.
   * @returns Returns a Promise. Success resolves to true. The Promise will be rejected on error.
   */
  focusTab(params) {
    return this.invokeApi('focusTab', params);
  }

  /**
   * Generates a URL to a workspace or workspace and subtabs.
   * @param {Object} params
   * @param {any[]} params.pageReferences An array of PageReferences to a workspace or workspace and subtabs to generate a URL for.
   * @returns Returns a Promise. Success resolves to the active tab id. The Promise will be rejected on error.
   */
  generateConsoleURL(params) {
    return this.invokeApi('generateConsoleURL', params);
  }

  /**
   * @returns Returns a Promise. Success resolves to an array of tabInfo objects. The Promise will be rejected on error.
   */
  getAllTabInfo() {
    return this.invokeApi('getAllTabInfo');
  }

  /**
   * @returns Returns the enclosing tab id.
   */
  getEnclosingTabId() {
    return this.invokeApi('getEnclosingTabId');
  }

  /**
   * Returns information about the focused workspace tab or subtab.
   * @returns Returns a Promise. Success resolves to a tabInfo object. The Promise will be rejected on error.
   */
  getFocusedTabInfo() {
    return this.invokeApi('getFocusedTabInfo');
  }

  /**
   * Returns information about the specified tab.
   * @param {Object} params
   * @param {string} params.tabId ID of the tab for which to retrieve the information.
   * @returns Returns a Promise. Success resolves to a tabInfo object. The Promise will be rejected on error.
   */
  getTabInfo(params) {
    return this.invokeApi('getTabInfo', params);
  }

  /**
   * Returns the URL of the specified tab.
   * @param {Object} params
   * @param {string} params.tabId ID of the tab for which to retrieve the URL.
   * @returns Returns a Promise. Success resolves to the tab URL. The Promise will be rejected on error.
   */
  getTabURL(params) {
    return this.invokeApi('getTabURL', params);
  }

  /**
   *
   * @returns {Promise<boolean>} Returns a Promise. Success resolves to true if console navigation is present, false otherwise. The Promise will be rejected on error.
   */
  isConsoleNavigation() {
    if (this._isConsoleNavigationPromise) {
      return this._isConsoleNavigationPromise;
    }

    const promiseFalse = utils.timeout(100).then(() => false);

    this._isConsoleNavigationPromise = Promise.race([
      this.invokeApi('isConsoleNavigation'),
      promiseFalse
    ]).catch(() => false);
    return this._isConsoleNavigationPromise;
  }

  /**
   * Checks whether a tab is a subtab.
   * @param {Object} params
   * @param {string} params.tabId ID of the tab.
   * @returns Returns a Promise. Success resolves to true if the tab is a subtab, false otherwise. The Promise will be rejected on error.
   */
  isSubtab(params) {
    return this.invokeApi('isSubtab', params);
  }

  /**
   * Opens a URL generated via the generateConsoleURL API.
   * @param {Object} params
   * @param {string} params.url The URL representing the content of the new workspace or workspace and subtabs.
   * @param {boolean} [params.focus] Optional. Specifies whether the new active tab has focus.
   * @param {any[]} [params.labels] Optional. An array of labels to be applied to the workspace or workspace and subtabs.
   * @returns Returns a Promise. Success resolves to true. The Promise will be rejected on error.
   */
  openConsoleURL(params) {
    return this.invokeApi('openConsoleURL', params);
  }

  /**
   * Opens a subtab within a workspace tab. The new subtab displays the content of the specified pageReference, recordId, or URL, which can be relative or absolute. If the specified subtab is already open and focus is set to true, it is focused.
   * @param {Object} params
   * @param {string} params.parentTabId ID of the workspace tab within which the new subtab should open.
   * @param {Object} [params.pageReference] Optional. A PageReference representing the content of the new subtab.
   * @param {string} [params.recordId] Optional. A record ID representing the content of the new subtab.
   * @param {string} [params.url] Optional. The URL representing the content of the new subtab. URLs can be either relative or absolute.
   * @param {boolean} [params.focus] Optional. Specifies whether the new subtab has focus.
   * @returns Returns a Promise. Success resolves to the tabId of the subtab. The Promise will be rejected on error.
   */
  openSubtab(params) {
    return this.invokeApi('openSubtab', params);
  }

  /**
   * Opens a new workspace tab that displays the content of the specified pageReference, recordId, or URL, which can be relative or absolute. If the specified tab is already open and focus is set to true, it is focused.
   * @param {Object} params
   * @param {Object} [params.pageReference] Optional. A PageReference representing the content of the new subtab.
   * @param {string} [params.recordId] Optional. A record ID representing the content of the new subtab.
   * @param {string} [params.url] Optional. The URL representing the content of the new subtab. URLs can be either relative or absolute.
   * @param {boolean} [params.focus] Optional. Specifies whether the new subtab has focus.
   * @param {boolean} [params.overrideNavRules] Optional. Specifies whether to override nav rules when opening the new tab.
   * @returns Returns a Promise. Success resolves to the tabId of the workspace. The Promise will be rejected on error.
   */
  openTab(params) {
    return this.invokeApi('openTab', params);
  }

  /**
   * Refreshes a workspace tab or a subtab specified by tabId. Keep in mind that the first subtab has the same tabId as the workspace tab.
   * @param {Object} params
   * @param {string} params.tabId ID of the workspace tab or subtab to refresh.
   * @param {boolean} [params.includeAllSubtabs] Optional. If the tabId corresponds to a workspace tab, all subtabs within that workspace are refreshed. The default is true. Keep in mind that the first subtab has the same tabId as the workspace tab.
   * @returns Returns a Promise. Success resolves to true. The Promise will be rejected on error.
   */
  refreshTab(params) {
    return this.invokeApi('refreshTab', params);
  }

  /**
   * Removes a browser tab title from the list of titles, which rotates every few seconds
   * @param {Object} params
   * @param {string} params.title Title that needs to be removed from the browser title queue
   * @returns Returns a Promise. Success resolves to true if title was removed, false otherwise. The Promise will be rejected on error.
   */
  removeFromBrowserTitleQueue(params) {
    return this.invokeApi('removeFromBrowserTitleQueue', params);
  }

  /**
   * Highlights the specified tab.
   * @param {Object} params
   * @param {string} params.tabId The ID of the tab for which to highlight.
   * @param {boolean} params.highlighted Specifies whether the new tab should be highlighted.
   * @param {Object} [params.options] Optional. Additional options that modify the appearance of the highlighted tab.
   * @returns Returns a Promise. Success resolves to a tabInfo object of the modified tab. The Promise will be rejected on error.
   */
  setTabHighlighted(params) {
    return this.invokeApi('setTabHighlighted', params);
  }

  /**
   * Sets the icon and alternative text of the specified tab.
   * @param {Object} params
   * @param {string} params.tabId The ID of the tab for which to set the icon.
   * @param {string} params.icon An SLDS icon key. See a full list of icon keys on the SLDS reference site.
   * @param {string} [params.iconAlt] Optional. Alternative text for the icon.
   * @returns Returns a Promise. Success resolves to a tabInfo object of the modified tab. The Promise will be rejected on error.
   */
  setTabIcon(params) {
    return this.invokeApi('setTabIcon', params);
  }

  /**
   * Sets the label of the specified tab.
   * @param {Object} params
   * @param {string} params.tabId The ID of the tab for which to set the label.
   * @param {string} params.label The label of the workspace tab or subtab.
   */
  setTabLabel(params) {
    return this.invokeApi('setTabLabel', params);
  }

  /**
   *
   * @param {string} methodName
   * @param {*} [methodArgs]
   * @returns
   */
  invokeApi(methodName, methodArgs) {
    return internalApiEventService.invoke(
      'workspaceAPI',
      methodName,
      methodArgs
    );
  }
}

export const workspaceService = new WorkspaceService();