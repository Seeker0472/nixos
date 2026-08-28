.pragma library

function deepClone(value) {
    return JSON.parse(JSON.stringify(value))
}

function limits(group) {
    return group === "cpu" ? {
        minPwm: [64, 160],
        startTemp: [40, 65],
        fullTemp: [70, 85]
    } : {
        minPwm: [64, 128],
        startTemp: [40, 65],
        fullTemp: [65, 85]
    }
}

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, Number(value)))
}

function withSetting(settings, group, key, value) {
    var result = deepClone(settings)
    var ranges = limits(group)
    if (!ranges[key]) return result
    result[key] = Math.round(clamp(value, ranges[key][0], ranges[key][1]))
    if (key === "startTemp" && result.fullTemp - result.startTemp < 10)
        result.fullTemp = Math.min(ranges.fullTemp[1], result.startTemp + 10)
    if (key === "fullTemp" && result.fullTemp - result.startTemp < 10)
        result.startTemp = Math.max(ranges.startTemp[0], result.fullTemp - 10)
    return result
}

function pwmPercent(value) {
    return Math.round(clamp(value, 0, 255) * 100 / 255)
}

function rpmLabel(value) {
    if (value === null || value === undefined || value === "") return "-- RPM"
    var rpm = Number(value)
    return isFinite(rpm) && rpm >= 0 ? Math.round(rpm) + " RPM" : "-- RPM"
}

function normalized(value, minimum, maximum) {
    return (clamp(value, minimum, maximum) - minimum) / Math.max(1, maximum - minimum)
}
