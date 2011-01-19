<html>
  <head><title>Hello world in PHP</title></head>
  <body>
    <h1>Hello <?= $_POST['name'] ?></h1>
    <form action="helloworld.php" method="POST">
      <input type="text" name="name"/>
      <input type="submit" value="Submit"/>
    </form>
  </body>
</html>
