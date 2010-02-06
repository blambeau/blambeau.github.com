<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>www.revision-zero.org</title>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <link rel="stylesheet" href="../images/style.css" type="text/css" />
</head>
<body>
  <div class="content">
    <div class="preheader">
      <div class="padding"></div>
    </div>
    <div class="header">
      <div class="title">Hello world in PHP</div>
      <div class="slogan">The way you shouldn't do it !</div>
    </div>
    <div id="nav">
      <ul>
        <li><a href="../../wlang">WLang, the related paper</a></li>
      </ul>
    </div>
    <div class="main_content">
      <div class="sd_left">
        <div class="text_padding">
          <h1>Hello <?= $_POST['name'] ?> !</h1>
          <ul>
          <li>Enter your name in the field below and this page will say hello to 
          you.</li>
            <form style="margin:10px;" action="helloworld.php" method="POST">
              <input type="text" name="name"/>
              <input type="submit" value="Submit"/>
            </form>
          <li>Now, copy paste <tt><?= htmlentities("<script>alert('You are a fu..... m..... f..... !!')</script>") ?></tt> in the field and enjoy what happens ...</li>
          <li>Even worse, copy paste <tt><?= htmlentities("<img src='hard.jpg'/>") ?></tt></li>
          <li>A last example, <tt><?= htmlentities("<script>window.location='http://www.badlocation.com/'</script>") ?></tt></li>
          </ul>
          <p>What if the injected value does not come from you but from a not trustworthy user? 
          Congratulations, your PHP programs allows cross-side scripting attacks (XSS) ! Don't
          know what it means ? Use the form !</p>
          <p><tt><?= htmlentities("<script>window.open('http://www.google.com/search?q=XSS+attack','','')</script>") ?></tt></p>
        </div>
      </div>
      <div class="footer">
        <div class="padding">
        <a rel="license" href="http://creativecommons.org/licenses/by/2.0/be/">&copy;</a> www.revision-zero.org | author: <a href="author">bernard lambeau</a> | design (free-css): <a href="http://www.free-css-templates.com/" title="Free CSS Templates">david herreman</a> </div>
      </div>
    </div>
  </div>
</body>
</html>
<html>
</html>

