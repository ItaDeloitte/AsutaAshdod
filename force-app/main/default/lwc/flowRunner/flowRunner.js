import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class FlowRunner extends LightningElement {
    @api flowApiName = 'Screen_Send_Message_By_Population';
    @api recordId;
    @api cardTitle = 'Flow Runner';


    handleStatusChange(event) {
        const status = event.detail.status;

        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            // כאן אפשר להוסיף ניווט, toast, או refresh אם רוצים
            // כרגע לא עושים כלום כדי שהמשתמש יישאר בטאב
            // console.log('Flow finished');
        }
    }
}