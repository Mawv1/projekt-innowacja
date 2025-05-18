import { LightningElement, api, wire, track } from 'lwc';
import getOpeningHours from '@salesforce/apex/ShelterHoursController.getOpeningHours';

export default class ReadOnlyOpeningHours extends LightningElement {
    @api recordId;
    @track openingHours = [];
    error;

    @wire(getOpeningHours, { shelterId: '$recordId' })
    wiredHours({ error, data }) {
        if (data) {
            this.openingHours = data.map(day => ({
                ...day,
                openTime: this.formatTime(day.Open__c),
                closeTime: this.formatTime(day.Close__c)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.openingHours = [];
        }
    }

    formatTime(ms) {
        if (typeof ms !== 'number') return '';
        const date = new Date(ms);
        const hours = String(date.getUTCHours()).padStart(2, '0');
        const minutes = String(date.getUTCMinutes()).padStart(2, '0');
        return `${hours}:${minutes}`;
    }
}