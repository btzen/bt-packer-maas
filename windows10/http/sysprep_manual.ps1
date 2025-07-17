# 一切就绪后,手动执行此文件等待封装完成
"$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/oobe `/shutdown `/unattend:"$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
