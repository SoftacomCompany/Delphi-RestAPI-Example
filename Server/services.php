<?php

$db_servername = 'localhost:3306';
$db_name = 'demobase2';
$db_username = 'root';
$db_password = '_sE4DTFyPLXXU8rZ_';

// https://www.easyphp.org/save-easyphp-devserver-latest.php

// Possible fixes:
// https://stackoverflow.com/questions/50026939/php-mysqli-connect-authentication-method-unknown-to-the-client-caching-sha2-pa
// https://stackoverflow.com/a/56680098
// https://stackoverflow.com/questions/3513773/change-mysql-default-character-set-to-utf-8-in-my-cnf
// https://stackoverflow.com/a/3513812

$user_name = ( isset( $_REQUEST['user'] ) ? $_REQUEST['user'] : '' ); 
$user_pswd = ( isset( $_REQUEST['pswd'] ) ? $_REQUEST['pswd'] : '' ); 
$user_mail = ( isset( $_REQUEST['mail'] ) ? filter_var( $_REQUEST['mail'], FILTER_SANITIZE_EMAIL)  : '' );

$data = ( isset( $_REQUEST['data'] ) ? json_decode($_REQUEST['data'], true) : '' );

$procedure = ( isset( $_REQUEST['proc'] ) ? $_REQUEST['proc'] : '' );


function create_user($name, $pswd, $email) {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  // set the PDO error mode to exception
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("SELECT * FROM users WHERE name = '$name' OR email = '$email'");
  $stmt->execute();
  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo "";
} else {
    $stmt = $conn->prepare("INSERT INTO users (name, email, pass, capabilities) VALUES ('$name', '$email', '$pswd', 0)");
    $stmt->execute();

    $stmt = $conn->prepare("SELECT * FROM users WHERE name = '$name' AND pass = '$pswd' AND email = '$email'");
    $stmt->execute();

    $stmt->setFetchMode(PDO::FETCH_ASSOC);

    $result = $stmt->fetchAll();

    if ( count($result) > 0 ) {
      echo json_encode($result);
  } else {
      echo "";
  }
}

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
} 




function login_user($name, $pswd) {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("SELECT * FROM users WHERE name = '$name' AND pass = '$pswd'");
  $stmt->execute();
  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "[]";
}  

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
} 




function is_user_logged($name, $pswd) {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("SELECT * FROM users WHERE name = '$name' AND pass = '$pswd'");
  $stmt->execute();
  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    return true;
} else {
    return false;
}  

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
} 




function update_profile($profile_data) {
  global $db_servername, $db_name, $db_username, $db_password;

$id = $profile_data['id'];
$name = $profile_data['name'];
$email = $profile_data['email'];
$pass = $profile_data['pass'];

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("UPDATE users SET name = '$name', email = '$email', pass = '$pass' WHERE id = '$id'");
  $stmt->execute();

  $stmt = $conn->prepare("SELECT * FROM users WHERE id = '$id'");
  $stmt->execute();

  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "";
}  

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null; 
} 




function get_customers() {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("SELECT * FROM customers");
  $stmt->execute();
  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "";
}  

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
}




function get_users() { 
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $conn->prepare("SELECT * FROM users");
  $stmt->execute();
  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "";
}  

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
}




function update_customers($dataset) {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $sql = '';
  $idx = array();

foreach ($dataset as $value) {
  $sql .= ("UPDATE customers SET name = " . $conn->quote($value['name']) . ", contact = " . $conn->quote($value['contact']) . ", address = " . $conn->quote($value['address']) . ", city = " . $conn->quote($value['city']) . ", postal = " . $conn->quote($value['postal']) . ", country = " . $conn->quote($value['country']) . " WHERE id = $value[id];");
  $idx[] = "id = " . $value['id'];
}

  $stmt = $conn->prepare($sql);
  $stmt->execute();

  $stmt = $conn->prepare("SELECT * FROM customers WHERE " . implode(" OR ", $idx));
  $stmt->execute();

  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "";
}

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();    echo '<br>' . $sql;
}

$conn = null;
}



function update_users($dataset) {
  global $db_servername, $db_name, $db_username, $db_password;

try {
  $conn = new PDO("mysql:host=$db_servername;dbname=$db_name", $db_username, $db_password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $sql = '';
  $idx = array();

foreach ($dataset as $value) {
  $sql .= ("UPDATE users SET name = " . $conn->quote($value['name']) . ", email = " . $conn->quote($value['email']) . ", pass = " . $conn->quote($value['pass']) . ", capabilities = " . $conn->quote($value['capabilities']) . " WHERE id = $value[id];");
  $idx[] = "id = " . $value['id'];
}

  $stmt = $conn->prepare($sql);
  $stmt->execute();

  $stmt = $conn->prepare("SELECT * FROM users WHERE " . implode(" OR ", $idx));
  $stmt->execute();

  $stmt->setFetchMode(PDO::FETCH_ASSOC);

  $result = $stmt->fetchAll();

  if ( count($result) > 0 ) {
    echo json_encode($result);
} else {
    echo "";
}

} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}

$conn = null;
}










switch ( $procedure ) {

  case "register":
    create_user($user_name, $user_pswd, $user_mail);
    break;

  case "test":
	http_response_code(401);

  case "login":
	
    login_user($user_name, $user_pswd);
    break;


  case "update_profile":
    if ( is_user_logged($user_name, $user_pswd) ) {
      update_profile($data);
  } else {
      http_response_code(401);
  }  
    break;


  case "get_customers":
    if ( is_user_logged($user_name, $user_pswd) ) {
      get_customers();
  } else {
      http_response_code(401);
  }
    break;


  case "get_users":
    if ( is_user_logged($user_name, $user_pswd) ) {
      get_users();
  } else {
      http_response_code(401);
  }
    break;


  case "update_customers":
    if ( is_user_logged($user_name, $user_pswd) ) {
      update_customers($data);
  } else {
      http_response_code(401);
  }
    break;


  case "update_users":
      if ( is_user_logged($user_name, $user_pswd) ) {
      update_users($data);
  } else {
      http_response_code(401);
  }
    break;
	

  default:
    http_response_code(404);
}


?>