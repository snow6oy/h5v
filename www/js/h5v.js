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
  source[1].src=filename+".webm";  // Exiftool can't update webm
  video.load();
  video.play();
  /* lookup the selected vid using the href as a key */
  for (var i=0;i<window.vids.length;i++) {
    if (window.vids[i].source==videotarget) {
      window.id=i; // store the index to lookup vid attributes later
    }
  }
  updateForm();
  show('update_metadata');
}
function updateForm() {
  var x=window.id; // convenience
  // but what about the placholders?
  for(var i=0;i<h5vTags.length;i++){
    // console.log("mdat form "+ h5vTags[i]+ ':'+ val);
    document.getElementById(h5vTags[i]).value=window.vids[x][h5vTags[i]];
  }
  // source is in both h5vTags and below .. might need to sort it out later
  // for now it goes after the loop
  document.getElementById('source').innerHTML=window.vids[x].source;  
  document.getElementById('type').innerHTML=window.vids[x].type;
  document.getElementById('caption').innerHTML=window.vids[x].caption;  
}

window.addEventListener("load", function(){
  // allowed values: [-1..5]    well ok -5 should not be allowed but it is *shrug*
  function ratingIsNumber(rating){
    //var reg=new RegExp("^[-]?[0-9]+[\.]?[0-9]+$");
    var reg=new RegExp("^[-]?[0-5]$");    
    return reg.test(rating);
  }
  function trackIsNumber(trackNumber){
    var reg=new RegExp("^[0-9]+$");  // any positive integer    
    return reg.test(trackNumber);
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
        document.querySelector('update_metadata').setAttribute("action", this.links.add.url); */
        handleLinks();
      }else{ // nuke anything displayed from previous search
        document.getElementById('video_player').innerHTML='';
        updateForm();
        /* var pluralised=(window.vids.length==1) ? 'video' : 'videos';
        $('#search_results').html('Found '+ window.vids.length+ ' '+ pluralised); */
        document.getElementById('video_player').innerHTML='No videos found';
      }
    });
  });
  /*
   * UPDATE
   */
  var form=document.getElementById("update_metadata");
  form.addEventListener("submit", function (event){
    event.preventDefault();
    if(! ratingIsNumber(document.getElementById('rating'))){
      document.getElementById('rating').value=-1; // revert to unrated
    }
    if(! trackIsNumber(document.getElementById("trackNumber"))){
      document.getElementById('trackNumber').value=0; // trackNumber='thirteen' will raise a server error
    }
    u.update(form, function(){
      if(this.status==200){  // TODO use a switch 200 400 500 etc.
        console.log("response "+ this.response.body);
      }else{
        console.log("response '"+ this.status+ "' fnarg!");
      }
    });
  });
});
