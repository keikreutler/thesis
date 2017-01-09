	var canvas;
	var ctx;
	var dx = 5;
	var dy = 5;
	var x = 150;
	var y = 100;
	var WIDTH = 300;
	var HEIGHT = 200;
	var down_color = "#B5C0AF";
	var up_color = "#B5C0AF";
	
	function circle(x,y,r) {
	ctx.beginPath();
	ctx.arc(x, y, r, 0, Math.PI*2, true);
	ctx.fill();
	}
	
	function rect(x,y,w,h) {
	ctx.beginPath();
	ctx.rect(x,y,w,h);
	ctx.closePath();
	ctx.fill();
	ctx.stroke();
	}
	
	function clear() {
	ctx.clearRect(0, 0, WIDTH, HEIGHT);
	}
	
	function init() {
	canvas = document.getElementById("canvas");
	ctx = canvas.getContext("2d");
	return setInterval(draw, 10);
	}
	
	function doKeyDown(evt){
	switch (evt.keyCode) {
	case 38:  /* Up arrow was pressed */
		up_color = "#787F74";
		down_color = "#B5C0AF";
	break;
	case 40:  /* Down arrow was pressed */
		down_color = "#787F74";
		up_color = "#B5C0AF";
	break;
		}
	}
	
	function draw() {
	clear();
	ctx.strokeStyle = up_color;
	ctx.lineWidth   = 10;
	ctx.beginPath();
	// Start from the top-left point.
	ctx.moveTo(20, 50); // give the (x,y) coordinates
	ctx.lineTo(50, 10);
	ctx.lineTo(80, 50);
	ctx.lineCap = "round";
	ctx.stroke();
	ctx.closePath();
	ctx.beginPath();
	// Start from the top-left point.
	ctx.moveTo(50, 10); // give the (x,y) coordinates
	ctx.lineTo(50, 115);
	ctx.stroke();
	ctx.closePath();
	
	
	ctx.strokeStyle = down_color;
	ctx.lineWidth = 10;
	ctx.beginPath();
	ctx.moveTo(20, 200); // give the (x,y) coordinates
	ctx.lineTo(50, 240);
	ctx.lineTo(80, 200);
	ctx.lineCap = "round";
	ctx.stroke();
	ctx.closePath();
	ctx.beginPath();
	ctx.moveTo(50, 145); // give the (x,y) coordinates
	ctx.lineTo(50, 240);
	ctx.stroke();
	ctx.closePath();
	
	}
	
	init();
	window.addEventListener('keydown',doKeyDown,true);