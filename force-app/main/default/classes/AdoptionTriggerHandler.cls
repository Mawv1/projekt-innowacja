public with sharing class AdoptionTriggerHandler {
    public static void sendStatusChangeEmails(List<Adoption__c> newList, Map<Id, Adoption__c> oldMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Construct the logo URL from the static resource
        String logoUrl = URL.getOrgDomainUrl().toExternalForm() + '/resource/ShelterLogo';

        // Collect Adoption__c record IDs
        Set<Id> adoptionIds = new Set<Id>();
        for (Adoption__c adoption : newList) {
            adoptionIds.add(adoption.Id);
        }

        // Query Adoption__c records with related Adopter__r and Animal__r fields
        Map<Id, Adoption__c> adoptionMap = new Map<Id, Adoption__c>(
            [SELECT Id, Status__c, Adopter__r.FirstName, Adopter__r.LastName, Adopter__r.PersonEmail, Animal__r.Name
             FROM Adoption__c
             WHERE Id IN :adoptionIds]
        );

        for (Adoption__c newAdoption : newList) {
            Adoption__c oldAdoption = oldMap.get(newAdoption.Id);
            Adoption__c fullAdoption = adoptionMap.get(newAdoption.Id);

            // Check if the status has changed
            if (oldAdoption != null && newAdoption.Status__c != oldAdoption.Status__c) {
                // Check if adopter's email is available
                if (fullAdoption.Adopter__r != null && String.isNotBlank(fullAdoption.Adopter__r.PersonEmail)) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{ fullAdoption.Adopter__r.PersonEmail });
                    email.setSubject('AiMals - Adoption Status Changed');

                    String htmlBody = ''
                        + '<html><body>'
                        +   '<div style="text-align:center;margin-bottom:20px;">'
                        +     '<img src="' + logoUrl + '" alt="Shelter Logo" style="max-width:200px;"/>'
                        +   '</div>'
                        +   '<p>Good Morning ' 
                        +      fullAdoption.Adopter__r.FirstName + ' ' + fullAdoption.Adopter__r.LastName
                        +   ',</p>'
                        +   '<p>Status of adoption for your animal <strong>'
                        +      fullAdoption.Animal__r.Name
                        +   '</strong> has changed to <strong>'
                        +      fullAdoption.Status__c
                        +   '</strong>.</p>'
                        +   '<br/>'
                        +   '<p>Kind regards,<br/>'
                        +      'Your Shelter Team</p>'
                        + '</body></html>';

                    email.setHtmlBody(htmlBody);

                    String plainTextBody = 'Good Morning ' + fullAdoption.Adopter__r.FirstName + ' ' + fullAdoption.Adopter__r.LastName + ',\n\n'
                        + 'Status of adoption for your animal ' + fullAdoption.Animal__r.Name
                        + ' has changed to ' + fullAdoption.Status__c + '.\n\n'
                        + 'Kind regards,\n'
                        + 'Your Shelter Team';

                    email.setPlainTextBody(plainTextBody);

                    emails.add(email);
                }
            }
        }

        // Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}