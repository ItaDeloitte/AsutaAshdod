/**@typedef {DocExpertServiceTypes.Doctor} Doctor */
/**@typedef {DocExpertServiceTypes.Option} Option */
/**@typedef {DocExpertDashboardModalTypes.Filters} Filters */
/**@typedef {DocExpertDashboardModalTypes.FilterOptions} FilterOptions */

/**
 *
 * @callback FilterFn
 * @param {Doctor} doc
 * @returns {boolean}
 */

/**
 * @callback GetDocOptionsMapFn
 * @param {Doctor} doc
 */

/**
 * @param {string} gender
 * @returns {FilterFn}
 */
function byGender(gender = '') {
  return (doc) => {
    return gender ? doc.gender.value === gender : true;
  };
}

/**
 * @param {string} degree
 * @returns {FilterFn}
 */
function byDegree(degree = '') {
  return (doc) => {
    return degree ? doc.degree.value === degree : true;
  };
}

/**
 * @param {boolean} onlyExperts
 * @returns {FilterFn}
 */
function byExpert(onlyExperts) {
  return (doc) => {
    if (onlyExperts) {
      return doc.isExpert || doc.isPromoted || doc.isExcellent;
    }
    return true;
  };
}

/**
 * @param {boolean} operationsInLastMonths
 * @returns {FilterFn}
 */
function byOperationsInLastMonths(operationsInLastMonths) {
  return (doc) => {
    if (operationsInLastMonths) {
      return doc.quantity >= 2;
    }
    return true;
  };
}

/**
 * @param {Option[]|string[]} options
 * @param {GetDocOptionsMapFn} getMapFn
 * @returns {FilterFn}
 */
function bySelectedOptions(options = [], getMapFn) {
  return (doc) => {
    if (options.length === 0) {
      return true;
    }

    const optionsMap = getMapFn(doc);

    return options.some((item) => {
      return !!optionsMap[typeof item === 'object' ? item.value : item];
    });
  };
}

/**
 *
 * @param {Doctor[]} doctors
 * @param {Filters} filters
 * @param {FilterOptions} filterOptions
 * @returns {Doctor[]}
 */
export function docFilter(doctors, filters, filterOptions) {
  const { procedures, sites, arrangements } = filters;
  const procedureOptions =
    procedures.length === filterOptions.procedures.length ? [] : procedures;
  const siteOptions = sites.length === filterOptions.sites.length ? [] : sites;
  const arrangementOptions =
    arrangements.length === filterOptions.arrangements.length
      ? []
      : arrangements;

  return doctors
    .filter(byGender(filters.gender))
    .filter(byExpert(filters.onlyExperts))
    .filter(byDegree(filters.degree))
    .filter(byOperationsInLastMonths(filters.operationsInLastMonths))
    .filter(bySelectedOptions(procedureOptions, (doc) => doc.proceduresMap))
    .filter(bySelectedOptions(siteOptions, (doc) => doc.sitesMap))
    .filter(
      bySelectedOptions(arrangementOptions, (doc) => doc.arrangementsMap)
    );
}