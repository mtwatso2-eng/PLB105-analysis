modulePanel <- function(title, value){
  tabPanel(
    title = title,
    value = value,
    eval(parse(text = value))$ui
  )
}

reloadWarning <- tags$head(tags$script(HTML("
    // Enable navigation prompt
    window.onbeforeunload = function() {
        return 'Your changes will be lost!';
    };
")))

choices <- list("All" = unique(as.character(iris$Species)))


jsOptions <- HTML(
  "
$(function() {
  let observer = new MutationObserver(callback);

  function clickHandler(evt) {
    if ($('.dropdown-item').css('display') == 'block') {
        $('.dropdown-item').on('click', clickHandler).css('display', 'none');
    } else {
        $('.dropdown-item').on('click', clickHandler).css('display', 'block');
    }
  }

  function callback(mutations) {
      for (let mutation of mutations) {
          if (mutation.type === 'childList') {
              $('.dropdown-header').on('click', clickHandler).css('cursor', 'pointer');
              if ($('#group option').length == $('#group :selected').length) {
                  $('.dropdown-item').on('click', clickHandler).css('display', 'none');
              }
          }
      }
  }

  let options = {
    childList: true,
  };

  observer.observe($('.inner')[0], options);
})
"
)