Import-Module -Name PSReleaseTools

$features = Get-Secret -Name 'PowerShellProfileFeatures'
$PowerShellCachePath = Join-Path -Path $HOME -ChildPath "PowerShellCache"

function GetOpenWeatherMapCityID {
    param (
        [Parameter(Mandatory = $true)]
        [System.TimeZoneInfo]
        $TimeZone
    )

    $cityPerTimeZone = @{
        'Caucasus Standard Time' = @{
            CityID   = 616052
            CityName = 'Yerevan'
        }
        'FLE Standard Time'      = @{
            CityID   = 703448
            CityName = 'Kyiv'
        }
    }

    $city = $cityPerTimeZone[$TimeZone.Id]
    if ($city) {
        return $city.CityID
    }

    throw "OpenWeatherMap City was not found for timezone '$($TimeZone.Id)'"
}

function GetOpenWeather {
    param (
    )

    $localTimeZone = Get-TimeZone

    $cityId = GetOpenWeatherMapCityID -TimeZone $localTimeZone
    $openWeatherMapApiKey = Get-Secret  -Name 'OpenWeatherMapApiKey' -AsPlainText

    $response = Invoke-RestMethod -Method 'GET' -Uri "https://api.openweathermap.org/data/2.5/weather?id=$cityId&appid=$openWeatherMapApiKey"

    return @{
        CityID                   = $response.id
        CityName                 = $response.name
        CountryCode              = $response.sys.country
        TemperatureInKelvin      = $response.main.temp
        TemperatureFeelsInKelvin = $response.main.feels_like
    }
}

try {
    $ProfileCache = @{}

    $ProfileCache.OpenWeather = GetOpenWeather

    $ProfileCache.Release = Get-PSReleaseCurrent
    $ProfileCache.ReleasePreview = Get-PSReleaseCurrent -Preview

    if ($features.NationalBankOfUkraineRates) {
        $xml = New-Object xml

        $xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
        $exchangeRates = $xml.exchange | Select-Object -ExpandProperty currency

        $yesterdaysDatePattern = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

        $xml.Load("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=$yesterdaysDatePattern")
        $yesterdaysExchangeRates = $xml.exchange | Select-Object -ExpandProperty currency

        $ProfileCache.NationalBankOfUkraine = @{
            ExchangeRates           = $exchangeRates
            YesterdaysExchangeRates = $yesterdaysExchangeRates
        }
    }

    if ($features.CentralBankOfArmeniaRates) {
        $response = Invoke-RestMethod 'https://www.cba.am/_layouts/rssreader.aspx?rss=280F57B8-763C-4EE4-90E0-8136C13E47DA' -Method 'GET' -Headers $headers -Body $body
        $response = $response | Select-Object -ExpandProperty title
        $rates = $response | ForEach-Object {
            $parts = $_ -split '-' | ForEach-Object { $_.Trim() }
            @{
                Code = $parts[0]
                Rate = ($parts[2] -as [decimal]) / ($parts[1] -as [decimal])
            }
        }

        $ProfileCache.CentralBankOfArmeniaRates = $rates
    }

    $ProfileCache.AllCommands = Get-Command * | Select-Object -Unique
    
    $ProfileCache.Saved = Get-Date
    $ProfileCache | Export-Clixml -Path $PowerShellCachePath
}
catch {
    throw $_
}
