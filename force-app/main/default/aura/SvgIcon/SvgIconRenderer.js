//@ts-check
/**@type {import("SvgIcon").Renderer} */
({
  render: function(cmp, helper) {
    return this.superRender();
  },
  rerender: function(cmp, helper) {
    this.superRerender();
  },
  afterRender: function(cmp, helper) {
    this.superAfterRender();
  },
  unrender: function(cmp, helper) {
    this.superUnrender();
  }
});