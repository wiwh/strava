# The Strava API for newbies
Disclaimer: this is my own take on how to use the strava API and reflects my current understanding of it; for more information see [the official strava API documentation](https://developers.strava.com/docs/).

## API requests: the basic principle
Information is retrieved from the strava API by requesting a specific URL of the type [https://www.strava.com/api/v3/requests]() (which we call an API request) where "requests" is a string encoding what you want to access to. For instance, to request information on athlete number 1234142, the request could be [https://www.strava.com/api/v3/athlete/1234142](). We then access the information strava stores on this athlete in a neatly pre-processed `.json` file. A `.json` file is just a text file with the `.json` extension that encodes the information in a dictionary-like structure.

Hold on, does strava allow everyone who knows to write an API request to access the private information of any athlete? No, the information is securely locked by an authentication procedure (it is `OAuth2` at the time of this writing, see [the official documentation](https://developers.strava.com/docs/authentication/), so if you write in your browser [https://www.strava.com/api/v3/athlete/1234142]() you will get an error.

To access user information, you need the user themself to provide you with an access token `access_token`, which lookes like `f6036877ca12f5d64dke31278af583d80g87dls`. Among other things, this `access_token` stores 




In principle, you could get your user 

- they need to know which application is using the data (which application is making the request)
- they need the permission of the athlete to have their data accessed

