<?php
    $logdir = '../logs';
    if (isset($_GET['log'])) {
        $log = basename($_GET['log']);
        $log = preg_replace('/[^-a-zA-Z0-9_]/', '', $log);
        $data = file_get_contents(sprintf('%s/%s.log', $logdir, $log));
    }
?>
<!DOCTYPE html>
<html>
<head>
    <title>Log viewer</title>
</head>
<body>
    <h1>Log viewer</h1>

    <?php if (isset($data)): ?>

    <h2>Log: <em><?php echo $log; ?></em></h2>
    <p><a href="./">Back</a></p>
    <pre><?php echo $data; ?></pre>

    <?php else: ?>

    <h2>Select log:</h2>

    <ul>

    <?php

    if ($handle = opendir($logdir)) {

        while (false !== ($entry = readdir($handle))) {

            if ($entry[0] !== '.') {
                $filename = basename($entry, '.log');
                echo '
                <li><a href="./?log='.$filename.'">'.$filename.'</a></li>
                ';
            }

        }

        closedir($handle);
    }

    ?>

    </ul>

    <?php endif; ?>
</body>
</html>