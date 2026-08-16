/**
 * Created by danilvinnik on 15.09.2022.
 */

import { LightningElement, api, track } from 'lwc';
import { service } from "./service";
import { labels } from "./labels";
import { toastService } from "c/toastService";
import { errorsService } from "c/errorsService";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { modalService } from "c/modalService";

export default class SendQuestionnaireLinkModal extends LightningElement {
    @api modalParams;
    @track isLoading = false;
    @track appointmentId = '';
    @track surveyTakerId = '';
    @track tableRows;
    @track isButtonDisabled = true;

    columns = [
        {
            label: labels.surveyTakerName,
            fieldName: 'nameURL',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_blank'
            }
        },
        {
            label: labels.fillPercentage,
            fieldName: 'fillPercentage'
        },
        {
            label: labels.survey,
            fieldName: 'surveyNameURL',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'surveyName' },
                target: '_blank'
            }
        },
        {
            label: labels.isLocked,
            fieldName: 'isLocked',
            type: 'boolean'
        },
        {
            label: labels.link,
            fieldName: 'link',
            type: 'url',
            typeAttributes: { target: '_blank' }
        }
    ];
    
    get labels() {
        return labels;
    }

    connectedCallback() {
        this.isLoading = true;
        this.appointmentId = this.modalParams.modalData.recordId;
        service.obtainCases(this.appointmentId).then(res => {
            res.forEach(elem => {
                elem.surveyName = elem.survey.name
                elem.surveyId = elem.survey.id
                elem.nameURL = '/' + elem.id;
                elem.surveyNameURL = '/' + elem.survey.id;
                elem.fillPercentage = elem.fillPercentage ? elem.fillPercentage+'%' : elem.fillPercentage;
            })
            this.tableRows = res;
            this.isLoading = false;
        }).catch(err => {
            this.isLoading = false;
            toastService.error(this, { message: errorsService.buildServerErrorsString(err)});
        })
    }

    handleRowSelection(event) {
        this.surveyTakerId = event.detail.selectedRows[0].id
        this.isButtonDisabled = false;
    }

    saveClickHandler(event) {
        this.isLoading = true;
        service.submit(this.appointmentId, this.surveyTakerId).then(res => {
            this.isLoading = false;
            toastService.success(this, { message: ''});
            modalService.emitCloseModal(this);
            getRecordNotifyChange([{recordId: this.appointmentId}])
        }).catch(err => {
            this.isLoading = false;
            toastService.error(this, { message: errorsService.buildServerErrorsString(err)});
        })
    }

    cancelClickHandler(event){
        modalService.emitCloseModal(this, false);
    }
}