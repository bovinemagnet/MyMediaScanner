# google_mlkit_text_recognition references optional language-specific
# recogniser classes that may not be bundled. Suppress R8 missing-class errors.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
