$(function () {

  $('body').delegate('.links li', 'click', changeTab)
  

  function changeTab (e) {
    var el, id, container, now, old
    e.preventDefault()

    // Get reference to content to show
    el = $(e.currentTarget)
    id = el.find('a').attr('href')
    
    // Update link state
    el.siblings('.active').removeClass('active').end().addClass('active')
    
    // Update Content visibility
    container = el.closest('section')
    now = container.find(id)
    old = now.siblings(':visible')
    
    old.fadeOut(function () {
      now.fadeIn()
    })
  }
  
})
