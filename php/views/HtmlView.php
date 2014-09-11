<?php
class HtmlView {

  public function render($content) {
    $header=$this->getHeader();
    $body=<<<HTML
<body lang=en>
  <a href="#lang">en</a>
  <input id="filter" type=text class=query placeholder="Enter search term or leave empty for random" />
  <input id="search" type=button class=button value=Search />
  <input id="upload" type=button class=button value=Upload />
HTML;
    if(isset($_SESSION['status']) && $_SESSION['status']=='verified'){
      //       
        $body.='<a href="/clearsessions.php"><img alt="photo of signed-in user" title="Sign out @'. 
        $content['screen_name'].'" src="'. 
        $content['profile_image_url']. '"/></a><div id="twitter_profile" data-id_str='. 
        $content['id_str']. ' data-name='. 
        $content['name'].  ' data-screen_name='. 
        $content['screen_name']. '></div>'. "\n";
        // ignore $ok assume it works
        $ok=setcookie(
          'dzid',               // name
          $content['id_str'],   // value
          0,                    // expire
          "/",                  // path 
          "",                   // domain
          false,                // secure
          true                  // httponly
        );
    } else{
      $body.='<a href="/redirect.php"><img src="/static/lighter.png" alt="Sign in with Twitter"/></a>';
    }
/*
    test data
  <a href="/clearsessions.php"><img src="http://pbs.twimg.com/profile_images/2284174758/v65oai7fxn47qv9nectx_normal.png" title="Sign out @nature6oy" alt="photo of signed-in user"></a>
  <div data-screen_name="nature6oy" data-name="nature6oy" data-id_str="449230816" id="twitter_profile"></div>
*/    
    $body.=<<<HTML
  <figure id="video_player"></figure>
  <div id="results"></div>
  <div class="inputs" id="datazone" style="display:none">
    <form id="metadata" action>
      <input id="title" value="" placeholder=Title />
      <input id="artist" value="" placeholder=Artist />
      Genre <select id="genre">
        <option selected></option>
        <option>Alternative</option>
        <option>Country</option>
        <option>Classical</option>
        <option>Dance</option>
        <option>Hip-Hop</option>
        <option>Indie</option>
        <option>Jazz</option>
        <option>Latin</option>
        <option>Pop</option>
        <option>R&amp;B</option>
        <option>Rap</option>
        <option>Reggae</option>
        <option>Rock</option>
        <option>World</option>
      </select>
      <input id="album" value="" placeholder=Album />
      <input id="producer" value="" placeholder=Producer />
      <input maxlength="2" id="rating" value="" placeholder=Rating />
      <input maxlength="2" id="trackNumber" value="" placeholder=Track# />
      <input type=hidden id="source" />
      <!-- add filename as source here -->
      <input id="submit_button" type=submit class=button value=Update />
      Shared with
      <input type=radio name="permissions" value=0 /> Nobody
      <input type=radio name="permissions" value=1 style="display:none" />  <!-- Followers -->
      <input type=radio name="permissions" value=2 checked /> Everyone
    </form>
  </div>
  <div class="inputs" id="dropzone" style="display:none">
    Drag-n-drop your MP4 here
  </div>
  <!-- remmber data from drag-n-drop -->
  <div id="fileData" data-type data-name data-size></div>
</body>
HTML;
    $footer = $this->getFooter();
    echo $header. $body. $footer['start']. $footer['end'];
    return true;
  }
  function getHeader() {
    header('Content-Type: text/html; charset=utf8');
    $header = <<<HTML
<!doctype html>
<html lang=en>
  <head>
  <title>dishyzee | music video++</title>
  <link rel=stylesheet type=text/css href=/static/h5v.css media=screen />
</head>
HTML;
    return $header;
  }

  function getNav() {

    $nav = <<<HTML
    <!-- getNav() -->
HTML;
    return $nav;
  }

  function getFooter() {
    $footer_start = <<<HTML
    <!-- footer_start -->
HTML;
    // historic bets go here
    $footer_end = <<<HTML
<script src=/static/uber.js></script>
<script src=/static/h5v.js></script>
</html>
HTML;
    return array('start' => $footer_start, 'end' => $footer_end);
  }

  public function pricesRender($result) {

    $e = $result['event'];
    $header = $this->getHeader();
    $nav = $this->getNav();

    $body_start = '    <!-- Features Wrapper -->'. "\n";
    $body_start.= '    <div id="features-wrapper">'. "\n";
    $body_start.= '      <div class="container">'. "\n";
    $body_start.= '        <h2>'. $e['e_name']. "</h2>\n";
    $body_start.= '        <h3>'. $e['t_name']. '</h3><p>'. $e['e_date']. ' '. $e['e_time']. "</p>\n";

    $i = 0;
    $body = '';
    foreach ($result['outcomes'] as $o_id => $o) {
      $i++;
      $body.= '       <div class="row">'. "\n";
      $body.= '          <div class="4u">'. "\n";
      $body.= '            <!-- Box -->'. "\n";
      $body.= '            <section class="box box-feature">'. "\n";
      $body.= '              <div class="inner">'. "\n";
      $body.= '                <header>'. "\n";
      $body.= '                  <h2>'. $o['o_odds']. "</h2>\n";
      $body.= '                  <span class="byline">'.  $o['o_name']. "</span>\n";
      $body.= "                </header>\n";
      $body.= '                <form method="post" id="bet'. $i. '">'. "\n";
      $body.= '                  <input type="hidden" name="noun" value="betslips"/>'. "\n";
      $body.= '                  <input type="hidden" name="outcomeId" value="'. $o['o_id']. '"/>'. "\n";
      $body.= '                  <input type="hidden" name="odds" value="'. $o['o_odds']. '"/>'. "\n";
      $body.= '                  <a href="javascript:;" onclick="document.getElementById(\'bet'. $i;
      $body.= '\').submit();" class="button button-big button-icon button-icon-question">Place bet</a>'. "\n";
      $body.= "                </form>\n";
      $body.= "                 <p>Fixed stake of &pound;2.00</p>\n";
      $body.= "              </div>\n";
      $body.= "            </section>\n";
      $body.= "          </div>\n";
      $body.= "        </div>\n";
    }
    $body_end = <<<HTML
      </div>
    </div>
HTML;
    $footer = $this->getFooter();

    echo $header. $nav. $body_start. $body. $body_end. $footer['start']. $footer['end'];
    return true;
  }

  public function betslipsRender($result) {
    $header = $this->getHeader();
    $nav = $this->getNav();
    $body = <<<HTML
    <!-- Main Wrapper -->
    <div id="main-wrapper">
      <div class="container">
        <div class="row">            
          <div class="8u">
            <!-- Content -->
            <div id="content">
              <section class="last">
                <h2>Receipt</h2>

HTML;
    $body.= '                <p>'. $result['bet_receipt']. '</p>'. "\n";
    $body.= <<<HTML

		<form method="post" id="placeBet">
                  <a href="javascript:;" onclick="document.getElementById('placeBet').submit();" class="button button-icon button-icon-rarrow">Again</a>
                  <input type="hidden" name="noun" value="start"/>
                </form>
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>
HTML;
    $footer = $this->getFooter();

    echo $header. $nav. $body. $footer['start']. $footer['end'];
    return true;
  }

  public function betsRender($result) {
    $header = $this->getHeader();
    $nav = $this->getNav();


    $body = <<<HTML

    <!-- Main Wrapper -->
    <div id="main-wrapper">
      <div class="container">
        <div class="row">            
          <div class="8u">
            <!-- Content -->
              <div id="content">
                <section class="last">
                  <h2>Recent Bets</h2>
                  <p>The three most recent bets for <em>FNARG1</em> are shown below.</p>
                </section>
              </div>
          </div>
        </div>
      </div>
    </div>

HTML;

    $footer = '';
    foreach ($result['bet_history'] as $index => $h) {
      $footer.= '        <div class="row">'. "\n";
      $footer.= '          <div class="3u">'. "\n";
      $footer.= '            <!-- Links -->'. "\n";
      $footer.= '            <section class="widget-links">'. "\n";
      $footer.= '              <h2>'. $h['description']. '</h2>'. "\n";
      $footer.= '              <p>'. $h['eventDescription']. '</p>'. "\n";
      $footer.= '              <ul class="style2">'. "\n";
      $footer.= '                <li>odds: '. $h['priceNum']. '/'. $h['priceDen']. '</li>'. "\n";
      $footer.= '                <li>stake: '.       $h['stake']. '</li>'. "\n";
      $footer.= '                <li>return estimate: '.       $h['estimatedReturns']. '</li>'. "\n";
      $footer.= '                <li>settled: '.     $h['settled']. '</li>'. "\n";
      $footer.= '                <li>receipt: '.     $h['receipt']. '</li>'. "\n";
      $footer.= '              </ul>'. "\n";
      $footer.= '            </section>'. "\n";
      $footer.= '          </div>'. "\n";
      $footer.= '        </div>'. "\n";
// echo '<pre>';
// print_r($footer);
// echo '</pre>';
    }
    $footer_a = $this->getFooter();

    echo $header. $nav. $body. $footer_a['start']. $footer. $footer_a['end'];
    return true;
  }
  public function error($e){
    /* use a | to split title from message */
    if(preg_match('/^(.+)\|(.*)$/', $e->getMessage(), $matches)){
      $t=$matches[1];
      $m=$matches[2];
    } else{
      $t=$e->getMessage();
      $m="";
    }
    header('Content-Type: text/html; charset=utf8', TRUE, $e->getCode());
    echo '<h1>'. $e->getCode(). '</h1>';
    echo '<em>'. $t. '</em>';
    echo '<!-- '. $m. ' -->';
    return true;
  }
}
?>
