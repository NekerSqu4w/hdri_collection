$inputDir = "./hdr"
$outputDir = "./jpg"

# make the folder if outputDir doesn't exist
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# verify for each files if already converted or not
# if not, convert it
Get-ChildItem -Path $inputDir -Filter "*.hdr" | ForEach-Object {
    $inputFile = $_.FullName
    $outputFileName = [System.IO.Path]::ChangeExtension($_.Name, ".jpg")
    $outputFile = Join-Path $outputDir $outputFileName
	
    if (Test-Path $outputFile) {
        Write-Host "skip conversion for $outputFileName" -ForegroundColor Cyan
    }
    else {
        Write-Host "converting file $outputFileName" -ForegroundColor Yellow
		
		$startTime = Get-Date
		& ffmpeg -loglevel error -i $inputFile -vf "tonemap=mobius,eq=brightness=0.05:saturation=1.2:contrast=1.0,format=yuvj420p" -q:v 1 $outputFile
		$endTime = Get-Date
		$duration = $endTime - $startTime
		
        if ($LASTEXITCODE -eq 0) {
			$timeTaken = [math]::Round($duration.TotalMilliseconds)
            Write-Host "conversion done for $outputFileName in $timeTaken ms" -ForegroundColor Green
        }
        else {
            Write-Host "conversion failed for $outputFileName" -ForegroundColor Red
        }
    }
	
    Start-Sleep -Milliseconds 20 # just in case we have alot of files
}

Write-Host "all conversions to jpeg done." -ForegroundColor Magenta
pause