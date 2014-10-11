# Give and Take

This project aims to illustrate the creation and use of an
iOS 8 [document provider extension].

[document provider extension]: https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/ExtensibilityPG/FileProvider.html

## Deliverables

### Give

The Give app shall

 - serve as a container for text files
 - include a Document Picker View Controller Extension
 - include a File Provider Extension

There was some work done on Give, but I'm planning to start afresh on
this.

### Take

The Take app shall

 - be a basic text editor app
 - use iCloud to manage it's documents
 - be able to open documents using the Document Picker

Take is now in a presentable state. You can create and edit text
documents in iCloud. It can open documents using the Document Picker,
and its documents are editable from other apps supporting the Document
Picker.

Before you can run Take, you might have to do the following:

 1. In Apple Developer Member Center:

    1. Go to the "Certificates, Identifiers & Profiles" page
    2. Create an "explicit" App ID with the iCloud service enabled

 2. In Xcode:

    1. Go to Capabilities tab of the app
    2. Enable iCloud, enable only iCloud Documents
    3. Xcode does the following automatically:
       - Creates an \<app\>.entitlements file with the
         icloud-services and icloud-container-identifiers
         entitlement keys

## System Requirements

iOS 8 on iPad, on the Simulator or a real iPad. Take has not yet been tested on the iPhone.

Requires Xcode 6.1.

