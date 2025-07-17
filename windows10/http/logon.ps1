try
{
        # 安装 WDK
        $Host.UI.RawUI.WindowTitle = "Installing Windows Driver Kit..."
        $p = Start-Process -PassThru -Wait -FilePath "f:\wdksetup.exe" -ArgumentList "/features OptionId.WindowsDriverKitComplete /q /ceip off /norestart"
        if ($p.ExitCode -ne 0)
        {
            throw "Installing wdksetup.exe failed."
        }

        # 使用 WDK 中的 dpinst.exe 安装驱动
        $Host.UI.RawUI.WindowTitle = "Injecting Windows drivers..."
        $dpinst = "$ENV:ProgramFiles (x86)\Windows Kits\8.1\redist\DIFx\dpinst\EngMui\x64\dpinst.exe"
        Start-Process -Wait -FilePath "$dpinst" -ArgumentList "/S /C /F /SA /Path E:\infs"

        # 卸载 WDK
        $Host.UI.RawUI.WindowTitle = "Uninstalling Windows Driver Kit..."
        Start-Process -Wait -FilePath "f:\wdksetup.exe" -ArgumentList "/features + /q /uninstall /norestart"

        # 安装 Cloudbase-Init
        $Host.UI.RawUI.WindowTitle = "Installing Cloudbase-Init..."
        $cloudbaseInitLog = "$ENV:Temp\cloudbase_init.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i f:\CloudbaseInitSetup_1_1_6_x64.msi /qn /norestart /l*v $cloudbaseInitLog LOGGINGSERIALPORTNAME=$serialPortName"
        if ($p.ExitCode -ne 0)
        {
            throw "Installing $cloudbaseInitPath failed. Log: $cloudbaseInitLog"
        }

        # 安装 virtio
        $Host.UI.RawUI.WindowTitle = "Installing Virtio Drivers..."
        certutil -addstore "TrustedPublisher" A:\rh.cer
        $virtioLog = "$ENV:Temp\virtio.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/a f:\virtio-win-gt-x64.msi /qn /norestart /l*v $virtioLog LOGGINGSERIALPORTNAME=$serialPortName"
        $p = Start-Process -Wait -PassThru -FilePath f:\virtio-win-guest-tools.exe -Argument "/silent"

        # 删除 Logon 脚本, 禁用自动登录
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount

        $Host.UI.RawUI.WindowTitle = "Running SetSetupComplete..."
        & "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

        if ($RunPowershell) {
            $Host.UI.RawUI.WindowTitle = "Paused, waiting for user to finish work in other terminal"
            Write-Host "Spawning another powershell for the user to complete any work..."
            Start-Process -Wait -PassThru -FilePath powershell
        }

        # 写入成功，这用于检查该过程是否完成至此为止。
        New-Item -Path c:\success.tch -Type file -Force
}
catch
{
    $_ | Out-File c:\error_log.txt
}
