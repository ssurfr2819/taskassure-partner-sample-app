//Client side validation  
jQuery(document).ready(function() {
  
	//validation for tasks form
  //for this release we handle validations from server
  //but we process address and convert to lat/lng if valid
  jQuery("#task").validate({
	errorElement:'span',
	rules: {
	  // "name":{
	 	// 			  required: true
			// 	}			
		},
	messages: {
	// "name":{
	// 				  required: "Name cannot be blank!"
					 
	// 			}			
		},
        
         submitHandler: function(form){ 
           //var zz = confirm("Submit handler");
           // check first if desired address fields are blank
           var va = jQuery('input[name="task[address]"]').val();
           var vc = jQuery('input[name="task[city]"]').val();
           var vs = jQuery('input[name="task[state]"]').val();
           var vz = jQuery('input[name="task[zipcode]"]').val();
           var vy = jQuery('select[name="task[country]"]').val();
           // no longer requiring state or zip since some countries don't have, but now require country (vy)
           // we aren't going to geocode a partial address, they'll need to come back and fill in a proper address, city, and state, or correct it now
           if ((va == '') || (vc == '') || (vy == '')) {
             var z = confirm("INCOMPLETE ADDRESS: The address provided appears to be incomplete or invalid. You can save it now, but a complete valid address must be provided before the task will be shared with the assigned helper. A valid address includes at least an address, city, and country. You may Cancel now and correct it, or choose OK and update it later.");
             if (z) {
              jQuery("#task_latitude").val('');
              jQuery("#task_longitude").val('');
              form.submit();
             }
             else {
              document.getElementById("proggif").style.display="none";
              return false;
             }
           }
           else {
                // build one text string with best format for geocode
                var vt = va + ", " + vc;
                if (vs) 
                  { 
                    vt = vt + ", " + vs;
                  }
                if (vz) 
                  { 
                    vt = vt + ", " + vz;
                  }
                vt = vt + ", " + vy;
                // geocode the address
                var geocoder = new google.maps.Geocoder(); 
    geocoder.geocode({ 'address': vt },
        function(results, status) {
          if (status.toLowerCase() == 'ok') {
            jQuery("#task_latitude").val(results[0]['geometry']['location'].lat());
            jQuery("#task_longitude").val(results[0]['geometry']['location'].lng());
            //use country name that is returned by geocode in case its different than what user entered
            for (var i=0; i<results[0].address_components.length; i++) {
               for (var b=0;b<results[0].address_components[i].types.length;b++) {

                 if (results[0].address_components[i].types[b] == "country") {
                    //this is the object you are looking for
                    country= results[0].address_components[i];
                    break;
                 }
               }
            }
            jQuery('select[name="task[country]"]').val(country.short_name);
            form.submit();
          } 
          else if (status == "ZERO_RESULTS"){
            var a = confirm("The address provided could not be found in the global locations database. You may Cancel now and correct it, or choose OK and we will save it now. If you save an invalid address, you will need to update it before it can be seen by the person you assign it to.");
            if (a) {
              form.submit();
            }
            else {
              document.getElementById("proggif").style.display="none";
              return false;
            }
          }
          else {
            var e  = confirm("An error occurred while trying to process the task address. Please try again, or if the error continues, let us know. Error message: " + status);
            jQuery("#task_latitude").val('');
            jQuery("#task_longitude").val('');
            if (e) {
              document.getElementById("proggif").style.display="none";
              return false;
            }
            else {
              document.getElementById("proggif").style.display="none";
              return false;
            }

          }
        } //function
    ); //geocoder
           } //else valid address entered
          } //submit function
	}); //task function
	
});