angular.module('Summarizer')
  .controller 'DigestCtrl', ['$scope', '$http', '$window', '$timeout', ($scope, $http, $window, $timeout) ->
    
    getArticles = () ->
      $scope.state = "init"
      $scope.index = 0
      $scope.articles = [
        { 
          summary: '' 
          img: '/assets/no.png' 
          url: ''
        }
      ]

      $http({
          url: $window.location.origin + '/news_digest/latest_digest'
          method: 'GET'
        })
        .success (data, status, headers, config) ->
          $scope.articles = data.articles
          $scope.limit = $scope.articles.length
          d = new Date(data.updated_at)
          updated = "Updated at: "+ ("0" + d.getHours()).slice(-2) + ':'
          updated += ("0" + d.getMinutes()).slice(-2) + ':'
          updated += ("0" + d.getSeconds()).slice(-2)
          $scope.updated_at = updated
          $scope.articles[0].visible=true
        .error (data, status, headers, config) ->
          $scope.state = 'error'

    getArticles()
    
    hideButtons = () ->
      $.each $('a.next'), (i, a) ->
        $(a).hide()
      $.each $('a.previous'), (i, a) ->
        $(a).hide()
      return

    showButtons = () ->
      $.each $('a.next'), (i, a) ->
        $(a).show()
      $.each $('a.previous'), (i, a) ->
        $(a).show()
      return

    $scope.playDigest = () ->
      $scope.state = "presentation"
      $scope.articles[0].visible = true
      hideButtons()
      $timeout($scope.slideShow, 4000)

    $scope.slideShow = () ->
      if $scope.index == $scope.limit - 1
        showButtons()
        $scope.index = 0
        return
      else
        $scope.index += 1        
        $timeout($scope.slideShow, 1000)
  ]