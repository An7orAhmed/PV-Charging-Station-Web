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

    case 'recharge':
      handleRecharge();
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

    case 'queue':
      handleQueue();
      break;
    case 'stationQueue':
      handleStationQueue();
      break;
    case 'customerQueue':
      handleCustomerQueue();
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

// Handle queue request
function handleQueue()
{
  global $conn;
  $user_id = $_GET['user_id'];
  $station_id = $_GET['station_id'];
  $charger_id = $_GET['charger_id'];
  $charge_bill = $_GET['charge_bill'];
  $charge_time = $_GET['charge_time'];
  $charging_mode = $_GET['charging_mode'];
  $sql = "SELECT * FROM chargers WHERE id='$charger_id' AND station_id='$station_id' AND charger_state='off'";
  $result = $conn->query($sql);
  if ($result->num_rows > 0) {
    $sql = "UPDATE chargers SET charger_state='busy' WHERE id='$charger_id' AND station_id='$station_id'";
    if ($conn->query($sql) === TRUE) {
      $sql = "INSERT INTO charging_logs (user_id, station_id, charger_id, charge_bill, charge_time, charging_mode, start_time) VALUES ('$user_id', '$station_id', '$charger_id', '$charge_bill', '$charge_time', '$charging_mode', NOW())";
      if ($conn->query($sql) === TRUE) {
        echo "Charger queued successfully.";
        sleep($charge_time * 60);
        $sql = "UPDATE chargers SET charger_state='off' WHERE id='$charger_id' AND station_id='$station_id'";
        if ($conn->query($sql) === TRUE) {
          echo "Charger state updated.";
        } else {
          echo "Error updating charger state: " . $conn->error;
        }
      } else {
        echo "Error creating charger queue: " . $conn->error;
      }
    } else {
      echo "Error updating charger state: " . $conn->error;
    }
  } else {
    echo "Charger is not available.";
  }
}

// Handle recharge request
function handleRecharge()
{
  global $conn;
  $user_id = $_GET['user_id'];
  $amount = $_GET['amount'];
  $sql = "UPDATE users SET balance=balance+'$amount' WHERE id='$user_id'";
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
