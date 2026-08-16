/**@type {import("SearchAccountModal").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},

  searchAccountCmp: function(cmp) {
    return cmp.find('searchAccount');
  },
  cancel: function(cmp) {
    var searchAccountCmp = this.searchAccountCmp(cmp);
    searchAccountCmp.cancel();
  }
});