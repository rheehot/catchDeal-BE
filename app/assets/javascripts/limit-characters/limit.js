function textCounter(field,cnt, maxlimit) {         
	var cntfield = document.getElementById(cnt)	
	cntfield.value = maxlimit - field.value.length;
}