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
    
    $ProfileCache.Saved = Get-Date
    $ProfileCache | Format-Custom
}
catch {
    throw $_
}
