import { LightningElement, api, wire, track } from 'lwc';
import getFilesForAccount from '@salesforce/apex/FilesOpenTogether_LWCtrl.getFilesForAccount';
import accountFilesTitle from '@salesforce/label/c.CF_AccountFilesTitle';
import openSelectedFilesBtn from '@salesforce/label/c.CF_OpenSelectedFilesBtn';
import fileNameColTitle from '@salesforce/label/c.CF_FileNameColTitle';
import fileTypeColTitle from '@salesforce/label/c.CF_FileTypeColTitle';

export default class FilesOpenTogether extends LightningElement {
    @api recordId;
    @track files = [];
    selectedFileIds = [];
    selectedRows = [];
    isButtonDisabled = true

    labels = {
        accountFilesTitle,
        openSelectedFilesBtn,
        fileNameColTitle,
        fileTypeColTitle,
    };

    columns = [
        {   label: this.labels.fileNameColTitle, 
            fieldName: 'downloadUrl',
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'title' },
                    target: '_blank'
                }
        },
        {
            label: this.labels.fileTypeColTitle,
            fieldName: 'type', 
        }
    ];

    @wire(getFilesForAccount, { accountId: '$recordId' })
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data;
        } else if (error) {
            console.error('Error in file loading: ', error);
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.selectedFileIds = this.selectedRows.map(row => row.versionId);
        this.isButtonDisabled = this.selectedFileIds.length == 0;
    }

    handleOpenFilesClick() {
        if (this.selectedRows.length === 0) {
            alert('Select at least one file');
            return;
        }
        this.selectedRows.forEach(row => {
            const a = document.createElement('a');
            a.href = row.downloadUrl;
            a.target = '_blank';
            a.rel = 'noopener';
            a.click();
        });
    }
}