<?php
$GPU_temp = exec('vcgencmd measure_temp');
$CPU_temp = exec('cat /sys/class/thermal/thermal_zone0/temp');

$GPU_temp = str_replace('temp=','',$GPU_temp);
//$GPU_temp = str_replace('\'C','',$GPU_temp);

$CPU_temp = $CPU_temp/1000;
//$CPU_temp = str_replace('\'C','',$CPU_temp);

print "GPU Temperatur: $GPU_temp";
?>

<br />

<?php
print "CPU Temparatur: $CPU_temp'C";

?>
