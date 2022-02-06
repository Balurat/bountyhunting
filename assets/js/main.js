$('document').ready(function() {
    // const wrapperId = 'overlay';
    // $('#'+wrapperId).hide();
    window.addEventListener('message', function(event) {
        
        if (event.data.action == 'open') {
            // $('.overlay').show();
            console.log('opened');
        }
    });
});