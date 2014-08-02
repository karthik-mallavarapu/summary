angular.module('Summarizer')
  .controller 'HomeCtrl', ['$scope', '$http', '$window', '$timeout', ($scope, $http, $window, $timeout) ->

    $scope.hoverIn = () ->
      this.visible = true
      return false

    $scope.hoverOut = () ->
      this.visible = false
      return false
  ]