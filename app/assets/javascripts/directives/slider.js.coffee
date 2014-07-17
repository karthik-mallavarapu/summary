angular.module('Summarizer')
  .directive 'slider', ($timeout) ->
    restrict: "AE"
    replace: true
    scope: {
      articles: '='
    }
    
    link: (scope, elem, attrs) ->
      
      scope.currentIndex = 0
      scope.next = () ->
        if scope.currentIndex < scope.articles.length - 1 
          scope.currentIndex += 1 

      scope.prev = () ->
        if scope.currentIndex > 0
          scope.currentIndex -= 1

      scope.$watch 'currentIndex', () ->
        scope.articles.forEach (article) ->
          article.visible = false
        scope.articles[scope.currentIndex].visible = true
        return

    templateUrl: "../../assets/slider.html"
