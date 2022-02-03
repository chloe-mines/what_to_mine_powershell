	#System calls
	Add-Type -AssemblyName System.Web
	
	#API_Key
	#You will need your own API key - go to CoinAPI.io and sign up for a free one - the free version is 100% all you need.
	$api_key = "X-CoinAPI-Key"
	$api_value = "YOUR_API_VALUE_GOES_HERE"
	$api_url = "https://rest.coinapi.io/v1/exchangerate/"
	
	#CURRENCY - what do you want to see the value in. USD, AUD, etc.
	$currency = "AUD"

	#What do you pay per kW/h
	$electricity="0.2" #value is a string in your unit of currency. I.e. 0.2 = $0.20 per kW/h

	#KAWPOW
	$kpw_p="280.00" #power in watts - TOTAL power of your rig for KAWPOW. Value is a string.
	$kpw_hr="44.00" #hashrate in watts - TOTAL hashrate of your rig for KAWPOW. Value is a string.
	$kpw="true" #do you want to include a KAWPOW miner in your options? If so, make this true, otherwise false.
	$kawpowMiner = "c:\mining\t-rex\ravencoin.bat" #Miner to fire up if Ravencoin is your best bet
	$kpwName="Ravencoin" #What are you mining, based on this algorithm. The name of the coin.

	#ETHHASH
	$eth_p="200.0" #power in watts - TOTAL power of your rig for KAWPOW. Value is a string.
	$eth_hr="100.00" #hashrate in watts - TOTAL hashrate of your rig for KAWPOW. Value is a string.
	$eth="true" #do you want to include a KAWPOW miner in your options? If so, make this true, otherwise false.
	$ethhashmMiner = "c:\mining\t-rex\ethereum_btc.bat" #Miner to fire up if Ethereum is your best bet
	$ethName="Ethereum" #What are you mining, based on this algorithm. The name of the coin.

	#ZelHash
	$zlh_p="200.00" #power in watts - TOTAL power of your rig for KAWPOW. Value is a string.
	$zlh_hr="100.00" #hashrate in watts - TOTAL hashrate of your rig for KAWPOW. Value is a string.
	$zlh="true" #do you want to include a KAWPOW miner in your options? If so, make this true, otherwise false.
	$zelhashMiner = "c:\mining\gminer\flux.bat" #Miner to fire up if Flux is your best bet
	$zlhName="Flux" #What are you mining, based on this algorithm. The name of the coin.

	#Get the list of GPU in this PC
	$gpu = Get-WmiObject win32_VideoController | Select-Object -ExpandProperty Name

	#empty array
	$GPUs = @()

	<#
	#We don't need this now but I am envisaging parsing the GPU to the URL, so we can automate a guess at hashrate and wattage, if people don't know
	write-host "Looking for GPUs on this box"
	foreach ($x in $gpu){
		$splitGPU = $x.split(' ').trim()
		if($splitGPU -match "Microsoft") {
			write-host "GPU Found: $x. Unusable for mining"
		} else {
			write-host "GPU Found: $x. WhatToMine Code:"$splitGPU[-1]
			$GPUs = $GPUs += $splitGPU[-1]
		}
	}
	$groupedGPU = $GPUs |group 
	#For future use, to allow you to populate without supplying your own code
	foreach ($x in $groupedGPU){
		$wtmGPU += "aq_$($x.name)=$($x.count)&"
		#can be added below to URL at some time in the future
	}
	#>

	#Build out our URL
	$url = "https://whattomine.com/coins.json?"
	$unencodedURL = "eth=$eth&factor[eth_hr]=$eth_hr&factor[eth_p]=$eth_p&kpw=$kpw&factor[kpw_hr]=$kpw_hr&factor[kpw_p]=$kpw_p&zlh=$zlh&factor[zlh_hr]=$zlh_hr&factor[zlh_p]=$zlh_p&factor[cost]=$electricity"
	$sendURL = "$url$unencodedURL"
	$wtmResponse = (Invoke-RestMethod -Uri $sendURL).coins

	
	#get our values
	if ($kpw -eq 'true'){
		$kpwTag = $wtmResponse.$kpwName.tag
		$kpwER = $wtmResponse.$kpwName.estimated_rewards
		$uri = "$($api_url)$($kpwTag)/$($currency)"
		$Params = @{
			"Uri"     = $uri
			"Method"  = "GET"
			"Headers" = @{
				"$($api_key)" = "$($api_value)"
			}
		}
		$kpwRate = Invoke-RestMethod @Params 
		$kpwValue = $kpwRate.rate
		$kpwEstimate = [double]$kpwER*[double]$kpwValue
		write-host "Estimated Earnings for $($kpwName) per day is $($kpwER) coins, valued at $($kpwEstimate) $($currency)"
	}
	
	if ($eth -eq 'true'){
		$ethTag = $wtmResponse.$ethName.tag
		$ethER = $wtmResponse.$ethName.estimated_rewards
		$uri = "$($api_url)$($ethTag)/$($currency)"
		$Params = @{
			"Uri"     = $uri
			"Method"  = "GET"
			"Headers" = @{
				"$($api_key)" = "$($api_value)"
			}
		}
		$ethRate = Invoke-RestMethod @Params 
		$ethValue = $ethRate.rate
		$ethEstimate = [double]$ethER*[double]$ethValue
		write-host "Estimated Earnings for $($ethName) per day is $($ethER) coins, valued at $($ethEstimate) $($currency)"
	}
	
	if ($zlh -eq 'true'){
		$zlhTag = $wtmResponse.$zlhName.tag
		$zlhER = $wtmResponse.$zlhName.estimated_rewards
		$uri = "$($api_url)$($zlhTag)/$($currency)"
		$Params = @{
			"Uri"     = $uri
			"Method"  = "GET"
			"Headers" = @{
				"$($api_key)" = "$($api_value)"
			}
		}
		$zlhRate = Invoke-RestMethod @Params 
		$zlhValue = $zlhRate.rate
		$zlhEstimate = [double]$zlhER*[double]$zlhValue
		write-host "Estimated Earnings for $($zlhName) per day is $($zlhER) coins, valued at $($zlhEstimate) $($currency)"
	}
	
	#Which one should we be mining:
	[string]$highest = Get-Variable -Name zlhEstimate,ethEstimate,kpwEstimate | Sort-Object -Property Value | Select -Last 1 -ExpandProperty Name
	
	#Get processes
	$trex = Get-Process "t-rex" -ErrorAction SilentlyContinue
	$gminer = Get-Process "gminer" -ErrorAction SilentlyContinue

	if ($highest -eq "zlhEstimate") {
		write-host "Looks like your best bet is mining $($zlhName)"
		if (!$trex.HasExited) {
			$trex | Stop-Process -Force
		}
		if (!$gminer.HasExited) {
			$gminer | Stop-Process -Force
		}
		cmd.exe /c $zelhashMiner
	} ElseIf ($highest -eq "ethEstimate") {
		write-host "Looks like your best bet is mining $($ethName)"		
		if (!$trex.HasExited) {
			$trex | Stop-Process -Force
		}
		if (!$gminer.HasExited) {
			$gminer | Stop-Process -Force
		}
		cmd.exe /c $ethhashmMiner
	} ElseIf ($highest -eq "ethEstimate"){
		write-host "Looks like your best bet is mining $($kpwName)"
		if (!$trex.HasExited) {
			$trex | Stop-Process -Force
		}
		if (!$gminer.HasExited) {
			$gminer | Stop-Process -Force
		}
		cmd.exe /c $kawpowMiner
	} Else {
		write-host "Not sure what is going on, so I am not changing anything"
	}