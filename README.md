# MarvelWikiApp

This is a technical test performed within a 2-week time limit. The objective was to make an app that used [Marvel's API](https://developer.marvel.com/docs) that was capable of lazy-loading the list of characters, search for specific character names and access the details of a character. 

It uses Swift, UIKit and Combine. 
The design pattern used for the app is MVVM. 
The communication layer used Alamofire.
Unit tests are used for guaranteeing that proper decoding of the JSON responses was done successfully.
Image loading was done using SDWebImage.

## Implementation

Dependency injection is used altogether with interface abstraction to leave the door open for reusability and free configuration.

### MVVM design pattern:
- The ViewModel asks for data, communicates with the Dto objects (model data) and publishes the view model.
- The View subscribes to the ViewModel publisher and waits for the data to be be sent, adjusting to the errors received. 

### Dependencies
- The implementation of several UseCases for separating the request or the mapping logic simplifies the ViewModel classes.

### Communication layer
- It is defined using the protocol EndpointType, which defines all the required values to identify and use and endpoint (host, path, http method, parameters, port ...).
- After that, the definition of CharactersAPI, the enum MarvelCharactersEndpoint which implements EndpointType, and the enum CharactersAPIRequestParams containing structs to expose simply the parameters to the app are the only things needed to create the requests.
- Then, the response is decoded and the different steps return the proper error so that I can control the type of error and what went wrong.

### Tests
- The usage of protocols would help testing. Unfortunately, the only tests that have been implemented, are decoding tests.
- The idea would be to implement UnitTests for the different UseCases, and then UITests to test the views.

# Overall app description and features

The app is divided into two screens:
  - The Characters screen presents the list of characters with a search bar. This screen loads the first contents of the default list. When searching a character name, the screen will load the first contents matching the searched criteria. In either type of list loaded, if the user scrolls down, the app will load the next contents of the list if available.
    When removing the text from the search bar, the app displays the full list that was previously loaded. 
    When tapping on a character, the app will display the details for that character.
    
  - The Character Details screen will request the character info using its ID, any error fetching the data will make the user go back after a popup informing about the error is dismissed. 
    This screen has dynamic scrollable information data, and the content displayed can be modified by interacting with the appearances buttons in the appearances section. This will display a list of information that could be navigated to, but this part of the app has not been implemented (although it displays a popup to notify the intention).

The app can be displayed in portrait or landscape, and it arranges the views depending on the available space.
  - The Characters screen screen shows a different number of cells per row depending.
  - The Character Details screen has 3 layout modes:
      - Vertical: The image is displayed on top of the information data and can be moved by scrolling.
      - Horizontal: Only for iPhone, the image is displayed in the left side, and the right side is the scrollable content, which only displays the information data.
      - Image on background: Only for iPad, the image is displayed as the background, and a gradient is shown behind the information data that moves with it.

# Usage (IMPORTANT)

To make use of this app, and following the developer guide of Marvel's API documentation, you would need to add in the info for the required elements inside CharactersAPI.swift:
- private let apiKey = ""
- private let hash = ""
- private let timestamp = ""

# Libraries used

- [SDWebImage](https://github.com/SDWebImage/SDWebImage)
- [Alamofire](https://github.com/Alamofire/Alamofire)
