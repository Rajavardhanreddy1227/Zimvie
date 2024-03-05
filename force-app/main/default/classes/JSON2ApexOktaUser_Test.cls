@isTest
private class JSON2ApexOktaUser_Test {

    @isTest
    static void testJSONParsing() {
        String jsonData = '{' +
                            '"profile": {' +
                                '"firstName": "John",' +
                                '"lastName": "Doe",' +
                                '"email": "john.doe@example.com",' +
                                '"login": "johndoe",' +
                                '"mobilePhone": "123-456-7890",' +
                                '"customernumber": "C12345"' +
                            '},' +
                            '"groupIds": ["group1", "group2"]' +
                          '}';

        JSON2ApexOktaUser result = JSON2ApexOktaUser.parse(jsonData);
        JSONParser parser = JSON.createParser(jsonData);
		//JSON2ApexOktaUser.arrayOfString(parser);
		JSON2ApexOktaUser obj = new JSON2ApexOktaUser(); 
        JSON2ApexOktaUser.consumeObject(parser);
        // Verify parsed data
        System.assertEquals('John', result.profile.firstName);
        System.assertEquals('Doe', result.profile.lastName);
        System.assertEquals('john.doe@example.com', result.profile.email);
        System.assertEquals('johndoe', result.profile.login);
        System.assertEquals('123-456-7890', result.profile.mobilePhone);
        System.assertEquals('C12345', result.profile.customernumber);

        System.assertEquals(2, result.groupIds.size());
        System.assertEquals('group1', result.groupIds[0]);
        System.assertEquals('group2', result.groupIds[1]);
    }
    
}