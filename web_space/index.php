<?php
$dir = dirname($_SERVER['DOCUMENT_ROOT'])."/public_html/ziks";
$filename = $_GET['id'];
$file = $dir."/".$filename;
$file_size  = filesize($file);

if(file_exists($file)){
	header("Pragma: public");
	header("Expires: -1");
    header('Content-type:audio/mpeg');
    header('Content-Disposition: filename="' . $filename);
    header('X-Pad: avoid browser bug');
	header("Cache-Control: public, must-revalidate, post-check=0, pre-check=0");
	header('Content-Disposition: inline;');
//	header('Content-Transfer-Encoding: binary');
	header("Content-Length: $file_size");
	header('Content-Transfer-Encoding: chunked');
	ob_start(null, 1024, false);
	set_time_limit(0);
	$file_play = @fopen($file,"rb");
	while(!feof($file_play))
	{
	print(@fread($file_play, 1024 * 1));
	ob_flush();
	flush();
	}
	fclose($file);
}
?>
