jQuery(document).ready(function() {
  //validation for tasks form
  jQuery("#copytask").validate({
  errorElement:'div',
  rules: {
    "increment":{
            required: true,
            number: true,
            min:0
        },
   "number":{
             required: true,
             number: true,
             min:1,
             max:4
        }
    },
  messages: {

      
    }
  });
  
    
  
});