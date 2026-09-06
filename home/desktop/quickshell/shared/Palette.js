function luminance(colorValue) {
    return colorValue.r * 0.2126 + colorValue.g * 0.7152 + colorValue.b * 0.0722
}

function isColorValue(value) {
    return typeof value === "string" && /^#[0-9a-fA-F]{6,8}$/.test(value)
}

function tomlColor(data, key) {
    var match = new RegExp("^\\s*" + key + "\\s*=\\s*\"(#[0-9a-fA-F]{6,8})\"", "m").exec(data)
    return match ? match[1] : ""
}
