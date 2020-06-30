using Toybox.WatchUi;

class PowerEfficiencyView extends WatchUi.SimpleDataField {
	
	
	var powerLabel = "Power Eff.";
	
    var lastSecondsPowerCapacity = 30;
    var lastSecondsPowerArray = new [lastSecondsPowerCapacity];
    var currentPowerArrayFilling = 0;
    
    
    var lastSecondsHRCapacity = 5;
    var lastSecondsHRArray = new [lastSecondsHRCapacity];
    var currentHRArrayFilling = 0;
    
	var timerTime = 0;
	var previousTimerTime = 0;
	var lastSecondsAvgPower = 0;
	var lastSecondsAvgHR = 0;
	
	var currentPower = 0;
	var currentHR = 0;
	
	var restHR = 60;
	
	var efficiency = "--";
	
    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        
        label = powerLabel;
        
        if (lastSecondsPowerCapacity < lastSecondsHRCapacity) {
        	lastSecondsPowerCapacity = lastSecondsHRCapacity;
       	}
       	
       	restHR = Application.getApp().getProperty("RestHR");
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        
		timerTime = info.timerTime/1000;
		
		if( timerTime > previousTimerTime ) {
    		// Manage pause without info.timerState because it's not supported under 2.1.0 sdk
    		previousTimerTime = timerTime;
    		
    		 currentPower = info.currentPower;
    		 currentHR = info.currentHeartRate;
    		 
    		 
			System.println("Current power " + currentPower + "W");
			System.println("Current HR " + currentHR + " bpm");
			System.println("");
			

	        if (currentPower != null && currentHR != null) {
		        if (currentPowerArrayFilling == lastSecondsPowerCapacity) {
		        		
        			addAndRollPower(lastSecondsPowerArray, currentPower);
        			addAndRollHR(lastSecondsHRArray, currentHR);
        			
        		    lastSecondsAvgPower = getLastSecondsAveragePower(lastSecondsPowerArray);
        		    lastSecondsAvgHR = getLastSecondsAverageHR(lastSecondsHRArray);
        			
        			// TODO : utiliser les W/kg et %FC max ?
        			efficiency = 100 * lastSecondsAvgPower / (lastSecondsAvgHR - restHR);
		        	
		        	
					System.println("Average power " + lastSecondsAvgPower + "W");
					System.println("Average HR " + lastSecondsAvgHR + " bpm");
					System.println("");
        		} else {
        		
        			lastSecondsPowerArray[currentPowerArrayFilling] = currentPower;
	        		currentPowerArrayFilling++;
	        		
        			if (currentHRArrayFilling == lastSecondsHRCapacity) {
        				addAndRollHR(lastSecondsHRArray, currentHR);
        			} else {
        				lastSecondsHRArray[currentHRArrayFilling] = currentHR;
        				currentHRArrayFilling++;
        			}
	        		
	        	}
			} else {
				efficiency = "--";
			}
    	}
		
		
		System.println("==> Efficiency : " + efficiency);
		System.println("");
		System.println("");
			
        return efficiency;
    }
    
    function addAndRollPower (array, newValue)  {
    
    	for( var i = 0; i < lastSecondsPowerCapacity-1; i++ ) {
    		array[i] = array[i+1];
    	}
    	
    	array[lastSecondsPowerCapacity-1] = newValue;
    	
    	return array;
    }
    
    
    function addAndRollHR (array, newValue)  {
    
    	for( var i = 0; i < lastSecondsHRCapacity-1; i++ ) {
    		array[i] = array[i+1];
    	}
    	
    	array[lastSecondsHRCapacity-1] = newValue;
    	
    	return array;
    }
    
    function getLastSecondsAveragePower (array)  {
    	
    	var powerSum = 0;
    	
    	for( var i = 0; i < lastSecondsPowerCapacity-1; i++ ) {
    		powerSum += array[i];
    	}
    	
		return powerSum/lastSecondsPowerCapacity;
    }
    
    function getLastSecondsAverageHR (array)  {
    	
    	var hrSum = 0;
    	
    	for( var i = 0; i < lastSecondsHRCapacity-1; i++ ) {
    		hrSum += array[i];
    	}
    	
		return hrSum/lastSecondsHRCapacity;
    }

}