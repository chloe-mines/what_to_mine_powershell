$threshold = 10
#value as a percent - i.e. 25 = 25%. So if GPU is 25 idle or less, kick off the miner batch file.
#Probably start this at like 10 or 5%? I don't know - I don't game on my mining rigs
#Just play with a value that works for you.
#make this "1" if you want to be really, truly idle (i.e. less than 1 = 0).

$gameName = "steam"
#I am totally guessing here but I assume when you're playing a game, steam or something is open? Origin? I dunno. This is the application that implies you're now playing games.
#Maybe just replace this with wow.exe or whatever the specific game is.
#to find the name of the process, run get-process from an elevated PowerShell and look for the name. You should see something like steam or cyberpunk or whatever there

$minerName = "t-rex"
#the name of the miner you use. I guess t-rex.exe or something. Again, you will know better than me.
#to fine the name of the process, run get-process from an elevated PowerShell and look for the name.
#Chances are it's the name of you executable, minus the file extension.

#to run this task, schedule it to run once a minute, here, by running the below command in an elevated cmd.
#please confirm that your scheduled task is running with ELEVATED privileges, or it won't have permission to stop steam and it won't have permission to run overclocking, on behalf of t-rex, etc.
#please ensure you modify the command below to correctly locate the file.
#schtasks /create /tn myTask /tr "PowerShell -NoLogo -WindowStyle hidden -file c:\scripts\gpu.ps1" /sc minute /mo 1 /ru System

$game = Get-Process $gameName -ErrorAction SilentlyContinue
$miner = Get-Process $minerName -ErrorAction SilentlyContinue

#This section of code will fire up the miner if your GPU usage drops below the threshold set below.
$GpuMemTotal = (((Get-Counter "\GPU Process Memory(*)\Local Usage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$GpuUseTotal = (((Get-Counter "\GPU Engine(*engtype_3D)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum

if ($GpuUseTotal -lt $threshold) {
	write-output "GPU Usage is $([math]::Round($GpuUseTotal,2))%"
	if ($miner) {
		}else {
			write-output "mining time"
			cmd.exe /c '\miners\t-rex\ethereum.bat'
		}
}

#this section will kill the miner if you fire up "steam" or whatever it is you use to play games.

if ($game) {
	# try gracefully first
	$miner.CloseMainWindow()
	# kill after five seconds
	Sleep 5
	if (!$miner.HasExited) {
		$miner | Stop-Process -Force
	}
}