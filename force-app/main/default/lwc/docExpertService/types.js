/**
 *
 * @typedef {Object} IOption
 * @property {string} label
 * @property {string} value
 */

/**
 * @typedef {Object<string,IOption>} IOptionsMap
 */
/**
 * @typedef {Object<string,string>} IOptionsToIndexMap
 */

/**
 *
 * @typedef {Object} IExpertiseOption
 * @property {string} id
 * @property {string} name
 * @property {string} title
 * @property {string} value
 */

/**
 * @typedef {Object} ISubExpertiseOption
 * @property {string} id
 * @property {string} name
 * @property {string} title
 * @property {string} value
 * @property {IExpertiseOption} [expertise]
 */

/**
 * @typedef {Object} IMedicalProcedureOption
 * @property {string} id
 * @property {string} name
 * @property {string} title
 * @property {string} icon
 * @property {string} optionLabel
 * @property {string} code
 * @property {boolean} [isWaitingList]
 * @property {ISubExpertiseOption} [subExpertise]
 */

/**
 * @typedef {Object} IDoctor
 * @property {string} id
 * @property {string} recordUrl
 * @property {string} name
 * @property {string} photo
 * @property {string} alert
 * @property {boolean} isExpert
 * @property {boolean} isPromoted
 * @property {boolean} isExcellent
 * @property {boolean} isRecommended
 * @property {number} quantity
 * @property {number} rank
 * @property {IOption} gender
 * @property {IOption} degree
 * @property {IOption[]} agreements
 * @property {IOptionsToIndexMap} agreementsMap
 * @property {IOption[]} arrangements
 * @property {IOptionsToIndexMap} arrangementsMap
 * @property {IOption[]} procedures
 * @property {IOptionsToIndexMap} proceduresMap
 * @property {IOption[]} sites
 * @property {IOptionsToIndexMap} sitesMap
 */

/**
 * @typedef {Object} IDocActionDetails
 * @property {string} action
 * @property {string} doctorId
 */

/**
 * @typedef {Object} IClinic
 * @property {string} id
 * @property {string} clinicId
 * @property {string} name
 * @property {string} address
 * @property {string} calendar
 * @property {string} phone
 * @property {string} workingHours
 * @property {string} insuranceFactor
 * @property {string} siteName
 * @property {string} siteUrl
 * @property {string} recordUrl
 *
 */

export const types = null;