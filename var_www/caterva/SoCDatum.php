<?php
// phpinfo();
// Datei SoCDatum.php


// Pruefe ob uebergebener Parameter ein Datum vom Format YYY-MM-DD oder 'heute' ist

$date = filter_input(INPUT_POST, 'date', FILTER_VALIDATE_REGEXP, array("options"=>array("regexp"=>"/(heute|[1|2][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]))/")));
//$keyfigure = filter_input(INPUT_POST, 'keyfigure',  );


// Starte das Script zum Erstellen der Graphik mit den entsprechenden Parameterm
if ( $date == 'heute') 
{
    $date = date("Y-m-d");
    exec("/var/www/caterva-phyton/scripts/Graphik.sh -h");
}
else
{
    exec("/var/www/caterva-phyton/scripts/Graphik.sh -d $date");
}

// Zeige die Graphik an
header('Content-type: image/png');
readfile("/var/caterva/data/SoC-{$date}.png");

exit;
?>