if ES then --ExclServer support
  if CLIENT then
    hook.Add("ESSupressCustomVoice","JB.SupressESVoice",function()
      return true
    end)
  end
end
