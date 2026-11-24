-- Elemental Power Tycoon | AUTO FARM v3 (Delta / Luau) - PART 1/3
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local TeleportService=game:GetService("TeleportService")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer
local genv=(getgenv and getgenv()) or _G
if genv.ETAF_CLEANUP then pcall(genv.ETAF_CLEANUP) end

local CONFIG={
 AutoStart=true,LoopDelay=0.16,ScanInterval=3,
 CollectOscillateAmp=0.42,CollectOscillateSpeed=18,
 StepAboveOffset=2.8,CamSensitivity=0.0055,
 WaitLimit=45,StepGiveUp=8,GhostSkip=60,StepSkip=30,
 ProbeInterval=1.5,ProbeMaxTries=3,
 AntiAfk=true,AutoRejoin=true,RejoinDelay=8,
 SCRIPT_URL="",Debug=false,
}

local PRIORITY_LIST={
 {Label="Dropper 2",Keywords={"dropper2","dropper 2"},kind="buy"},
 {Label="Dropper 3",Keywords={"dropper3","dropper 3"},kind="buy"},
 {Label="Dropper 4",Keywords={"dropper4","dropper 4"},kind="buy"},
 {Label="Dropper 5",Keywords={"dropper5","dropper 5"},kind="buy"},
 {Label="Walls 1",Keywords={"wallswalls","walls"},kind="buy"},
 {Label="Door Lasers",Keywords={"lasersdoor","door lasers","lasers"},kind="door"},
 {Label="Walls 2",Keywords={"walls 2","walls2"},kind="buy"},
 {Label="Walls 3",Keywords={"walls 3","walls3"},kind="buy"},
 {Label="Stairs T2",Keywords={"stairsstairs","stairs"},kind="door"},
 {Label="Big Track",Keywords={"track2","big track","bigtrack"},kind="buy"},
 {Label="Big Dropper 1",Keywords={"bigdropper1","big dropper 1"},kind="buy"},
 {Label="Big Dropper 2",Keywords={"bigdropper2","big dropper 2"},kind="buy"},
 {Label="Big Dropper 3",Keywords={"bigdropper3","big dropper 3"},kind="buy"},
 {Label="Walls 4",Keywords={"walls 4","walls4"},kind="buy"},
 {Label="Walls 5",Keywords={"walls 5","walls5"},kind="buy"},
 {Label="Walls 6",Keywords={"walls 6","walls6"},kind="buy"},
 {Label="Third Floor",Keywords={"thirfloor","thirdfloor","third floor","tang 3"},kind="door"},
 {Label="Stairs 2 T3",Keywords={"stairs2","stairs 2"},kind="door"},
 {Label="Super Track",Keywords={"track3","super track","supertrack"},kind="buy"},
 {Label="Super Dropper",Keywords={"superdropper","super dropper"},kind="buy"},
 {Label="Walls 7",Keywords={"walls 7","walls7"},kind="buy"},
 {Label="Walls 8",Keywords={"walls 8","walls8"},kind="buy"},
 {Label="Walls 9",Keywords={"walls 9","walls9"},kind="buy"},
 {Label="Roof",Keywords={"roof"},kind="door"},
 {Label="Stairs 3",Keywords={"stairs3","stairs 3"},kind="door"},
 {Label="Energy Turret",Keywords={"turret","energy turret"},kind="special"},
 {Label="Mystery Block",Keywords={"mysteryblock","mystery block"},kind="special"},
 {Label="Ability Pad T1",Keywords={"mieng dem kha nang","ability pad","power pad"},kind="buy"},
 {Label="Ability Pad T2",Keywords={"mieng dem kha nang lon","big ability","large ability"},kind="buy"},
 {Label="Heal Pad",Keywords={"mieng dem chua benh","heal","healing"},kind="buy"},
 {Label="Elemental Body",Keywords={"co the nguyen to","elemental body","body"},kind="buy"},
 {Label="Elemental Pet",Keywords={"thu cung nguyen to","elemental pet","pet"},kind="buy"},
 {Label="Security Gun T3",Keywords={"sung an ninh","security","sentry","gun"},kind="buy"},
 {Label="Airstrike",Keywords={"khong kich","airstrike","air strike"},kind="buy"},
 {Label="Potion Stand",Keywords={"be dung thuoc","potion","stand"},kind="buy"},
 {Label="Upgrade 1 2 3",Keywords={"tang 1 2 3","upgrade","boost"},kind="buy"},
 {Label="Rebirth",Keywords={"tai sinh","chap nhan","rebirth","accept"},kind="special"},
}

local destroyed=false
local run={on=false,token=0}
local conns={}
local function track(c) conns[#conns+1]=c return c end
local skippedUntil=setmetatable({},{__mode="k"})
local cache={list={},dirty=true,scannedAt=0,tycoonRetryAt=0,tycoonFails=0,lastCount=-1}
local waitState,stepStreak={},{}
local probeState={}
local lastStepPart=nil
local bought=0

local ACCENT={}
do
 local groups={a="àáạảãâầấậẩẫăằắặẳẵ",e="èéẹẻẽêềếệểễ",i="ìíịỉĩ",
  o="òóọỏõôồốộổỗơờớợởỡ",u="ùúụủũưừứựửữ",y="ỳýỵỷỹ",d="đ"}
 for plain,chars in pairs(groups) do
  for _,cp in utf8.codes(chars) do
   ACCENT[utf8.char(cp)]=plain
   local up=(cp>=0xE0 and cp<=0xFE) and (cp-32) or (cp-1)
   ACCENT[utf8.char(up)]=plain
  end
 end
end
local normCache,normCount={},0
local function normalizeStr(str)
 if type(str)~="string" or str=="" then return "" end
 local hit=normCache[str]; if hit then return hit end
 local s=string.gsub(str,utf8.charpattern,function(ch) return ACCENT[ch] end)
 s=string.lower(s):gsub("%s+","")
 if normCount>3000 then normCache,normCount={},0 end
 normCache[str]=s; normCount+=1; return s
end
for _,rule in ipairs(PRIORITY_LIST) do
 rule.nk={}
 for _,kw in ipairs(rule.Keywords) do
  local n=normalizeStr(kw); if n~="" then rule.nk[#rule.nk+1]=n end
 end
end

local function getChar()
 local char=LP.Character
 if not char or not char.Parent then return nil,nil end
 local root=char:FindFirstChild("HumanoidRootPart")
 local hum=char:FindFirstChildOfClass("Humanoid")
 if not root or not hum then return nil,nil end
 return root,hum
end

local cam={on=false,pos=nil,yaw=0,pitch=-0.15,lastPos=nil,lastInput=nil,conns={}}
local function stopCam()
 local was=cam.on; cam.on,cam.pos,cam.lastPos,cam.lastInput=false,nil,nil,nil
 for _,c in ipairs(cam.conns) do c:Disconnect() end
 table.clear(cam.conns)
 if was then
  local c=Workspace.CurrentCamera
  if c then pcall(function() c.CameraType=Enum.CameraType.Custom
   local _,hum=getChar(); if hum then c.CameraSubject=hum end end) end
 end
end
local function startCam()
 if cam.on then return end
 local c=Workspace.CurrentCamera; if not c then return end
 cam.on=true; cam.pos=c.CFrame.Position
 local rx,ry=c.CFrame:ToEulerAnglesYXZ()
 cam.pitch=math.clamp(rx,-1.35,1.35); cam.yaw=ry
 cam.lastPos,cam.lastInput=nil,nil
 pcall(function() c.CameraType=Enum.CameraType.Scriptable end)
 table.insert(cam.conns,UIS.InputChanged:Connect(function(input,processed)
  if not cam.on or processed then return end
  local t=input.UserInputType
  if t==Enum.UserInputType.MouseMovement then
   if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then cam.lastPos=nil return end
  elseif t~=Enum.UserInputType.Touch then return end
  if cam.lastInput and cam.lastInput~=input and cam.lastInput.UserInputState~=Enum.UserInputState.End then return end
  cam.lastInput=input; local p=input.Position
  if cam.lastPos then
   cam.yaw-=(p.X-cam.lastPos.X)*CONFIG.CamSensitivity
   cam.pitch=math.clamp(cam.pitch-(p.Y-cam.lastPos.Y)*CONFIG.CamSensitivity,-1.35,1.35)
  end
  cam.lastPos=Vector2.new(p.X,p.Y)
 end))
 table.insert(cam.conns,UIS.InputEnded:Connect(function(input)
  if input==cam.lastInput or input.UserInputType==Enum.UserInputType.MouseButton2 then
   cam.lastPos,cam.lastInput=nil,nil
  end
 end))
 table.insert(cam.conns,RS.RenderStepped:Connect(function()
  if not cam.on or not cam.pos then return end
  local cc=Workspace.CurrentCamera
  if cc then
   if cc.CameraType~=Enum.CameraType.Scriptable then cc.CameraType=Enum.CameraType.Scriptable end
   cc.CFrame=CFrame.new(cam.pos)*CFrame.fromEulerAnglesYXZ(cam.pitch,cam.yaw,0)
  end
 end))
end

local myName=string.lower(LP.Name)
local myDisplay=string.lower(LP.DisplayName)
local function matchesMe(inst)
 local n=string.lower(inst.Name)
 if n==myName or n==myDisplay then return true end
 local ov=inst:FindFirstChild("Owner")
 if ov then
  if ov:IsA("ObjectValue") and ov.Value==LP then return true end
  if ov:IsA("StringValue") and string.lower(ov.Value)==myName then return true end
 end
 return false
end
local function findMyTycoon()
 local char=LP.Character
 local function ok(inst)
  return (inst:IsA("Model") or inst:IsA("Folder")) and inst~=char
   and not inst:FindFirstChildOfClass("Humanoid") and matchesMe(inst)
 end
 local top=Workspace:GetChildren()
 for _,a in ipairs(top) do if ok(a) then return a end end
 for _,a in ipairs(top) do
  for _,b in ipairs(a:GetChildren()) do if ok(b) then return b end end
 end
 local n=0
 for _,d in ipairs(Workspace:GetDescendants()) do
  n+=1; if n%3000==0 then task.wait() end
  if ok(d) then return d end
 end
 return nil
end

-- PART 2/3
local function underCollector(inst,root)
 local cur=inst.Parent
 for _=1,3 do
  if not cur or cur==root then return false end
  local n=string.lower(cur.Name)
  if n=="collector" or n=="collect" then return true end
  cur=cur.Parent
 end
 return false
end
local function looksBought(part,root,sole)
 local cur,hops=part.Parent,0
 while cur and cur~=Workspace and hops<5 do
  if cur:GetAttribute("Purchased")==true or cur:GetAttribute("Bought")==true
   or cur:GetAttribute("Owned")==true or cur:GetAttribute("Locked")==true
   or cur:GetAttribute("Hidden")==true then return true end
  if cur==root then break end
  cur=cur.Parent; hops+=1
 end
 if sole and part.Parent then
  for _,sub in ipairs(part.Parent:GetDescendants()) do
   if sub:IsA("BoolValue") then
    local b=normalizeStr(sub.Name)
    if (b=="purchased" or b=="bought" or b=="owned") and sub.Value==true then return true end
    if (b=="unlocked" or b=="visible") and sub.Value==false then return true end
   elseif sub:IsA("TextLabel") or sub:IsA("TextButton") then
    if sub.Visible then
     local t=normalizeStr(sub.Text)
     if string.find(t,"purchased",1,true) or string.find(t,"owned",1,true) or string.find(t,"damua",1,true) then return true end
    end
   end
  end
 end
 return false
end
local function textChunks(part,root,withLabels)
 local chunks={}
 local own=normalizeStr(part.Name)
 if own~="button" then chunks[#chunks+1]=own end
 local container=part.Parent
 local cur,depth=container,0
 while cur and cur~=root and cur~=Workspace and depth<3 do
  chunks[#chunks+1]=normalizeStr(cur.Name); cur=cur.Parent; depth+=1
 end
 if withLabels and container then
  local labels={}
  for _,d in ipairs(container:GetDescendants()) do
   if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text~="" then labels[#labels+1]=d.Text end
  end
  if #labels>0 then chunks[#chunks+1]=normalizeStr(table.concat(labels," | ")) end
 end
 return chunks
end
local function kwFind(chunk,kw)
 local init=1
 while true do
  local s,e=string.find(chunk,kw,init,true)
  if not s then return false end
  local before=s>1 and string.sub(chunk,s-1,s-1) or ""
  local after=string.sub(chunk,e+1,e+1)
  if not string.find(before,"^%a") and not string.find(after,"^%d") then return true end
  init=s+1
 end
end
local function classify(chunks)
 local best,bestScore=nil,-1
 for idx,rule in ipairs(PRIORITY_LIST) do
  for _,kw in ipairs(rule.nk) do
   for ci,chunk in ipairs(chunks) do
    if kwFind(chunk,kw) then
     local score=#kw*10-ci
     if score>bestScore then best,bestScore=idx,score end
     break
    end
   end
  end
 end
 return best
end
local function scanTycoon(tycoon)
 local parts,perParent={},{}
 local collect,collectLoose
 local n=0
 for _,d in ipairs(tycoon:GetDescendants()) do
  n+=1; if n%4000==0 then task.wait() end
  if d:IsA("BasePart") then
   local ln=string.lower(d.Name)
   
   if ln=="collect" then
    local pn=d.Parent and string.lower(d.Parent.Name) or ""
    if pn=="collector" then collect=collect or d else collectLoose=collectLoose or d end
   
   -- CHỈ NHẬN DIỆN NÚT BẤM THẬT SỰ
   elseif string.find(ln,"button",1,true) then
    if not underCollector(d,tycoon) then
     -- Lọc nhiễu: Bỏ qua nếu tên hoặc thư mục cha chứa các từ khóa gây nhiễu
     local parentName = d.Parent and string.lower(d.Parent.Name) or ""
     local isNoise = string.find(ln,"door") or string.find(ln,"laser") or string.find(ln,"wall") 
                     or string.find(parentName,"door") or string.find(parentName,"laser") or string.find(parentName,"wall")
     
     if not isNoise then
      parts[#parts+1]=d; perParent[d.Parent]=(perParent[d.Parent] or 0)+1 
     end
    else
     collectLoose=collectLoose or d
    end
   end
  end
 end
 
 local relaxed=false
 if #parts==0 then
  relaxed=true
  for _,d in ipairs(tycoon:GetDescendants()) do
   if d:IsA("TouchTransmitter") then
    local p=d.Parent
    if p and p:IsA("BasePart") and string.lower(p.Name)~="collect"
     and not underCollector(p,tycoon) and not p:FindFirstAncestorOfClass("Humanoid") then
     -- Lọc nhiễu tương tự cho trường hợp dự phòng
     local pn = string.lower(p.Name)
     if not string.find(pn,"door") and not string.find(pn,"laser") then
      parts[#parts+1]=p; perParent[p.Parent]=(perParent[p.Parent] or 0)+1
     end
    end
   end
  end
 end
 
 local total=#PRIORITY_LIST
 local list={}
 for i,part in ipairs(parts) do
  local sole=(perParent[part.Parent] or 0)<=1
  if not looksBought(part,tycoon,sole) then
   local order=classify(textChunks(part,tycoon,sole)) or (total+1)
   local label,kind
   if order<=total then label=PRIORITY_LIST[order].Label; kind=PRIORITY_LIST[order].kind
   else label=part.Parent and part.Parent.Name or part.Name; kind="buy" end
   list[#list+1]={part=part,order=order,label=label,kind=kind,seq=i}
  end
 end
 table.sort(list,function(a,b)
  if a.order~=b.order then return a.order<b.order end
  return a.seq<b.seq
 end)
 
 cache.list=list; cache.collect=collect or collectLoose
 cache.dirty=false; cache.scannedAt=os.clock()
 if #list~=cache.lastCount then
  cache.lastCount=#list
  if #list==0 then warn("[Farm] Không thấy nút mua nào trong "..tycoon:GetFullName())
  elseif relaxed then warn("[Farm] Không có part tên 'Button', dùng chế độ dự phòng") end
 end
 if CONFIG.Debug then
  print(("[Farm] Quét: %d nút, collect = %s"):format(#list,cache.collect and cache.collect:GetFullName() or "không có"))
  for _,c in ipairs(list) do
   print(("  #%d [%s] %s -> %s"):format(c.order,c.kind,c.label,c.part:GetFullName()))
  end
 end
end
 table.sort(list,function(a,b)
  if a.order~=b.order then return a.order<b.order end
  return a.seq<b.seq
 end)
 cache.list=list; cache.collect=collect or collectLoose
 cache.dirty=false; cache.scannedAt=os.clock()
 if #list~=cache.lastCount then
  cache.lastCount=#list
  if #list==0 then warn("[Farm] Không thấy nút mua nào trong "..tycoon:GetFullName())
  elseif relaxed then warn("[Farm] Không có part tên 'Button', dùng chế độ dự phòng") end
 end
 if CONFIG.Debug then
  print(("[Farm] Quét: %d nút, collect = %s"):format(#list,cache.collect and cache.collect:GetFullName() or "không có"))
  for _,c in ipairs(list) do
   print(("  #%d [%s] %s -> %s"):format(c.order,c.kind,c.label,c.part:GetFullName()))
  end
 end
end

local function isLive(part)
 return part:IsDescendantOf(Workspace) and part.Transparency<0.95 and part.CanTouch~=false
end
local function isButtonGreen(part)
 local c=part.Color
 if c.G>0.45 and c.G>(c.R+0.12) and c.G>(c.B+0.08) then return true end
 if c.G>0.55 and c.R<0.65 and c.B<0.4 then return true end
 return false
end
local function isButtonRed(part)
 local c=part.Color
 if c.R>0.6 and c.G<0.35 and c.B<0.35 then return true end
 return false
end

local hasFTI=typeof(firetouchinterest)=="function"
local function touch(root,part,hold)
 if not hasFTI then return end
 pcall(function()
  firetouchinterest(root,part,0)
  task.wait(hold)
  firetouchinterest(root,part,1)
 end)
end

local oscPhase=0
local function doCollect(collectPart)
 local root=getChar(); if not root then return end
 startCam()
 oscPhase+=CONFIG.CollectOscillateSpeed*CONFIG.LoopDelay
 local y=collectPart.Size.Y*0.5+2.6+math.sin(oscPhase)*CONFIG.CollectOscillateAmp
 pcall(function()
  root.AssemblyLinearVelocity=Vector3.zero
  root.AssemblyAngularVelocity=Vector3.zero
  root.CFrame=CFrame.new(collectPart.Position+Vector3.new(0,y,0))
 end)
 touch(root,collectPart,0.025)
end
local function doStep(btnPart)
 local root,hum=getChar(); if not root then return end
 stopCam()
 pcall(function()
  root.AssemblyLinearVelocity=Vector3.zero
  root.AssemblyAngularVelocity=Vector3.zero
  root.CFrame=CFrame.new(btnPart.Position+Vector3.new(0,btnPart.Size.Y*0.5+CONFIG.StepAboveOffset,0))
 end)
 touch(root,btnPart,0.035)
 if hum then pcall(function() hum:Move(Vector3.new(0,0,-1),true) end) end
end

local ui={}
local lastStatus=""
local function setStatus(msg)
 local full=msg.."  |  Đã mua: "..bought
 if full==lastStatus then return end
 lastStatus=full; if ui.status then ui.status.Text=full end
end
local function refreshToggle()
 if not ui.toggle then return end
 if run.on then
  ui.toggle.Text="Auto Farm: ĐANG BẬT (chạm để tắt)"
  ui.toggle.BackgroundColor3=Color3.fromRGB(195,120,35)
 else
  ui.toggle.Text="Auto Farm: TẮT (chạm để bật)"
  ui.toggle.BackgroundColor3=Color3.fromRGB(45,135,85)
 end
end
local function skipPart(cand,seconds,why)
 skippedUntil[cand.part]=os.clock()+seconds
 warn(("[Farm] Bỏ qua tạm %ds - %s: %s (%s)"):format(seconds,why,cand.label,cand.part:GetFullName()))
 setStatus("Bỏ qua tạm: "..cand.label)
end

local function farmTick()
 local now=os.clock()
 local root,hum=getChar()
 if not root or hum.Health<=0 then stopCam(); setStatus("Chờ nhân vật..."); return 0.5 end
 local tycoon=cache.tycoon
 if not tycoon or not tycoon:IsDescendantOf(Workspace) then
  cache.tycoon=nil
  if now<cache.tycoonRetryAt then return 0.5 end
  tycoon=findMyTycoon()
  if not tycoon then
   cache.tycoonFails+=1
   cache.tycoonRetryAt=os.clock()+math.min(1+cache.tycoonFails,5)
   stopCam(); setStatus("Chưa thấy nhà mang tên: "..LP.Name); return 0.6
  end
  cache.tycoon,cache.dirty,cache.tycoonFails=tycoon,true,0
 end
 if cache.dirty or (now-cache.scannedAt)>CONFIG.ScanInterval then
  scanTycoon(tycoon); now=os.clock()
 end
 if lastStepPart and not isLive(lastStepPart) then
  bought+=1; lastStepPart=nil; cache.dirty=true
 end
 local target
 for _,c in ipairs(cache.list) do
  local p=c.part
  if not p:IsDescendantOf(Workspace) then cache.dirty=true
  elseif isLive(p) then
   local exp=skippedUntil[p]
   if not exp or now>=exp then target=c break end
  end
 end
 local collectPart=cache.collect
 if collectPart and not collectPart:IsDescendantOf(Workspace) then
  collectPart,cache.collect,cache.dirty=nil,nil,true
 end
 local function collectOrIdle()
  if collectPart then doCollect(collectPart) else stopCam() end
 end
 if not target then
  waitState,stepStreak={},{}
  setStatus("Không còn nút mở -> Collect..."); collectOrIdle()
 else
  local kind=target.kind or "buy"
  local probe=probeState[target.part]

  if kind=="door" then
   waitState,stepStreak={},{}
   if probe and probe.isDoor then
    if now-probe.lastProbe>CONFIG.ProbeInterval then
     setStatus("Đạp cửa: "..target.label)
     lastStepPart=target.part; doStep(target.part); probe.lastProbe=now
    else collectOrIdle() end
   else
    setStatus("Đạp thử cửa: "..target.label)
    lastStepPart=target.part; doStep(target.part)
    probeState[target.part]={tries=1,lastProbe=now,isDoor=false}
   end

  elseif kind=="special" then
   waitState,stepStreak={},{}
   if not probe or now-probe.lastProbe>CONFIG.ProbeInterval*2 then
    setStatus("Đạp đặc biệt: "..target.label)
    lastStepPart=target.part; doStep(target.part)
    probeState[target.part]={tries=(probe and probe.tries or 0)+1,lastProbe=now,isDoor=false}
   else collectOrIdle() end

  else
   if isButtonGreen(target.part) then
    waitState={}
    if stepStreak.part~=target.part then stepStreak={part=target.part,since=now} end
    if (now-stepStreak.since)>CONFIG.StepGiveUp then
     skipPart(target,CONFIG.StepSkip,"đạp mãi không mua được")
     stepStreak={}
    else
     setStatus("Đủ tiền -> Đạp: "..target.label)
     lastStepPart=target.part; doStep(target.part)
    end
   elseif probe and probe.tries>=CONFIG.ProbeMaxTries and not probe.isDoor then
    probe.isDoor=true
    setStatus("Nút không đổi màu -> đạp định kỳ: "..target.label)
    if now-probe.lastProbe>CONFIG.ProbeInterval then
     lastStepPart=target.part; doStep(target.part); probe.lastProbe=now
    else collectOrIdle() end
   else
    stepStreak={}
    if waitState.part~=target.part then waitState={part=target.part,since=now} end
    local canProbe=not probe or now-probe.lastProbe>CONFIG.ProbeInterval
    if canProbe then
     setStatus("Đạp thử: "..target.label)
     lastStepPart=target.part; doStep(target.part)
     probeState[target.part]={tries=(probe and probe.tries or 0)+1,lastProbe=now,isDoor=false}
    elseif (now-waitState.since)>CONFIG.WaitLimit then
     skipPart(target,CONFIG.GhostSkip,"chờ quá lâu không xanh")
     waitState={}
    else
     setStatus("Chờ tiền ("..target.label..") -> Collect...")
     collectOrIdle()
local function farmTick()
 local now=os.clock()
 local root,hum=getChar()
 if not root or hum.Health<=0 then stopCam(); setStatus("Chờ nhân vật..."); return 0.5 end
 local tycoon=cache.tycoon
 if not tycoon or not tycoon:IsDescendantOf(Workspace) then
  cache.tycoon=nil
  if now<cache.tycoonRetryAt then return 0.5 end
  tycoon=findMyTycoon()
  if not tycoon then
   cache.tycoonFails+=1
   cache.tycoonRetryAt=os.clock()+math.min(1+cache.tycoonFails,5)
   stopCam(); setStatus("Chưa thấy nhà mang tên: "..LP.Name); return 0.6
  end
  cache.tycoon,cache.dirty,cache.tycoonFails=tycoon,true,0
 end
 
 if cache.dirty or (now-cache.scannedAt)>CONFIG.ScanInterval then
  scanTycoon(tycoon); now=os.clock()
 end
 
 -- Kiểm tra nếu nút vừa đạp đã biến mất (mua thành công)
 if lastStepPart and not isLive(lastStepPart) then
  bought+=1; lastStepPart=nil; cache.dirty=true
 end
 
 -- Chọn mục tiêu
 local target
 for _,c in ipairs(cache.list) do
  local p=c.part
  if not p:IsDescendantOf(Workspace) then 
   cache.dirty=true
  elseif isLive(p) and not doorIgnoreList[p] then -- Bỏ qua nếu nằm trong danh sách đen
   local exp=skippedUntil[p]
   if not exp or now>=exp then target=c break end
  end
 end
 
 local collectPart=cache.collect
 if collectPart and not collectPart:IsDescendantOf(Workspace) then
  collectPart,cache.collect,cache.dirty=nil,nil,true
 end
 
 local function collectOrIdle()
  if collectPart then doCollect(collectPart) else stopCam() end
 end
 
 if not target then
  waitState,stepStreak={},{}
  setStatus("Không còn nút mở -> Collect..."); collectOrIdle()
 else
  local kind=target.kind or "buy"
  local probe=probeState[target.part]

  if kind=="door" then
   waitState,stepStreak={},{}
   if not probe then
    -- Lần đầu gặp: Đạp thử 1 lần
    setStatus("Thử đạp cửa: "..target.label)
    lastStepPart=target.part
    doStep(target.part)
    probeState[target.part]={lastProbe=now, tries=1}
   elseif now - probe.lastProbe > 3 then
    -- Đợi 3s, nếu cửa vẫn còn thì đưa vào danh sách đen
    if isLive(target.part) then
     doorIgnoreList[target.part] = true
     warn("[Farm] Bỏ qua vật cản: "..target.part:GetFullName())
     cache.dirty = true
    end
   else
    -- Trong 3s chờ đợi thì đi Collect
    collectOrIdle()
   end

  elseif kind=="special" then
   waitState,stepStreak={},{}
   if not probe or now-probe.lastProbe>CONFIG.ProbeInterval*2 then
    setStatus("Đạp đặc biệt: "..target.label)
    lastStepPart=target.part; doStep(target.part)
    probeState[target.part]={tries=(probe and probe.tries or 0)+1,lastProbe=now,isDoor=false}
   else collectOrIdle() end

  else
   -- Nút thường (mua)
   if isButtonGreen(target.part) then
    waitState={}
    if stepStreak.part~=target.part then stepStreak={part=target.part,since=now} end
    if (now-stepStreak.since)>CONFIG.StepGiveUp then
     skipPart(target,CONFIG.StepSkip,"đạp mãi không mua được")
     stepStreak={}
    else
     setStatus("Đủ tiền -> Đạp: "..target.label)
     lastStepPart=target.part; doStep(target.part)
    end
   elseif probe and probe.tries>=CONFIG.ProbeMaxTries and not probe.isDoor then
    -- Nút không đổi màu -> đạp định kỳ
    probe.isDoor=true
    setStatus("Nút không đổi màu -> đạp định kỳ: "..target.label)
    if now-probe.lastProbe>CONFIG.ProbeInterval then
     lastStepPart=target.part; doStep(target.part); probe.lastProbe=now
    else collectOrIdle() end
   else
    -- Chờ tiền (chưa xanh)
    stepStreak={}
    if waitState.part~=target.part then waitState={part=target.part,since=now} end
    local canProbe=not probe or now-probe.lastProbe>CONFIG.ProbeInterval
    if canProbe then
     setStatus("Đạp thử: "..target.label)
     lastStepPart=target.part; doStep(target.part)
     probeState[target.part]={tries=(probe and probe.tries or 0)+1,lastProbe=now,isDoor=false}
    elseif (now-waitState.since)>CONFIG.WaitLimit then
     skipPart(target,CONFIG.GhostSkip,"chờ quá lâu không xanh")
     waitState={}
    else
     setStatus("Chờ tiền ("..target.label..") -> Collect...")
     collectOrIdle()
    end
   end
  end
 end
 return CONFIG.LoopDelay
    end

local function stopFarm()
 run.on=false; run.token+=1; stopCam()
 lastStepPart=nil; waitState,stepStreak={},{}; probeState={}
 setStatus("Đã dừng"); refreshToggle()
end
local function startFarm()
 if destroyed or run.on then return end
 run.on=true; run.token+=1
 local myToken=run.token
 cache.dirty=true; setStatus("Đang chạy..."); refreshToggle()
 task.spawn(function()
  while run.on and run.token==myToken and not destroyed do
   local ok,res=pcall(farmTick)
   local delay=CONFIG.LoopDelay
   if ok then
    if type(res)=="number" then delay=res end
   else
    warn("[Farm] Lỗi vòng lặp: "..tostring(res))
    setStatus("Lỗi, tự thử lại..."); cache.dirty=true; delay=1
   end
   task.wait(delay)
  end
  if run.token==myToken then run.on=false; stopCam(); refreshToggle() end
 end)
end

-- PART 3/3
local function getUiParent()
 local ok,h=pcall(function() return gethui and gethui() end)
 if ok and h then return h end
 if pcall(function() return CoreGui:GetChildren() end) then return CoreGui end
 return LP:WaitForChild("PlayerGui")
end
local function makeDraggable(handle,target,gui)
 local dragging,startInput,startPos,startUi=false,nil,nil,nil
 handle.InputBegan:Connect(function(input)
  local t=input.UserInputType
  if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
  dragging,startInput=true,input; startPos,startUi=input.Position,target.Position
  input.Changed:Connect(function()
   if input.UserInputState==Enum.UserInputState.End then dragging=false end
  end)
 end)
 track(UIS.InputChanged:Connect(function(input)
  if not dragging then return end
  if input~=startInput and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
  local d=input.Position-startPos
  target.Position=UDim2.new(startUi.X.Scale,startUi.X.Offset+d.X,startUi.Y.Scale,startUi.Y.Offset+d.Y)
  local vp,ap,sz=gui.AbsoluteSize,target.AbsolutePosition,target.AbsoluteSize
  local dx=math.clamp(ap.X,0,math.max(vp.X-sz.X,0))-ap.X
  local dy=math.clamp(ap.Y,0,math.max(vp.Y-sz.Y,0))-ap.Y
  if dx~=0 or dy~=0 then target.Position+=UDim2.fromOffset(dx,dy) end
 end))
end
local function createUi()
 local gui=Instance.new("ScreenGui")
 gui.Name="ElementalTycoonAutoGui"; gui.ResetOnSpawn=false
 gui.IgnoreGuiInset=true; gui.DisplayOrder=999
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 gui.Parent=getUiParent()
 local panel=Instance.new("Frame")
 panel.Size=UDim2.new(0,260,0,120); panel.Position=UDim2.new(0.5,-130,0.14,0)
 panel.BackgroundColor3=Color3.fromRGB(22,24,30); panel.BorderSizePixel=0
 panel.Active=true; panel.Parent=gui
 Instance.new("UICorner",panel).CornerRadius=UDim.new(0,8)
 local title=Instance.new("TextLabel")
 title.Size=UDim2.new(1,-40,0,22); title.Position=UDim2.new(0,10,0,2)
 title.BackgroundTransparency=1; title.Text="Auto Tycoon ("..LP.Name..")"
 title.TextColor3=Color3.fromRGB(235,238,245); title.TextSize=12
 title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left
 title.TextTruncate=Enum.TextTruncate.AtEnd; title.Parent=panel
 local closeBtn=Instance.new("TextButton")
 closeBtn.Size=UDim2.new(0,22,0,22); closeBtn.Position=UDim2.new(1,-26,0,3)
 closeBtn.BackgroundColor3=Color3.fromRGB(180,45,55); closeBtn.Text="X"
 closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.TextSize=12
 closeBtn.Font=Enum.Font.GothamBold; closeBtn.BorderSizePixel=0
 closeBtn.AutoButtonColor=false; closeBtn.Parent=panel
 Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
 local toggle=Instance.new("TextButton")
 toggle.Size=UDim2.new(1,-20,0,30); toggle.Position=UDim2.new(0,10,0,28)
 toggle.BackgroundColor3=Color3.fromRGB(45,135,85); toggle.Text=""
 toggle.TextColor3=Color3.fromRGB(255,255,255); toggle.TextSize=12
 toggle.Font=Enum.Font.GothamBold; toggle.BorderSizePixel=0
 toggle.AutoButtonColor=false; toggle.Parent=panel
 Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,6)
 local resetBtn=Instance.new("TextButton")
 resetBtn.Size=UDim2.new(0,80,0,22); resetBtn.Position=UDim2.new(0,10,0,62)
 resetBtn.BackgroundColor3=Color3.fromRGB(60,70,110); resetBtn.Text="Reset cache"
 resetBtn.TextColor3=Color3.fromRGB(255,255,255); resetBtn.TextSize=10
 resetBtn.Font=Enum.Font.Gotham; resetBtn.BorderSizePixel=0
 resetBtn.AutoButtonColor=false; resetBtn.Parent=panel
 Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,6)
 local status=Instance.new("TextLabel")
 status.Size=UDim2.new(1,-20,0,32); status.Position=UDim2.new(0,10,0,86)
 status.BackgroundTransparency=1; status.Text="Sẵn sàng"
 status.TextColor3=Color3.fromRGB(175,185,205); status.TextSize=10
 status.Font=Enum.Font.Gotham; status.TextXAlignment=Enum.TextXAlignment.Left
 status.TextYAlignment=Enum.TextYAlignment.Top; status.TextWrapped=true
 status.Parent=panel
 ui.gui,ui.toggle,ui.status=gui,toggle,status
 makeDraggable(panel,panel,gui)
 toggle.Activated:Connect(function()
  if destroyed then return end
  if run.on then stopFarm() else startFarm() end
 end)
 resetBtn.Activated:Connect(function()
  cache.dirty=true; cache.tycoon=nil; probeState={}
  skippedUntil=setmetatable({},{__mode="k"})
  setStatus("Đã reset cache")
 end)
 closeBtn.Activated:Connect(function() if ui.destroy then ui.destroy() end end)
 refreshToggle()
end
local function destroyScript()
 if destroyed then return end
 destroyed=true; stopFarm()
 for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
 if ui.gui then ui.gui:Destroy() end
 if genv.ETAF_CLEANUP==destroyScript then genv.ETAF_CLEANUP=nil end
end
ui.destroy=destroyScript
genv.ETAF_CLEANUP=destroyScript

if CONFIG.AntiAfk then
 track(LP.Idled:Connect(function()
  pcall(function()
   local vu=game:GetService("VirtualUser")
   vu:CaptureController(); vu:ClickButton2(Vector2.new())
  end)
 end))
end

if CONFIG.SCRIPT_URL~="" and typeof(queue_on_teleport)=="function" then
 pcall(queue_on_teleport,('loadstring(game:HttpGet("%s"))()'):format(CONFIG.SCRIPT_URL))
end
if CONFIG.AutoRejoin then
 local rejoining=false
 local function rejoin()
  if rejoining or destroyed then return end
  rejoining=true
  task.spawn(function()
   while not destroyed do
    pcall(function()
     if #Players:GetPlayers()<=1 then
      TeleportService:Teleport(game.PlaceId,LP)
     else
      TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)
     end
    end)
    task.wait(CONFIG.RejoinDelay)
   end
   rejoining=false
  end)
 end
 track(GuiService.ErrorMessageChanged:Connect(function(msg)
  if msg and msg~="" then rejoin() end
 end))
 pcall(function()
  local overlay=CoreGui.RobloxPromptGui.promptOverlay
  track(overlay.ChildAdded:Connect(function(c)
   if c.Name=="ErrorPrompt" then rejoin() end
  end))
 end)
end

createUi()
if CONFIG.AutoStart then task.defer(startFarm) end
