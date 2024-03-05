var myModule = angular.module('app', ['ionic', 'profiles', 'search'])
    .run(function ($ionicPlatform, $state, $document, $window) {
			var document = $document[0]; //unwrap the document from the jquery wrapper 
			// RMB HACK FOR IPAD NOT FOCUSING INPUTS INSIDE IFRAME
			document.addEventListener('click', function (event) {
					var hasFocus = document.hasFocus();
					if (!hasFocus)
							$window.focus();
			});
      $ionicPlatform.ready(function () {
      });
    })

		.config(function ($stateProvider, $urlRouterProvider) {
      $stateProvider
				.state('search', {
						url: "/search",
						templateUrl: "apex/Surgeon_360_Search_Template",
						controller: "SearchController"
				})
        .state('profile/:surgeonId', {
            url: "/surgeons/profile/:surgeonId",
            templateUrl: "apex/Surgeon_360_Profile_Template",
            controller: "ProfileDetailController"
        });

			$urlRouterProvider.otherwise('/search');
    });

