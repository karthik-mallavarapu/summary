angular.module('Summarizer')
  .directive 'slider', ($timeout) ->
    restrict: "AE"
    replace: true
    scope: {
      articles: '='
      index: '='
    }
    
    link: (scope, elem, attrs) ->
      
      #scope.index = 0
      scope.next = () ->
        if scope.index < scope.articles.length - 1 
          scope.index += 1 

      scope.prev = () ->
        if scope.index > 0
          scope.index -= 1

      scope.$watch 'index', () ->
        scope.articles.forEach (article) ->
          article.visible = false
        scope.articles[scope.index].visible = true
        return

    templateUrl: "../../assets/slider.html"
