param([int]$Port = 8787)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = "C:\Users\rushk\.gemini\antigravity\scratch\ptcg-event-radar"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "HTTPD_READY port=$Port root=$root"

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response

        $rawPath = $req.Url.LocalPath.TrimStart('/')
        if ($rawPath -eq '' -or $rawPath -eq '/') { $rawPath = 'index.html' }

        $filePath = Join-Path $root ($rawPath -replace '/', '\')

        if (Test-Path $filePath -PathType Leaf) {
            $mime = 'text/plain'
            switch ([System.IO.Path]::GetExtension($filePath).ToLower()) {
                '.html' { $mime = 'text/html; charset=utf-8' }
                '.js'   { $mime = 'application/javascript' }
                '.css'  { $mime = 'text/css' }
                '.json' { $mime = 'application/json; charset=utf-8' }
                '.png'  { $mime = 'image/png' }
                '.jpg'  { $mime = 'image/jpeg' }
                '.ico'  { $mime = 'image/x-icon' }
            }
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $res.ContentType = $mime
            $res.ContentLength64 = $bytes.Length
            $res.StatusCode = 200
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $notFound = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
            $res.StatusCode = 404
            $res.ContentLength64 = $notFound.Length
            $res.OutputStream.Write($notFound, 0, $notFound.Length)
        }
        $res.OutputStream.Close()
    } catch {
        # ignore
    }
}
