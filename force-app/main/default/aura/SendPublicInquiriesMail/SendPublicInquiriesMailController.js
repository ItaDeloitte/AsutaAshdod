({
    doInit : function(component, event, helper) {
        //component.set("v.selectedChildCaseIds", new Set());
        
        let action = component.get("c.getChildCases");
        action.setParams({ caseId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let retVal = response.getReturnValue();
                component.set("v.caseWrapperList", retVal);
            }
        });

        $A.enqueueAction(action);
    },

    onCaseCheckboxChange : function(component, event, helper) {
        let caseId = event.getSource().get("v.name");
        let caseWrapperList = component.get("v.caseWrapperList");
        let theElement;
        caseWrapperList.forEach(e => e.caseId === caseId ? theElement = e : theElement = theElement);
        theElement.isResponsibleChecked = !theElement.isAshdod ? theElement.isCaseChecked : theElement.isResponsibleChecked;
        theElement.isTakingCareChecked = theElement.isCaseChecked;
        theElement.isFilesChecked = !theElement.isCaseChecked ? false : theElement.isFilesChecked;
        component.set("v.caseWrapperList", caseWrapperList);
    },
    
    onFileCheckboxChange : function(component, event, helper) {
        let fileId = event.getSource().get("v.name");
        let caseId = event.getSource().get("v.value");
        let caseWrapperList = component.get("v.caseWrapperList");
        let theElement;
        caseWrapperList.forEach(e => e.caseId === caseId ? theElement = e : theElement = theElement);
        theElement.fileIds = [...theElement.fileIds, fileId];        
        component.set("v.caseWrapperList", caseWrapperList);             
    },

    sendButtonFunction : function(component, event, helper) {
        component.set("v.isTryingToSendRightNow", true);
        let caseWrapperList = component.get("v.caseWrapperList");
        let hasRecepient = false, hasCaseSelected = false, hasAllMailExists= true;        
        const caseNumList = [];
        caseWrapperList.forEach(function(e) { 
            hasCaseSelected = e.isCaseChecked ? true : hasCaseSelected;
            hasRecepient = e.isCaseChecked && (e.isResponsibleChecked || e.isTakingCareChecked) ?  true : hasRecepient;            
            if (e.isCaseChecked && (e.isResponsibleChecked && e.responsibleMail == null ) || (e.isTakingCareChecked && e.takingCareMail == null)){
                hasAllMailExists = false;
                caseNumList.push(e.caseNum);                                 
            }
        });
        let toastEvent = $A.get("e.force:showToast");
        if(hasCaseSelected) {
            if (hasRecepient) {
                if(hasAllMailExists){                
                    let action = component.get("c.sendEmail");
                    action.setParams({ caseWrapperListJsonStr : JSON.stringify(component.get("v.caseWrapperList")), parentCaseId : component.get("v.recordId") });
                    action.setCallback(this, function(response) {
                        let state = response.getState();
                        if (state === "SUCCESS") {
                            let result = response.getReturnValue();
                            if (result === true) {
                                toastEvent.setParams({
                                    "message": "המייל נשלח בהצלחה",
                                    "type": "success"
                                });
                            }
                            else {
                                toastEvent.setParams({
                                    "message": "אופס, קרתה תקלה לא צפויה, אנא נסו שוב מאוחר יותר",
                                    "type": "error"
                                });
                            }
                            toastEvent.fire();
                        }
                        component.set("v.isTryingToSendRightNow", false);
                    });
                    $A.enqueueAction(action);
                }else {
                    toastEvent.setParams({
                        "message": "לא ניתן לשלוח מייל עבור פריטי פניה : " + caseNumList.toString() + ". בגלל שחסרה כתובת מייל לגורם המטפל/אחראי",
                        "type": "error"
                    });
                    toastEvent.fire();
                    component.set("v.isTryingToSendRightNow", false);
                }
            }else {
                toastEvent.setParams({
                    "message": "יש לבחור לפחות נמען אחד",
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.isTryingToSendRightNow", false);
            }
        }else {
            toastEvent.setParams({
                "message": "יש לבחור לפחות פריט פניה אחד",
                "type": "error"
            });
            toastEvent.fire();
            component.set("v.isTryingToSendRightNow", false);
        }
    }
})