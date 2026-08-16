({
    controllers: {
        buttonsController: 'LC_ButtonsController'
    },

    handle: function (cmp) {
        var self = this;
        var caseId = this.recordId(cmp);
        var params = {
            caseId: caseId,
            actionName: 'transferToManager'
        };
        return this.executeApex(cmp, {
            controllerName: this.controllers.buttonsController,
            params: params
        })
            .then(this.BASE_RES_PIPES.statusPipe)
            .then(
                $A.getCallback(function (res) {
                    var options = {
                        "title": "Success",
                        "type": "success",
                        "message": 'Case was transferred to manager successfully'
                    }
                    self.showToast(options);
                    self.refreshView();

                })
            )
            .catch(
                $A.getCallback(function (err) {
                    var options = {
                        "title": "Error",
                        "type": "error",
                        "message": err.responseObj
                    }
                    self.showToast(options);
                    console.log(err);
                })
            );
    },

})