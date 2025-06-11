# Speech Emotion Recognition

Experiments to compose AI services.  The AI service composition under
study is the Speech Emotion recognizer.  That is the composition takes
speech in input and outputs the recognized emotion in that speech,
however it does not do it directly, it must first convert the speech
into text, then detect the emotion in the text, as graphically shown
below.

![Speech Emotion Recognition](figs/RecognizeSpeechEmotion.png "Speech Emotion Recognition AI service composition")

- [rse-xp.metta](rse-xp.metta): Experiment to synthesize the
  composition.  There are two services to combine in series, requiring
  only the bluebird combinator.  No ontology is used.

- [rse-curried-xp.metta](rse-curried-xp.metta): Same as
  [rse-xp.metta](rse-xp.metta) but a curried version of the bluebird
  is used.

