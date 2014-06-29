/* vids=[{},{},{}] id=0..2 */
var vids, id;
var u=new uber('/playlists/');
/* Event handlers */
window.onload = function() {
  var dropzone = document.getElementById("dropzone");
  dropzone.ondragover=dropzone.ondragenter=function(event){
    event.stopPropagation();
    event.preventDefault();
  }
  /* File object has these properties
   * .name: the file name (it does not include path information)
   * .type: the MIME type, e.g. image/jpeg, text/plain, etc.
   * .size: the file size in bytes
   **/
  dropzone.ondrop = function(event) {
    event.stopPropagation();
    event.preventDefault();
    var twitter_profile=document.getElementById('twitter_profile');
    if(twitter_profile){
      var upFilename=twitter_profile.getAttribute('data-id_str');
      var upFile=event.dataTransfer.files[0]; // ignore any subsequent drops
  //    if(upFile.type.indexOf("video")==0 && upFile.size>1048576 && upFile.size<104857600){
      if(upFile.type=='video/mp4' && upFile.size>0 && upFile.size<8566470){
      /*  console.log("about to send:"+ upFile.name);
        console.log("type:"+ + " bytes:"+ upFile.size); */
        sendFile(upFilename, upFile);
      }else{
        alert(upFile.name+ " is not valid.\nMust be an MP4 and smaller than 8 megabytes");
      }
    }else{
      alert("You need to sign-in to upload");
    }
  }
}
window.addEventListener("load", function(){
  // allowed values: [-1..5]    well ok -5 should not be allowed but it is *shrug*
  function ratingIsNumber(rating){
    //var reg=new RegExp("^[-]?[0-9]+[\.]?[0-9]+$");
    var reg=new RegExp("^[-]?[0-5]$");    
    return reg.test(rating.value);
  }
  function trackIsNumber(trackNumber){
    var reg=new RegExp("^[0-9]+$");  // any positive integer    
    return reg.test(trackNumber.value);
  }
  function getPayload(form){
    var perms='';     // holds the value of the permissions radio button
    var payload={};   // the entire payload object
    var twitter_profile=document.getElementById('twitter_profile');    
    // radio button
    for(i=0;i<form.permissions.length; i++){ 
      if (form.permissions[i].checked){
          perms=form.permissions[i].value;          
      }
    }
    for(var i=0;i<form.length;i++){
      elem=form.elements[i];
      if(elem.id&&elem.type!="submit"){ // skip the controlling elements
        payload[elem.id]=elem.value;
      }
    }
    payload['permissions']=perms;
    payload['tw_id_str']=twitter_profile.getAttribute('data-id_str');
    payload['tw_screen_name']=twitter_profile.getAttribute('data-screen_name');
    return payload;
  }
  /* READ */
  var button=document.getElementById('search');
  button.addEventListener("click", function (event){
    var filter=document.getElementById('filter').value;
    u.read(filter, function(){
      window.vids=this.items; // make global for later
      var sources=captions='';
      this.items.forEach(function (i){
        sources+='<source src="'+ i.source+ '" type="'+ i.type+ '">';
        captions+='<a href="'+ i.source+ '"><img src="'+ i.caption+ '" alt="'+ i.title+ '"></a>';
      });
      if(this.items.length>0){
        document.getElementById('video_player').innerHTML='<video controls poster='+ this.links.poster.url+ '>'+ sources+ '</video>'+ '<figcaption>'+ captions+ '</figcaption>';
        /* TODO is it null because its hidden?
                console.log("action link is "+ this.links.add.url);
        document.querySelector('metadata').setAttribute("action", this.links.add.url); */
        handleLinks();
      }else{ 
        if(window.vids.length>0){ // nuke anything from previous search
          document.getElementById('video_player').innerHTML='';
          updateForm();
          window.vids=[];
        }
        document.getElementById('results').innerHTML='No videos found';
      }
    });
  });
  var form=document.getElementById("metadata");
  /* CREATE: Uploader */
  var uploadLink=document.getElementById('upload');
  uploadLink.addEventListener("click", function (event){
    event.preventDefault();    
    document.getElementById("submit_button").value="Upload";
    show("dropzone");
  });
  form.addEventListener("submit", function (event){
    event.preventDefault();
    if(!ratingIsNumber(document.getElementById('rating'))){
      document.getElementById('rating').value=-1; // revert to unrated
    }
    if(!trackIsNumber(document.getElementById("trackNumber"))){
      document.getElementById('trackNumber').value=0; // trackNumber='thirteen' will raise a server error
    }
  /* UPDATE */    
    if(document.getElementById("submit_button").value=='Update'){
      u.update(getPayload(form), function(){
        var r=JSON.parse(this.responseText);
        switch(this.status){
          case 200:
            document.getElementById('results').innerHTML=r.status;
            break;
          default:
            document.getElementById('results').innerHTML=r.uber.error.data[1].message;
        }        
      });
    }
    if(document.getElementById("submit_button").value=='Upload'){
  /* CREATE: Uploader */      
      u.create(getPayload(form), function(){
        if(this.error){
          document.getElementById('results').innerHTML=this.error;          
        }else{
          document.getElementById('results').innerHTML=this;
        }
      });
    }
  });
});

/* toggle display of page elements */
function show(elementID){(
  function(style){style.display='block';})(document.getElementById(elementID).style);
}
function hide(elementID){(
  function(style){style.display='none';})(document.getElementById(elementID).style);
}
/* events triggered from video list */
function handleLinks(){
  var video_player=document.getElementById('video_player');
  var links=video_player.getElementsByTagName('a');
  for(var i=0;i<links.length;i++){
    links[i].onclick=handler;
  }
}
function handler(e){
  e.preventDefault(); // don't follow the a tag
  videotarget=this.getAttribute("href");
  filename=videotarget.substr(0,videotarget.lastIndexOf('.'))||videotarget;
  video=document.querySelector("#video_player video");
  /*  video.removeAttribute("controls");
      video.setAttribute("poster","/images/video-placeholder.jpg"); */
  source=document.querySelectorAll("#video_player video source");
  source[0].src=filename+".mp4";
  /* source[1].src=filename+".webm"; Exiftool can't update webm */
  video.load();
  video.play();
  /* lookup the selected vid using the href as a key */
  for (var i=0;i<window.vids.length;i++) {
    if (window.vids[i].source==videotarget) {
      window.id=i; // store the index to lookup vid attributes later
    }
  }
  updateForm();
  hide("dropzone");  
  show("datazone");
}
function updateForm() {
  var x=window.id; // convenience
  var mdat=document.getElementById('metadata');
  for(var i=0;i<mdat.length;i++){
    elem=mdat.elements[i];
    if(elem.id&&elem.type!="submit"){ // skip the controlling elements
      document.getElementById(elem.id).value=window.vids[x][elem.id];
    }
  }
  if(!window.vids[x].permissions){
    console.log("warning: no permissions set");
    /* quick panic! deselect all the radio buttons */
    for(i=0;i<mdat.permissions.length;i++){
      mdat.permissions[i].checked=false;
    }
  }else{
    /* console.log("perms from api "+ window.vids[x].permissions+ "mdat perms len "+mdat.permissions.length); */
    mdat.permissions[window.vids[x].permissions].checked=true;
  }
  // we maintain state for the data-foo placholders. but we never access them. Why?
  var file=document.getElementById('fileData');
  file.dataset.type=window.vids[x].type;
  file.dataset.name=window.vids[x].caption;
}

function sendFile(fileName, file) {
  var uri="/videos/";
  var xhr=new XMLHttpRequest();
  var fd=new FormData();
  xhr.open("POST", uri, true);
  xhr.onreadystatechange=function(){
    if(xhr.readyState==4){
      var r=JSON.parse(xhr.responseText);
      if(xhr.status==202){
        show("datazone");
  //      console.log("ready to add metadata");
  /* TODO replace window.vids and hidden form elements with dataset        */
        var fileData=document.getElementById('fileData');
        if(file.name!=fileData.dataset.name){
          // rest metadata whenver there is a new file dropped
          var form=document.getElementById("metadata");
          form.reset();
        }
        fileData.dataset.type=file.type;
        fileData.dataset.name=file.name;
        fileData.dataset.size=file.size;
        document.getElementById('source').value=file.name;
        document.getElementById('results').innerHTML=file.name+ " ok";
      }else{
        document.getElementById('results').innerHTML=r.error;
      }
    }
  };
  fd.append(fileName, file);
  xhr.send(fd); // Initiate a multipart/form-data upload
}