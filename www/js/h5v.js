/* vids=[{},{},{}] id=0..2 */
var vids, id;
var u=new uber('/playlists/');
/* TODO refactor the API so the client can use "action":"replace" to create H5VTags
 * source, title and caption are all "action":"read"
 * OR just this array from the form.elements[]
 **/
var h5vTags=["source","title","artist","album","rating","trackNumber","producer","genre"];

function show(elementID){(
  function(style){style.display='block';})(document.getElementById(elementID).style);
}
function hide(elementID){(
  function(style){style.display='none';})(document.getElementById(elementID).style);
}
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
  /*
  video.removeAttribute("controls");
  video.setAttribute("poster","file:///C:/Users/gavinj/github/vplayer/www/images/video-placeholder.jpg");
  */
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
  // but what about the placholders?
  for(var i=0;i<h5vTags.length;i++){
    // console.log("mdat form "+ h5vTags[i]+ ':'+ val);
    document.getElementById(h5vTags[i]).value=window.vids[x][h5vTags[i]];
  }
  // source is in both h5vTags and below .. might need to sort it out later
  // to avoid it being clobbered it goes after the loop
  // source has moved to <form metadata>
  /* document.getElementById('source').innerHTML=window.vids[x].source;
  document.getElementById('type').innerHTML=;
  document.getElementById('caption').innerHTML=;  */
  var file=document.getElementById('fileData');
  file.dataset.type=window.vids[x].type;
  file.dataset.name=window.vids[x].caption;
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

  /*
   * READ
   */
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
  /*
   * CREATE: Uploader
  var button=document.getElementById('upload');
  button.addEventListener("click", function (event){
    document.getElementById("submit_button").value="Upload";
    console.log("ready to upload");
  });   
   */
  var uploadLink=document.getElementById('upload');
  uploadLink.addEventListener("click", function (event){
    event.preventDefault();    
    document.getElementById("submit_button").value="Upload";
    show("dropzone");
  });
  form.addEventListener("submit", function (event){
    event.preventDefault();
    if(! ratingIsNumber(document.getElementById('rating'))){
      document.getElementById('rating').value=-1; // revert to unrated
    }
    if(! trackIsNumber(document.getElementById("trackNumber"))){
      document.getElementById('trackNumber').value=0; // trackNumber='thirteen' will raise a server error
    }
    if(document.getElementById("submit_button").value=='Update'){
  /* 
   * UPDATE
   */
      u.update(form, function(){
        var r=JSON.parse(this.responseText);
        switch(this.status){
          case 200:
            document.getElementById('results').innerHTML=r.body;
            break;
          case 201:
          case 400:
          case 404:
          case 405:
          case 500:
          default:
            document.getElementById('results').innerHTML=r.uber.error.data[1].message;
        }        
      });
    }
    if(document.getElementById("submit_button").value=='Upload'){
  /*
   * CREATE: Uploader
   */      
      u.create(form, function(){
        if(this.error){
          document.getElementById('results').innerHTML=this.error;          
        }else{
          document.getElementById('results').innerHTML=this;
        }
      });
    }
  });
});
/* Uploader
 * 1. on clicking [Upload] show dropzone
 * 2. receive and validate dropped file to browser (must be mp4 between 1 and 100MB)
 * 3. POST /up/loader.php
 * 4. read {location::id} apply :id and show metadata form
 * 5. receive metadata input. validate (title, genre and artist = required)
 * 6. update new upload and mark as "done" for searching 
 * https://developer.mozilla.org/en-US/docs/Using_files_from_web_applications#Creating_the_upload_tasks 
 **/
function sendFile(file) {
  var uri="/videos/";  // PHP script, shhh!
  var xhr=new XMLHttpRequest();
  var fd=new FormData();
  xhr.open("POST", uri, true);
  xhr.onreadystatechange=function(){
    if(xhr.readyState==4){
      var r=JSON.parse(xhr.responseText);
      if(xhr.status==201){
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
  fd.append('myFile', file);
  xhr.send(fd); // Initiate a multipart/form-data upload
}
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
    var upFile=event.dataTransfer.files[0]; // ignore any subsequent drops
//    if(upFile.type.indexOf("video")==0 && upFile.size>1048576 && upFile.size<104857600){
    if(upFile.type=='video/mp4' && upFile.size>0 && upFile.size<8566470){
    /*  console.log("about to send:"+ upFile.name);
      console.log("type:"+ + " bytes:"+ upFile.size); */
      sendFile(upFile);
    }else{
      alert(upFile.name+ " is not valid.\nMust be an MP4 and smaller than 8 megabytes.")
    }
  }
}