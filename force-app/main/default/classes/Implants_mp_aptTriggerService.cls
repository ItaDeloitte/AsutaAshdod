public with sharing class Implants_mp_aptTriggerService {
    
    public static void calculateImplantsForApp(Set<Id> appsIds) {
        //map to store app id with its prices
        Map<Id, Decimal> appIdMinPrice = new Map<Id, Decimal>();
        Map<Id, Decimal> appIdMaxPrice = new Map<Id, Decimal>();
        List<String> codes = new List<string>{'3', '4', '5', '6', '7'};
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        //aggregate function for min and max prices
        AggregateResult[] aggPrices = [SELECT Appointment__c appointment, status__c,
                                       SUM(min_price__c) min, SUM(max_price__c) max
                                       FROM Implants_mp_apt__c  WHERE Appointment__c IN: appsIds AND status__c = 'פעיל'
                                       GROUP BY Appointment__c, status__c];
        System.debug('aggPrices: ' + aggPrices);
        if(!aggPrices.isEmpty()){
            //take prices for active implants and order app prices maps
            for(AggregateResult agg : aggPrices){
                System.debug('entered if');
                appIdMinPrice.put((Id)agg.get('appointment'), (Decimal)agg.get('min'));
                appIdMaxPrice.put((Id)agg.get('appointment'), (Decimal)agg.get('max'));
                System.debug('appIdMinPrice: ' + appIdMinPrice);
                System.debug('appIdMaxPrice: ' + appIdMaxPrice);
            }
        }
        List<Appointment__c> apps = [SELECT Id, implantsMinPrice__c, implantsMaxPrice__c, 
                                Help_Parent_Code_in__c, Agreement_with_assuta__c, RecordTypeId
                                FROM Appointment__c WHERE Id IN : appsIds AND Agreement_with_assuta__c = 'Y'
                                                    AND RecordTypeId = :surgeriesRTId AND Help_Parent_Code_in__c NOT IN :codes];
        System.debug('apps: ' + apps);
        List<Appointment__c> appsToUpdate = new List<Appointment__c>();
        //update appointment only if it meets the conditions
        for(Appointment__c app : apps){
            if(appIdMinPrice.containsKey(app.Id)){
                app.implantsMinPrice__c = appIdMinPrice.get(app.Id);
                app.implantsMaxPrice__c = appIdMaxPrice.get(app.Id);
            }else{
                app.implantsMinPrice__c = 0;
                app.implantsMaxPrice__c = 0;
            }
            appsToUpdate.add(app);
            System.debug('appsToUpdate.add(app): ' + app);
        }
        System.debug('appsToUpdate: ' + appsToUpdate);
        if(!appsToUpdate.isEmpty()){
            update appsToUpdate;
        }
    }
    
}