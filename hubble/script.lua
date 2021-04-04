-- So here's all the stuff to configure.

MAX_ARM_ROTATION = 80       -- What's the largest rotation
MIN_ARM_ROTATION = 20       -- What's the smallest rotation
ARM_CLIP_ANGLE = 70         -- When should the lower part disappear? It's the wrong way around, I know.
ALTER_UPWARDS_STATE = false -- Should the wings fold in when you're facing upwards too?



-- Heres the stuff to hide!

for key, value in pairs(vanilla_model) do
    value.setEnabled(false)    
end




-- And heres the check that runs every tick!

lastPitch = 0
targetPitch = 0

function tick()
    if player.getAnimation() == "FALL_FLYING" then
        lastPitch = targetPitch
        targetPitch = player.getRot().pitch
        model.LEFT_ARM.LEFT_WING.setEnabled(true)
        model.RIGHT_ARM.RIGHT_WING.setEnabled(true)

    else
        lastPitch = 0
        targetPitch = 0
        model.LEFT_ARM.LEFT_WING.setEnabled(false)
        model.RIGHT_ARM.RIGHT_WING.setEnabled(false)

    end
end

function render(delta)
    if player.getAnimation() == "FALL_FLYING" then
        pitchDelta = (targetPitch - lastPitch) * delta
        lastPitch = lastPitch + pitchDelta

        local rotPercent

        if ALTER_UPWARDS_STATE then
            rotPercent = 1 - math.abs(player.getRot().pitch) / 90
        else 
            rotPercent = 1 - math.abs(math.max(player.getRot().pitch, 0)) / 90
        end

        absRotation = MIN_ARM_ROTATION + ((MAX_ARM_ROTATION - MIN_ARM_ROTATION) * rotPercent)

        if absRotation <= ARM_CLIP_ANGLE then
            model.LEFT_ARM.LEFT_WING.LOWER_LEFT_WING.setEnabled(false)
            model.RIGHT_ARM.RIGHT_WING.LOWER_RIGHT_WING.setEnabled(false)
        else
            model.LEFT_ARM.LEFT_WING.LOWER_LEFT_WING.setEnabled(true)
            model.RIGHT_ARM.RIGHT_WING.LOWER_RIGHT_WING.setEnabled(true)
        end

        model.LEFT_ARM.setRot({0, 0, -absRotation})
        model.RIGHT_ARM.setRot({0, 0, absRotation})
    else
        model.LEFT_ARM.setRot({0, 0, 0})
        model.RIGHT_ARM.setRot({0, 0, 0})
    end
end


