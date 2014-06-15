// CRUD wrapper for uber hypermedia
function uber(url){
  this.homeUrl=url;
//  this.links;
//  this.items=["one","two"];
//  var items;
  //this.tags=["title","artist","album","rating","trackNumber","producer","genre"];
  this.create=function(form, responseHandler){ // either upload a new asset OR promote an existing asset
    console.log("uploader called with "+ form.id);
    /* refactor to use UPDATE code */
    var payload={};
    for(var i=0;i<form.length;i++){
      elem=form.elements[i];
      if(elem.type!="submit" && elem.type!="checkbox"){ // skip the controlling elements
        payload[elem.id]=elem.value;
      }
    }
    var xhr=new XMLHttpRequest();
    xhr.open('POST', this.homeUrl);
    xhr.onreadystatechange=function(){
      if(this.readyState==4){
        var r=JSON.parse(this.responseText);
        var data={};
        switch(this.status){
          case 200:
          case 201:
            data=r.body;
            break;
          case 400:
          case 404:
          case 405:
          case 500:
          default:
            data.error=r.uber.error.data[1].message.error;
        }        
        responseHandler.call(data);
      }
    }
    xhr.send(JSON.stringify(payload));    
  };  
  // search with a filter or leave empty for random
  this.read=function(filter, responseHandler){
    var xhr=new XMLHttpRequest();
    var data={};
    (filter) ?
      xhr.open('GET', this.homeUrl+ 'search?term='+ filter) :
      xhr.open('GET', this.homeUrl); // returns a random selection
    xhr.onreadystatechange=function(){
      if(this.readyState==4){  // readyState 4 means "complete"
        if(this.status==200){  // TODO use a switch 200 400 500 etc.
          response=JSON.parse(xhr.responseText);
          // add version too ..
          data.links=flattenLinks(response.uber.data[0]);
          data.items=flattenItems(response.uber.data[1]);
          responseHandler.call(data);
        }else{
          console.log("error handling:'"+ this.status+ "' fnarg!");
          return false;
        }
      }
    }
    xhr.send(null); // no payload
  };
  this.update=function(form, responseHandler){ // replace metadata
    var payload={};
    for(var i=0;i<form.length;i++){
      elem=form.elements[i];
      if(elem.type!="submit" && elem.type!="checkbox"){ // skip the controlling elements
        payload[elem.id]=elem.value;
      }
    }
    var xhr=new XMLHttpRequest();
    xhr.open('PUT', this.homeUrl);
    xhr.onreadystatechange=function(){
      if(this.readyState==4){
        responseHandler.call(this);
      }
    }
    xhr.send(JSON.stringify(payload));
  };
  // delete means move item to archived folder
  this.delete=function(){};
  function flattenItems(uber) {
    var label;
    var items=[];
    uber.data.forEach(function (uber) {
       if (uber["id"]) {
          // come back later please
       } else {
          uber.forEach(function (uber) {
             if (uber["data"]) {
                var x={};
                uber.data.forEach(function (item) {
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
    uber.data.forEach(function (link) {
      var key=link.id;
      delete link["id"];
      links[key]=link;
    });
    return links;
  }
};
