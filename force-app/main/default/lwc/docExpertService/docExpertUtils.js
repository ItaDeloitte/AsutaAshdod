import { resourceLoaderService } from 'c/resourceLoaderService';
import { DASHBOARD_STYLES_URL } from './constants';
import { navigationService } from 'c/navigationService';
import { IClinic } from './types';

/**
 *
 * @param {*} lwc
 */
export function loadDashboardStyles(lwc) {
  return resourceLoaderService
    .loadStyles(lwc, [DASHBOARD_STYLES_URL])
    .catch(() => {});
}

/**
 *
 * @param {*} lwc
 * @param {*} clinicData
 * @returns {Promise<IClinic>}
 */
export async function buildClinic(lwc, clinicData) {
  const { clinicId, pfNames, site } = clinicData;
  const siteName = site ? site.name : '';
  let siteUrl = null;
  const recordUrl = await navigationService.generateUrl(
    lwc,
    navigationService.buildRecordViewParams(clinicId)
  );
  if (site) {
    siteUrl = await navigationService.generateUrl(
      lwc,
      navigationService.buildRecordViewParams(site.id)
    );
  }

  return Object.assign({}, clinicData, {
    insuranceFactor: pfNames || '',
    siteName,
    siteUrl,
    recordUrl: recordUrl
  });
}