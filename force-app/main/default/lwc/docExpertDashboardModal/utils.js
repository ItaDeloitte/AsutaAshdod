import { SORT_BY, searchTypes } from './constants';
import { labels } from './labels';
import { utils } from 'c/utils';
import { navigationService } from 'c/navigationService';

import { doctorImages } from 'c/docExpertService';

/**@typedef {DocExpertServiceTypes.ExpertiseOption} ExpertiseOption */
/**@typedef {DocExpertServiceTypes.SubExpertiseOption} SubExpertiseOption */
/**@typedef {DocExpertServiceTypes.MedicalProcedureOption} MedicalProcedureOption */
/**@typedef {DocExpertServiceTypes.Option} Option */
/**@typedef {DocExpertServiceTypes.Doctor} Doctor */

/**@typedef {DocExpertDashboardModalTypes.InitData} InitData */
/**@typedef {DocExpertDashboardModalTypes.FilterLookupOption} FilterLookupOption */
/**@typedef {DocExpertDashboardModalTypes.FilterOptions} FilterOptions */
/**@typedef {DocExpertDashboardModalTypes.FilterOptionsMap} FilterOptionsMap */
/**@typedef {DocExpertDashboardModalTypes.SearchResult} SearchResult */
/**@typedef {DocExpertDashboardModalTypes.Filters} Filters */

/**
 *
 * @param {*} res
 * @returns {InitData}
 */
export function buildInitData(res) {
  const { defaultData } = res;
  const newDefaultData = Object.assign({}, defaultData, {
    expertise: buildExpertiseOption(defaultData.expertise),
    subExpertise: buildSubExpertiseOption(defaultData.subExpertise),
    procedure: buildMedProcedureOption(defaultData.procedure)
  });

  return Object.assign({}, res, {
    maxProcedureSelection: 3,
    maxRecommendedDoctors: 3,
    defaultData: newDefaultData,
    sorts: [
      { label: labels.SortByNone, value: '' },
      { label: labels.SortByQuantity, value: SORT_BY.quantity },
      { label: labels.SortByArrangement, value: SORT_BY.arrangement }
    ]
  });
}

/**
 *
 * @param {*} data
 * @returns {ExpertiseOption}
 */
export function buildExpertiseOption(data) {
  if (!data) {
    return null;
  }

  return Object.assign({}, data, {
    title: data.name,
    value: data.id,
    icon: null
  });
}

/**
 *
 * @param {*} data
 * @returns {SubExpertiseOption}
 */
export function buildSubExpertiseOption(data) {
  if (!data) {
    return null;
  }

  const { expertise } = data;

  return Object.assign({}, data, {
    title: data.name,
    value: data.id,
    expertise: expertise ? buildExpertiseOption(expertise) : null,
    icon: null
  });
}

/**
 *
 * @param {*} data
 * @returns {MedicalProcedureOption}
 */
export function buildMedProcedureOption(data) {
  if (!data) {
    return null;
  }

  const { subExpertise, name, code } = data;

  return Object.assign({}, data, {
    title: data.name,
    value: data.id,
    optionLabel: `${name} - ${code}`,
    subExpertise: subExpertise ? buildSubExpertiseOption(subExpertise) : null,
    icon: null
  });
}

/**
 *
 * @param {Option} data
 * @returns {FilterLookupOption}
 */
export function buildFilterLookupOption(data) {
  if (!data) {
    return null;
  }

  return Object.assign({}, data, {
    title: data.label,
    id: data.value,
    icon: null
  });
}

/**
 *
 * @param {*} lwc
 * @param {{doctors:any[],filterOptions:FilterOptions}} res
 * @returns {Promise<SearchResult>}
 */
export async function buildSearchResult(lwc, res) {
  const { doctors: docList, filterOptions } = res;
  const doctors = await buildDoctors(lwc, docList, filterOptions);
  return Object.assign({}, res, { doctors });
}

/**
 *
 * @param {*} lwc
 * @param {any[]} docList
 * @param {FilterOptions} filterOptions
 * @returns {Promise<Doctor[]>}
 */
export async function buildDoctors(lwc, docList, filterOptions) {
  const keys = ['arrangements', 'degrees', 'genders', 'procedures', 'sites'];
  const filterOptionsMap = keys.reduce((acc, key) => {
    const optMap = buildOptionsMap(filterOptions[key] || []);
    acc[key] = optMap;
    return acc;
  }, {});

  const docs = await Promise.all(
    docList.map((doc) => buildSingleDoctor(lwc, doc, filterOptionsMap))
  );

  return docs;
}

/**
 * @param {Option[]} options
 * @returns {Object<string,Option[]>}
 */
function buildOptionsMap(options = []) {
  return options.reduce((acc, opt) => {
    acc[opt.value] = opt;
    return acc;
  }, {});
}

/**
 *
 * @param {*} lwc
 * @param {*} docData
 * @param {FilterOptionsMap} filterOptionsMap
 * @returns {Promise<Doctor>}
 */
export async function buildSingleDoctor(lwc, docData, filterOptionsMap) {
  const optionFieldKeys = ['procedures', 'sites'];
  /**@type {Option} */
  const emptyOption = { label: '', value: '' };

  const recordUrl = await navigationService.generateUrl(
    lwc,
    navigationService.buildRecordViewParams(docData.id)
  );
  /**@type {*} */
  const docOptionsFields = optionFieldKeys.reduce((acc, key) => {
    const mapKey = `${key}Map`;
    const options = buildDocOptionsFromIds(docData[key], filterOptionsMap[key]);
    acc[key] = options;
    acc[mapKey] = options.reduce((_acc, opt, index) => {
      _acc[opt.value] = String(index);
      return _acc;
    }, {});
    return acc;
  }, {});

  const arrangementsMap = docData.arrangements.reduce((acc, item, index) => {
    acc[item.value] = String(index);
    return acc;
  }, {});

  /**@type {Option} */
  const gender = docData.gender
    ? filterOptionsMap.genders[docData.gender] || emptyOption
    : emptyOption;
  /**@type {Option} */
  const degree = docData.degree
    ? filterOptionsMap.degrees[docData.degree] || emptyOption
    : emptyOption;
  const photo = resolveDoctorPhoto(docData.picture, gender.value);

  const doctor = Object.assign({}, docData, docOptionsFields, {
    recordUrl,
    gender,
    degree,
    photo,
    arrangementsMap,
    arrangement: docData.arrangement || '',
    expertiseETL1: docData.expertiseETL1 || '',
    expertiseETL2: docData.expertiseETL2 || ''
  });

  return doctor;
}

/**
 *
 * @param {string} pictureHtml
 * @param {string} gender
 * @returns {string}
 */
function resolveDoctorPhoto(pictureHtml = '', gender) {
  const matched = pictureHtml.match(/src="(.+?)"/);
  if (matched) {
    return matched[1];
  }
  if (pictureHtml) {
    return pictureHtml;
  }
  return gender === 'נ' ? doctorImages.female : doctorImages.male;
}

/**
 *
 * @param {string[]} ids
 * @param {Object<string,Option>} optionsMap
 * @returns {Option[]}
 */
function buildDocOptionsFromIds(ids = [], optionsMap = {}) {
  return ids
    .map((id) => {
      const option = optionsMap[id];
      if (!option) {
        console.error(
          `Id: ${id} is missed in optionsMap`,
          utils.unproxyData(optionsMap)
        );
      }
      return option;
    })
    .filter((option) => !!option);
}

/**
 *
 * @returns {Filters}
 */
export function buildDefaultFilters() {
  return {
    onlyExperts: true,
    operationsInLastMonths: false,
    gender: '',
    degree: '',
    procedures: [],
    arrangements: [],
    sites: []
  };
}

/**
 *
 * @param {Option[]} allProcedures
 * @param {string} searchTerm
 * @param {string[]} selectedIds
 * @returns {Promise<any[]>}
 */
export async function searchFilterProcedures(
  allProcedures,
  searchTerm,
  selectedIds
) {
  searchTerm = searchTerm.toLowerCase();
  /**@type {Object<string,boolean>} */
  const idsMap = selectedIds.reduce((acc, id) => {
    acc[id] = true;
    return acc;
  }, {});

  const result = allProcedures
    .filter((item) => {
      const { label, value } = item;
      if (idsMap[value]) {
        return false;
      }
      return label.toLowerCase().includes(searchTerm);
    })
    .map((item) => buildFilterLookupOption(item));

  return result;
}

/**
 *
 * @param {string} currentSearchType
 */
export function buildSerchTypeFields(currentSearchType) {
  const fields = [
    {
      label: labels.SearchByDoctorName,
      value: searchTypes.byDoctorName,
      checked: currentSearchType === searchTypes.byDoctorName
    },
    {
      label: labels.SearchByExpertise,
      value: searchTypes.byExpertise,
      checked: currentSearchType === searchTypes.byExpertise
    },
    {
      label: labels.SearchByComingWeek,
      value: searchTypes.byComingWeek,
      checked: currentSearchType === searchTypes.byComingWeek
    }
  ];

  return fields;
}