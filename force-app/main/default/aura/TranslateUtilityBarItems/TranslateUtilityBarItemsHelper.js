/**@type {import("TranslateUtilityBarItems").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  isDisabled: function(cmp, value) {
    return this.attribute(cmp, 'isDisabled', value);
  },

  utilityBarApiCmp: function(cmp) {
    return cmp.find('utilitybar');
  },

  config: function(cmp) {
    var that = this;

    var isDisabled = that.isDisabled(cmp);
    if (isDisabled) {
      return;
    }

    var delay = 50;
    setTimeout(function() {
      that.translateItems(cmp);
    }, delay);
  },

  translateItems: function(cmp) {
    var that = this;
    var translateLabelsMap = {
      'Omni-Channel': $A.get('$Label.c.Omni_Channel'),
      'History': $A.get('$Label.c.History'),
      'Macros': $A.get('$Label.c.Macros'),
      'Notes': $A.get('$Label.c.Notes')
    };
    var utilityBarApiCmp = that.utilityBarApiCmp(cmp);
    utilityBarApiCmp
      .getAllUtilityInfo()
      .then(function(items) {
        var itemsForTranslate = items.filter(function(item) {
          return !!translateLabelsMap[item.utilityLabel];
        });

        var translatePromises = itemsForTranslate.reduce(function(acc, item) {
          var itemPromises = [
            utilityBarApiCmp.setUtilityLabel({
              label: translateLabelsMap[item.utilityLabel],
              utilityId: item.id
            }),
            utilityBarApiCmp.setPanelHeaderLabel({
              label: translateLabelsMap[item.utilityLabel],
              utilityId: item.id
            })
          ];
          return acc.concat(itemPromises);
        }, []);
        return Promise.all(translatePromises);
      })
      .catch(function(err) {
        console.log(err);
      });
  }
});