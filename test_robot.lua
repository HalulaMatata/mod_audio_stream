session:setAutoHangup(true) 
api = justswitch.API()

if (session:ready() == false) then      
	session:consoleLog("notice", "welcome ready false start") 
    return
end

--session:answer()
local sample_rate      = session:getvariable("effective_sample_rate")
local caller_id_number = session:getVariable("caller_id_number")
local uuid             = session:get_uuid()
local wait_time        = 2000 --ms
local metadata         = "{\"type\":\"websocket.receive\",\"text\":\""..caller_id_number.."\"}"

local cmd = uuid.." start 8k ws://192.168.18.234 read "..metadata
local res = api:executeString(cmd)
if not res or res ~= "+OK Success\n" then
    session:consoleLog("notice", "res"..tostring())
    return
end

local old_audio_stream_tts_file = ""
local new_audio_stream_tts_file = ""
while (session:ready() ~= false) then
    
    session:execute("play_and_wait_audio_stream", wait_time.." "..new_audio_stream_tts_file)
   
    local audio_stream_wait_cause = session:getVariable("audio_stream_wait_cause")
    local audio_stream_wait_result = session:getVariable("audio_stream_wait_result")
    local audio_stream_tts_file = session:getVariable("audio_stream_tts_file")
    local audio_stream_terminator_used = session:getVariable("audio_stream_terminator_used")
    if audio_stream_wait_cause and audio_stream_wait_cause ~= "000" then
        session:consoleLog("notice", "return case: "..audio_stream_wait_cause.." result:"..tostring(audio_stream_wait_result))
        return
    end
    if audio_stream_terminator_used and audio_stream_terminator_used ~= "" then
        session:consoleLog("notice", "terminator dight: "..audio_stream_terminator_used.." case: "..audio_stream_wait_cause.." result:"..tostring(audio_stream_wait_result))
        return
    end
    
    old_audio_stream_tts_file = new_audio_stream_tts_file
    if audio_stream_tts_file and audio_stream_tts_file ~= "" then
        new_audio_stream_tts_file = audio_stream_tts_file
    else
        new_audio_stream_tts_file = ""
    end
end