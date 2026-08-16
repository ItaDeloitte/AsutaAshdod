import { navigationService } from 'c/navigationService';
import { idGeneratorService } from 'c/idGeneratorService';
import { buildClinic } from 'c/docExpertService';
import { labels } from './labels';

/**
 * @typedef {Object} DetailField
 * @property {string} label
 * @property {string} value
 * @property {string} [key]
 * @property {string} [url]
 */

/**
 * @typedef {Object} DetailItem
 * @property {string} key
 * @property {DetailField[]} fields
 */

/**
 *
 * @param {*} lwc
 * @param {*} clinicData
 * @returns {Promise<DetailItem>}
 */
export async function buildClinicDetailItem(lwc, clinicData) {
  const clinic = await buildClinic(lwc, clinicData);
  /**@type {DetailField[]} */
  const fields = [
    {
      label: labels.ClinicName,
      value: clinic.name,
      url: clinic.recordUrl
    },
    { label: labels.ClinicAddress, value: clinic.address },
    { label: labels.ClinicCalendar, value: clinic.calendar },
    { label: labels.ClinicPhone, value: clinic.phone },
    { label: labels.ClinicWorkinHours, value: clinic.workingHours },
    { label: labels.ClinicInsuranceFactor, value: clinic.insuranceFactor }
  ];
  fields.forEach((field) => {
    field.key = idGeneratorService.guid();
  });

  return {
    key: clinic.clinicId,
    fields
  };
}

/**
 *
 * @param {*} lwc
 * @param {{label:string,value:string}} item
 */
export async function buildSimpleDetailItem(lwc, { label, value }) {
  const url = await navigationService.generateUrl(
    lwc,
    navigationService.buildRecordViewParams(value)
  );
  return {
    key: value,
    fields: [{ value: label, url, key: value }]
  };
}
/**
 *
 * @param {*} lwc
 * @param {any[]} dataList
 * @param {Function} buildFn
 * @returns {Promise<DetailItem[]>}
 */
export async function buildDetailItems(lwc, dataList, buildFn) {
  return Promise.all(dataList.map((item) => buildFn(lwc, item)));
}