
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
		name: '15DPA',
		timg: '/static/images/anatomy_viewer/t15DPA.jpg',
		ximg: '/static/images/anatomy_viewer/x15DPA.jpg',
		yimg: '/static/images/anatomy_viewer/y15DPA.jpg'
	    },

            {
                name: '20DPA',
                timg: '/static/images/anatomy_viewer/t20DPA.jpg',
                ximg: '/static/images/anatomy_viewer/x20DPA.jpg',
                yimg: '/static/images/anatomy_viewer/y20DAP.jpg'
            },

            {
                name: '30DPA',
                timg: '/static/images/anatomy_viewer/t30DPA.jpg',
                ximg: '/static/images/anatomy_viewer/x30DPA.jpg',
                yimg: '/static/images/anatomy_viewer/y30DPA.jpg'
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
	    },

            {
                name: 'B2',
                timg: '/static/images/anatomy_viewer/tB2.jpg',
                ximg: '/static/images/anatomy_viewer/xB2.jpg',
                yimg: '/static/images/anatomy_viewer/yB2.jpg'
            },

            {
                name: 'B3',
                timg: '/static/images/anatomy_viewer/tB3.jpg',
                ximg: '/static/images/anatomy_viewer/xB3.jpg',
                yimg: '/static/images/anatomy_viewer/yB3.jpg'
            }

	];

	// display x and y images
	var distanceX = 0;
	var distanceY = 0;
	var initialX, initialY, finalX, finalY, presentX, presentY = 0;
	var isMouseDown = false;
	var counterX = 0;
	var counterY = 0;
	var noOfImagesX = 22;
	var noOfImagesY = 20;
	var slideHeightX = 839;
    	var slideHeightY = 839;
    	var selectStage = null;
	var fdiv, fdivLeft, fdivTop = null;
	var axis;

	/* init stages */
	/*
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
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-counterY * slideHeight)) + "px";
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
	*/

	var preSection;

	function movetoTop () {
		var section = 'top';
		$('html, body').animate({ scrollTop: $("#header").offset().top }, 2000); 
		$("#anatomy_headerV").fadeIn(2000);
		//$("#anatomy_footerV").height(250);
		$("#anatomy_footerV").animate({ height: '250px'}, 500);
		$("#anatomy_footerV").fadeIn(1500);
		preSection = section;
	}
        function movetoMiddle (data) {
		var section = 'middle';
		if (preSection == 'top') {
			$('html, body').animate({ scrollTop: $("#anatomy_middle").offset().top - 65 }, 2000); 
		} else {
			$('html, body').animate({ scrollTop: $("#anatomy_middle").offset().top }, 2000); 
		}
		$("#anatomy_headerV").fadeOut(2000);
		$("#anatomy_footerV").animate({ height: '80px'}, 500);
		$("#anatomy_footerV").fadeOut(2000);

		preSection = section;
	}
        function movetoBottom () { 
		var section = 'bottom'
		$('html, body').animate({ scrollTop: $("#anatomy_bottom").offset().top }, 2000); 
		$("#anatomy_headerV").fadeIn(2000);
		$("#anatomy_footerV").animate({ height: '80px'}, 500);
		$("#anatomy_footerV").fadeIn(2000);

		preSection = section;
	}

	var mySlider, mySlider2;

	/* switch div for x, and y axis */

	var preStage, preXY;
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

		$('#tIMG').css("background-image", "url("+timg+")");
		if (axis == 'x') {
			xyimg = ximg;
			$('#xyIMG').css("background-image", "url("+ximg+")");
			document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((0 * slideHeightX)) + "px";
			$('#sliderX').show();
			$('#sliderY').hide();
		} else {
			xyimg = yimg;
			$('#xyIMG').css("background-image", "url("+yimg+")");
			document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((0 * slideHeightY)) + "px";
			$('#sliderX').hide();
			$('#sliderY').show();
		}
		//console.log(stage," + ",axis," + ",timg," + ",ximg," + ",yimg," + ",xyimg);

		if (preStage == stage) {
			movetoMiddle(1);
		} else {
			movetoMiddle(2);
		}
		switchVideo(1);

		preStage = stage;
		preXY = axis;
	}

	/* slider init */
		
	function doOnLoad(){
		mySlider = new dhtmlXSlider({
			parent: "sliderX",
			size: 240,
			value: 5,
			step: 1,
			min: 0,
			max: 21
		});
			
		mySlider2 = new dhtmlXSlider({
			parent: "sliderY",
			size: 240,
			value: 15,
			step: 1,
			min: 0,
			max: 19,
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
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-data.arg[0] * slideHeightX)) + "px";
	}
	
	function setYimg (data) {
		//console.log(data.arg);
		document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((-data.arg[0] * slideHeightY)) + "px";
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


	function switchVideo (data) {

		var stage;
                var stages = document.getElementsByName('radioStage') ;
                for (var i=0; i<stages.length; i++) {
                        if (stages[i].checked) { stage = stages[i].value; }
                }

		var videoSource = "/static/video/" + stage + data + ".ogv";
		var fruit_video = $('#fruit_video');
		fruit_video.attr('src', videoSource);
		var video_block = $('#video_block');
		video_block.load();
		//console.log(videoSource);	
	}



window.onload = function()
{
	// hide the footer
	$('#footer').hide();

	// adjust the section div size according to screen szie
	var height = $(window).height();
	$("#anatomy_top").height(height);
	$("#anatomy_middle").height(height);
	$("#anatomy_bottom").height(height);

	// set floating header and footer
	$('.anatomy_header').scrollToFixed();
	$('.anatomy_footer').scrollToFixed( {
		bottom: 0,
		limit: $('.anatomy_footer').offset().top
	});	

	// load slide bar
	doOnLoad();

	// load default stage images pink, and video
	$('#tIMG').css("background-image", "url(/static/images/anatomy_viewer/tPink.jpg)");
        $('#xyIMG').css("background-image", "url(/static/images/anatomy_viewer/xPink.jpg)");
        document.getElementById('xyIMG').style.backgroundPosition = "0px " + ((0 * slideHeightX)) + "px";
 	$('#sliderX').show();
	$('#sliderY').hide();

	// load default video
	var videoSource = "/static/video/Pink1.ogv";
        var fruit_video = $('#fruit_video');
        fruit_video.attr('src', videoSource);
        var video_block = $('#video_block');
        video_block.load();

	// move stage to top
	movetoTop();

	$("body").css("overflow", "hidden");
	
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
