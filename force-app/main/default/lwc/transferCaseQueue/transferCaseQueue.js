import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { services, utils } from 'c/assutaGlobalService';
import queueLabel from '@salesforce/label/c.Queue';
import transferCaseQueue from '@salesforce/label/c.Transfer_Case_Queue';
import transfer from '@salesforce/label/c.Transfer';

const { executeService, errorsService, toastService } = services;

const labels = {
  Queue: queueLabel,
  TransferCaseTitle: transferCaseQueue,
  Transfer: transfer
};

export default class TransferCaseQueue extends LightningElement {
  _isConnected = false;
  labels = labels;
  @api recordId;
  @track isLoading = false;
  @track isTransfered = false;
  @track editData = {
    queue: null
  };
  @track errors = [];

  @wire(getRecord, { recordId: '$recordId', fields: ['Site__r.Id'] })
  wiredRecord({ error, data }) {
    if (error) {
      console.log(error);
      return;
    }
    const queueLookup = this.queueLookup;
    if (data && queueLookup) {
      queueLookup.triggerSearch();
    }
  }

  connectedCallback() {
    this._isConnected = true;
  }

  disconnectedCallback() {
    this._isConnected = false;
  }

  get selectedQueueId() {
    const queue = this.editData.queue;
    return queue && queue.Id;
  }

  get isTransferButtonDisabled() {
    return this.isLoading || this.isTransfered || !this.selectedQueueId;
  }

  get queueLookup() {
    return this.template.querySelector('[data-form-field="queue"]');
  }

  changeInputHandler() {}

  closeErrorsHandler() {
    this.resetErrors();
  }

  resetErrors() {
    this.errors = [];
  }

  searchQueueHandler(event) {
    const { detail, target } = event;
    const { searchTerm } = detail;
    this.searchQueues(searchTerm)
      .then(options => {
        target.setSearchResults(options);
      })
      .catch(err => {
        target.setSearchResults([]);
        const errorText = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errorText });
      });
  }

  changeQueueHandler(event) {
    if (this.isTransfered) {
      this.isTransfered = false;
    }
    const { target } = event;
    const selection = target.getSelection();
    const newEditData = Object.assign({}, this.editData);
    newEditData.queue = selection;
    this.editData = newEditData;
  }

  transferClickHandler() {
    this.transferCase();
  }

  transferCase() {
    const params = {
      actionName: 'transferCase',
      recordId: this.recordId,
      queueId: this.selectedQueueId
    };
    this.resetErrors();
    this.isLoading = true;
    this.request(params)
      .then(message => {
        this.isLoading = false;
        this.isTransfered = true;
        toastService.success(this, { message: message });
      })
      .catch(err => {
        this.errors = errorsService.buildServerErrorsArray(err);
        this.isLoading = false;
      });
  }

  buildQueueOption(data) {
    return Object.assign({}, data, {
      id: data.Id,
      title: data.Name,
      icon: null
    });
  }

  searchQueues(searchTerm) {
    const params = {
      actionName: 'obtainQueues',
      recordId: this.recordId,
      keyword: searchTerm
    };
    return this.request(params).then(data => {
      return data.map(item => this.buildQueueOption(item));
    });
  }

  request(params) {
    return executeService.execute('LC_CaseQueue', params);
  }
}