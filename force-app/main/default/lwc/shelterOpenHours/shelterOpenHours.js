import { LightningElement, api, wire, track } from 'lwc';
import getOpeningHours from '@salesforce/apex/ShelterHoursController.getOpeningHours';

export default class ReadOnlyOpeningHours extends LightningElement {
    @api recordId;
    @track openingHours = [];
    error;

    @wire(getOpeningHours, { shelterId: '$recordId' })
    wiredHours({ error, data }) {
        if (data) {
            this.openingHours = data.map(day => ({ ...day }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.openingHours = [];
        }
    }
}