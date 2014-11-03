
	function getEventObject(W3CEvent) {   //事件标准化函数
		return W3CEvent || window.event;
	}

	// fruit image object
	var fruitImages = [
	   {
		name: '10DPA',
		simg: '/static/images/anatomy_viewer/s10DPA.jpg',
		timg: '/static/images/anatomy_viewer/t10DPA.jpg',
		ximg: '/static/images/anatomy_viewer/x10DPA.jpg',
		yimg: '/static/images/anatomy_viewer/y10DPA.jpg',
		ximgs: '/static/images/anatomy_viewer/x10DPAS.jpg',
		yimgs: '/static/images/anatomy_viewer/y10DPAS.jpg'
	    },

	    {
		name: '15DPA',
		simg: '/static/images/anatomy_viewer/s15DPA.jpg',
		timg: '/static/images/anatomy_viewer/t15DPA.jpg',
		ximg: '/static/images/anatomy_viewer/x15DPA.jpg',
		yimg: '/static/images/anatomy_viewer/y15DPA.jpg',
		ximgs: '/static/images/anatomy_viewer/x15DPAS.jpg',
		yimgs: '/static/images/anatomy_viewer/y15DPAS.jpg'
	    },

            {
                name: '20DPA',
		simg: '/static/images/anatomy_viewer/s20DPA.jpg',
                timg: '/static/images/anatomy_viewer/t20DPA.jpg',
                ximg: '/static/images/anatomy_viewer/x20DPA.jpg',
                yimg: '/static/images/anatomy_viewer/y20DAP.jpg',
		ximgs: '/static/images/anatomy_viewer/x20DPAS.jpg',
		yimgs: '/static/images/anatomy_viewer/y20DPAS.jpg'
            },

            {
                name: '30DPA',
		simg: '/static/images/anatomy_viewer/s30DPA.jpg',
		simg: '/static/images/anatomy_viewer/s30DPA.jpg',
                timg: '/static/images/anatomy_viewer/t30DPA.jpg',
                ximg: '/static/images/anatomy_viewer/x30DPA.jpg',
                yimg: '/static/images/anatomy_viewer/y30DPA.jpg',
		ximgs: '/static/images/anatomy_viewer/x30DPAS.jpg',
		yimgs: '/static/images/anatomy_viewer/y30DPAS.jpg'
            },

	    {
		name: 'MG',
		simg: '/static/images/anatomy_viewer/sMG.jpg',
		timg: '/static/images/anatomy_viewer/tMG.jpg',
		ximg: '/static/images/anatomy_viewer/xMG.jpg',
		yimg: '/static/images/anatomy_viewer/yMG.jpg',
		ximgs: '/static/images/anatomy_viewer/xMGS.jpg',
		yimgs: '/static/images/anatomy_viewer/yMGS.jpg'
	    },

	    {
		name: 'Pink',
		simg: '/static/images/anatomy_viewer/sPink.jpg',
		timg: '/static/images/anatomy_viewer/tPink.jpg', 
		ximg: '/static/images/anatomy_viewer/xPink.jpg',
		yimg: '/static/images/anatomy_viewer/yPink.jpg',
		ximgs: '/static/images/anatomy_viewer/xPinkS.jpg',
		yimgs: '/static/images/anatomy_viewer/yPinkS.jpg'
	    },

            {
                name: 'B2',
		simg: '/static/images/anatomy_viewer/sB2.jpg',
                timg: '/static/images/anatomy_viewer/tB2.jpg',
                ximg: '/static/images/anatomy_viewer/xB2.jpg',
                yimg: '/static/images/anatomy_viewer/yB2.jpg',
		ximgs: '/static/images/anatomy_viewer/xB2S.jpg',
		yimgs: '/static/images/anatomy_viewer/yB2S.jpg'
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
	var sheight = screen.height;
	var footerV_height1 = 250;
	var footerV_height2 = 80;
	var sliderX_size = 240;
	var sliderY_size = 240;
	if ( sheight < 901 ) {
		footerV_height1 = 50;
		footerV_height2 = 50;
		//sliderX_size = 120;
		//sliderY_size = 120;
		slideHeightX = 620;
		slideHeightY = 620;
	}

	function movetoTop () {
		var section = 'top';
		$('html, body').animate({ scrollTop: $("#header").offset().top }, 2000); 
		$("#anatomy_headerV").fadeIn(2000);
		//$("#anatomy_footerV").height(250);
		$("#anatomy_footerV").animate({ height: footerV_height1 + 'px'}, 500);
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
		$("#anatomy_footerV").animate({ height: footerV_height2 + 'px'}, 500);
		$("#anatomy_footerV").fadeOut(2000);
		preSection = section;
	}

        function movetoBottom () { 
		var section = 'bottom'
		$('html, body').animate({ scrollTop: $("#anatomy_bottom").offset().top }, 2000); 
		$("#anatomy_headerV").fadeIn(2000);
		$("#anatomy_footerV").animate({ height: footerV_height2 + 'px'}, 500);
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
	
		var simg, timg, ximg, yimg , ximgs, yimgs;
		for (var i=0; i<fruitImages.length; i++) {
			if (fruitImages[i].name == stage) {
				timg = fruitImages[i].timg;
				ximg = fruitImages[i].ximg;
				yimg = fruitImages[i].yimg;
				if ( footerV_height1 == 50 ) {
					//timg = fruitImages[i].simg;
					ximg = fruitImages[i].ximgs;
					yimg = fruitImages[i].yimgs;
				}
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
			size: sliderX_size,
			value: 0,
			step: 1,
			min: 0,
			max: 21
		});
			
		mySlider2 = new dhtmlXSlider({
			parent: "sliderY",
			size: sliderY_size,
			value: 0,
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

	function get_browser() {
		var ua=navigator.userAgent,tem,M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
		if(/trident/i.test(M[1])){
			tem=/\brv[ :]+(\d+)/g.exec(ua) || [];
			return 'IE '+(tem[1]||'');
        	}
		if(M[1]==='Chrome'){
 			tem=ua.match(/\bOPR\/(\d+)/)
        		if(tem!=null)   {return 'Opera '+tem[1];}
        	}
		M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
		if((tem=ua.match(/version\/(\d+)/i))!=null) {M.splice(1,1,tem[1]);}
		return M[0];
	}

	var browser = get_browser();

	function switchVideo (data) {

		var stage;
                var stages = document.getElementsByName('radioStage') ;
                for (var i=0; i<stages.length; i++) {
                        if (stages[i].checked) { stage = stages[i].value; }
                }

		var videoSource = "/static/video/" + stage + data;
		var videoType;
		if (browser == 'Firefox' || browser == 'Chrome') {
			videoSource += ".ogv";
			videoType = "video/ogg";
		} else {
			videoSource += ".mp4";
			videoType = "video/mp4";
		}
		
		var fruit_video = $('#fruit_video');
		fruit_video.attr('src', videoSource);
		fruit_video.attr('type', videoType);
		var video_block = $('#video_block');
		video_block.load();
	}

window.onload = function()
{
	if (browser != 'Firefox' && browser != 'Chrome') {
		$("#anatomy_headerV").html( $("#anatomy_headerV").html() + "<br />This web page is only supported by Firefox and Chrome");
	}

	// hide the footer
	$('#footer').hide();

	// adjust the section div size according to screen szie
	if (sheight < 800 ) {
		//$("#tIMG").width(120);
		//$("#tIMG").height(120);
		$("#xyIMG").width(650);
		$("#xyIMG").height(620);
	}

	var wheight = $(window).height();
	$("#anatomy_top").height(wheight);
	$("#anatomy_middle").height(wheight);
	$("#anatomy_bottom").height(wheight);

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
	var videoSource = "/static/video/Pink1";
	var videoType;
	if (browser == 'Firefox' || browser == 'Chrome') { videoSource += ".ogv"; } else { videoSource += ".mp4"; }
	if (browser == 'Firefox' || browser == 'Chrome') { videoType == "video/ogv"; } else { videoType == "video/mp4"; }
        var fruit_video = $('#fruit_video');
        fruit_video.attr('src', videoSource);
	fruit_video.attr('type', videoType);
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
