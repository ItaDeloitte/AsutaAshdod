({
    init: function(cmp) {},
    CONSTANTS: {},
    controllers: {caseExpertise: 'LC_CaseExpertise'},
    destroy: function(cmp) {},
    render: function(cmp) {},
    serverError: function(cmp, value) {return this.attribute(cmp, 'serverError', value);},
    selectedExpertiseId: function(cmp, value) {return this.attribute(cmp, 'selectedExpertiseId', value);},
    selectedSubExpertiseId: function(cmp, value) {return this.attribute(cmp, 'selectedSubExpertiseId', value);},
    selectedProcedureId: function(cmp, value) {return this.attribute(cmp, 'selectedProcedureId', value);},
    formFieldCmpExpertise: function(cmp) {return cmp.find('formFieldExpertice');},
    formFieldCmpSubExpertise: function(cmp) {return cmp.find('formFieldSubExpertise');},
    formFieldCmpProcedure: function(cmp) {return cmp.find('formFieldProcedure');},
    searchExpertise: function(cmp, term) {
        var self = this;
        var params = {actionName: 'getExpertises',
                      expertiseName: term};
        return self
            .executeApex(cmp, {controllerName: this.controllers.caseExpertise,
                               params: params})
            .then(this.BASE_RES_PIPES.statusPipe)
            .then($A.getCallback(function(res) {
                var expertises = res.map(function(item) {
                    return Object.assign(item, { label: item.Name, value: item.Id });
                });
                return expertises;
            }))
            .catch($A.getCallback(function(err) {
                console.log(err);
                return [];
            }));
    },
    searchSubExpertise: function(cmp, term) {
        var self = this;
        var expertiseId = this.selectedExpertiseId(cmp);
        var params = {actionName: 'getSubExpertises',
                      expertiseId: expertiseId,
                      subExpertiseName: term};
        return self
            .executeApex(cmp, {controllerName: this.controllers.caseExpertise,
                               params: params})
            .then(this.BASE_RES_PIPES.statusPipe)
            .then($A.getCallback(function(res) {
                var subExpertises = res.map(function(item) {
                    return Object.assign(item, { label: item.Name, value: item.Id });
                });
                return subExpertises;
            }))
            .catch($A.getCallback(function(err) {
                console.log(err);
                return [];
            }));
    },
    searchProcedure: function(cmp, term) {
        var self = this;
        var subExpertiseId = this.selectedSubExpertiseId(cmp);
        var params = {actionName: 'getProcedures',
                      subExpertiseId: subExpertiseId,
                      procedureName: term};
        return self
            .executeApex(cmp, {controllerName: this.controllers.caseExpertise,
                               params: params})
            .then(this.BASE_RES_PIPES.statusPipe)
            .then($A.getCallback(function(res) {
                var procedures = res.map(function(item) {
                    return Object.assign(item, { label: item.Name, value: item.Id });
                });
                return procedures;
            }))
            .catch($A.getCallback(function(err) {
                console.log(err);
                return [];
            }));
    },
    submit: function(cmp) {
        var self = this;
        var isValid = this.validate(cmp, 1);
        if (!isValid) {return;}
        isValid = this.validate(cmp, 2);
        if (!isValid) {return;}
        isValid = this.validate(cmp, 3);
        if (!isValid) {return;}

        var caseId = this.recordId(cmp);
        var expertiseId = this.selectedExpertiseId(cmp);
        var subExpertiseId = this.selectedSubExpertiseId(cmp);
        var procedureId = this.selectedProcedureId(cmp);
        var params = {actionName: 'setExpertises',
                      caseId: caseId,
                      expertiseId: expertiseId,
                      subExpertiseId: subExpertiseId,
                      procedureId: procedureId};
        self.serverError(cmp, '');
        self.isLoading(cmp, true);
        this.executeApex(cmp, {controllerName: this.controllers.caseExpertise,
                               params: params})
        .then(this.BASE_RES_PIPES.statusPipe)
        .then($A.getCallback(function(res) {
            self.isLoading(cmp, false);
            self.showToast({title: 'Success',
                            message: 'Expertise updated',
                            type: 'success'});
            self.refreshView();
        }))
        .catch($A.getCallback(function(err) {
            console.log(err);
            self.isLoading(cmp, false);
            var errMessage = self.buildHtmlServerError(err);
            self.serverError(cmp, errMessage);
        }));
    },
    validate: function(cmp, formField) {
        var isValid = true;
        if (formField == 1) {
            var formFieldCmp = this.formFieldCmpExpertise(cmp);
        } else if (formField == 2) {
            var formFieldCmp = this.formFieldCmpSubExpertise(cmp);
        } else {
            var formFieldCmp = this.formFieldCmpProcedure(cmp);
        }

        if (formFieldCmp) {
            formFieldCmp.showHelpMessageIfInvalid();
            var validity = this.attribute(formFieldCmp, 'validity');
            isValid = validity.valid;
        }
        return isValid;
    },
    doSubExpertiseSearch: function(cmp) {
        var self = this;
        var formField = cmp.find("formFieldSubExpertise");
        formField.reset();
        formField.triggerSearch();
        return self;
    },
    doProcedureSearch: function(cmp) {
        var self = this;
        var formField = cmp.find("formFieldProcedure");
        formField.reset();
        formField.triggerSearch();
        return self;
    }
});