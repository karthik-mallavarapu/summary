angular.module('Summarizer')
  .controller 'DigestCtrl', ['$scope', '$http', '$window', '$timeout', ($scope, $http, $window, $timeout) ->
    
    $scope.state = "init"
    $scope.articles = [
      { 
        summary: '' 
        img: '/assets/no.png' 
      }
    ]

    $http({
        url: $window.location.origin + '/news_digest/latest_digest'
        method: 'GET'
      })
      .success (data, status, headers, config) ->
        $scope.articles = data
        $scope.articles[0].visible=true
      .error (data, status, headers, config) ->
        $scope.state = 'error'

    $scope.playDigest = () ->
      $scope.state = "presentation"
      $scope.articles[0].visible = true


  ]