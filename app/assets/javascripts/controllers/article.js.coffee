angular.module('Summarizer')
  .controller 'ArticleCtrl', ['$scope', '$http', '$window', '$timeout', ($scope, $http, $window, $timeout) ->
    
    $scope.state = "init"
    $scope.article = {}

    $scope.onSubmit = () ->
      $scope.state = "processing"
      $http({
          url: $window.location.origin + '/article/summary'
          method: 'POST',
          data: {title: $scope.article.title, content: $scope.article.content}
        })
        .success (data, status, headers, config) ->
          $scope.state = 'processed'
          $scope.summary = data.summary 
        .error (data, status, headers, config) ->
          $scope.state = 'unauthorized'

    onTimeout = () ->
      $scope.state = "processing"
      $timeout(onComplete, 2000)

    $scope.onReset = () ->
      $scope.article = {}
      $scope.state = "init"
      
    onComplete = () ->
      $scope.state = "processed"
      $scope.summary.summary = $scope.summary.article.slice(0, 100)
  ]