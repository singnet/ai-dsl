# English to Chinese Song Experiment

Experiments to compose AI services.  The AI service composition under
study is the English to Chinese song converter.  That is the
composition takes an English song in input, and outputs the same song
sung in Chinese.  See the graphical representation of the AI service
composition below.

![English to Chinese song](figs/EnglishToChineseSong.png "English to Chinese song AI service composition")

- [etcs-xp.metta](etcs-xp.metta):
  Experiment to type check an actual AI service combination.  Most
  services, with the exception of ToMidi and Mixer, are obtained from
  the SingularityNET marketplace, including their data types and
  methods alongside their type signature.

- [etcs-simple-ontology-xp.metta](etcs-simple-ontology-xp.metta):
  Same as
  [etcs-xp.metta](etcs-xp.metta)
  but simplifies the AI service methods by avoid data contructors when
  possible, and introduces a simple ontology, one level deep subtyping
  relation such as `(<: Audio Bytes)`.  In this experience the
  ontology is sufficiently simple that no type coercion is required.

- [etcs-moderate-ontology-xp.metta](etcs-moderate-ontology-xp.metta):
  Same as
  [etcs-simple-ontology-xp.metta](etcs-simple-ontology-xp.metta)
  but slightly complexifies the ontology by adding a second level,
  such as `(<: Vocals Audio)`.  This time it does require a modest
  amount of type coercion.

- [etcs-dtl-ontology-xp.metta](etcs-dtl-ontology-xp.metta):
  Same as
  [etcs-moderate-ontology-xp.metta](etcs-moderate-ontology-xp.metta)
  but complexifies the ontology further and uses actual dependent
  types, such as `(<: (VocalsIn $t) Vocals)`.

- [etcs-dtl-atw-ontology-xp.metta](etcs-dtl-atw-ontology-xp.metta):
  Same as
  [etcs-dtl-ontology-xp.metta](etcs-dtl-ontology-xp.metta)
  but overload the type signatures of sound-spleeter and mixer to
  handle parameterized types such as `(SongIn $l)`.  That way, the
  type signature of the AI service composition is more specific,
  provided as `(-> (: $s (SongIn "English")) (SongIn "Chinese"))`,
  which should considerably narrow the set of AI service composition
  during zynthesis.

- [etcs-dtl-atw-ontology-syn-xp.metta](etcs-song-qdtl-atw-ontology-syn-xp.metta):
  Same as
  [etcs-dtl-ontology-xp.metta](etcs-dtl-atw-ontology-xp.metta)
  but tries to synthesize the the whole AI service composition.

- [etcs-dtl-atw-ontology-syn-sd-xp.metta](etcs-dtl-atw-ontology-syn-sd-xp.metta):
  Same as
  [etcs-dtl-ontology-syn-xp.metta](etcs-dtl-atw-ontology-syn-xp.metta)
  but uses a scaled down version because synthesizing the full
  composition turns out to be difficult.  The graphical representation
  of the scaled down AI service composition can be found below.

  ![Scaled down English to Chinese song](figs/EnglishToChineseSongScaledDown.png "Scaled down English to Chinese song AI service composition")

- [etcs-combinator-sd-xp.metta](etcs-combinator-sd-xp.metta):
  Introduce combinators, bluebird and phoenix, on scaled-down version
  of the English to Chinese Song AI service composition.

- [etcs-combinator-sd-data-xp.metta](etcs-combinator-sd-data-xp.metta):
  Same as [etcs-combinator-sd-xp.metta](etcs-combinator-sd-xp.metta)
  but add an extra Data type to avoid using the combinators over
  higher order functions.  The constrain is added as extra arguments
  of the combinators.

- [etcs-combinator-sd-data-uncurry-xp.metta](etcs-combinator-sd-data-uncurry-xp.metta):
  Same as
  [etcs-combinator-sd-data-xp.metta](etcs-combinator-sd-data-xp.metta)
  but the backward chainer in uncurried and directly contains the
  constraint that function domains and codomains must be concrete data
  types.

- [etcs-combinator-data-uncurry-xp.metta](etcs-combinator-data-uncurry-xp.metta):
  Same as
  [etcs-combinator-sd-data-uncurry-xp.metta](etcs-combinator-sd-data-uncurry-xp.metta)
  but scaled-up.  It also contains an ontology to DOT and typing
  relationship to DOT converter (for displaying AI service
  compositions).
