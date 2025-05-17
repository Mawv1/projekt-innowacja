import { LightningElement, api, wire } from 'lwc';
import getSheltersInSameCity from '@salesforce/apex/ShelterMapController.getSheltersInSameCity';

export default class ShelterMap extends LightningElement {
    @api recordId;
    mapMarkers = [];
    currentShelterId;

    currentMapIcon = {
        path: "M224.5 111c0-19.9-16.1-36-36-36-19.9 0-36 16.1-36 36s16.1 36 36 36c19.9 0 36-16.1 36-36zm-140.7 5.8c-14.4-3-28.7 1.5-39.2 11.5-10.5 10-14.7 24.2-11 37.8 3.6 13.6 13.9 22.6 27.5 25.6 14.2 3.1 30.1-1.9 41.4-12.7 12-11.2 15.3-28.1 10.8-42.7-4.8-16.3-19-22.2-29.5-19.5zm132.4 1.5c-10.3-11.2-24.8-16.2-39.2-13.8-15.4 2.6-26.7 15-28.4 33.3-1.5 17.1 7 34.5 21.8 45.3 14.8 10.8 33 11.3 46.4 1.1 14.3-11.2 18.4-34.7-.6-56zm-45.6 92.6c-22.2-8.5-55.8-9-79.5 6.3-23.6 15.4-28.5 41.4-10.7 53.8 17.8 12.3 41.4 9.5 67.8-5.1 26.4-14.6 36.4-36.5 27.7-54.9-2.9-6-8-10.5-15.3-11.3z",
        fillColor: '#4CAF50',   // greenish for nature/animals
        fillOpacity: 1,
        strokeWeight: 0,
        scale: 0.06,
        anchor: { x: 20, y: 20 }
    };



    @wire(getSheltersInSameCity, { shelterId: '$recordId' })
    wiredShelters({ error, data }) {
        if (data) {
            this.mapMarkers = data.map(shelter => ({
                location: {
                    Latitude: shelter.Location__Latitude__s,
                    Longitude: shelter.Location__Longitude__s
                },
                title: shelter.Name,
                description: `Address: ${shelter.Address__c}<br>Email: ${shelter.Email__c}<br>Phone: ${shelter.Phone__c}`,
                icon: shelter.Id === this.recordId ? 'standard:home' : 'utility:animal_and_nature',
                mapIcon: {
                    path: "M39.041,36.843c2.054,3.234,3.022,4.951,3.022,6.742c0,3.537-2.627,5.252-6.166,5.252c-1.56,0-2.567-0.002-5.112-1.326c0,0-1.649-1.509-5.508-1.354c-3.895-0.154-5.545,1.373-5.545,1.373c-2.545,1.323-3.516,1.309-5.074,1.309c-3.539,0-6.168-1.713-6.168-5.252c0-1.791,0.971-3.506,3.024-6.742c0,0,3.881-6.445,7.244-9.477c2.43-2.188,5.973-2.18,5.973-2.18h1.093v-0.001c0,0,3.698-0.009,5.976,2.181C35.059,30.51,39.041,36.844,39.041,36.843z M16.631,20.878c3.7,0,6.699-4.674,6.699-10.439S20.331,0,16.631,0S9.932,4.674,9.932,10.439S12.931,20.878,16.631,20.878z M10.211,30.988c2.727-1.259,3.349-5.723,1.388-9.971s-5.761-6.672-8.488-5.414s-3.348,5.723-1.388,9.971C3.684,29.822,7.484,32.245,10.211,30.988z M32.206,20.878c3.7,0,6.7-4.674,6.7-10.439S35.906,0,32.206,0s-6.699,4.674-6.699,10.439C25.507,16.204,28.506,20.878,32.206,20.878zM45.727,15.602c-2.728-1.259-6.527,1.165-8.488,5.414s-1.339,8.713,1.389,9.972c2.728,1.258,6.527-1.166,8.488-5.414S48.455,16.861,45.727,15.602z",
                    fillColor: shelter.Id === this.recordId ? '#4CAF50' : '#00000', 
                    fillOpacity: 1,
                    strokeWeight: 0,
                    scale: 1,
                    anchor: { x: 20, y: 20 }
                }
            }));
        } else if (error) {
            console.error(error);
        }
    }
}