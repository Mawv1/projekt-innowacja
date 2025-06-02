import { LightningElement, track } from 'lwc';
import getMissingAnimals from '@salesforce/apex/MissingAnimalService.getMissingAnimals';
import getMissingAnimalDetails from '@salesforce/apex/MissingAnimalService.getMissingAnimalDetails';
import createMissingAnimal from '@salesforce/apex/MissingAnimalService.createMissingAnimal';
import updateAnimalFoundStatus from '@salesforce/apex/MissingAnimalService.updateAnimalFoundStatus';

export default class MissingAnimals extends LightningElement {
    @track dayDelta = 7;
    @track animals = [];

    // Formularz - zmienne do trzymania wartości
    newAnimalName = '';
    newReportAddress = '';
    newDisappearanceDate = '';
    newReportDescription = '';
    newAnimalBreed = '';
    newAnimalAge;
    newAnimalUniqueFeatures = '';
    newAnimalSize = '';
    newAnimalImageUrl = '';

    handleDeltaChange(event) {
        this.dayDelta = parseInt(event.target.value, 10) || 0;
    }

    async fetchAnimals() {
        try {
            const list = await getMissingAnimals({ dayDelta: this.dayDelta });
            const detailedPromises = list.map(item => {
                if (!item.id) {
                    console.warn('Skipping detail fetch: missing id for item', item);
                    return Promise.resolve({
                        id: null,
                        name: item.name || 'Unnamed',
                        missingDate: item.missingDate,
                        imageUrl: null,
                        found: false
                    });
                }
                return getMissingAnimalDetails({ id: item.id })
                    .then(detail => ({
                        id: detail.id,
                        name: detail.name,
                        missingDate: detail.missingDate,
                        imageUrl: detail.imageUrl,
                        found: detail.found || false
                    }))
                    .catch(err => {
                        console.error(`Error fetching details for ID ${item.id}:`, err);
                        return {
                            id: item.id,
                            name: item.name,
                            missingDate: item.missingDate,
                            imageUrl: null,
                            found: false
                        };
                    });
            });
            this.animals = await Promise.all(detailedPromises);
        } catch (error) {
            console.error('Error fetching animals list:', error);
        }
    }

    async handleAddAnimal() {
        if (!this.newAnimalName || !this.newReportAddress || 
            !this.newDisappearanceDate || !this.newReportDescription) {
            console.error('Missing required fields');
            return;
        }
        
        const formattedDate = new Date(this.newDisappearanceDate).toISOString();
        
        const wrapper ={
                report: {
                    "address": "ul. Kwiatowa 10, Warszawa",
                    "disappearancePlaceLongitude": null,
                    "disappearancePlaceLatitude": null,
                    "disappearanceDate": "2023-05-25T09:12:13.716Z",
                    "description": "Uciekł i nie wrócił"
                },
                animal: {
                    "name": "Antek",
                    "imageUrl": "https://example.com/animal.jpg",
                    "breed": "York",
                    "age": 1,
                    "uniqueFeatures": "w niebieskie ciapki",
                    "size": "small"
                }
        };
        
        console.warn('Adding new animal with data:', wrapper);
        
        try {
            await createMissingAnimal({ wrapper });
            this.newAnimalName = '';
            this.newReportAddress = '';
            this.newDisappearanceDate = '';
            this.newReportDescription = '';
            this.newAnimalBreed = '';
            this.newAnimalAge = null;
            this.newAnimalUniqueFeatures = '';
            this.newAnimalSize = '';
            this.newAnimalImageUrl = '';

            this.fetchAnimals();
        } catch (error) {
            console.error('Error adding missing animal:', error);
        }
    }

    async handleFoundChange(event) {
        const animalId = event.target.dataset.id;
        const found = event.target.checked;

        try {
            await updateAnimalFoundStatus({ animalId, found });

            const animal = this.animals.find(a => a.id === animalId);
            if (animal) animal.found = found;
        } catch (error) {
            console.error('Error updating found status:', error);
        }
    }

    handleNewAnimalNameChange(event) {
        this.newAnimalName = event.target.value;
    }

    handleNewReportAddressChange(event) {
        this.newReportAddress = event.target.value;
    }

    handleNewDisappearanceDateChange(event) {
        this.newDisappearanceDate = event.target.value;
    }

    handleNewReportDescriptionChange(event) {
        this.newReportDescription = event.target.value;
    }

    handleNewAnimalBreedChange(event) {
        this.newAnimalBreed = event.target.value;
    }

    handleNewAnimalAgeChange(event) {
        this.newAnimalAge = event.target.value;
    }

    handleNewAnimalUniqueFeaturesChange(event) {
        this.newAnimalUniqueFeatures = event.target.value;
    }

    handleNewAnimalSizeChange(event) {
        this.newAnimalSize = event.target.value;
    }

    handleNewAnimalImageUrlChange(event) {
        this.newAnimalImageUrl = event.target.value;
    }
}
