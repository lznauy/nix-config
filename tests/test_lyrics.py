import importlib.util
import json
import pathlib
import tempfile
import unittest
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("lyrics", ROOT / "home/desktop/quickshell/dynamic-island/scripts/lyrics_fetcher.py")
lyrics = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lyrics)


class LyricsTests(unittest.TestCase):
    def test_exact_match_beats_wrong_artist_and_live_version(self):
        exact = lyrics.candidate_score("Song", "Artist", "Song", ["Artist"])
        self.assertGreater(exact, lyrics.candidate_score("Song", "Artist", "Song", ["Other"]))
        self.assertGreater(exact, lyrics.candidate_score("Song", "Artist", "Song (Live)", ["Artist"]))

    def test_lrc_timestamps(self):
        parsed = lyrics.parse_lrc("[00:01.50]hello\n[00:03.00]world")
        self.assertEqual(parsed[0]["text"], "hello")
        self.assertEqual(parsed[0]["time"], 1.5)
        self.assertEqual(parsed[1]["time"], 3.0)

    def test_cache_roundtrip_and_corruption(self):
        with tempfile.TemporaryDirectory() as directory:
            cache = str(pathlib.Path(directory) / "entry.json")
            value = [{"time": 1, "text": "hello"}]
            lyrics.write_cache(cache, value)
            self.assertEqual(lyrics.read_cache(cache), value)
            pathlib.Path(cache).write_text("{", encoding="utf8")
            self.assertIsNone(lyrics.read_cache(cache))

    def test_cached_lyrics_do_not_contact_providers(self):
        with tempfile.TemporaryDirectory() as directory:
            cache = lyrics.get_cache_path(directory, "Song", "Artist")
            value = [{"time": 1, "text": "hello"}]
            lyrics.write_cache(cache, value)
            with mock.patch.object(lyrics, "fetch_qq", side_effect=AssertionError("network")):
                self.assertEqual(lyrics.load_lyrics("Song", "Artist", directory), value)


if __name__ == "__main__":
    unittest.main()
