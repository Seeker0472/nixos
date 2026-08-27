.pragma library

function deepClone(value) {
    return JSON.parse(JSON.stringify(value))
}

function sceneInfo(catalog, sceneId) {
    for (var i = 0; i < catalog.length; i++) {
        if (catalog[i].id === sceneId) return catalog[i]
    }
    return { id: sceneId, name: "RGB", params: [], defaults: {}, preview: ["#89DCEB"] }
}

function setSetting(scenes, sceneId, key, value) {
    var result = deepClone(scenes)
    if (!result[sceneId]) return result
    result[sceneId][key] = value
    return result
}

function setColorAt(scenes, sceneId, key, index, color) {
    var settings = scenes[sceneId] || {}
    var colors = Array.isArray(settings[key]) ? settings[key].slice() : []
    if (index < 0 || index >= colors.length) return deepClone(scenes)
    colors[index] = String(color).toUpperCase()
    return setSetting(scenes, sceneId, key, colors)
}

function setColorCount(scenes, sceneId, key, count) {
    var settings = scenes[sceneId] || {}
    var colors = Array.isArray(settings[key]) ? settings[key].slice() : []
    var target = Math.max(1, Math.min(4, Math.round(count)))
    var additions = ["#89DCEB", "#F5C2E7", "#A6E3A1", "#F9E2AF"]
    while (colors.length < target) colors.push(additions[colors.length % additions.length])
    while (colors.length > target) colors.pop()
    return setSetting(scenes, sceneId, key, colors)
}

function resetScene(scenes, sceneId, defaults) {
    var result = deepClone(scenes)
    if (result[sceneId]) result[sceneId] = deepClone(defaults || {})
    return result
}

function colorsForScene(settings, preview) {
    if (Array.isArray(settings.colors) && settings.colors.length > 0) {
        var colors = settings.colors.slice()
        if (settings.background) colors.unshift(settings.background)
        return colors
    }
    if (settings.color) return [settings.color]
    return Array.isArray(preview) && preview.length > 0 ? preview : ["#89DCEB"]
}
