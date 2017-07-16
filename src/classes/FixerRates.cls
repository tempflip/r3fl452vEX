public with sharing class FixerRates {

	public static final String ENDPOINT = 'http://api.fixer.io/latest';

	public Class FixerRes {
		//{"base":"EUR","date":"2017-07-14","rates":{"HUF":306.51}}
		String base;
		Map<String, Decimal> rates;
	}

	public static void Retrieve() {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(ENDPOINT);
        req.setMethod('GET');
        String url = ENDPOINT + '?symbols=EUR,HUF';
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
        	
        	system.debug(res.getBody());
        	
        	FixerRes fr = (FixerRes) JSON.deserialize(res.getBody(), FixerRes.class);

			Fixer_Rates__c rates = Fixer_Rates__c.getOrgDefaults();
			if (fr.rates.get('HUF') != null) {
				rates.EUR_to_HUF__c = fr.rates.get('HUF');
				upsert rates;
			}

        }

	}

}