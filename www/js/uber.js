// CRUD wrapper for uber hypermedia
function uber(url){
  this.homeUrl=url;
  //this.tags=["title","artist","album","rating","trackNumber","producer","genre"];
  // search with a filter or leave empty for random
  this.read=function(filter){
    if(arguments.length){
      console.log('Searching for '+ filter+ ' with this '+ this.homeUrl);
    }else{
      console.log('Being random with this '+ this.homeUrl);
    }
  };
  this.create=function(){ // either upload a new asset OR promote an existing asset
  };
  this.update=function(mdat){ // replace metadata
    var payload={};
    for(var i=0;i<mdat.length;i++){
      elem=mdat.elements[i];
      if(elem.id){ // skip elements without ids, e.g. the submit button
        payload[elem.id]=elem.value;
      }
    }
    var xhr=new XMLHttpRequest();
    xhr.open('PUT', this.homeUrl);
    xhr.onreadystatechange=function(){
      if(this.readyState==4){
        if(this.status==200){  // TODO use a switch 200 400 500 etc.
          response=JSON.parse(xhr.responseText);
          console.log("response "+ response.body);
        }else{
          console.log("response '"+ this.status+ "' fnarg!");
        }
      }
    }
    xhr.send(JSON.stringify(payload));
  };
  // delete means move item to archived folder
  this.delete=function(){};
};
