-- Chat commands: the retail build ships without an in-game console, so
-- maintenance commands travel through the chat box instead ("/palvolve
-- rollback"). PalPlayerState:EnterChat executes on the world authority for
-- every sender, so the same command works in singleplayer, for a co-op host
-- and for clients on dedicated servers. The typed command stays visible as a
-- normal chat line; the response goes back to the sender only.

local Role = require("role")

local ChatCommands = {}

-- Palgenesis (Nyx fork): "!" prefixes, because the game's own chat parser
-- intercepts every "/" message and spams "You are not an Admin" in reply.
-- The legacy /palvolve prefix stays accepted (muscle memory, upstream docs);
-- it just keeps the admin noise.
local PREFIXES = { "!pg", "!palgenesis", "/palvolve" }

-- resolves the sending player's context from the chatting PlayerState
local function senderCtxOf(ps)
    if not (ps and ps:IsValid()) then return nil end
    local pc = nil
    pcall(function() pc = ps:GetPlayerController() end)
    if not (pc and pc:IsValid()) then
        pcall(function() pc = ps:GetOwner() end)
    end
    return Role.playerCtxFor(pc)
end

-- handlers = { rollback = function(playerCtx, args) ... end, ... }; unknown
-- subcommands fall back to handlers.help. args is an array of the tokens
-- after the subcommand, taken from the ORIGINAL text (case preserved: item
-- and character ids read better in logs, and FName lookups stay exact).
--
-- Rearm support (Palgenesis): UE4SS's callback GC can free a live hook's
-- function ref mid-session ("Ref was not function ... removing hook!"),
-- which kills every chat command until relaunch. The handlers are kept on
-- the module so rearm() can re-register without a restart. Rearm is MANUAL
-- (a probe keybind) because stacked script hooks on one function are a
-- crash risk - only re-register once the old hook is confirmed dead.
ChatCommands._handlers = nil
-- Generation counter: every (re)registration bumps it and the new closure
-- captures its own generation. A stale hook instance (left behind by a
-- rearm over a still-live hook) sees the mismatch and no-ops, so stacked
-- registrations never double-dispatch - rearm is safe even when pressed
-- while the hook is alive.
ChatCommands._gen = 0

function ChatCommands.init(handlers)
    ChatCommands._handlers = handlers or ChatCommands._handlers
    ChatCommands._gen = ChatCommands._gen + 1
    local myGen = ChatCommands._gen
    return pcall(function()
        RegisterHook("/Script/Pal.PalPlayerState:EnterChat", function(self, msgParam)
            if myGen ~= ChatCommands._gen then return end
            pcall(function()
                local text = ""
                pcall(function() text = msgParam:get():ToString() end)
                if type(text) ~= "string" then return end
                local lower = text:lower()
                local matched = nil
                for _, p in ipairs(PREFIXES) do
                    -- prefix must be the whole first token ("!pg spawn", not "!pgs")
                    if lower == p or lower:sub(1, #p + 1) == (p .. " ") then
                        matched = p
                        break
                    end
                end
                if not matched then return end
                local ctx = senderCtxOf(self:get())
                if not ctx then return end
                local sub = lower:match("^%S+%s+(%S+)") or "help"
                local args = {}
                local rest = text:match("^%S+%s+%S+%s+(.*)$")
                if rest then
                    for token in rest:gmatch("%S+") do
                        args[#args + 1] = token
                    end
                end
                local handler = handlers[sub] or handlers.help
                if handler then handler(ctx, args) end
            end)
        end)
    end)
end

-- Re-register the chat hook with the stored handlers. Call ONLY when the
-- hook is confirmed dead (chat commands silent) - see rearm note above.
function ChatCommands.rearm()
    if not ChatCommands._handlers then return false, "no handlers stored" end
    return ChatCommands.init(ChatCommands._handlers)
end

return ChatCommands
