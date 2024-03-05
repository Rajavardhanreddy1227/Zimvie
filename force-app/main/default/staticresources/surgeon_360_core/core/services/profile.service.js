angular.module('profiles')

.service('profile.service', ['$q', 'profileDetailRemote', '$log', function ($q, profileDetailRemote, $log) {
    var getMockProfile = function() {
        var defer = $q.defer();

        var mock = {
            'First_Name': 'Malcom',
            'Last_Name': 'Hicks',
            'Address_1': '534 Highcourt Lane',
            'Address_2': '',
            'City': 'Chicago',
            'Country': 'USA',
            'Rating': 5
        };

        defer.resolve(mock);
        return defer.promise;
    };

		var getProfileDetail = function(id) {
			var dfd = $q.defer();

			profileDetailRemote(id).then(
				function(result) {
					if (result.success) {
						//$log.info('profile detail result is ' + JSON.stringify(result));
						dfd.resolve(result.data);
					} else {
						$log.info('profile detail failed ' + result.message );
						dfd.reject('profile detail failed ' + result.message);
					}
				},
				function(error)  {
					$log.info('profile detail failed ' + error.message );
					dfd.reject('profile detail failed ' + error.message);
				}
			);

			return dfd.promise;
		};

    return {
        getMockProfile: getMockProfile,
        getProfileDetail: getProfileDetail
    };

}]);

