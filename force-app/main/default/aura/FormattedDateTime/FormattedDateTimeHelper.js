/**@type {import("FormattedDateTime").Helper} */
({
  init: function(cmp) {
    this.formatDate(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  CONSTANTS: {},
  date: function(cmp, value) {
    return this.attribute(cmp, 'date', value);
  },
  locale: function(cmp, value) {
    return this.attribute(cmp, 'locale', value);
  },
  format: function(cmp, value) {
    return this.attribute(cmp, 'format', value);
  },
  formattedDate: function(cmp, value) {
    return this.attribute(cmp, 'formattedDate', value);
  },

  formatDate: function(cmp) {
    var date = this.date(cmp);
    var format = this.format(cmp);
    var locale = this.locale(cmp);
    var $Locale = this.$Locale();
    var formattedDate = $A.localizationService.formatDate(
      date,
      format,
      locale || $Locale.langLocale
    );
    this.formattedDate(cmp, formattedDate);
  }
});