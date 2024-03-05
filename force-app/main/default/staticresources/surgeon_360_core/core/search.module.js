angular.module('search', [])
	.config(function ($stateProvider, $urlRouterProvider) {
        $stateProvider

            .state('app.searchForm', {
                url: "/search",
                templateUrl: "apex/surgeon_360_search_form_template",
                controller: 'SearchFormController'
            })

            .state('app.searchResults', {
                url: "/search/results",
								templateUrl: "apex/surgeon_360_search_result_template",
                controller: 'SearchResultsController'
            });


    });
