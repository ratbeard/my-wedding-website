$(function () {

  $('body').delegate('.links li', 'click', changeTab)
  

  function changeTab (e) {
    e.preventDefault()
    // var el, id, container, current, content

    el = $(e.currentTarget)
    id = el.find('a').attr('href')
    
    // Update link
    el.siblings('.active').removeClass('active').end().addClass('active')
    
    // Update Content
    container = el.closest('section')
    old = container.find('.content .active')
    now = container.find(id)
    
    old.fadeOut(function () { 
      old.removeClass('active')
      now.fadeIn(function () { now.addClass('active') })
    })
    
    console.log(ee = el, old, now)
  }
  
})
