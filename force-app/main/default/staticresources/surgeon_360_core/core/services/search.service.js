angular.module('search')

.service('search.service', ['$q', 'profileSearchRemote', '$log', function ($q, profileSearchRemote, $log) {
    var getMockResults = function() {
    	var defer = $q.defer();

    	var results = [
	    		{
						'id': '1',
	    			'First_Name': 'Jim',
            'Last_Name': 'Sanders',
	    			'City': 'Chicago',
	    			'State': 'IL',
	    			'Country': 'USA'
    			},
	    		{
						'id': '1',
	    			'First_Name': 'Malcom',
                    'Last_Name': 'Goodfriar',
	    			'City': 'London',
	    			'State': '',
	    			'Country': 'UK'
    			},
	    		{
						'id': '1',
	    			'First_Name': 'Angela',
                    'Last_Name': 'Parsons',
	    			'City': 'Clevland',
	    			'State': 'OH',
	    			'Country': 'USA'
    			},
					{
						'id': '1',
						'First_Name': 'Daniel',
						'Last_Name': 'Wilson',
						'City': 'New York',
						'State': 'NY',
						'Country': 'USA'
					},
					{
						'id': '1',
						'First_Name': 'Liz',
						'Last_Name': 'Lochead',
						'City': 'Glasgow',
						'State': '',
						'Country': 'UK'
					},
					{
						'id': '1',
						'First_Name': 'Mary',
						'Last_Name': 'Polson',
						'City': 'Toldeo',
						'State': 'OH',
						'Country': 'USA'
					},
					{
						'id': '1',
						'First_Name': 'Keith',
						'Last_Name': 'Hermitage',
						'City': 'Anchorage',
						'State': 'AK',
						'Country': 'USA'
					},
					{
						'id': '1',
						'First_Name': 'Dante',
						'Last_Name': 'Colmestes',
						'City': 'Rome',
						'State': '',
						'Country': 'Italy'
					},
					{
						'id': '1',
						'First_Name': 'Angela',
						'Last_Name': 'Cunningham',
						'City': 'Santa Fe',
						'State': 'NM',
						'Country': 'USA'
					},
					{
						'id': '1',
						'First_Name': 'Derrick',
						'Last_Name': 'Wall',
						'City': 'Birmingham',
						'State': 'MI',
						'Country': 'USA'
					},
					{
						'id': '1',
						'First_Name': 'Grace',
						'Last_Name': 'Masterton',
						'City': 'Edinburgh',
						'State': '',
						'Country': 'UK'
					},
					{
						'id': '1',
						'First_Name': 'Mary',
						'Last_Name': 'Soames',
						'City': 'Hartford',
						'State': 'CT',
						'Country': 'USA'
					}          
    		];

        defer.resolve(results);
        return defer.promise;
    };

    var getSearchResults = function(phrase, page) {
      var dfd = $q.defer();

			profileSearchRemote(phrase, page).then(
        function(result) {
          if (result.success) {
            //$log.info('profile search results is ' + JSON.stringify(result));
            dfd.resolve(result.data);
          } else {
            $log.info('surgeon search failed ' + result.message );
            dfd.reject('surgeon search failed ' + result.message);
          }
        },
        function(error)  {
          $log.info('surgeon search failed ' + error.message );
          dfd.reject('surgeon search failed ' + error.message);
        }
      );

      return dfd.promise;
    };

    return {
        getMockResults: getMockResults,
				getSearchResults: getSearchResults
    };

}]);






