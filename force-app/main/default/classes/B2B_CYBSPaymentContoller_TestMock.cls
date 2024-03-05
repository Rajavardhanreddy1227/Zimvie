@IsTest
global class B2B_CYBSPaymentContoller_TestMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        	HttpResponse response = new HttpResponse();
        	response.setStatusCode(200);
        response.setBody('{"keyId": "testKeyId",\n' +
                         	'"status":"AUTHORIZED",\n' +
                         	'"id":"mock_id",\n' +
                         	'"consumerAuthenticationInformation":\n' + 
                         		'{ \n' +
                                    '"accessToken": "AccessToken",\n'+
                         			'"stepUpUrl":"expected_step_up_url_here",\n' +
                         			'"pareq":"mock_pareq",\n' +
                         			'"veresEnrolled":"mock_veres_enrolled",\n' +
                         			'"accessToken":"mock_access_token",\n' +
                                    '"deviceDataCollectionUrl": "DeviceDataCollectionUrl/risk/V1/authentication-setups", \n'+
                         			'"referenceId" : "ReferenceId",\n'+
                         			'"token":"Token"\n'+
                                '} \n' +
                         '}');
        	return response;
    	}
}
//'{"status":"AUTHORIZED","consumerAuthenticationInformation":{"stepUpUrl":"expected_step_up_url_here","pareq":"mock_pareq","veresEnrolled":"mock_veres_enrolled","accessToken":"mock_access_token"},"id":"mock_id"}'