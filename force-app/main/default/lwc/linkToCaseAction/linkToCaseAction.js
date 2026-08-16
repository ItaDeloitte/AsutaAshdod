/**
 * Created by danilvinnik on 12.09.2022.
 */

import { LightningElement, track, api} from 'lwc';
import { labels } from "./labels";
import { service } from "./service";
import { utils } from "c/utils";
import { errorsService } from "c/errorsService";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { modalService } from "c/modalService";
import { toastService } from "c/toastService";

export default class LinkToCaseAction extends LightningElement {
    @api modalParams;
    @track patientId = '';
    @track caseId = '';
    @track selectedCaseId = '';
    @track isLoading = false;
    @track fetchTableData;
    @track isButtonDisabled = true;

    columns = [
        { label: labels.caseNumber, fieldName: 'caseNumberURL', type: 'url',
            typeAttributes: {
                label: { fieldName: 'caseNumber' },
                target: '_blank'
            }
        },
        { label: labels.subject, fieldName: 'subject'},
        { label: labels.subjectPublicInquiry, fieldName: 'subjectPublicInquiry'},
        { label: labels.sitePublicInquiry, fieldName: 'sitePublicInquiry'},
        { label: labels.status, fieldName: 'status'},
        { label: labels.createdDate, fieldName: 'createdDate'},
    ];

    get labels() {
        return labels;
    }

    connectedCallback() {
        const { modalData } = this.modalParams;
        this.caseId = modalData.recordId;
        this.isLoading = true;
        service.obtainCases(this.caseId, this.patientId).then(res => {
            this.fetchTableData = res;
            this.fetchTableData.forEach(item => {
                item.caseNumberURL = '/lightning/r/Case/' +item.id +'/view'
            })
            this.isLoading = false;
        }).catch(err => {
            this.isLoading = false;
            toastService.error(this, { message: errorsService.buildServerErrorsString(err)});
            this.cancelClickHandler();
        })
    }

    handleRowSelection(event) {
        this.selectedCaseId = event.detail.selectedRows[0].id
        this.isButtonDisabled = false;
    }

    cancelClickHandler(event){
        modalService.emitCloseModal(this, false);
    }

    saveClickHandler(event) {
        this.isLoading = true;
        service.submit(this.caseId, this.selectedCaseId).then(res => {
            this.isLoading = false;
            toastService.success(this, { message: ''});
            modalService.emitCloseModal(this);
            getRecordNotifyChange([{recordId: this.caseId}])
        }).catch(err => {
            this.isLoading = false;
            toastService.error(this, { message: errorsService.buildServerErrorsString(err)});
        })
    }
}