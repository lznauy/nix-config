pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    readonly property string srcLang: "en"
    readonly property string tgtLang: "zh"
    readonly property string audioDevice: Quickshell.env("QS_TRANSLATOR_AUDIO_DEVICE")
    readonly property string modelDir: Quickshell.env("QS_TRANSLATOR_MODEL_DIR") || (Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share") + "/live-translator/models"
    readonly property string bin: Quickshell.env("QS_TRANSLATOR_BIN") || "live-translator"

    property bool binValid: false

    function command() {
        var args = [
            bin,
            "--auto-start",
            "--auto-src", srcLang,
            "--auto-tgt", tgtLang,
            "--vad-model", modelDir + "/silero_vad.onnx",
            "--asr-model", modelDir + "/sensevoice.onnx",
            "--asr-tokens", modelDir + "/tokens.txt",
            "--nllb-model", modelDir + "/nllb-600M",
        ]
        if (audioDevice !== "") args.push("--audio-device", audioDevice)
        return args
    }

    property var _checker: Process {
        id: checker
        command: ["sh", "-c", 'command -v -- "$1" >/dev/null 2>&1', "_", TranslationConfig.bin]
        running: true
        onExited: function(exitCode) { TranslationConfig.binValid = (exitCode === 0) }
    }

    function checkBin() {
        checker.running = false
        checker.running = true
    }
}
