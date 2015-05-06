<?php

// This simple page enables you to generate a Strava read/write API key
// For instructions, see the readme
// (StravaApi included rather than installed via composer for ease of use...)

require_once 'StravaApi.php';
require_once 'config.php';

$api = new Iamstuartwilson\StravaApi(
    $config['client_id'],
    $config['client_secret']
);


if (!isset($_GET['code'])) {

    $url = $api->authenticationUrl('http://localhost:8000/', 'auto',
                                   'view_private,write');

    echo '<a href="' . $url . '">Request authentication from Strava</a>';

} else {

    echo "<pre>";
    print_r($api->tokenExchange($_GET['code']));
    echo "</pre>";

}
