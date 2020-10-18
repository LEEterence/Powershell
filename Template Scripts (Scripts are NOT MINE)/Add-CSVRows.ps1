$header = "Name","Employee ID","Title","Phone","Email","Site","Location","Department"
$data   = import-csv "$env:USERPROFILE\desktop\in.csv"

foreach( $headerinfo in $header){
    $data | Add-Member NoteProperty $headerinfo 'null'
}

$data | Format-Table *