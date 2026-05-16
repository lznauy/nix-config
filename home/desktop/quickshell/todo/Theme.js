// Theme.js — shared style tokens

var background   = "#1c1f26"
var surface      = "#232730"
var surfaceVariant = "#2a2f3a"
var primary      = "#7aa2f7"
var secondary    = "#9d7cd8"
var success      = "#9ece6a"
var warning      = "#e0af68"
var error        = "#f7768e"
var textPrimary  = "#c0caf5"
var textSecondary = "#9aa5ce"
var textMuted    = "#565f89"
var outline      = "#3b4261"

var fontSizeXS = 10
var fontSizeS  = 11
var fontSizeM  = 12.5
var fontSizeL  = 14

var spacingXS = 4
var spacingS  = 6
var spacingM  = 10
var spacingL  = 14
var spacingXL = 20

var radiusS   = 6
var radiusM   = 10
var radiusL   = 14
var radiusXL  = 20
var radiusPill = 100

function alpha(c, a) {
    if (typeof c === "string" && c.startsWith("#")) {
        var hex = c.slice(1)
        var r, g, b
        if (hex.length === 3) {
            r = parseInt(hex[0] + hex[0], 16) / 255
            g = parseInt(hex[1] + hex[1], 16) / 255
            b = parseInt(hex[2] + hex[2], 16) / 255
        } else {
            r = parseInt(hex.slice(0, 2), 16) / 255
            g = parseInt(hex.slice(2, 4), 16) / 255
            b = parseInt(hex.slice(4, 6), 16) / 255
        }
        return Qt.rgba(r, g, b, a)
    }
    return Qt.rgba(c.r, c.g, c.b, a)
}
