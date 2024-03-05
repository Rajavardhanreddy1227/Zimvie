angular.module('profiles', [])
	.config(function ($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('app.surgeons', {
                url: "/surgeons/profile/:surgeonId",
                templateUrl: "apex/Surgeon_360_Profile_Template",
                controller: 'ProfileDetailController'
            });

    });
    
