/**
 * Apex Class to apply Shipping Rates on Quote
 * */
public class CalculateShippingRatesCtrl { 
    
    @AuraEnabled
    public static void updateQuote(String recId, String shippingRate){
        Astonous_SM.ShippingRate[] rates = (Astonous_SM.ShippingRate[]) JSON.deserialize(shippingRate, Astonous_SM.ShippingRate[].class);
        System.debug(rates);
        if(rates.size()>0){
            Opportunity opp = new Opportunity(id=recId, Estimated_Shipping_Cost__c = Decimal.valueOf(rates[0].totalCharge.substringBefore(' ')));
            update opp;
        }
    }
    
    @AuraEnabled
    public static List<Astonous_SM.ShippingRate> calcRates(String recId){
        List<Astonous_SM.RatingRequest.ShippingPackage> pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
        List<Astonous_SM__Shipping_Preference__c> preferenceList = [Select ID, Name, Astonous_SM__Company__c,Astonous_SM__Contact_Person_Name__c,Astonous_SM__City__c,Astonous_SM__Country__c, 
        Astonous_SM__Email__c,Astonous_SM__Is_it_Residential_Address__c,Astonous_SM__Phone__c,Astonous_SM__Postal_Code__c,
        Astonous_SM__State__c , Astonous_SM__Street__c From Astonous_SM__Shipping_Preference__c  Where Astonous_SM__Default__c = true];        
        
        List<Opportunity> oppList = [SELECT Id, Name, Shipping_Company_Name__c,Shipping_Street__c,Shipping_State__c,Shipping_Country__c,Phone__c,Shipping_City__c,Shipping_Postal_Code__c,Business_Email__c,
                                     (Select Id, Equipment_Weight__c from ELTON__Equipment__r Where Equipment_Weight__c != null)From Opportunity where id = : recId];
        String shippingCarrier;
        Decimal totalWeight = 0; 
        if(oppList.size() > 0){         
            Opportunity oppRecord = oppList.get(0);
            if(oppRecord.ELTON__Equipment__r.size() < 1) {
                throw new CustomException('Please add Equipments to opportunity.');
            }               
            for(ELTON__Equipment__c  lineItem : oppRecord.ELTON__Equipment__r) {
                Astonous_SM.RatingRequest.ShippingPackage pkg = new Astonous_SM.RatingRequest.ShippingPackage();
                pkg.quantity = 1;
                pkg.weight = lineItem.Equipment_Weight__c;
                totalWeight = totalWeight + pkg.weight;
                pkgLst.add(pkg);
            }          
            shippingCarrier =  'Fedex';
            Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
            rr.serviceType = 'All';
            rr.shippingCarrier = shippingCarrier;
            rr.GoodsDescription = oppList[0].Name;//'test description';
            rr.totalWeight = String.valueOf(totalWeight);
            rr.weightUnit = 'LB';
            rr.linearUnit = 'IN';
            rr.packagingType = 'YOUR_PACKAGING'; 
            rr.dropoffType = 'REGULAR_PICKUP'; 
            rr.signatureOption = 'SERVICE_DEFAULT';
            
            rr.recipientInfomration.city = oppRecord.Shipping_City__c;
            rr.recipientInfomration.contactPersonName = oppRecord.Shipping_Company_Name__c ;
            rr.recipientInfomration.companyName = oppRecord.Shipping_Company_Name__c ; 
            rr.recipientInfomration.streetLine = oppRecord.Shipping_Street__c;
            rr.recipientInfomration.state = oppRecord.Shipping_State__c ;
            rr.recipientInfomration.country = 'US';
            rr.recipientInfomration.postalCode = oppRecord.Shipping_Postal_Code__c;
            rr.recipientInfomration.phoneNumber = oppRecord.Phone__c;
            rr.recipientInfomration.isItResidentialAddress = false;
            
            rr.senderInfomration.city = preferenceList[0].Astonous_SM__City__c;
            rr.senderInfomration.contactPersonName = preferenceList[0].Astonous_SM__Contact_Person_Name__c;
            rr.senderInfomration.email = preferenceList[0].Astonous_SM__Email__c;
            rr.senderInfomration.companyName = preferenceList[0].Astonous_SM__Company__c;
            rr.senderInfomration.phoneNumber = preferenceList[0].Astonous_SM__Phone__c;
            rr.senderInfomration.streetLine = preferenceList[0].Astonous_SM__Street__c;
            rr.senderInfomration.state = preferenceList[0].Astonous_SM__State__c;
            rr.senderInfomration.country = preferenceList[0].Astonous_SM__Country__c;
            rr.senderInfomration.isItResidentialAddress = true;
            
            rr.senderInfomration.country = 'US'; 
            
            
            rr.currencyUnit = 'USD';
            rr.senderInfomration.postalCode = preferenceList[0].Astonous_SM__Postal_Code__c;
            rr.shipDate = System.today(); 
            rr.packageList = pkgLst;
            List<Astonous_SM.ShippingRate>  lstRates = Astonous_SM.ShippingController.fetchAllShippingRates(rr); // Make request to fetch all Rates
            return lstRates;
        }
        return null; 
    } 
    
    public class CustomException extends Exception{
        
    }
}