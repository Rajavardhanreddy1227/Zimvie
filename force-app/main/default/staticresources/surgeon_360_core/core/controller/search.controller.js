angular.module('search')
.controller('SearchController', 
		['$scope', '$log', '$state', 'search.service', 
		function ($scope, $log, $state, searchService) {
			$scope.search = {
				criteria: {}
			};
		    $scope.data = {};
			$scope.page = 0;
			$scope.results = [];
			$scope.loading = false;
			$scope.searchAttempted = false;
			$scope.searchFailure = false;
			$scope.sortOptions = [
						{
							value: 'Last_Name',
							label: 'Last Name A-Z' 
						},
						{
							value: '-Last_Name',
							label: 'Last Name Z-A'
						},
						{
							value: 'City',
							label: 'City A-Z'
						},
						{
							value: '-City',
							label: 'City Z-A'
						},
						{
							value: 'Country',
							label: 'Country A-Z'
						},
						{
							value: '-Country',
							label: 'Country Z-A'
						},
						{
							value: 'Rating',
							label: 'Rating High to Low'
						},
						{
							value: '-Rating',
							label: 'Rating Low to High'
					}
			];

			// default sort
        	if (!$scope.data.resultsSort) {
        	   $scope.data.resultsSort = {};
        	    $log.info('Set sort first time ');
        	    $scope.data.resultsSort = $scope.sortOptions[0];
                $log.info('	$scope.resultsSort is ',$scope.data.resultsSort);  
        	}
        	
			$scope.search = function (criteria) {
				//$log.info('searching. phrase is ' + searchPhrase);
				/*
				if ((typeof searchPhrase == 'undefined') || (searchPhrase == '')) { 
					alert('Please enter a search phrase');
					return;
				}
				*/
				$scope.loading = true;
				//FIXME handle paging
				searchService.getSearchResults(criteria,$scope.page).then(function(results) {
					$scope.searchAttempted = true;

					//$log.info('got page ' + $scope.page + ' search results ' + JSON.stringify(results));
					if ($scope.results.length==0) {

						$scope.results = results;
					} else {
						$scope.results.push.apply($scope.results, results);
					}

					for (var i = 0, len = results.length; i < len; i++) {
						if (!results[i].photo) {
							results[i].photo = 'placeholder';
						}
					}

					$scope.loading = false;
					$scope.searchFailure = false;
					$log.info(results);
				}, function(error) {
					$log.info('Error occured ',error);
					$scope.loading = false;
					$scope.searchFailure = true;
				});
			};

			$scope.doSearch = function (criteria) {
				$scope.results = [];
				$scope.page = 0;
				// the following plain JS not angular friendly line will be replaced soon - emergency use only. Dom
				document.activeElement.blur();
				$scope.search(criteria);
			};

			$scope.addPage = function (criteria) {
				$scope.page++;
				$scope.search(criteria);
			};

			$scope.goToProfile = function (id) {
				$state.go("profile/:surgeonId", {surgeonId: id});
			};

			$scope.clear = function () {
				$scope.results=[];
			};

            $scope.showSort = function() {
                $log.info('	$scope.data.resultsSort is ',$scope.data.resultsSort);  
            };
}]);
