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
        $scope.articles = data.articles
        d = new Date(data.updated_at)
        updated = "Updated at: "+ ("0" + d.getHours()).slice(-2) + ':'
        updated += ("0" + d.getMinutes()).slice(-2) + ':'
        updated += ("0" + d.getSeconds()).slice(-2)
        $scope.updated_at = updated
        $scope.articles[0].visible=true
      .error (data, status, headers, config) ->
        $scope.state = 'error'

    $scope.playDigest = () ->
      $scope.state = "presentation"
      $scope.articles[0].visible = true


  ]