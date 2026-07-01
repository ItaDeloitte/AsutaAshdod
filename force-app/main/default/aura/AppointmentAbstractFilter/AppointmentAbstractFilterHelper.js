({
  filterName: function(cmp, value) {
    return this.attribute(cmp, 'filterName', value);
  },
  emitFilterChanged: function(cmp, value) {
    var filterName = this.filterName(cmp);
    this.emitEvent(cmp, 'filterChanged', {
      value: {
        filterName: filterName,
        value: value
      }
    });
  }
});