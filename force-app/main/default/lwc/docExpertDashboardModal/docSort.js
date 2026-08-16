import { SORT_BY } from './constants';

/**@typedef {DocExpertServiceTypes.Doctor} Doctor */

/**
 * @callback SortCompareFn
 * @param {Doctor} doc1
 * @param {Doctor} doc2
 * @returns {number}
 */

/**@type {SortCompareFn} */
const sortByQuantity = (doc1, doc2) => {
  return doc2.quantity - doc1.quantity;
};
/**@type {SortCompareFn} */
const sortByRank = (doc1, doc2) => {
  return doc2.rank - doc1.rank;
};

/**@type {Object<string,SortCompareFn>} */
const sortCompareFn = {
  [SORT_BY.quantity]: sortByQuantity,
  [SORT_BY.rank]: sortByRank
};

/**
 *
 * @param {Doctor[]} doctors
 * @param {string} sortBy
 */
export function docSort(doctors, sortBy) {
  doctors = doctors.slice();
  const compareFn = sortCompareFn[sortBy];
  if (compareFn) {
    doctors.sort(compareFn);
  }

  return doctors;
}