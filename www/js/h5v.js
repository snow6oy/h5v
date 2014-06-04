/* vids=[{},{},{}] id=0..2 */
var vids, id;
/* TODO refactor the API so the client can use "action":"replace" to create ZzTags
 * source, title and caption are all "action":"read"
 * OR just this array from the form.elements[]
 **/
var zzTags=["source","title","artist","album","rating","trackNumber","producer","genre"];

$(document).ready(
  /* after button is clicked fetch the playlist */
  $('.button').click(function(){
    $.ajax({
      url:"/playlists/",
      dataType:"text",
      success:function(data){
        var json=$.parseJSON(data);
        var sources=captions=items='';
        /* uber structures are a bit obtuse: transformation is so i can think of a posterLink as 
           json.uber.playlist[i].url  NOT json.uber.data[0].data[0].url; */
        var links=flattenLinks(json.uber.data[0]);
	      window.vids=flattenItems(json.uber.data[1]);
	      window.vids.forEach(function(i){
          sources+='<source src="'+ i.source+ '" type="'+ i.type+ '">';
          captions+='<a href="'+ i.source+ '"><img src="'+ i.caption+ '" alt="'+ i.title+ '"></a>';
  	    });
        $('#video_player').html('<video controls poster='+ links.poster.url+ '>'+ sources+ '</video>'+ '<figcaption>'+ captions+ '</figcaption>');
        $("#zzmeta").attr("action", links.add.url);
        handleLinks();
      }
    });
  }),
  $("#zzmeta").submit(function(e){
    var json={};
    /* copy the user-entered form data */ 
    for(var i=0;i<zzTags.length;i++){
      json[zzTags[i]]=document.getElementById(zzTags[i]).value;
    }
    /* add the static file reference */
    json.source=$('#source').html();
    //alert("Handler called."+ json.source);
    // var json={"source":"http://192.168.1.100/zz/marcoPolo/m6.m4v","title":"Tabatha Cazh","artist":"Artist","album":"Album","rating":"5","trackNumber":"21","producer":"Producer","genre":"Genre"};
    // remember for after form submitted
    window.vids[window.id]=json;
/* TODO it like this var json=vids[id]; 
   validate source==defined and that rating/trackNumber are integers
    json.title=document.getElementById('title').value;
*/
    e.preventDefault(); // dont send the form via cgi
    $.ajax({
      url:'/playlists/',
      type:'put',
      dataType:'json',
      data:JSON.stringify(json),
      success:function(response){
        console.log('it worked '+ response.body); 
      },
      error:function(thing,desc){
        console.log('not good '+ desc);
      }
    });
  })
);

function handleLinks(){
  var video_player=document.getElementById("video_player");
  var links=video_player.getElementsByTagName('a');
  for(var i=0;i<links.length;i++){
    links[i].onclick=handler;
  }
}

function handler(e){
  e.preventDefault();
  videotarget=this.getAttribute("href");
  filename=videotarget.substr(0,videotarget.lastIndexOf('.'))||videotarget;
  video=document.querySelector("#video_player video");
  source=document.querySelectorAll("#video_player video source");
  source[0].src=filename+ ".m4v";
/*source[0].src=filename+".mp4";
  source[1].src=filename+".webm"; */
  video.load();
  video.play();
  /* lookup the selected vid using the href as a key */
  for (var i=0;i<window.vids.length;i++) {
    if (window.vids[i].source==videotarget) {
      window.id=i; // store the index to lookup vid attributes later
    }
  }
  updateForm();
}

/* TODO rewrite this the jQuery way $.(#zzmeta).html(htmlString);
function updateText(link) {
  var x; 
  for (var i=0;i<vids.length;i++) {
    if (vids[i].source==link) {
      x=i; // index to lookup vid attributes
      //console.log(vids[i].source+ ' <> '+ link);
    }
  }
*/

function updateForm() {
  var x=window.id; // convenience

  document.getElementById('source').innerHTML=window.vids[x].source;
  document.getElementById('type').innerHTML=window.vids[x].type;
  document.getElementById('caption').innerHTML=window.vids[x].caption;
  // only override the placeholders if there is content
  if (window.vids[x].title && window.vids[x].title.length) {
    document.getElementById('title').value=window.vids[x].title;
  } 
  if (window.vids[x].artist && window.vids[x].artist.length) {
    document.getElementById('artist').value=window.vids[x].artist;
  }
  if (window.vids[x].album && window.vids[x].album.length) {
    document.getElementById('album').value=window.vids[x].album;
  }
  if (window.vids[x].rating && window.vids[x].rating.length) {
    document.getElementById('rating').value=window.vids[x].rating;
  }
  if (window.vids[x].trackNumber && window.vids[x].trackNumber.length) {
    document.getElementById('trackNumber').value=window.vids[x].trackNumber;
  }
  if (window.vids[x].producer && window.vids[x].producer.length) {
    document.getElementById('producer').value=window.vids[x].producer;
  }
  if (window.vids[x].genre && window.vids[x].genre.length) {
    document.getElementById('genre').value=window.vids[x].genre;
  }
}

function flattenItems(uber) {
  var label;
  var items=[];
  uber.data.forEach(function(uber) {
     if (uber["id"]) {
        // come back later please
     } else {
        uber.forEach(function(uber) {
           if (uber["data"]) {
              var x={};            
              uber.data.forEach(function(item) {
                if (undefined==item) {
                  x[label]=null;
                } else if (item.name) {
                  label=item.name;
                } else {
                  x[label]=item;
                }
              })
              items.push(x);
           }
        });
     }
  });
  return items;
}

function flattenLinks(uber){
  var links={};
  uber.data.forEach(function(link) {
    var key=link.id;
    delete link["id"];
    links[key]=link;
  });
  return links;
}
