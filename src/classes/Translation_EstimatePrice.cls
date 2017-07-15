// @@ DEPRECATED
// the last update statement is commented out
public class Translation_EstimatePrice extends TranslationTrigger {
    public static final string TRANSLATION_UNIT_CHAR = ReflexSettings.TRANSLATION_UNIT_CHAR;
    public static final string TRANSLATION_UNIT_WORD = ReflexSettings.TRANSLATION_UNIT_WORD;

    public Map <id, Language__c> languagesMap;
    public Map <Id, Pricing__c> pricingMap = new Map <id, Pricing__c>();
	public Map <String, Pricing__c> pricingPairsMap = new map <String, Pricing__c>();
    public Map <Id, Account> accountMap;
    public Map <Id, Account_Pricing__c[]> accountPricing;
    
    public Translation_EstimatePrice(Translation__c[] sobjectOldList, Translation__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }    
	
    public override Boolean getIsMatching(Translation__c sobjectOld, Translation__c sobjectNew) {
    	
        if (sobjectNew.Target_Language__c == null) {   sobjectNew.addError('Please set the Language To field'); return false;}    	
        if (sobjectNew.Source_Language__c == null) { sobjectNew.addError('Please set the Language From field'); return false;}
    

        // if the price is locked, we dont do anything
        if (sobjectNew.Lock_Price__c) {
        	return false;
        }
        
        // if this is a new tranlastion we are going on
        if (sobjectOld == null) {
        	return true;
        }

        if (sobjectOld.Lock_Price__c == true) {
            return false;
        }

        return sobjectOld.Account__c != sobjectNew.Account__c  || 
                sobjectOld.Source_Language__c != sobjectNew.Source_Language__c  ||
                sobjectOld.Target_Language__c != sobjectNew.Target_Language__c ||
                sobjectOld.Estimated_Count__c != sobjectNew.Estimated_Count__c ||
                sobjectOld.Estimated_Units__c != sobjectNew.Estimated_Units__c ||
                sobjectOld.Urgent__c != sobjectNew.Urgent__c ||
                sobjectOld.Express__c != sobjectNew.Express__c ||
                sobjectOld.Proofreading__c != sobjectNew.Proofreading__c ||
                sobjectOld.Native_Language_Proofreading__c != sobjectNew.Native_Language_Proofreading__c ||
                sobjectOld.Proofreading_Only__c != sobjectNew.Proofreading_Only__c ||
                sobjectOld.Region__c != sobjectNew.Region__c ||
                sobjectOld.Due_Date__c != sobjectNew.Due_Date__c ||
                sobjectOld.Charge_Urgent__c != sobjectNew.Charge_Urgent__c || 
                sobjectOld.Charge_Proofreading__c != sobjectNew.Charge_Proofreading__c ||
                sobjectOld.Price_Based__c != sobjectNew.Price_Based__c ||
                sobjectOld.Field__c != sobjectNew.Field__c ||
                sobjectOld.Certified__c != sobjectNew.Certified__c
                ;
    }

    public override void execute(Translation__c[] sobjectList, Boolean doUpdate) {
		languagesMap = new map <id, Language__c>([SELECT Name
                                             ,Pricing__c
                                             ,Pricing__r.Name                          
                                             FROM Language__c
                                             LIMIT 10000]);                        

        pricingMap = new Map<Id, Pricing__c>([SELECT Name
                                        ,Language_From__c
                                        ,Language_To__c
                                        ,(SELECT Name 
                                            , Base_Price__c
                                            , Source_Char_Price__c
                                            , Source_Word_Price__c
                                            , Express_Multiplier__c
                                            , Proofreading_Multiplier__c
                                            , Region__c
                                            , Target_Char_Price__c
                                            , Target_Word_Price__c
                                            , Urgent_Multiplier__c
                                            FROM Region_Pricing__r)
                                        FROM Pricing__c LIMIT 10000]); 

        accountMap = new Map<Id, Account>([SELECT Name
                                                ,Translation_Discount__c
                                                ,Translation_Surcharge__c
                                                FROM Account WHERE
                                                Id IN (
                                                    SELECT Account__c 
                                                    FROM Translation__c
                                                    WHERE Id IN : sobjectList)
                                            ]);                      
        // getting the custom account pricing
        accountPricing = new Map <Id, Account_Pricing__c[]>();
        for (Account_Pricing__c ap : [SELECT Name 
                                                , Account__c
	                                            , Base_Price__c
	                                            , Source_Char_Price__c
	                                            , Source_Word_Price__c
	                                            , Express_Multiplier__c
	                                            , Proofreading_Multiplier__c
	                                            , Source_Language__c
	                                            , Target_Char_Price__c
	                                            , Target_Word_Price__c
	                                            , Target_Language__c
	                                            , Urgent_Multiplier__c
	                                            FROM Account_Pricing__c
	                                            WHERE Account__c != null]) {
	        if (accountPricing.containsKey(ap.Account__c) ) {
	        	accountPricing.get(ap.Account__c).add(ap);
	        }                                       	
	        else {
	        	accountPricing.put(ap.Account__c, new Account_Pricing__c[]{ap});
	        }
        }
	                                            
        // storing here the exact pairs                        
		for (Pricing__c pricing : pricingMap.values()) {
			if (pricing.Language_From__c != null && pricing.Language_To__c != null) {
				pricingPairsMap.put((String) pricing.Language_From__c + '|' + (String) pricing.Language_To__c, pricing); 
			}
		}
        
        for (Translation__c estimate : sobjectList) {
        	// some adjustments
        	if (estimate.Estimated_Count__c == null) {
        		estimate.Estimated_Count__c = 0;
        	}
            if (estimate.Due_Date__c == null) {
                estimate.Due_Date__c = DateTime.Now() + ReflexSettings.DEFAULT_DUE_DATE;
            }
                    	
            //setting the currency
            if (estimate.Region__c == null) {
                estimate.addError('Please set a Region.');
                continue;
            }
            estimate.Currency__c = ReflexSettings.getSettingValue('CURRENCY_CODE_' + estimate.Region__c);

            //estimating the completion due date
            Integer unitPerDay = 99999999;
            Integer unitPerDayUrgent = 99999999;
            if (estimate.Estimated_Units__c == ReflexSettings.TRANSLATION_UNIT_CHAR) {
                unitPerDay = Integer.ValueOf(ReflexSettings.getSettingValue('MAXIMUM_CHARS_PER_DAY'));
                unitPerDayUrgent = Integer.ValueOf(ReflexSettings.getSettingValue('MAXIMUM_CHARS_PER_DAY_URGENT'));   
            }
            if (estimate.Estimated_Units__c == ReflexSettings.TRANSLATION_UNIT_WORD) {
                unitPerDay = Integer.ValueOf(ReflexSettings.getSettingValue('MAXIMUM_WORDS_PER_DAY'));
                unitPerDayUrgent = Integer.ValueOf(ReflexSettings.getSettingValue('MAXIMUM_WORDS_PER_DAY_URGENT'));  
            }

            Decimal normalDays = Integer.valueOf(math.Ceil(estimate.Estimated_Count__c / unitPerDay));
            Decimal urgentDays = Integer.valueOf(math.Ceil(estimate.Estimated_Count__c / unitPerDayUrgent));
            //if there is proofreading, we are working 1,5 times slower
            if (estimate.Proofreading__c) {
                normalDays = math.Ceil(normalDays * 1.5);
                urgentDays = math.Ceil(urgentDays * 1.5);
            }

            estimate.Estimated_Due_Date__c = workingDaysFrom(Date.Today(), normalDays); 
            
            Date estimatedUrgentDate = workingDaysFrom(Date.Today(), urgentDays); 
            // setting express / urgent
            if (estimate.Due_Date__c != null) {
                if (estimate.Due_Date__c < estimate.Estimated_Due_Date__c) {
                    if(estimate.Due_Date__c < estimatedUrgentDate) {
                        estimate.Express__c = true;
                        estimate.Urgent__c = false;
                    }
                    else {
                        estimate.Urgent__c = true;
                        estimate.Express__c = false;
                    }
                }
            }

            //calculating the price
            String myKey = (String) estimate.Source_Language__c + '|' + (String) estimate.Target_Language__c;
            Region_Pricing__c myRegionPricing;
            Boolean customPricing = false;
            
            // if there are some custom pricing for this account
            if (accountPricing.containsKey(estimate.Account__c)) {
            	//looking up the exact language pair
            	for (Account_Pricing__c ap : AccountPricing.get(estimate.Account__c)) {
            		if (ap.Source_Language__c == estimate.Source_Language__c && ap.Target_Language__c == estimate.Target_Language__c) {
                        myRegionPricing = new Region_Pricing__c();
                        myRegionPricing.Base_Price__c = ap.Base_Price__c;
                        myRegionPricing.Express_Multiplier__c = ap.Express_Multiplier__c;
                        myRegionPricing.Proofreading_Multiplier__c = ap.Proofreading_Multiplier__c;
                        myRegionPricing.Source_Char_Price__c = ap.Source_Char_Price__c;
                        myRegionPricing.Source_Word_Price__c = ap.Source_Word_Price__c;
                        myRegionPricing.Target_Char_Price__c = ap.Target_Char_Price__c;
                        myRegionPricing.Target_Word_Price__c = ap.Target_Word_Price__c;
                        myRegionPricing.Urgent_Multiplier__c = ap.Urgent_Multiplier__c;
                        customPricing = true;
                        break;    			
            		}
            	}
            }
            // else we look for the price for the language pair
            if (myRegionPricing == null && pricingPairsMap.containsKey(myKey)) {
	            for (Region_Pricing__c regionPricing : pricingPairsMap.get(myKey).Region_Pricing__r) {
	                if (regionPricing.Region__c == estimate.Region__c) {
	                	myRegionPricing = regionPricing;
	                	break;
	                }
	            }
            }
            
            if (estimate.Price_Based__c == null && estimate.Region__c == 'HU') {
            	estimate.Price_Based__c = ReflexSettings.PRICE_BASED_TARGET;
            }

            if (estimate.Price_Based__c == null && estimate.Region__c == 'INT') {
                estimate.Price_Based__c = ReflexSettings.PRICE_BASED_SOURCE;
            }
            
            // if proofreading or NLP is true, we set proofreading to true
            priceEstimate priceEstimate = new priceEstimate(myRegionPricing, 
                    estimate.Estimated_Count__c, 
                    estimate.Estimated_Units__c, 
                    estimate.Proofreading__c || estimate.Native_Language_Proofreading__c,  // OR
                    estimate.Urgent__c, 
                    estimate.Express__c,
                    estimate.Price_Based__c);
            
            // checking, if we charge everthinh, or only the base price
            Decimal calculatedPrice;
            if (estimate.Charge_Proofreading__c && estimate.Charge_Urgent__c) {
                calculatedPrice = priceEstimate.totalPrice();
            } else if (!estimate.Charge_Proofreading__c && estimate.Charge_Urgent__c) {
                calculatedPrice = priceEstimate.basePrice + 
                                  priceEstimate.urgentPrice +
                                  priceEstimate.expressPrice;
            } else if (estimate.Charge_Proofreading__c && !estimate.Charge_Urgent__c) {
                calculatedPrice = priceEstimate.basePrice + 
                                  priceEstimate.proofreadingPrice;
            } else if (!estimate.Charge_Proofreading__c && !estimate.Charge_Urgent__c) {
                calculatedPrice = priceEstimate.basePrice;
            }
            // adding some, if there is a certified multiplier applied
            if (estimate.Certified__c) {
            	calculatedPrice *= (1 + defaultZero(Decimal.valueOf(ReflexSettings.getSettingValue('CERTIFIED_MULTIPLIER'))) / 100);
            }
            // the proofreading-only option
            if (estimate.Proofreading_Only__c) {
            	calculatedPrice = priceEstimate.basePrice * 
            	   defaultZero(Decimal.valueOf(ReflexSettings.getSettingValue('PROOFREADING_ONLY_MULTIPLIER'))) / 100;
            }
            
            // looking for field-specied multipliers
            if (ReflexSettings.getSettingValue('FIELD_MULTI__' + estimate.Field__c) != null) {
            	calculatedPrice *= Decimal.valueOf(ReflexSettings.getSettingValue('FIELD_MULTI__' + estimate.Field__c));
            }
            
            // applying account discount and surcharge (if there is no custom pricing applied)
            if (accountMap.containsKey(estimate.Account__c) && !customPricing) {
            	calculatedPrice *= 1 
            	                   - defaultZero(accountMap.get(estimate.Account__c).Translation_Discount__c) / 100
                                   + defaultZero(accountMap.get(estimate.Account__c).Translation_Surcharge__c) / 100;
            }       
            
            // setting the company-wide minimal
            Decimal minPrice = defaultOf(Decimal.valueOf(ReflexSettings.getSettingValue('MINIMUM_CUSTOMER_PRICE_' + estimate.Region__c)),0);
            
            //estimate.Estimated_Price__c =  calculatedPrice < minPrice ? minPrice : calculatedPrice;
        }
    }

    public class priceEstimate {
        public Decimal basePrice;
        public Decimal proofreadingPrice;
        public Decimal urgentPrice;
        public Decimal expressPrice;
        
        public priceEstimate(Region_Pricing__c regionPricing,
                    Decimal unitCount,
                    String unitType, 
                    Boolean proofreading, 
                    Boolean urgent, 
                    Boolean express,
                    String priceBased
                    ) 
        {
                  	
            if (regionPricing == null) {
                this.basePrice = 0;
                this.proofreadingPrice = 0;
                this.urgentPrice = 0;
                this.expressPrice = 0;
                return;
            }      	
            // the baseprice
            
            
            decimal myUnitPrice;
            if (unitType == ReflexSettings.TRANSLATION_UNIT_CHAR) {
            	if (priceBased == ReflexSettings.PRICE_BASED_SOURCE) {
            	    myUnitPrice = defaultZero(regionPricing.Source_Char_Price__c);
            	} else {
                    myUnitPrice = defaultZero(regionPricing.Target_Char_Price__c);
            	}
            }
            if (unitType == ReflexSettings.TRANSLATION_UNIT_WORD) {
            	if (priceBased == ReflexSettings.PRICE_BASED_SOURCE) {
                    myUnitPrice = defaultZero(regionPricing.Source_Word_Price__c);
            	} else {
            		myUnitPrice = defaultZero(regionPricing.Target_Word_Price__c);
            	}
            }
            
            this.basePrice = defaultZero(regionPricing.Base_Price__c)
                            + defaultZero(unitCount) * defaultZero(myUnitPrice);
            // the proofreading price
            if (proofreading) {
            	this.proofreadingPrice = basePrice * (defaultZero(regionPricing.Proofreading_Multiplier__c)/100);
            } else {
            	this.proofreadingPrice = 0;
            }

            // the proofreading price
            if (urgent) {
                this.urgentPrice = basePrice * (defaultZero(regionPricing.Urgent_Multiplier__c)/100);
            } else {
                this.urgentPrice = 0;
            }

            // the express price
            if (express) {
                this.expressPrice = basePrice * (defaultZero(regionPricing.Express_Multiplier__c)/100);
            } else {
                this.expressPrice = 0;
            }
                    	
        }
        
        public Decimal totalPrice() {
            return this.basePrice
                 + this.proofreadingPrice
                 + this.urgentPrice
                 + this.expressPrice;
        }  

	    private decimal defaultZero(Decimal value) {
	        return value != null ? value : 0;
	    }
    }

    public Date workingDaysFrom(Date d, Decimal n) {
    	system.debug('+++ N: ' + n);
        Integer days = 0;
        Integer workDays = 0;
        do {
        	days ++;
        	system.debug('+++ ' + (d+days) + ' --- ' + dayOfWeek(d + days));
            if (dayOfWeek(d + days) != 0 && dayOfWeek(d + days) != 6) {
                workDays ++;  
            }  
                 	
        } while (workDays < n);
  
        return d + days;
    }

    //returns day of the week for a given date. 0-sunday, 1-monday....
    public Integer dayOfWeek(Date d) {
        return Math.mod(Date.NewInstance(1984, 1, 1).daysBetween(d), 7);
    }
           

}