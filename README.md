# what_to_mine_powershell
A powershell command to work out what you should be mining

This is very much a work in progress but the idea is to make a simple powershell command that can run every <period of time> to determing if your GPU based mining is hitting up the most efficient coin, for your rig, and, if not change the coin you're mining. At this point in time, this is a proof of concept, only and needs some work but it's functional and it does work.
  
It leans on a few public APIs:
   CoinAPI.io --> you will need to sign up and get your own API key
   WhatToMine.JSON --> this is just a JSON response to a crafted URL.
   It is possible these could change at any day, as they're third party resources.
  
To manage it, you need an idea of the following information (which, if you've been mining for more than about 1 minute, you already would know).
  1. How much you pay for electricity.
  2. Which algorithms you mine against and which coins within them.
  3. What hashrate you realistically get for each coin (total)
    a. I plan to allow WTM JSON responses to allow you to not need to know this - but their estimates are just that - estimates. You shouldn't trust them.
  4. What power draw you can optimise your rig for (total)
    a. I plan to allow WTM JSON responses to allow you to not need to know this - but their estimates are just that - estimates. You shouldn't trust them.
  5. You should know where your mining batch files are located. 
  
Things to fix in the future:
  1. I have been super lazy on the kill/start chain for the miners. I only use t-rex at this time, so I kind of haven't put any effort into anything else.
  2. The kill process is clunky - I should not be killing ethereum (for example) if you plan to start it again.
  3. Some of the code is repeatative and should be functions, but I only made this in an hour or so and I was being lazy.
  4. I only support ZelHash, EthHash and Kawpow at this time. I mean, techincally, you just copy and paste / repeat the code to add more but it should build itself.
  5. I don't support dual mining.
  6. I would rather calculate figures based off real world data from your actual mining pool of choice but I have not had time.
    a. This would need to include difficulty, shares, pay out model, etc. so it's complex.
  
How to use:
  1. Set your API details:
  #API_Key
	#You will need your own API key - go to CoinAPI.io and sign up for a free one - the free version is 100% all you need.
	$api_key = "X-CoinAPI-Key"
	$api_value = "YOURS_GOES_HERE"
	$api_url = "https://rest.coinapi.io/v1/exchangerate/"
	
  2. Set your currency & electricity costs
	#CURRENCY - what do you want to see the value in. USD, AUD, etc.
	$currency = "AUD"
	#What do you pay per kW/h
	$electricity="0.2" #value is a string in your unit of currency. I.e. 0.2 = $0.20 per kW/h
	
  3. Set your values for each algorithm you want
  #KAWPOW
	$kpw_p="280.00" #power in watts - TOTAL power of your rig for KAWPOW. Value is a string.
	$kpw_hr="44.00" #hashrate in watts - TOTAL hashrate of your rig for KAWPOW. Value is a string.
	$kpw="true" #do you want to include a KAWPOW miner in your options? If so, make this true, otherwise false.
	$kawpowMiner = "c:\mining\t-rex\ravencoin.bat" #Miner to fire up if Ravencoin is your best bet.
	$kpwName="Ravencoin" #What are you mining, based on this algorithm. The name of the coin.
	
  4. Repeat 3 for each algorithm.
  
  5. Run your powershell in an ELEVATED session, once per day or less. Not more. If you're pool mining, your payout is based on your shares over the last several blocks, so you're not doing yourself any favours pool hopping.
