import SingularityNET.MarketPlace.All

myservice : Audio -> Text Chinese
myservice = Melodize . SpeechRecognize

myotherservice : Bytes -> MIDI
myotherservice = -- ToMidi
               = Melodize . SpeechRecognize

