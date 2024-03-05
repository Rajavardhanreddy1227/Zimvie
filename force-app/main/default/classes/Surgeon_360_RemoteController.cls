global with sharing class Surgeon_360_RemoteController {
	@TestVisible private static String ERROR_MESSAGE = 'Error has occured.';
	@TestVisible private static String CORRECT_MESSAGE = 'Correct request';

	@RemoteAction
	global static Surgeon_360_ResponseWrapper getSearchResult(Map<String, String> searchParams, Integer pageNumber) {
		Map<String, String> fields = new Map<String, String>();
		fields.put('firstName', 'FirstName');
		fields.put('lastName', 'LastName');
		fields.put('city', 'PersonMailingCity');
		fields.put('state', 'PersonMailingState');
		fields.put('zip', 'PersonMailingPostalCode');

		Integer recordsLimit = 25;
		Integer recordsOffset = 25 * pageNumber;
		String query = 'SELECT Id, FirstName, Account_Picture_Id__c, LastName, PersonMailingCity, PersonMailingState, PersonMailingCountry'
		               + ' FROM Account'
		               + ' WHERE (RecordType.DeveloperName = \'Physician_Processing\''
		               + ' OR RecordType.DeveloperName = \'Physician\')';
		if (!searchParams.isEmpty()) {
			query += ' AND (';
			Integer count = 1;
			Set<String> keys = searchParams.keySet();
			for (String key : keys) {
				query += fields.get(key) + ' LIKE \'' + searchParams.get(key) + '%\'';
				count++;
				if (count <= keys.size()) query += ' AND ';
			}
			query += ')';
		}

		query += ' ORDER BY Name ASC'
		         + ' LIMIT :recordsLimit OFFSET :recordsOffset';
		List<Surgeon_360_ResponseWrapper.SearchResultWrapper> result = new List<Surgeon_360_ResponseWrapper.SearchResultWrapper>();
		try {
			for (Account acc : Database.query(query)) {
				result.add(new Surgeon_360_ResponseWrapper.SearchResultWrapper(acc));
			}
			return new Surgeon_360_ResponseWrapper(true, CORRECT_MESSAGE, result);
		} catch (Exception e) {
			System.debug('Line: ' + e.getLineNumber());
			System.debug('Message: ' + e.getMessage());
			System.debug('Trace: ' + e.getStackTraceString());
			return new Surgeon_360_ResponseWrapper(false, ERROR_MESSAGE);
		}
	}

	@RemoteAction
	global static Surgeon_360_ResponseWrapper getProfileSummary(String selectedId) {
		Map<String, Object> response = new Map<String, Object>();
		try {
			SurgeonSummarryWrapper profileSummary = getProfileSummaryValues(selectedId);
			response.put('profileSummary', profileSummary.profileSummary);
			if (!profileSummary.isRatingHiddedn) {
				response.put('rating', getRating(profileSummary.objectMap));
			}
			response.put('personalData', profileSummary.personalData);

			return new Surgeon_360_ResponseWrapper(true, CORRECT_MESSAGE, response);
		} catch (Exception e) {
			System.debug('Line: ' + e.getLineNumber());
			System.debug('Message: ' + e.getMessage());
			System.debug('Trace: ' + e.getStackTraceString());
			return new Surgeon_360_ResponseWrapper(false, ERROR_MESSAGE);
		}
	}

	private static RatingColourWrapper getColour(Double rating) {
		if (rating < 5) {
			return new RatingColourWrapper('Bronze', Label.Surgeon_360_Rating_Label_Bronze);
		} else if (rating < 8 && rating >= 5) {
			return new RatingColourWrapper('Silver', Label.Surgeon_360_Rating_Label_Silver);
		} else if (rating >= 8) {
			return new RatingColourWrapper('Gold', Label.Surgeon_360_Rating_Label_Gold);
		}
		return null;
	}

	private static String getMultiplierName(String key) {
		Map<String, String> rowMultiplierNames = new Map<String, String>();
		rowMultiplierNames.put('Campaigns', 'Multiplier_Campaigns__c');
		rowMultiplierNames.put('Healthcare Facility Relationships', 'Multiplier_Healthcare_Facilities__c');
		rowMultiplierNames.put('Opportunities', 'Multiplier_Opportunities__c');
		rowMultiplierNames.put('Payors', 'Multiplier_Payors__c');
		rowMultiplierNames.put('Peer Networks', 'Multiplier_Peer_Networks__c');
		rowMultiplierNames.put('Product Usage - Market', 'Multiplier_Product_Usage_Market__c');
		rowMultiplierNames.put('Product Usage - ZB', 'Multiplier_Product_Usage_ZB__c');
		rowMultiplierNames.put('Public Engagements', 'Multiplier_Public_Engagements__c');
		rowMultiplierNames.put('Schedules', 'Multiplier_Schedules__c');
		rowMultiplierNames.put('Sunshine Payments', 'Multiplier_Sunshine_Payments__c');
		rowMultiplierNames.put('Tasks', 'Multiplier_Activities__c');
		rowMultiplierNames.put('% Zimmer Usage', 'Multiplier_Percent_Zimmer_Usage__c');

		return rowMultiplierNames.get(key);
	}

	private static Surgeon_360_ResponseWrapper.RatingWrapper getRating(Map<String, Double> objectMap) {
		Double rating = 0;
		Integer multipliers = 0;
		Surgeon360Settings__c rowMultipliers = Surgeon360Settings__c.getValues('Object Multipliers');
		List<Surgeon360_RatingInfluence__c> influences = [SELECT Operator__c, Range_High__c, Range_Low__c, Related_Object_Name__c, Return_Value__c, RHS_Value__c FROM Surgeon360_RatingInfluence__c];

		for (String objectName : objectMap.keySet()) {
			if (objectMap.get(objectName) == null) continue;
			Integer rowMultiplier = Integer.valueOf(rowMultipliers.get(getMultiplierName(objectName)));
			multipliers += rowMultiplier;
			rating += rowMultiplier * processInfluence(objectMap.get(objectName), objectName, influences);
		}
		if (multipliers != 0) rating /= multipliers;
		RatingColourWrapper colour = getColour(rating);
		return new Surgeon_360_ResponseWrapper.RatingWrapper(rating, colour.label, colour.translatedLabel);
	}

	private static Double processInfluence(Double objectValue, String objectName,
	                                       List<Surgeon360_RatingInfluence__c> influences) {
		for (Surgeon360_RatingInfluence__c influence : influences) {
			if (objectName.equals(influence.Related_Object_Name__c)) {
				if (influence.Operator__c == '=' && objectValue == influence.RHS_Value__c) {
					return influence.Return_Value__c;
				} else if (influence.Operator__c == '>' && objectValue > influence.RHS_Value__c) {
					return influence.Return_Value__c;
				} else if (influence.Operator__c == '>=' && objectValue >= influence.RHS_Value__c) {
					return influence.Return_Value__c;
				} else if (influence.Operator__c == '<' && objectValue < influence.RHS_Value__c) {
					return influence.Return_Value__c;
				} else if (influence.Operator__c == '<=' && objectValue <= influence.RHS_Value__c) {
					return influence.Return_Value__c;
				} else if (influence.Operator__c == 'Range' && objectValue > influence.Range_Low__c && objectValue <= influence.Range_High__c) {
					return influence.Return_Value__c;
				}
			}
		}
		return 0;
	}

	private static SurgeonSummarryWrapper getProfileSummaryValues(String selectedId) {
		Date last12months = Date.today().addMonths(-12);
		Date last24months = last12months.addMonths(-12);
		Date last18months = last12months.addMonths(-6);
		Date today = Date.today();

		//1
		String personMailingAddress = 'SELECT Id, FirstName, LastName, PersonContactId, PersonMailingAddress, Hide_Surgeon_Rating__c'
		                              + ' FROM Account'
		                              + ' WHERE Id = :selectedId';

		//2
		String photo = 'SELECT PhotoId__c'
		               + ' FROM GPL_Profile__c'
		               + ' WHERE Account__c = :selectedId';

		//3
		String zbUsage = 'SELECT sum(Total_Volume__c) totalValue'
		                 + ' FROM Product_Usage__c'
		                 + ' WHERE Market_Units__c = False'
		                 + ' AND ZB_Procedure__c = true'
		                 + ' AND Surgeon__c = :selectedId'
		                 + ' AND Date__c >= :last12months';

		//4
		String  marketUsage = 'SELECT sum(Total_Volume__c) totalValue'
		                      + ' FROM Product_Usage__c'
		                      + ' WHERE Market_Units__c = True'
		                      + ' AND Date__c >= :last18months'
		                      + ' AND Surgeon__c = :selectedId';

		//5
		String sunshinePayments = 'SELECT sum(Amount__c) amount'
		                          + ' FROM Sunshine_Payment__c'
		                          + ' WHERE Physician__c = :selectedId';

		//6
		String activePayers = 'SELECT count(Id) totalCount'
		                      + ' FROM Payor__c'
		                      + ' WHERE Physician__c = :selectedId'
		                      + ' AND Archived__c = False';

		//7
		String campaigns = 'SELECT count(Id) totalCount'
		                   + ' FROM CampaignMember'
		                   + ' WHERE ContactId = :personContactId'
		                   + ' AND Campaign.StartDate >= :last24months';

		//8
		String opportunities = 'SELECT sum(Amount) amount'
		                       + ' FROM Opportunity'
		                       + ' WHERE Id IN (SELECT OpportunityId FROM OpportunityContactRole WHERE ContactId = :personContactId)'
		                       + ' AND StageName != \'Closed Won\''
		                       + ' AND StageName != \'Closed Lost\'';

		//9
		String surgerySchedules = 'SELECT count(Id) totalCount'
		                          + ' FROM Schedule__c'
		                          + ' WHERE Surgeon__c = :selectedId'
		                          + ' AND Schedule_Date__c >= :today';

		//10
		String  healthcareFacilityRelationships = 'SELECT count(Id) totalCount'
		        + ' FROM Healthcare_Surgeon_Relationship__c'
		        + ' WHERE Surgeon__c = :selectedId';

		//11
		String publicEngagement = 'SELECT count(Id) totalCount'
		                          + ' FROM Public_Engagement__c'
		                          + ' WHERE  Date__c >= :last24months'
		                          + ' AND (Doctor__c = :personContactId OR Surgeon_del__c = :selectedId)';


		//12
		String peerNetwork = 'SELECT count(Id) totalCount'
		                     + ' FROM Peer_Network__c'
		                     + ' WHERE Doctor__c = :personContactId';

		//13
		String activities = 'SELECT count(Id) totalCount'
		                    + ' FROM Task'
		                    + ' WHERE AccountID = :selectedId'
		                    + ' AND ActivityDate >= :last24months';

		try {
			List<Account> personMailingAddressResult = Database.query(personMailingAddress);
			Map<String, Double> objectNameMap = new Map<String, Double>();

			Id personContactId = null;
			Address personMailingAddressElement = null;
			Boolean hideSurgeonRating = null;
			Id accountId = null;
			String accountFirstName = null;
			String accountLastName = null;
			if (!personMailingAddressResult.isEmpty()) {
				personMailingAddressElement = personMailingAddressResult.get(0).PersonMailingAddress;
				personContactId = personMailingAddressResult.get(0).PersonContactId;
				hideSurgeonRating = personMailingAddressResult.get(0).Hide_Surgeon_Rating__c;
				accountId = personMailingAddressResult.get(0).Id;
				accountFirstName = personMailingAddressResult.get(0).FirstName;
				accountLastName = personMailingAddressResult.get(0).LastName;
			}

			List<GPL_Profile__c > photoResult = Database.query(photo);
			List<AggregateResult> zbUsageResult = Database.query(zbUsage);
			List<AggregateResult> marketUsageResult = Database.query(marketUsage);
			List<AggregateResult> sunshinePaymentsResult = Database.query(sunshinePayments);
			List<AggregateResult> activePayersResult = Database.query(activePayers);
			List<AggregateResult> campaignsResult = Database.query(campaigns);
			List<AggregateResult> opportunitiesResult = Database.query(opportunities);
			List<AggregateResult> surgerySchedulesResult = Database.query(surgerySchedules);
			List<AggregateResult> healthcareFacilityRelationshipsResult = Database.query(healthcareFacilityRelationships);
			List<AggregateResult> publicEngagementResult = Database.query(publicEngagement);
			List<AggregateResult> peerNetworkResult = Database.query(peerNetwork);
			List<AggregateResult> activitiesResult = Database.query(activities);


			String photoElement = null;
			Decimal zbUsageElement = null;
			Decimal marketUsageElement = null;
			Decimal sunshinePaymentsElement = null;
			Integer activePayersElement = null;
			Integer campaignsElement = null;
			Decimal opportunitiesElement = null;
			Integer surgerySchedulesElement = null;
			Integer healthcareFacilityRelationshipsElement = null;
			Integer publicEngagementElement = null;
			Integer peerNetworkElement = null;
			Integer activitiesElement = null;
			Decimal percentZimmerUsage = null;

			if (!photoResult.isEmpty()) photoElement = (String)photoResult.get(0).PhotoId__c;
			if (!zbUsageResult.isEmpty()) zbUsageElement = (Decimal)zbUsageResult.get(0).get('totalValue');
			if (!marketUsageResult.isEmpty()) marketUsageElement = (Decimal)marketUsageResult.get(0).get('totalValue');
			if (!sunshinePaymentsResult.isEmpty()) sunshinePaymentsElement = (Decimal)sunshinePaymentsResult.get(0).get('amount');
			if (!activePayersResult.isEmpty()) activePayersElement = (Integer)activePayersResult.get(0).get('totalCount');
			if (!campaignsResult.isEmpty()) campaignsElement = (Integer)campaignsResult.get(0).get('totalCount');
			if (!opportunitiesResult.isEmpty()) opportunitiesElement = (Decimal)opportunitiesResult.get(0).get('amount');
			if (!surgerySchedulesResult.isEmpty()) surgerySchedulesElement = (Integer)surgerySchedulesResult.get(0).get('totalCount');
			if (!healthcareFacilityRelationshipsResult.isEmpty()) healthcareFacilityRelationshipsElement = (Integer)healthcareFacilityRelationshipsResult.get(0).get('totalCount');
			if (!publicEngagementResult.isEmpty()) publicEngagementElement = (Integer)publicEngagementResult.get(0).get('totalCount');
			if (!peerNetworkResult.isEmpty()) peerNetworkElement = (Integer)peerNetworkResult.get(0).get('totalCount');
			if (!activitiesResult.isEmpty()) activitiesElement = (Integer)activitiesResult.get(0).get('totalCount');
			if (marketUsageElement != null && zbUsageElement != null && marketUsageElement == 0) {
				percentZimmerUsage = 0;
			} else if (marketUsageElement != null && zbUsageElement != null) {
				percentZimmerUsage = zbUsageElement / marketUsageElement;
			}

			objectNameMap.put('Campaigns', campaignsElement);
			objectNameMap.put('Healthcare Facility Relationships', healthcareFacilityRelationshipsElement);
			objectNameMap.put('Opportunities', opportunitiesElement);
			objectNameMap.put('Payors', activePayersElement);
			objectNameMap.put('Peer Networks', peerNetworkElement);
			objectNameMap.put('Product Usage - Market', marketUsageElement);
			objectNameMap.put('Product Usage - ZB', zbUsageElement);
			objectNameMap.put('Public Engagements', publicEngagementElement);
			objectNameMap.put('Schedules', surgerySchedulesElement);
			objectNameMap.put('Sunshine Payments', sunshinePaymentsElement);
			objectNameMap.put('Tasks', activitiesElement);
			objectNameMap.put('% Zimmer Usage', percentZimmerUsage);

			return new SurgeonSummarryWrapper(objectNameMap,
			                                  new Surgeon_360_ResponseWrapper.ProfileSummaryWrapper(
			                                      zbUsageElement,
			                                      marketUsageElement,
			                                      sunshinePaymentsElement,
			                                      activePayersElement,
			                                      campaignsElement,
			                                      opportunitiesElement,
			                                      surgerySchedulesElement,
			                                      healthcareFacilityRelationshipsElement,
			                                      publicEngagementElement,
			                                      peerNetworkElement,
			                                      activitiesElement
			                                  ), hideSurgeonRating,
			                                  new Surgeon_360_ResponseWrapper.AccountPersonalDataWrapper(personMailingAddressElement,
			                                          photoElement,
			                                          accountId,
			                                          accountFirstName,
			                                          accountLastName
			                                                                                            ));
		} catch (Exception e) {
			System.debug('Line: ' + e.getLineNumber());
			System.debug('Message: ' + e.getMessage());
			System.debug('Trace: ' + e.getStackTraceString());
			throw e;
		}
	}

	private class SurgeonSummarryWrapper {
		public Map<String, Double> objectMap;
		public Surgeon_360_ResponseWrapper.ProfileSummaryWrapper profileSummary;
		public Boolean isRatingHiddedn;
		public Surgeon_360_ResponseWrapper.AccountPersonalDataWrapper personalData;

		public SurgeonSummarryWrapper(Map<String, Double> objectMap,
		                              Surgeon_360_ResponseWrapper.ProfileSummaryWrapper profileSummary,
		                              Boolean isRatingHiddedn,
		                              Surgeon_360_ResponseWrapper.AccountPersonalDataWrapper personalData) {
			this.objectMap = objectMap;
			this.profileSummary = profileSummary;
			this.isRatingHiddedn = isRatingHiddedn;
			this.personalData = personalData;
		}
	}

	private class RatingColourWrapper {
		public String label;
		public String translatedLabel;


		public RatingColourWrapper(String label, String translatedLabel) {
			this.label = label;
			this.translatedLabel = translatedLabel;
		}
	}
}