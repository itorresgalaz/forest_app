## Forest Senior Mobile Engineer (Flutter)

We are not looking for a finished product. We want to understand how you prioritize, structure your solution, and make engineering decisions when time is limited.

## Tech stack

This is the stack we use internally:

- Flutter

- flutter_bloc with bloc_concurrency

- get_it and injectable

- dio

- Layered architecture (Domain / Data / Presentation)

- Mapbox

- Geolocator

- Sentry

- mocktail and bloc_test

Feel free to use different libraries or patterns if you prefer. If you do, be prepared to explain your reasoning during the interview.

## The challenge

Build a small two-screen Flutter application using the Open Brewery DB public API.

The API requires no authentication and provides latitude and longitude for every brewery, making it a good fit for location-based features.

## Endpoints

## List

None

```
https://api.openbrewerydb.org/v1/breweries?per_page=20&page=1
```

## Detail


None

https://api.openbrewerydb.org/v1/breweries/{id}

## Search

None

https://api.openbrewerydb.org/v1/breweries/search?query={q}

## Core requirements

Try to complete this section first.

## 1. Brewery list

Build a paginated list showing:

- Name

- Brewery type

- City

Handle and display:

- Loading

- Error

- Empty state

Avoid silent failures.

## 2. Brewery detail

Selecting an item should navigate to a detail screen that fetches and displays:

- Name

- Address

- Phone

- Website

Handle request failures gracefully.

## 3. Architecture

Use a layered architecture with:

- Data layer


- Repository implementation

- DTO → Entity mapping

- Business logic

- Cubit or Bloc

- Sealed states

- Dependency Injection

- get_it and injectable

- (or another DI solution)

Avoid calling the service locator directly from widgets.

## 4. Error handling

Repositories should throw typed exceptions.

Cubit/Bloc should convert those exceptions into user-facing states.

Avoid empty catch blocks.

## 5. Testing

Include at least one meaningful test.

For example, a bloc_test covering:

- Loading → Success

- Loading → Error

using a fake or mocked repository.

## Bonus

Choose one improvement that you would realistically prioritize.

## Map

Display breweries as markers on a Mapbox map and allow selecting an item by tapping its marker.

## Distance

Request location permission, obtain the user's position with Geolocator, and sort breweries by distance.

A Haversine implementation or Turf is perfectly acceptable.


## Search with debounce

Implement search using bloc_concurrency (or an equivalent approach) so rapid typing doesn't generate unnecessary requests.

## Offline support

Cache the last successful list and display it immediately when the app is reopened.

One well-executed bonus tells us more than several partially completed features.

## Out of scope

Don't spend time on:

- Pixel-perfect UI

- Authentication

- Full test coverage

- CI/CD

These are intentionally outside the scope of the exercise.

## What to submit

## Please provide:

- A Git repository (or ZIP archive)

- A short README explaining:

- How to run the project

- What you completed

- What you intentionally left out

- Any trade-offs you made

- What you would improve with more time

We value clear engineering decisions. A concise explanation of why you chose one approach over another is more valuable than trying to complete everything.
