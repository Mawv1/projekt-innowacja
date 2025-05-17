import { LightningElement, api, wire } from 'lwc';
import getSheltersInSameCity from '@salesforce/apex/ShelterMapController.getSheltersInSameCity';

export default class ShelterMap extends LightningElement {
    @api recordId;
    mapMarkers = [];
    currentShelterId;

    @wire(getSheltersInSameCity, { shelterId: '$recordId' })
    wiredShelters({ error, data }) {
        if (data) {
            this.mapMarkers = data.map(shelter => ({
                location: {
                    Latitude: shelter.Location__Latitude__s,
                    Longitude: shelter.Location__Longitude__s
                },
                title: shelter.Name,
                description: `Miasto: ${shelter.City__c}`,
                icon: shelter.Id === this.recordId ? 'standard:account' : 'utility:animal_and_nature'
            }));
        } else if (error) {
            console.error(error);
        }
    }
}