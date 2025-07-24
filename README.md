# SpellingPractice

## How to build

Carthage:
https://github.com/Carthage/Carthage?tab=readme-ov-file#quick-start
https://github.com/Carthage/Carthage?tab=readme-ov-file#adding-frameworks-to-an-application

Download DLRadioButton and SwiftIconFont by "carthage update --no-build"
https://github.com/DavydLiu/DLRadioButton
https://github.com/segecey/SwiftIconFont

Open Carthage/Checkouts/DLRadioButton (and Carthage/Checkouts/SwiftIconFont) via Xcode.

Open the "Build Settings" tab in the Project Settings (for DLRadioButton and SwiftIconFont).

Change "iOS Deployment Target" from "iOS 8.0" to "iOS 15".

Open the SpellingPractice project via Xcode.

Build DLRadioButton and SwiftIconFont by "carthage build --use-xcframeworks"

Open the "General" tab and scroll down until you see "Frameworks, Libraries and Embedded Content".

Drag and drop Carthage/Build/DLRadioButton.xcframework and Carthage/Build/SwiftIconFont.xcframework to "Frameworks, Libraries and Embedded Content".

Select "Do Not Embed" for both DLRadioButton and SwiftIconFont.

And build the SpellingPractice project.
