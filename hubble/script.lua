
-- Here's a few configurable things:

-- Helmet-on-crouch config
TICK_TIMEOUT = 40           -- How many ticks after a crouch should the counter reset
CROUCH_AMOUNT = 2           -- How many crouches for it to toggle?

-- Wingsuit Config:
MAX_ARM_ROTATION = 80       -- What's the largest rotation
MIN_ARM_ROTATION = 20       -- What's the smallest rotation
ARM_CLIP_ANGLE = 70         -- When should the lower part disappear? It's the wrong way around, I know.
ALTER_UPWARDS_STATE = false -- Should the wings fold in when you're facing upwards too?



-- Heres the stuff to hide!

for key, value in pairs(vanilla_model) do
    value.setEnabled(false)    
end



-- Code for the helmet hiding

showingHead = true

function crouchAction()
    if showingHead then
        log("§c Helmet disabled!")
        showingHead = false
        model.HEAD.HELMET.setEnabled(showingHead)
    else
        log("§a Helmet enabled!")
        showingHead = true
        model.HEAD.HELMET.setEnabled(showingHead)
    end
end


-- Tick check

lastPitch = 0
targetPitch = 0

ticksSinceCrouch = 0
crouchCount = 0
isCrouched = false

function tick()

    -- \/\/\/\/\/ WINGSUIT ANGLE CHECKING HERE \/\/\/\/\/

    -- If the player is flying, make the changes according to the player's pitch.
    if player.getAnimation() == "FALL_FLYING" then
        lastPitch = targetPitch
        targetPitch = player.getRot().pitch  -- Update the pitch target for rendering
        model.LEFT_ARM.LEFT_WING.setEnabled(true)
        model.RIGHT_ARM.RIGHT_WING.setEnabled(true)

    -- Else just make sure the wings are hidden.
    else
        lastPitch = 0
        targetPitch = 0
        model.LEFT_ARM.LEFT_WING.setEnabled(false)
        model.RIGHT_ARM.RIGHT_WING.setEnabled(false)

    end


    -- \/\/\/\/\/ HELMET CROUCH CHECKING HERE \/\/\/\/\/

    -- Check for a distinct crouch
    if player.isSneaky() then
        ticksSinceCrouch = 0 -- Reset tick counter as a crouch has occured.

        if isCrouched == false then
            crouchCount = crouchCount + 1 -- Increment number of crouches
        end

        isCrouched = true -- Set crouch state to true *after* the check
    

    else 
        ticksSinceCrouch = ticksSinceCrouch + 1
        isCrouched = false
    end

    if ticksSinceCrouch > TICK_TIMEOUT then
        ticksSinceCrouch = 0
        crouchCount = 0    -- Reset as it's past the timeout.
    end


    if crouchCount == CROUCH_AMOUNT then
        crouchCount = 0 -- Crouch has happened! Start the action
        crouchAction()
    end
end



-- Used to actually update the positions.
-- It's done here so that it can be smoothed with deltatime :)
function render(delta)

    if player.getAnimation() == "FALL_FLYING" then

        -- Generate the interpolated pitch according to the frame.
        pitchDelta = (targetPitch - lastPitch) * delta
        lastPitch = lastPitch + pitchDelta  -- Update the last pitch so the next frame can build upon it.

        local rotPercent

        if ALTER_UPWARDS_STATE then
            rotPercent = 1 - math.abs(player.getRot().pitch) / 90  -- At it's widest *only* at horizontal
        else 
            rotPercent = 1 - math.abs(math.max(player.getRot().pitch, 0)) / 90  -- Anything above horizontal is just as wide
        end

        absRotation = MIN_ARM_ROTATION + ((MAX_ARM_ROTATION - MIN_ARM_ROTATION) * rotPercent)  -- How far should the arms be open?


        -- The wings are split into 2 halfs in order to stop them from going through the player
        -- to the other side.

        -- If the rotation is less than or equal to the clip angle, hide the lower half
        if absRotation <= ARM_CLIP_ANGLE then
            model.LEFT_ARM.LEFT_WING.LOWER_LEFT_WING.setEnabled(false)
            model.RIGHT_ARM.RIGHT_WING.LOWER_RIGHT_WING.setEnabled(false)

        -- Else, the angle is wide enough, reveal the lower half.
        else
            model.LEFT_ARM.LEFT_WING.LOWER_LEFT_WING.setEnabled(true)
            model.RIGHT_ARM.RIGHT_WING.LOWER_RIGHT_WING.setEnabled(true)
        end

        -- Set the arm rotation. Negative for the left arm.
        model.LEFT_ARM.setRot({0, 0, -absRotation})
        model.RIGHT_ARM.setRot({0, 0, absRotation})

    else
        -- Ensure the arms are at default as the player isn't flying.
        model.LEFT_ARM.setRot({0, 0, 0})
        model.RIGHT_ARM.setRot({0, 0, 0})
    end
end



