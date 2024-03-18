[DscResource()]
class Tailspin {

    [DscProperty(Key)] [TailspinScope]
    $ConfigurationScope

    [DscProperty()] [TailspinEnsure]
    $Ensure = [TailspinEnsure]::Present

    [DscProperty(Mandatory)] [bool]
    $UpdateAutomatically

    [DscProperty()] [int] [ValidateRange(1, 90)]
    $UpdateFrequency

    hidden [Tailspin] $CachedCurrentState
    hidden [PSCustomObject] $CachedData

    [Tailspin] Get() {
        $CurrentState = [Tailspin]::new()

        $CurrentState.ConfigurationScope = $this.ConfigurationScope

        $FilePath = $this.GetConfigurationFile()

        if (!(Test-Path -Path $FilePath)) {
                $CurrentState.Ensure = [TailspinEnsure]::Absent
                return $CurrentState
            }

        $Data = Get-Content -Raw -Path $FilePath |
                ConvertFrom-Json -ErrorAction Stop

        $this.CachedData = $Data

        if ($null -ne $Data.Updates.Automatic) {
                $CurrentState.UpdateAutomatically = $Data.Updates.Automatic
            }

        if ($null -ne $Data.Updates.CheckFrequency) {
                $CurrentState.UpdateFrequency = $Data.Updates.CheckFrequency
            }

        $this.CachedCurrentState = $CurrentState

        return $CurrentState
    }

    [bool] Test() {
        $InDesiredState = $true
        return $InDesiredState
    }  

    [void] Set() {}

    [string] GetConfigurationFile() {
        $FilePaths = @{
            Linux = @{
                Machine   = '/etc/xdg/TailSpinToys/tstoy/tstoy.config.json'
                User      = '~/.config/TailSpinToys/tstoy/tstoy.config.json'
            }
            MacOS = @{
                Machine   = '/Library/Preferences/TailSpinToys/tstoy/tstoy.config.json'
                User      = '~/Library/Preferences/TailSpinToys/tstoy/tstoy.config.json'
            }
            Windows = @{
                Machine = "$env:ProgramData\TailSpinToys\tstoy\tstoy.config.json"
                User    = "$env:APPDATA\TailSpinToys\tstoy\tstoy.config.json"
            }
        }

        $Scope = $this.ConfigurationScope.ToString()

        if ($Global:PSVersionTable.PSVersion.Major -lt 6 -or $Global:IsWindows) {
                return $FilePaths.Windows.$Scope
            } elseif ($Global:IsLinux) {
                return $FilePaths.Linux.$Scope
            } else {
                return $FilePaths.MacOS.$Scope
            }
    }

}

enum TailspinScope {
    Machine
    User
}

enum TailspinEnsure {
    Absent
    Present
}