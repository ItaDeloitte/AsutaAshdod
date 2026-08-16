//@ts-check

class PaginationService {
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getStartIndex(currentPage, perPage, total) {
    return this.getStartNumber(currentPage, perPage, total) - 1;
  }
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getEndIndex(currentPage, perPage, total) {
    return this.getEndNumber(currentPage, perPage, total) - 1;
  }
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getStartNumber(currentPage, perPage, total) {
    return Math.min(Math.max(1 + (currentPage - 1) * perPage, 0), total);
  }
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getEndNumber(currentPage, perPage, total) {
    return Math.min(
      this.getStartNumber(currentPage, perPage, total) + (perPage - 1),
      total
    );
  }
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getSliceFromIndex(currentPage, perPage, total) {
    return this.getStartIndex(currentPage, perPage, total);
  }
  /**
   *
   * @param {number} currentPage
   * @param {number} perPage
   * @param {number} total
   * @returns {number}
   */
  getSliceToIndex(currentPage, perPage, total) {
    return this.getEndNumber(currentPage, perPage, total);
  }
}

export const paginationService = new PaginationService();