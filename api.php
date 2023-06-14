<?php
header('Access-Control-Allow-Origin: *');
// Define database connection parameters
$servername = "localhost";
$username = "esinebdc_projects";
$password = "QyO2P7h{e;DBW)o!7)Of";
$dbname = "esinebdc_chargerStation";

// Create database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Handle API requests
if (isset($_GET['action'])) {
  switch ($_GET['action']) {
    case 'signup':
      handleSignup();
      break;
    case 'login':
      handleLogin();
      break;

    case 'info':
      handleInfo();
      break;

    case 'recharge':
      handleRecharge();
      break;
    case 'balance':
      handleBalance();
      break;
    case 'addCharger':
      handleAddCharger();
      break;
    case 'deleteCharger':
      handleDeleteCharger();
      break;
    case 'updateCharger':
      handleUpdateCharger();
      break;

    case 'rate':
      handleRate();
      break;
    case 'queue':
      handleQueue();
      break;
    case 'stationQueue':
      handleStationQueue();
      break;
    case 'customerQueue':
      handleCustomerQueue();
      break;

    case 'chargerState':
      handleChargerState();
      break;
    case 'stationChargers':
      handleStationChargers();
      break;

    default:
      echo "Invalid action";
      break;
  }
}

// Handle signup request
function handleSignup()
{
  global $conn;
  $email = $_GET['email'];
  $password = $_GET['password'];
  $name = $_GET['name'];
  $phone_number = $_GET['phone_number'];
  $user_type = $_GET['user_type'];
  if (isset($_GET['balance'])) $balance = $_GET['balance'];
  if (isset($_GET['charger_count'])) $charger_count = $_GET['charger_count'];
  if ($user_type == 'user') {
    $sql = "INSERT INTO users (email, password, name, phone_number, balance) VALUES ('$email', '$password', '$name', '$phone_number', '$balance')";
  } else {
    $sql = "INSERT INTO stations (email, password, name, phone_number, charger_count) VALUES ('$email', '$password', '$name', '$phone_number', '$charger_count')";
  }
  if ($conn->query($sql) === TRUE) {
    $user_id = $conn->insert_id;
    echo "User created with ID: " . $user_id;
  } else {
    echo "Error: " . $sql . "<br>" . $conn->error;
  }
}

// Handle login request
function handleLogin()
{
  global $conn;
  $email = $_GET['email'];
  $password = $_GET['password'];
  $user_type = $_GET['user_type'];
  if ($user_type == 'user') {
    $sql = "SELECT * FROM users WHERE email='$email' AND password='$password'";
  } else {
    $sql = "SELECT * FROM stations WHERE email='$email' AND password='$password'";
  }
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo "Login successful. User ID: " . $row['id'];
  } else {
    echo "Login failed. Invalid email or password.";
  }
}

// Handle balance request
function handleBalance()
{
  global $conn;
  $email = $_GET['email'];
  $sql = "SELECT * FROM users WHERE email='$email'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo "Balance: " . $row['balance'];
  } else {
    echo "Error.";
  }
}

// Handle info request
function handleInfo()
{
  global $conn;
  $msg = $_GET['msg'];
  if(isset($_GET['msg'])) {
    $sql = "REPLACE INTO info (id, msg) VALUES ('1', '$msg')";
    if($conn->query($sql) === true) {
      echo "Updated.";
    }
  } 
  else {
    $sql = "SELECT * FROM info WHERE id='1'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
      $row = $result->fetch_assoc();
      echo "MSG: " . $row['msg'];
    } else {
      echo "Error.";
    }
  }
}

// Handle queue request
function handleQueue()
{
  global $conn;
  $user_id = $_GET['user_id'];
  $station_id = $_GET['station_id'];
  $charger_id = $_GET['charger_id'];
  $charge_bill = $_GET['charge_bill'];
  $charge_time = intval($_GET['charge_time']);
  $charging_mode = $_GET['charging_mode'];
  $sql = "UPDATE chargers SET charger_state='busy' WHERE id='$charger_id' AND station_id='$station_id'";
  if ($conn->query($sql) === TRUE) {
    $sql = "INSERT INTO charging_logs (user_id, station_id, charger_id, charge_bill, charge_time, charging_mode, start_time) VALUES ('$user_id', '$station_id', '$charger_id', '$charge_bill', '$charge_time', '$charging_mode', NOW())";
    $conn->query($sql);
    echo "Charger queued successfully.";
  } else {
    echo "Error updating charger state: " . $conn->error;
  }
}

// Handle recharge request
function handleRecharge()
{
  global $conn;
  $email = $_GET['email'];
  $amount = (int)$_GET['amount'];
  $sql = "UPDATE users SET balance=balance+'$amount' WHERE email='$email'";
  if ($conn->query($sql) === TRUE) {
    echo "Balance recharged successfully.";
  } else {
    echo "Error updating balance: " . $conn->error;
  }
}

// Handle add charger request
function handleAddCharger()
{
  global $conn;
  $station_id = $_GET['station_id'];
  $charger_state = $_GET['charger_state'];
  $rate = $_GET['rate'];
  $sql = "INSERT INTO chargers (station_id, charger_state, rate) VALUES ('$station_id', '$charger_state', '$rate')";
  if ($conn->query($sql) === TRUE) {
    echo "Charger added successfully.";
  } else {
    echo "Error adding charger: " . $conn->error;
  }
}

// Handle update charger request
function handleUpdateCharger()
{
  global $conn;
  $charger_id = $_GET['charger_id'];
  $charger_state = $_GET['charger_state'];
  $rate = $_GET['rate'];
  $sql = "UPDATE chargers SET charger_state='$charger_state', rate='$rate' WHERE id='$charger_id'";
  if ($conn->query($sql) === TRUE) {
    echo "Charger updated successfully.";
  } else {
    echo "Error updating charger: " . $conn->error;
  }
}

// Handle customer queue request
function handleCustomerQueue()
{
  global $conn;
  $user_id = $_GET['user_id'];
  $sql = "SELECT * FROM charging_logs WHERE user_id='$user_id'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $arr = array();
    while ($row = $result->fetch_assoc()) {
      $arr[] = $row;
    }
    echo json_encode($arr);
  } else {
    echo "No queued chargers for this customer.";
  }
}

// Handle charger state request
function handleChargerState()
{
  global $conn;
  $station_id = $_GET['station_id'];
  $charger_id = $_GET['charger_id'];
  $sql = "SELECT * FROM chargers WHERE station_id='$station_id' AND id='$charger_id'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo $row['charger_state'];
  } else {
    echo "No charger.";
  }
}

// Handle charger rate request
function handleRate()
{
  global $conn;
  $station_id = $_GET['station_id'];
  $charger_id = $_GET['charger_id'];
  $sql = "SELECT * FROM chargers WHERE station_id='$station_id' AND id='$charger_id'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo "Rate: " . $row['rate'];
  } else {
    echo "No charger.";
  }
}

// Handle station chargers request
function handleStationChargers()
{
  global $conn;
  $station_id = $_GET['station_id'];
  $sql = "SELECT * FROM chargers WHERE station_id='$station_id'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $arr = array();
    while ($row = $result->fetch_assoc()) {
      $arr[] = $row;
    }
    echo json_encode($arr);
  } else {
    echo "No chargers for this station.";
  }
}

// Handle station queue request
function handleStationQueue()
{
  global $conn;
  $station_id = $_GET['station_id'];
  $sql = "SELECT * FROM charging_logs WHERE station_id='$station_id'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $arr = array();
    while ($row = $result->fetch_assoc()) {
      $arr[] = $row;
    }
    echo json_encode($arr);
  } else {
    echo "No chargers for this station.";
  }
}

// Handle delete charger request
function handleDeleteCharger()
{
  global $conn;
  $charger_id = $_GET['id'];
  $station_id = $_GET['station_id'];
  $sql = "DELETE FROM chargers WHERE id='$charger_id' AND station_id='$station_id'";
  if ($conn->query($sql) === TRUE) {
    echo "Charger deleted successfully.";
  } else {
    echo "Error deleting charger: " . $conn->error;
  }
}
