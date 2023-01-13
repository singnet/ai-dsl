module SingularityNET.MartketPlace.All

import SingularityNET.MartketPlace.Deezer
import SingularityNET.MartketPlace.ChineseSinging
...

-- public
-- ToMidi : Audio -> MIDI
-- ToMidi a = believe_me () -- believe_me (Process.run "snet ToMidi 800 a.wav")
data Text a : adsfasdfasf where
  Translate Chinese : Text Chinese
  -- SpeechRecognize : Audio -> Text a

data List Words : asdfasdf where
  SpeechRecognize : Audio -> List Words
  ...

data MIDI : lkjahsldkjfhalksdjhf where
  ToMidi : Audio -> MIDI
  Transpose : Integer -> MIDI -> MIDI
  Melodize : Text a -> MIDI
  ...
