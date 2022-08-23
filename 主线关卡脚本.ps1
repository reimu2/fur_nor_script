
function toBs($str){#调用时需转换byte[]类型
    return [System.Text.Encoding]::UTF8.GetBytes($str)
}
function toStr($bs){
    return [System.Text.Encoding]::UTF8.GetString($bs)
}
function toCharsBs($bs){#调用时需转换byte[]类型
    $bsLen=$bs.length
    $newArr=@()
    for($i=0; $i -lt $bsLen; $i=$i+1)   
    {   
        $newArr+=([System.Text.Encoding]::UTF8.GetBytes([char]$bs[$i]))
    }
    return $newArr
}
Function indexOfB($bs,$bsFind){
    $bsFLen=$bsFind.length
    $bsLen=$bs.length
    for($i=0; $i -lt $bsLen; $i=$i+1)   
    {   
        for($j=0; ($j -lt $bsFLen) -and ($i+$j  -lt $bsLen) ; $j=$j+1)   
        {   
            if($bsFind[$j] -ne $bs[$i+$j]){
                break
            }
            if($j -eq $bsFLen-1){
                return $i
            }
        }
    }
    return -1
}
function sendMainBattleWinWith3Star{
    param
    (
        [Parameter(Mandatory=$true)][String]$token,
        [Parameter(Mandatory=$true)][int]$chapter,
        [Parameter(Mandatory=$true)][int]$section,
        [Parameter(Mandatory=$true)][int]$step
    )
    "`n当前关卡： "+$chapter+","+$section+","+$step
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    $ret=Invoke-WebRequest -UseBasicParsing -Uri "https://fruful.jp/gw/api" `
    -Method "POST" `
    -WebSession $session `
    -Headers @{
    "authority"="fruful.jp"
      "method"="POST"
      "path"="/gw/api"
      "scheme"="https"
      "accept"="*/*"
      "accept-encoding"="gzip, deflate, br"
      "accept-language"="zh-CN,zh;q=0.9,en;q=0.8"
      "authorization"="token "+$token
      "class"="Dungeon"
      "func"="get_dungeon_start"
      "origin"="https://fruful.jp"
      "referer"="https://fruful.jp/pc/?id=41340007&gid=1&key="+$token
      "sec-ch-ua"="`".Not/A)Brand`";v=`"99`", `"Google Chrome`";v=`"103`", `"Chromium`";v=`"103`""
      "sec-ch-ua-mobile"="?0"
      "sec-ch-ua-platform"="`"Windows`""
      "sec-fetch-dest"="empty"
      "sec-fetch-mode"="cors"
      "sec-fetch-site"="same-origin"
      "x-requested-with"="XMLHttpRequest"
    } `
    -ContentType "application/octet-stream" `
    -Body ([System.Text.Encoding]::UTF8.GetBytes("$([char]140)$([char]167)ma_type$([char]1)$([char]165)ma_lv$([char]$chapter)$([char]165)du_lv$([char]$section)$([char]170)difficulty$([char]1)$([char]165)st_lv$([char]$step)$([char]170)partner_id$([char]168)5b4acd50$([char]176)partner_chara_id$([char]166)402E7V$([char]167)deck_id$([char]1)$([char]168)ele_type$([char]2)$([char]169)limit_num$([char]255)$([char]167)meal_id$([char]160)$([char]168)echo_flg$([char]195)"))

    $s=toStr($ret.Content)

    $var=$s -match "battle_key.{1}(.*).{1}stage"
    if($Matches -eq $null -or $Matches[1] -eq $null){
        throw "服务器返回错误："+$s
    }
    $battle_key=$Matches[1]

    $i1=indexOfB $ret.Content (toBs "ds_id")
    $i2=indexOfB $ret.Content (toBs "battle_key")
    $dsAndK=$ret.Content[$i1..($i2-1)]

    $varArr=130,165
    $varArr+=$dsAndK
    $varArr+=toBs("battle_key")
    $varArr+=172
    $varArr+=toBs($battle_key)
    $bodyArr=[byte[]](toCharsBs($varArr))

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    $ret=Invoke-WebRequest -UseBasicParsing -Uri "https://fruful.jp/gw/api" `
    -Method "POST" `
    -WebSession $session `
    -Headers @{
    "authority"="fruful.jp"
      "method"="POST"
      "path"="/gw/api"
      "scheme"="https"
      "accept"="*/*"
      "accept-encoding"="gzip, deflate, br"
      "accept-language"="zh-CN,zh;q=0.9,en;q=0.8"
      "authorization"="token "+$token
      "class"="Dungeon"
      "func"="get_dungeon_battle"
      "origin"="https://fruful.jp"
      "referer"="https://fruful.jp/pc/?id=41340007&gid=1&key="+$token
      "sec-ch-ua"="`".Not/A)Brand`";v=`"99`", `"Google Chrome`";v=`"103`", `"Chromium`";v=`"103`""
      "sec-ch-ua-mobile"="?0"
      "sec-ch-ua-platform"="`"Windows`""
      "sec-fetch-dest"="empty"
      "sec-fetch-mode"="cors"
      "sec-fetch-site"="same-origin"
      "x-requested-with"="XMLHttpRequest"
    } `
    -ContentType "application/octet-stream" `
    -Body ($bodyArr)

    $s=toStr($ret.Content)
    #$s
    if($s -match "error" -or $s -match "Warning"){
        throw "执行失败："+$s
    }

    
    $varArr[0]=132
    $varArr+=166
    $varArr+=toBs("result")
    $varArr+=1,164
    $varArr+=toBs("star")
    $varArr+=3
    $bodyArr=[byte[]](toCharsBs($varArr))

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    $ret=Invoke-WebRequest -UseBasicParsing -Uri "https://fruful.jp/gw/api" `
    -Method "POST" `
    -WebSession $session `
    -Headers @{
    "authority"="fruful.jp"
      "method"="POST"
      "path"="/gw/api"
      "scheme"="https"
      "accept"="*/*"
      "accept-encoding"="gzip, deflate, br"
      "accept-language"="zh-CN,zh;q=0.9,en;q=0.8"
      "authorization"="token "+$token
      "class"="Dungeon"
      "func"="get_dungeon_end"
      "origin"="https://fruful.jp"
      "referer"="https://fruful.jp/pc/?id=41340007&gid=1&key="+$token
      "sec-ch-ua"="`".Not/A)Brand`";v=`"99`", `"Google Chrome`";v=`"103`", `"Chromium`";v=`"103`""
      "sec-ch-ua-mobile"="?0"
      "sec-ch-ua-platform"="`"Windows`""
      "sec-fetch-dest"="empty"
      "sec-fetch-mode"="cors"
      "sec-fetch-site"="same-origin"
      "x-requested-with"="XMLHttpRequest"
    } `
    -ContentType "application/octet-stream" `
    -Body ($bodyArr)
    
    $s=toStr($ret.Content)
    "服务器返回数据："+$s
    if($s -match "error" -or $s -match "Warning"){
        throw "执行失败2："+$s
    }

}



"注意"
"1、token获取方法：在chrome浏览器按F12查看network栏，游戏随便操作一下，点击下边出现的api文件，右边headers栏下authorization:开头的行就是了（只取‘token ’右边部分）。"
"2、如果token过期则会运行失败，需要重新获取。"
"3、不要泄露你的token。"
"4、仅支持普通关卡。"
"5、运行前确保体力充足。"
"6、运行后需要刷新游戏才能看到已通关。"
"7、有被封号的危险，不建议大号使用。`n"
$tk=read-host -prompt "输入你的token："
$tk=$tk.Trim()
$startK=[int](read-host -prompt "从哪一章节开始？（数字）")
$startI=[int](read-host -prompt "从哪一关开始？（数字1~5）")
$startJ=[int](read-host -prompt "从哪一小关开始？（数字1~4）")
$endK=[int](read-host -prompt "到哪个章节结束？（数字）（输入后立即开始运行）")

#sendMainBattleWinWith3Star $tk 3 1 3 
#sendMainBattleWinWith3Star $tk 4 1 1
#throw "end"

function trySend{
    for($k=$startK; $k -lt $endK; $k=$k+1)   
    {   
        for($i=$startI; $i -lt 6; $i=$i+1)   
        {   
            for($j=$startJ; $j -lt 5; $j=$j+1)   
            {   
                try{
                    sendMainBattleWinWith3Star $tk $k $i $j 
                }catch{
                    Write-Warning "Error:$_"
                    return
                }
            }
            $startJ=1
        }
        $startI=1
    }
}
trySend
read-host -prompt "脚本已结束。"