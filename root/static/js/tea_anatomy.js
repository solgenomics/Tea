
	function getEventObject(W3CEvent) {   //事件标准化函数
		return W3CEvent || window.event;
	}

	// fruit image object
	var fruitImages = [
	   {
		name: '10DPA',
		timg: '/static/images/anatomy_viewer/t10DPA.jpg',
		ximg: '/static/images/anatomy_viewer/x10DPA.jpg',
		yimg: '/static/images/anatomy_viewer/y10DPA.jpg'
	    },

	    {
		name: 'MG',
		timg: '/static/images/anatomy_viewer/tMG.jpg',
		ximg: '/static/images/anatomy_viewer/xMG.jpg',
		yimg: '/static/images/anatomy_viewer/yMG.jpg'    
	    },

	    {
		name: 'Pink',
		timg: '/static/images/anatomy_viewer/tPink.jpg', 
		ximg: '/static/images/anatomy_viewer/xPink.jpg',
		yimg: '/static/images/anatomy_viewer/yPink.jpg'
	    }
	];


	// display x and y images
	var distanceX = 0;
	var distanceY = 0;
	var initialX, initialY, finalX, finalY, presentX, presentY = 0;
	var isMouseDown = false;
	var counterX = 0;
	var counterY = 0;
	var noOfImagesX = 19;
	var noOfImagesY = 16;
    	var slideHeight = 940;
    	var selectStage = null;
	var fdiv, fdivLeft, fdivTop = null;
	var axis;

	/* init stages */
	function slideInit() 
	{
		fdiv = document.getElementById('tIMG');
		fdiv.addEventListener("mousedown", handleMouseDown, false);
		fdiv.addEventListener("mousemove", handleMouseMove, false);
		fdiv.addEventListener("mouseup", handleMouseUp, false);
		var pos = getPosition(fdiv).split(",");
		fdivLeft = pos[0];
		fdivTop = pos[1];
		//console.log(pos[0] + " " + pos[1] + " " + fdiv.offsetWidth + " " + fdiv.offsetHeight );
	}

	function getPosition(obj) 
	{ 
		var topValue= 0,leftValue= 0;
		while(obj)
		{  
			leftValue+= obj.offsetLeft;
			topValue+= obj.offsetTop; 
			obj = obj.offsetParent;
		}
		finalvalue = leftValue + "," + topValue;  
		return finalvalue; 
	}
		
    
	function handleMouseMove(event) 
	{
            if (isMouseDown) 
	    {
		presentX = event.pageX;
		presentY = event.pageY;                                
		distanceX = parseInt((presentX - fdivLeft));
		distanceY = parseInt((presentY - fdivTop));
            
		console.log("MoveX: " + distanceX + " PresentX: " + presentX);
		console.log("MoveY: " + distanceY + " PresentY: " + presentY);

		counterX = parseInt((distanceX / fdiv.offsetWidth  * noOfImagesX));
		counterY = parseInt((distanceY / fdiv.offsetHeight * noOfImagesY));

		//document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-counterX * slideHeight)-90) + "px";
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-counterY * slideHeight)-260) + "px";
            }
    	}
	
	function handleMouseDown(event) 
	{
        	event.preventDefault();
	    	isMouseDown = true;
            	initialX = event.pageX;
        	initialY = event.pageY;    
        	//console.log("Mouse Down: " + initialX + " " + initialY);
    	}
	
	function handleMouseUp(event) 
	{
        	if (isMouseDown) {
            		isMouseDown = false;
        	}	
        	finalX = event.pageX;
        	finalY = event.pageY;
        	//console.log("Mouse Up: " + finalX + "" + finalY);
    	}

	var mySlider, mySlider2;

	/* switch div for x, and y axis */
	function switchPlaningImages()
	{
		var d = document.getElementsByName( 'planing' );	
		for (var i=0; i<d.length; i++) {
			if ( d[i].checked ) { axis = d[i].value; }
		}

		var stage;
		var stages = document.getElementsByName('radioStage') ;
		for (var i=0; i<stages.length; i++) {
			if (stages[i].checked) { stage = stages[i].value; }
		}
	
		var timg; var ximg; var yimg;
		for (var i=0; i<fruitImages.length; i++) {
			if (fruitImages[i].name == stage) {
				timg = fruitImages[i].timg;
				ximg = fruitImages[i].ximg;
				yimg = fruitImages[i].yimg;
			} else {
				//alert("Images are not ready!");
			}
		}

		var xyimg;
		if (axis == 'x') {
			xyimg = ximg;
			$('#sliderX').show();
			$('#sliderY').hide();
		} else {
			xyimg = yimg;
			$('#sliderX').hide();
			$('#sliderY').show();
		}

		$('#tIMG').css("background-image", "url("+timg+")");  
		$('#xyIMG').css("background-image", "url("+xyimg+")");
		console.log(stage," + ",axis," + ",timg," + ",ximg," + ",yimg," + ",xyimg);
	}

	/* slider init */
		
	function doOnLoad(){
		mySlider = new dhtmlXSlider({
			parent: "sliderX",
			size: 240,
			value: 5,
			step: 1,
			min: 0,
			max: 18
		});
			
		mySlider2 = new dhtmlXSlider({
			parent: "sliderY",
			size: 240,
			value: 15,
			step: 1,
			min: 0,
			max: 15,
			vertical: true
		});


		mySlider.attachEvent("onChange", function(value){
			setXimg({
				eventNme: "onChange",
				arg: [value]
			});
		});
			
		mySlider.attachEvent("onmySliderideEnd", function(value){
			setXimg({
				eventNme: "onmySliderideEnd",
				arg: [value]
			});
		});

		mySlider2.attachEvent("onChange", function(value){
			setYimg({
				eventNme: "onChange",
				arg: [value]
			});
		});

		mySlider2.attachEvent("onmySliderideEnd", function(value){
			setYimg({
				eventNme: "onmySliderideEnd",
				arg: [value]
			});
		});


	};

	function setXimg (data) {
		//console.log(data.arg);
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-data.arg[0] * 1130)-260) + "px";
	}
	
	function setYimg (data) {
		//console.log(data.arg);
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-data.arg[0] * slideHeight)-150) + "px";
	}

	function doOnUnload(){
		if (mySlider != null){
			mySlider.unload();
			mySlider = null;
		}
		if (mySlider2 != null){
			mySlider2.unload();
			mySlider2 = null;
		}
	};


window.onload = function()
{
	slideInit("MG");
	switchPlaningImages();
	doOnLoad();

	/* slide bar */
	//var sliderX, sliderY;
	//sliderX = new dhtmlXSlider( "sliderX", { skin: "arrowgreen", min: 1, max: 10, value: 1, step: 1, size: 240, vertical: false }); 
	//sliderY = new dhtmlXSlider( "sliderY", { skin: "arrowgreen", min: 1, max: 10, value: 1, step: 1, size: 240, vertical: true }); 
	//sliderX.init();
	//sliderY.init();
	
	/*
	var c=document.getElementById("xyline");
	var cxt=c.getContext("2d");
	cxt.strokeStyle="#ff0000";
	cxt.lineWidth=3;
	cxt.moveTo(8,0);
	cxt.lineTo(8,240);
	cxt.moveTo(0,5);
	cxt.lineTo(240,5);
	cxt.globalAlpha=0.7;
	//cxt.stroke(ckground-image:url(/static/images/anatomy_viewer/xMG.jpg););

	*/
}
