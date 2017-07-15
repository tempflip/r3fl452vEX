public with sharing class Pricing_UpdateTool {
    public Language__c[] languageList {get; set;}
    public Pricing__c[] pricingList {get; set;}    
    public Map<String, Language__c> languageMap;
    public PricingWrapper[] pricingWrapperList {get; set;}
    public String lList1 {get; set;}
    public String lList2 {get; set;}
    public Boolean reverse {get; set;}
    
    public String region {get; set;}
    public String sourceChar {get; set;}
    public String targetChar {get; set;}
    public String sourceWord {get; set;}
    public String targetWord {get; set;}    
    public String prMult {get; set;}
    public String urMult {get; set;}
    public String exMult {get; set;}

  
    public class pricingWrapper {
        public Pricing__c pricing {get; set;}
    	public regionWrapper[] regionPricingList {get;set;}
    	public Boolean existing {get; set;}
    	
    	public pricingWrapper(Pricing__c pricing) {
    	    this.pricing = pricing;
    	    this.regionPricingList = new regionWrapper[]{};
    	    for (Region_Pricing__c rp : pricing.Region_Pricing__r) {
                addRegionPricing(rp, true);      
    	    }
    	    this.existing = true; 
        }
        
        public void addRegionPricing(Region_Pricing__c rp, Boolean existing) {
        	regionPricingList.add(new regionWrapper(rp, existing));
        }
        
    }

    public class regionWrapper {
        public Region_Pricing__c rp {get; set;}
        public Boolean existing {get; set;}
        public regionWrapper(Region_Pricing__c rp, Boolean existing) {
        	this.rp = rp;
        	this.existing = existing;
        }    
    }
    
    public PageReference initialize() {
        initializeLanguages();
        initializePricingList();
        initializePricingWrapperList();
        return null;
    }
    
    public void initializeLanguages() {
        languageList = [SELECT Name
                           ,Language_Code__c
                           ,Pricing__c
                           FROM Language__c];
          
        languageMap = new Map<String, Language__c>();                  
        for (Language__c language : languageList) {
            languageMap.put(language.Language_Code__c, language);
        }                          
    }
    
    public void initializePricingList() {
        pricingList = [SELECT Name
                        ,Language_From__c
                        ,Language_To__c
                        ,(SELECT Name
                            ,Base_Price__c
                            ,Express_Multiplier__c
                            ,Proofreading_Multiplier__c
                            ,Region__c
                            ,Source_Char_Price__c
                            ,Source_Word_Price__c
                            ,Target_Char_Price__c
                            ,Target_Word_Price__c
                            ,Urgent_Multiplier__c
                            FROM Region_Pricing__r)
                        FROM Pricing__c];
    }
    
    public void initializePricingWrapperList() {
    	pricingWrapperList = new PricingWrapper[]{};
    	for (Pricing__c pricing : pricingList) {
    	   pricingWrapperList.add(new PricingWrapper(pricing));
    	}
    }

    // pagereferences
    ////////////////    
    public PageReference generatePricing() {
        Pricing__c[] newPricingList = new Pricing__c[]{};
        if (lList1 == null || lList1 == '' || lList2 == null || lList2 == '') {
            return null;
        }
        String[] languagesFrom = lList1.split(',');
        String[] languagesTo = lList2.split(',');
        
        for (String lFrom : languagesFrom) {
                for (String lTo : languagesTo) {
                    if(lFrom == lTo) { continue;}
                    
                        Pricing__c pricing = new Pricing__c();
                        pricing.Language_From__c = languageMap.get(lFrom).Id;
                        pricing.Language_To__c = languageMap.get(lTo).Id;
                        pricing.Name = lFrom + '-' + lTo;
                        newPricingList.add(pricing);
            }
        }
        //addint to existing ones
        for(Pricing__c pricing: newPricingList) {
             // creating the new region pricing
            Region_Pricing__c rp = new Region_Pricing__c();
            rp.Region__c = region;
            rp.Source_Char_Price__c = Decimal.valueOf(sourceChar);
            rp.Target_Char_Price__c = Decimal.valueOf(targetChar);
            rp.Source_Word_Price__c = Decimal.valueOf(sourceWord);
            rp.Target_Word_Price__c = Decimal.valueOf(targetWord);           
            rp.Proofreading_Multiplier__c = Decimal.valueOf(prMult); 
            rp.Urgent_Multiplier__c = Decimal.valueOf(urMult); 
            rp.Express_Multiplier__c = Decimal.valueOf(exMult); 
            
            Boolean pricingExists = false;
            //looking for an existing Pricing
            for (pricingWrapper pw : pricingWrapperList) {
            	if (pw.pricing.Language_From__c == pricing.Language_From__c
            	   && pw.pricing.Language_To__c == pricing.Language_To__c) {
                       pricingExists = true;
            	       Boolean rpExists = false;
            	       // looking for an existing region
            	       for (regionWrapper rpw : pw.regionPricingList) {
            	           if (rpw.rp.Region__c == region) {
            	               rp.Id = rpw.rp.Id;
            	               rpw.rp = rp;
            	               rpw.existing = false;
            	               rpExists = true;
            	               break;
            	           }
            	       }
            	       // there is no selected location on an existin pricing
	            	   if (!rpExists) {
	            	       pw.addRegionPricing(rp, false);
	            	       break;
            	       }
            	   }
            }
            // there is no existing pricing
            if (!pricingExists) {
	            PricingWrapper pw = new PricingWrapper(pricing);
	            pw.existing = false;
	            pw.addRegionPricing(rp, false);
	            pricingWrapperList.add(pw);
            }
        }
                
        return null;
    }
    
    public pageReference upsertPricing() {
        Pricing__c[] pricingToUpdate = new Pricing__c[]{};
        for(PricingWrapper pw : PricingWrapperList) {
           pricingToUpdate.add(pw.pricing);
        }
        upsert pricingToUpdate;

        Region_Pricing__c[] rpToUpdateList = new Region_Pricing__c[]{};
    	for(PricingWrapper pw : PricingWrapperList) {
    	   //upsert pw.pricing;
    	   for (regionWrapper rw : pw.regionPricingList) {
    	       rw.rp.Pricing__c = pw.pricing.Id;
    	       rpToUpdateList.add(rw.rp);
    	   }
    	}
    	upsert rpToUpdateList;
    	return null;
    }
    
}