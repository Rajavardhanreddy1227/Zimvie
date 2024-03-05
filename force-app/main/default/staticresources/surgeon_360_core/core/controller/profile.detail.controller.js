angular.module('profiles')
.controller('ProfileDetailController', 
	['$scope', '$log', '$state', '$stateParams', 'profile.service', 
	function ($scope, $log, $state, $stateParams, profileService) {
		var init = function() {
			profileService.getProfileDetail($stateParams.surgeonId)
				.then(function(profile) {
					//$log.info('profile is ' + JSON.stringify(profile));
					
					profile.profileSummary.zbUsage = profile.profileSummary.zbUsage ? profile.profileSummary.zbUsage : 0;
					profile.profileSummary.sunshinePayments = profile.profileSummary.sunshinePayments ? profile.profileSummary.sunshinePayments : 0;
					profile.profileSummary.activities = profile.profileSummary.activities ? profile.profileSummary.activities : 0;
					profile.profileSummary.surgerySchedules = profile.profileSummary.surgerySchedules ? profile.profileSummary.surgerySchedules : 0;
					profile.profileSummary.healthcareFacilityRelationships = profile.profileSummary.healthcareFacilityRelationships ? profile.profileSummary.healthcareFacilityRelationships : 0;
					profile.profileSummary.marketUsage = profile.profileSummary.marketUsage ? profile.profileSummary.marketUsage : 0;
					profile.profileSummary.campaigns = profile.profileSummary.campaigns ? profile.profileSummary.campaigns : 0;
					profile.profileSummary.activePayers = profile.profileSummary.activePayers ? profile.profileSummary.activePayers : 0;
					profile.profileSummary.peerNetwork = profile.profileSummary.peerNetwork ? profile.profileSummary.peerNetwork : 0;
					profile.profileSummary.publicEngagement = profile.profileSummary.publicEngagement ? profile.profileSummary.publicEngagement : 0;
					profile.profileSummary.opportunities = profile.profileSummary.opportunities ? profile.profileSummary.opportunities : 0;

					$scope.profile = profile;
					//$scope.profile.id = $stateParams.surgeonId;
					
					// account level can be bronze / silver / gold 
					if(typeof profile.rating !== 'undefined' && profile.rating !== null) {
						$scope.profile.accountLevel = profile.rating.label;
						var level = $scope.profile.accountLevel;
						$scope.profile.accountLevelStyleClass = level.toLowerCase();
					} else {
						$scope.profile.accountLevelStyleClass = "default";
					}
					//$log.info($scope.profile.accountLevelStyleClass);
				});
		};

		$scope.close = function() {
			$state.go('search');
		};

		$scope.goToList = function(obj) {
			$log.info('got ' + obj + ' and ' + $scope.profile.personalData.id);
      if(typeof sforce !== 'undefined' && sforce !== null) {
      	sforce.one.navigateToRelatedList(obj, $scope.profile.personalData.id);
      } else {
      	alert("SF1 only feature.");
      }
		}

		$scope.goToDetail = function() {
			$log.info('going to ' + $scope.profile.personalData.id);
      if(typeof sforce !== 'undefined' && sforce !== null) {
      	sforce.one.navigateToSObject($scope.profile.personalData.id, 'detail');
      } else {
      	alert("SF1 only feature.");
      }
		}

		$scope.goToOpportunityPage = function() {
      if(typeof sforce !== 'undefined' && sforce !== null) {
				sforce.one.navigateToURL("#/sObject/Opportunity/home", isredirect=true);
      } else {
      	alert("SF1 only feature.");
      }
		}

		init();
	}]);
