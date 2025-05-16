public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [
            SELECT FirstName, LastName, PersonEmail, Phone 
            FROM Account 
            WITH SECURITY_ENFORCED
            ORDER BY FirstName
        ];
    } 
}