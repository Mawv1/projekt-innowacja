import { LightningElement, api, wire, track } from 'lwc';
import getOpeningHours from '@salesforce/apex/ShelterHoursController.getOpeningHours';

export default class ReadOnlyOpeningHours extends LightningElement {
    @api shelterId;
    @track openingHours = [];
    error;

    @wire(getOpeningHours, { shelterId: '$shelterId' })
    wiredHours({ error, data }) {
        if (data) {
            this.openingHours = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.openingHours = [];
        }
    }
}
