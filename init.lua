-- LuckyCoin by Algar
-- A simple macroquest script to use all of your lucky coins on the emulated Project Lazarus server (with some cursor/freespace safety features).
-- /lua run luckycoin to start. The script will see itself out when finished.

local mq = require('mq')

print("Starting Lucky Coin Check...")

local server = mq.TLO.EverQuest.Server()

if server ~= "Project Lazarus" then
    printf("Lucky Coin: This is a script intended for the Project Lazarus server. The detected server is: %s. Exiting.", server)
    return false
end

local coinCount = mq.TLO.FindItemCount("=Lucky Coin")() -- no nil safety required, returns 0 if not found

if coinCount > 0 then
    printf("Lucky Coin: Found %d coin(s). Big Money!", coinCount)

    -- abort if something is on the cursor before we start as a safety measure
    if mq.TLO.Cursor.ID() then
        print("Lucky Coin: Cursor item detected! For your safety, we will not use any coins. Aborting.")
        return false
    end

    -- ensure we have enough space to accept the items
    local freeSpace = mq.TLO.Me.FreeInventory()
    if freeSpace <= 3 then
        -- if we already have some of these in our inventory, we may not need this many slots
        -- no check for DC since we can only stack to 200 and a possible prize is 99 DC. Excessive coding would be required.
        local coins = { "Resplendent Coin", "Glimmering Coin", "Tarnished Coin", }

        for _, coin in ipairs(coins) do
            if mq.TLO.FindItemCount(coin)() < 800 then -- coins stack to 1000, fudge factor. Not coding for multiple stacks.
                freeSpace = freeSpace + 1
            end
        end

        if mq.TLO.Me.FreeInventory() <= 3 then
            print("Lucky Coin: Not enough free space for the possible prizes! Aborting.")
            return false
        end
    end

    while coinCount > 0 do
        if not mq.TLO.Cursor.ID() and mq.TLO.Me.ItemReady("Lucky Coin")() then
            mq.cmd("/useitem Lucky Coin")
            mq.delay(100, function() return mq.TLO.Cursor.ID() end)
        end
        if mq.TLO.Cursor.ID() then
            mq.cmd("/autoinventory")
            mq.delay(100, function() return not mq.TLO.Cursor.ID() end)
        end
        mq.delay(200) -- coin reuse timer is one second, this will allow multiple cursor checks in case the callback was busted
    end

    print("Lucky Coin: Finished using coins! Ending.")
else
    print("Lucky Coin: The script found no coins to use. Ending.")
end
