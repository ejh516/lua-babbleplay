#!/usr/bin/env lua
--[[ BABBLEPLAY
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]
local complex = require("./lib/complex")
local fft = require("./lib/fft")

local BUFFER_SIZE   = 1024   -- samples
local SAMPLE_RATE   = 16000 -- samples/sec
local BIT_DEPTH     = 16    -- bits
local NUM_CHANNELS  = 1     -- mono
local HISTORY_LEN   = 5    -- seconds
local BRIGHTNESS = 1.0

local devices = {}
local mic = nil
local isRecording
local screen = {}
local circle_size = 0

local ring = {
    data = {},
    length = BUFFER_SIZE,
    position = 1
}

local spectrum = {
    length = math.floor(BUFFER_SIZE * (2000/SAMPLE_RATE)),
    frequencies = {},
    amplitudes = {}
}

local peak_f = {
    frequency = 0,
    amplitude = 0
}

local history = {
    length = math.floor(HISTORY_LEN*SAMPLE_RATE / BUFFER_SIZE),
    data = {},
    position = 1
}

function love.load()
    devices = love.audio.getRecordingDevices()
    mic = devices[1]
    isRecording = mic:start(BUFFER_SIZE, SAMPLE_RATE, BIT_DEPTH, NUM_CHANNELS)
    screen["width"] = love.graphics.getWidth()
    screen["height"] = love.graphics.getHeight()

    for i=1, ring.length do
        ring.data[i] = 0
    end

    for i=1, spectrum.length do
        spectrum.frequencies[i] = (i-1) * SAMPLE_RATE/BUFFER_SIZE
        spectrum.amplitudes[i] = 0
    end

    for t=1, history.length do
        history.data[t] = {}
        for i=1, spectrum.length do
            spectrum.amplitudes[i] = 0
            table.insert(history.data[t], spectrum.amplitudes[i])
        end
    end
end

function process_buffer()
    -- Calcculate RMS amplitude
    local rms_amp = 0
    local sum_sq = 0
    for j=1, ring.length do
        sum_sq = sum_sq + ring.data[j]
    end
    rms_amp = math.sqrt(sum_sq) / ring.length
    circle_size = 10 + rms_amp * 10000

    -- Calculate frequencies
    cmplx_buffer = complex.table(ring.data)
    --cmplx_freqs = fft.ct(fft.window(cmplx_buffer))
    cmplx_freqs = fft.ct(cmplx_buffer)

    history.data[history.position] = {}
    for i=1, spectrum.length do
        spectrum.amplitudes[i] = complex.amplitude(cmplx_freqs[i])
        table.insert(history.data[history.position], spectrum.amplitudes[i])
    end
    history.position = history.position % history.length + 1

    -- Get peak frequency
    peak_f.frequency = 0
    peak_f.amplitude = 0
    for i=1, spectrum.length do
        if spectrum.amplitudes[i] > peak_f.amplitude then
            peak_f.frequency = spectrum.frequencies[i]
            peak_f.amplitude = spectrum.amplitudes[i]
        end
    end
end

function love.update(dt)
    local mic_data = mic:getData()

    if mic_data ~= nil then
        for i=1, mic_data:getSampleCount()-1 do
            ring.data[ring.position] = mic_data:getSample(i)

            if (ring.position == ring.length) then
                process_buffer()
                ring.position = 1
            else
                ring.position = ring.position + 1
            end
        end

    else
        print("No data found")
    end
    read()

end

function love.draw()
    for t=1, history.length do
        for i=1, spectrum.length do
            local c = (history.data[t][i] * BRIGHTNESS)
            if (spectrum.frequencies[i] >= 250 and spectrum.frequencies[i] <= 750) then
              love.graphics.setColor(c/2,c,c/2)
            else
              love.graphics.setColor(c,c/2,c/2)
            end
            love.graphics.rectangle(
                "fill",
                ((2*history.length+t-history.position) % history.length)*screen.width/history.length,
                (spectrum.length-i)*screen.height/spectrum.length,
                screen.width/history.length,
                screen.height/spectrum.length
            )
        end
    end
--    love.graphics.setColor(0.25,0.25,0.25)
--    for i=1, spectrum.length do
--      love.graphics.line(
--        0,
--        (spectrum.length-i)*screen.height/spectrum.length,
--        screen.width,
--        (spectrum.length-i)*screen.height/spectrum.length
--      )
--    end

end

