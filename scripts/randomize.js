<script type="text/javascript">

/***********************************************
* Random Content Order script- © Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

function randomizeContent(classname){
var contents=randomizeContent.collectElementbyClass(classname)
contents.text.sort(function() {return 0.5 - Math.random();})
var tbodyref=contents.ref[0].tagName=="TR"? contents.ref[0].parentNode : new Object()
for (var i=0; i<contents.ref.length; i++){
if (tbodyref.moveRow) //if IE
tbodyref.moveRow(0, Math.round(Math.random()*(tbodyref.rows.length-1)))
else
contents.ref[i].innerHTML=contents.text[i]
contents.ref[i].style.visibility="visible"
}
}

randomizeContent.collectElementbyClass=function(classname){ //return two arrays containing elements with specified classname, plus their innerHTML content
var classnameRE=new RegExp("(^|\\s+)"+classname+"($|\\s+)", "i") //regular expression to screen for classname within element
var contentobj=new Object()
contentobj.ref=new Array() //array containing references to the participating contents
contentobj.text=new Array() //array containing participating contents' contents (innerHTML property)
var alltags=document.all? document.all : document.getElementsByTagName("*")
for (var i=0; i<alltags.length; i++){
if (typeof alltags[i].className=="string" && alltags[i].className.search(classnameRE)!=-1){
contentobj.ref[contentobj.ref.length]=alltags[i]
contentobj.text[contentobj.text.length]=alltags[i].innerHTML
}
}
return contentobj
}

</script>